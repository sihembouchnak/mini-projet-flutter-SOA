import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/conversation.dart';
import 'gemini_service.dart';
import 'rest_service.dart';

class AppState extends ChangeNotifier {
  String? currentEmail;
  String? authToken;
  List<Conversation> conversations = [];
  String? selectedConversationId;
  bool isSending = false;

  Conversation? get selectedConversation {
    for (final conversation in conversations) {
      if (conversation.id == selectedConversationId) return conversation;
    }
    return null;
  }

  Future<void> initialize() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) await loginFromSession(user);
  }

  Future<String?> register(
    String email,
    String password,
    String confirmPassword,
  ) async {
    email = email.trim().toLowerCase();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Veuillez entrer une adresse email valide.';
    }
    if (password.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    if (password != confirmPassword) {
      return 'Les mots de passe ne correspondent pas.';
    }
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(email.split('@').first);
      await loginFromSession(credential.user!);
      return null;
    } on FirebaseAuthException catch (error) {
      return _firebaseError(error);
    }
  }

  Future<String?> login(String email, String password) async {
    email = email.trim().toLowerCase();
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await loginFromSession(credential.user!);
      return null;
    } on FirebaseAuthException catch (error) {
      return _firebaseError(error);
    }
  }

  Future<void> loginFromSession(User user) async {
    currentEmail = user.email;
    authToken = await user.getIdToken();
    await _loadConversations();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    currentEmail = null;
    authToken = null;
    conversations = [];
    selectedConversationId = null;
    notifyListeners();
  }

  String _firebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      default:
        return 'Erreur Firebase: ${error.message ?? error.code}';
    }
  }

  Future<void> _loadConversations() async {
    if (authToken == null) return;
    try {
      conversations = await RestService.getConversations(authToken!);
    } catch (_) {
      conversations = [];
    }
    selectedConversationId = conversations.isEmpty
        ? null
        : conversations.first.id;
    notifyListeners();
  }

  Future<void> _saveConversations() async {
    if (authToken == null) return;
    for (final conversation in conversations) {
      await RestService.updateConversation(authToken!, conversation);
    }
  }

  Future<Conversation> createConversation([
    String title = 'Nouvelle conversation',
  ]) async {
    var conversation = Conversation(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      messages: [],
      updatedAt: DateTime.now(),
    );
    final localId = conversation.id;

    conversations.insert(0, conversation);
    selectedConversationId = localId;
    notifyListeners();

    if (authToken != null) {
      conversation = await RestService.createConversation(
        authToken!,
        conversation,
      );
      final index = conversations.indexWhere((item) => item.id == localId);
      if (index != -1) {
        conversations[index] = conversation;
        if (selectedConversationId == localId) {
          selectedConversationId = conversation.id;
        }
      }
      notifyListeners();
    }
    return conversation;
  }

  Future<void> renameConversation(
    Conversation conversation,
    String title,
  ) async {
    conversation.title = title.trim().isEmpty
        ? 'Nouvelle conversation'
        : title.trim();
    conversation.updatedAt = DateTime.now();
    if (authToken != null) {
      await RestService.updateConversation(authToken!, conversation);
    }
    await _saveConversations();
    notifyListeners();
  }

  Future<void> deleteConversation(Conversation conversation) async {
    conversations.removeWhere((item) => item.id == conversation.id);
    if (selectedConversationId == conversation.id) {
      selectedConversationId = conversations.isEmpty
          ? null
          : conversations.first.id;
    }
    if (authToken != null) {
      await RestService.deleteConversation(authToken!, conversation.id);
    }
    await _saveConversations();
    notifyListeners();
  }

  Future<void> selectConversation(String id) async {
    selectedConversationId = id;
    notifyListeners();
  }

  Future<String?> sendMessage(String text) async {
    if (text.trim().isEmpty || isSending) return null;
    final conversation = selectedConversation;
    if (conversation == null) return null;
    isSending = true;
    conversation.messages.add(
      ChatMessage(
        role: 'user',
        content: text.trim(),
        createdAt: DateTime.now(),
      ),
    );
    conversation.updatedAt = DateTime.now();
    if (conversation.title == 'Nouvelle conversation') {
      conversation.title = text.trim().length > 32
          ? '${text.trim().substring(0, 32)}...'
          : text.trim();
    }
    notifyListeners();

    try {
      final reply = await _requestReply(text.trim(), conversation.messages);
      conversation.messages.add(
        ChatMessage(
          role: 'assistant',
          content: reply,
          createdAt: DateTime.now(),
        ),
      );
    } on Exception catch (error) {
      conversation.messages.add(
        ChatMessage(
          role: 'error',
          content: 'Je n’ai pas pu répondre. $error',
          createdAt: DateTime.now(),
        ),
      );
    } finally {
      conversation.updatedAt = DateTime.now();
      isSending = false;
      notifyListeners();
    }

    try {
      await _saveConversations();
      return null;
    } on Exception catch (error) {
      return 'Réponse affichée, mais historique non synchronisé : $error';
    }
  }

  Future<String> _requestReply(String prompt, List<ChatMessage> history) async {
    Exception? geminiError;
    if (GeminiService.isConfigured) {
      try {
        return await GeminiService.sendMessage(prompt, history);
      } on Exception catch (error) {
        geminiError = error;
      }
    }

    if (authToken != null) {
      try {
        return await RestService.sendMessage(authToken!, prompt, history);
      } on Exception catch (restError) {
        if (geminiError != null) {
          throw Exception(
            'Gemini et le serveur REST sont indisponibles. '
            'Gemini : $geminiError ; REST : $restError',
          );
        }
        throw Exception('Le serveur REST est indisponible : $restError');
      }
    }

    if (geminiError != null) {
      throw Exception('Gemini est indisponible : $geminiError');
    }
    throw Exception(
      'Aucun moteur de réponse n’est configuré. Ajoutez '
      '--dart-define=GEMINI_API_KEY=VOTRE_CLE ou démarrez le backend REST.',
    );
  }
}
