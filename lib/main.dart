import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

// Valores vindos de: flutter run --dart-define-from-file=supabase_config.json
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabasePublishableKey =
    String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Falha cedo e com mensagem clara se esqueceram o --dart-define-from-file.
  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    runApp(const _ConfigErrorApp());
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const MyApp());
}

class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Configuração ausente.\n\n'
              'Execute:\nflutter run --dart-define-from-file=supabase_config.json',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
