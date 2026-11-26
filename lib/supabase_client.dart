import 'package:supabase_flutter/supabase_flutter.dart';

/// Atalho para o cliente único criado em Supabase.initialize().
/// Use este getter nas telas e serviços; nunca crie um cliente por tela.
SupabaseClient get supabase => Supabase.instance.client;
