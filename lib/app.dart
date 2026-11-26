import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/items_page.dart';
import 'pages/login_page.dart';
import 'supabase_client.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minha Lista',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF7C4DFF),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

/// Decide a tela inicial conforme a sessão Auth.
/// O SDK restaura a sessão salva; o stream avisa login/logout.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, _) {
        final session = supabase.auth.currentSession;
        return session == null ? const LoginPage() : const ItemsPage();
      },
    );
  }
}
