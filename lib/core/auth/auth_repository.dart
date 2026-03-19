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

/// Result of a sign-up attempt.
enum SignUpResult {
  /// User was created and is immediately authenticated (email confirmation disabled).
  authenticated,

  /// User was created but needs to confirm their email first.
  needsEmailConfirmation,
}

/// Exception with a user-friendly (Dutch) error message.
class AuthError implements Exception {
  const AuthError(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;

  /// Returns the currently authenticated user, or null.
  AuthUser? get currentUser;

  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<SignUpResult> createUserWithEmailAndPassword(
    String email,
    String password, {
    String? name,
  });
  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  @override
  AuthUser? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return AuthUser(
      uid: user.id,
      email: user.email,
      displayName: user.userMetadata?['name'] as String? ??
          user.userMetadata?['full_name'] as String?,
      photoUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((data) {
      final event = data.event;
      final user = data.session?.user;

      // On sign-out events, always return null.
      if (event == AuthChangeEvent.signedOut) {
        return null;
      }

      // For all other events (initialSession, signedIn, tokenRefreshed,
      // userUpdated, mfaChallengeVerified), return the user if present.
      if (user == null) return null;

      return AuthUser(
        uid: user.id,
        email: user.email,
        displayName: user.userMetadata?['name'] as String? ??
            user.userMetadata?['full_name'] as String?,
        photoUrl: user.userMetadata?['avatar_url'] as String?,
      );
    });
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'nl.com.club.manager://login-callback',
      );
    } on AuthException catch (e) {
      throw AuthError(_mapAuthError(e.message));
    } catch (e) {
      throw AuthError('Inloggen met Google is mislukt. Probeer het opnieuw.');
    }
  }

  @override
  Future<void> signInWithApple() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'nl.com.club.manager://login-callback',
      );
    } on AuthException catch (e) {
      throw AuthError(_mapAuthError(e.message));
    } catch (e) {
      throw AuthError('Inloggen met Apple is mislukt. Probeer het opnieuw.');
    }
  }

  @override
  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthError(_mapAuthError(e.message));
    } catch (e) {
      throw AuthError('Er is een fout opgetreden. Probeer het opnieuw.');
    }
  }

  @override
  Future<SignUpResult> createUserWithEmailAndPassword(
    String email,
    String password, {
    String? name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      // If the session is null after sign-up, it means email confirmation is
      // required. The user object will exist but won't have a session yet.
      if (response.session == null) {
        return SignUpResult.needsEmailConfirmation;
      }

      return SignUpResult.authenticated;
    } on AuthException catch (e) {
      throw AuthError(_mapAuthError(e.message));
    } catch (e) {
      throw AuthError('Registratie is mislukt. Probeer het opnieuw.');
    }
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Maps English Supabase error messages to Dutch user-friendly messages.
  String _mapAuthError(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials')) {
      return 'Onjuist e-mailadres of wachtwoord.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Je e-mailadres is nog niet bevestigd. Controleer je inbox.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('already been registered')) {
      return 'Er bestaat al een account met dit e-mailadres.';
    }
    if (lower.contains('password') && lower.contains('weak')) {
      return 'Het wachtwoord is te zwak. Gebruik minimaal 6 tekens.';
    }
    if (lower.contains('email') && lower.contains('invalid')) {
      return 'Voer een geldig e-mailadres in.';
    }
    if (lower.contains('rate limit') || lower.contains('too many requests')) {
      return 'Te veel pogingen. Probeer het later opnieuw.';
    }
    if (lower.contains('network') || lower.contains('socket')) {
      return 'Geen internetverbinding. Controleer je netwerk.';
    }
    if (lower.contains('signup is disabled')) {
      return 'Registratie is momenteel uitgeschakeld.';
    }

    // Fallback: return the original message if we don't have a mapping.
    return message;
  }
}
