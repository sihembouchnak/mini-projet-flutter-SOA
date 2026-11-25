import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import 'auth_screen.dart';
import 'chat_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, state, _) =>
          state.currentEmail == null ? const AuthScreen() : const ChatScreen(),
    );
  }
}
