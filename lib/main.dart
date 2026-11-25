import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/auth_gate.dart';
import 'services/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _ChatbootBootstrap());
}

class _ChatbootBootstrap extends StatefulWidget {
  const _ChatbootBootstrap();

  @override
  State<_ChatbootBootstrap> createState() => _ChatbootBootstrapState();
}

class _ChatbootBootstrapState extends State<_ChatbootBootstrap> {
  AppState? _appState;
  String? _startupError;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    try {
      await _initializeFirebase();
      final appState = AppState();
      await appState.initialize();
      if (!mounted) return;
      setState(() => _appState = appState);
    } catch (error) {
      if (!mounted) return;
      setState(() => _startupError = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _startupError;
    if (error != null) return ChatbootApp(startupError: error);

    final appState = _appState;
    if (appState != null) {
      return ChangeNotifierProvider.value(
        value: appState,
        child: const ChatbootApp(),
      );
    }

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Démarrage de Chatboot...'),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _initializeFirebase() {
  if (!kIsWeb) return Firebase.initializeApp();

  const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  const appId = String.fromEnvironment('FIREBASE_APP_ID');
  const messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  if ([
    apiKey,
    appId,
    messagingSenderId,
    projectId,
  ].any((value) => value.isEmpty)) {
    throw StateError(
      'Configuration Firebase Web manquante. Fournissez '
      'FIREBASE_API_KEY, FIREBASE_APP_ID, FIREBASE_MESSAGING_SENDER_ID '
      'et FIREBASE_PROJECT_ID avec --dart-define.',
    );
  }

  return Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
    ),
  );
}

class ChatbootApp extends StatelessWidget {
  const ChatbootApp({super.key, this.startupError});

  final String? startupError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatboot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF246B56),
          secondary: const Color(0xFFE78355),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F5EF),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: startupError == null
          ? const AuthGate()
          : _StartupErrorScreen(error: startupError!),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 52,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Impossible de démarrer Chatboot',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      kIsWeb
                          ? 'Firebase n’est pas configuré pour le Web. '
                                'Le fichier google-services.json configure '
                                'uniquement Android. Ajoutez une application '
                                'Web dans Firebase et initialisez-la avec ses '
                                'FirebaseOptions.'
                          : 'Une erreur est survenue pendant le démarrage. '
                                'Vérifiez la configuration Firebase.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SelectableText(error),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
