// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:chatboot/main.dart';
import 'package:chatboot/screens/chat_screen.dart';
import 'package:chatboot/services/app_state.dart';

void main() {
  testWidgets('Chatboot affiche l’écran de connexion', (tester) async {
    final state = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: state, child: const ChatbootApp()),
    );
    expect(find.text('Ravi de vous revoir'), findsOneWidget);
  });

  testWidgets('Chatboot affiche une erreur visible si le démarrage échoue', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ChatbootApp(startupError: 'FirebaseOptions are required'),
    );

    expect(find.text('Impossible de démarrer Chatboot'), findsOneWidget);
    expect(find.text('FirebaseOptions are required'), findsOneWidget);
  });

  testWidgets('Nouvelle conversation crée et sélectionne un chat', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState()..currentEmail = 'test@example.com';
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: ChatScreen()),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('sidebar-new-conversation')));
    await tester.pumpAndSettle();

    expect(state.conversations, hasLength(1));
    expect(state.selectedConversation, isNotNull);
    expect(find.text('Qu’aimeriez-vous faire aujourd’hui ?'), findsOneWidget);
  });

  testWidgets('Nouvelle conversation ferme le menu sur mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState()..currentEmail = 'test@example.com';
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: ChatScreen()),
      ),
    );
    final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
    scaffold.openDrawer();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('sidebar-new-conversation')));
    await tester.pumpAndSettle();

    expect(state.selectedConversation, isNotNull);
    expect(scaffold.isDrawerOpen, isFalse);
  });

  test('un message reste visible si aucun moteur IA n’est configuré', () async {
    final state = AppState();
    final conversation = await state.createConversation();

    await state.sendMessage('Bonjour');

    expect(conversation.messages, hasLength(2));
    expect(conversation.messages.first.role, 'user');
    expect(conversation.messages.first.content, 'Bonjour');
    expect(conversation.messages.last.role, 'error');
    expect(conversation.messages.last.content, contains('GEMINI_API_KEY'));
    expect(state.isSending, isFalse);
  });

  testWidgets('le bouton envoyer affiche le message et son erreur', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState()..currentEmail = 'test@example.com';
    await state.createConversation();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: ChatScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Bonjour');
    await tester.tap(find.byTooltip('Envoyer le message'));
    await tester.pumpAndSettle();

    expect(state.selectedConversation!.messages.first.content, 'Bonjour');
    expect(find.textContaining('Je n’ai pas pu répondre.'), findsOneWidget);
    expect(state.isSending, isFalse);
  });
}
