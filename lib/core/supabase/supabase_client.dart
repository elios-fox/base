import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class SupabaseClientWrapper {
  SupabaseClientWrapper._();
  static final SupabaseClientWrapper instance = SupabaseClientWrapper._();

  SupabaseClient get client => Supabase.instance.client;

  bool get isAuthenticated => client.auth.currentUser != null;

  String get userId => client.auth.currentUser?.id ?? '';

  String get userDisplayName =>
      client.auth.currentUser?.userMetadata?['name'] as String? ??
      client.auth.currentUser?.email?.split('@').first ??
      '';

  String get userEmail => client.auth.currentUser?.email ?? '';
}

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
}
