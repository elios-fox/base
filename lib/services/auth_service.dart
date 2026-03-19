import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase/supabase_client.dart';

abstract class AuthService {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String email, String password, String name);
  Future<void> loginWithOAuth2(String provider);
  Future<void> logout();
  bool get isAuthenticated;
  User? get currentUser;
  Stream<AuthState> get authStateChanges;
}

class SupaAuthService implements AuthService {
  SupaAuthService({SupabaseClientWrapper? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  final SupabaseClientWrapper _client;
  SupabaseClient get _supabase => _client.client;

  @override
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  @override
  User? get currentUser => _supabase.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<AuthResponse> register(
      String email, String password, String name) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<void> loginWithOAuth2(String provider) async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.values.firstWhere((p) => p.name == provider),
      );
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
