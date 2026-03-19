import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}

abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> createUserWithEmailAndPassword(String email, String password,
      {String? name});
  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  @override
  Stream<AuthUser?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return AuthUser(
        uid: user.id,
        email: user.email,
        displayName: user.userMetadata?['name'] as String?,
        photoUrl: user.userMetadata?['avatar_url'] as String?,
      );
    });
  }

  @override
  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'nl.com.club.manager://login-callback',
    );
  }

  @override
  Future<void> signInWithApple() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'nl.com.club.manager://login-callback',
    );
  }

  @override
  Future<void> signInWithEmailAndPassword(
      String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> createUserWithEmailAndPassword(String email, String password,
      {String? name}) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: name != null ? {'name': name} : null,
    );
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
