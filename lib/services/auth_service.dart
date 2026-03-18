import 'dart:async';

import 'package:pocketbase/pocketbase.dart';

import '../core/pocketbase/pb_client.dart';

abstract class AuthService {
  Future<RecordAuth> login(String email, String password);
  Future<RecordAuth> register(String email, String password, String name);
  Future<void> loginWithOAuth2(String provider);
  Future<void> logout();
  bool get isAuthenticated;
  RecordModel? get currentUser;
  Stream<RecordModel?> get authStateChanges;
}

class PbAuthService implements AuthService {
  PbAuthService({PbClient? client}) : _client = client ?? PbClient.instance;

  final PbClient _client;
  final _authController = StreamController<RecordModel?>.broadcast();

  PocketBase get _pb => _client.pb;

  @override
  Future<RecordAuth> login(String email, String password) async {
    final result = await _pb.collection('users').authWithPassword(
          email,
          password,
        );
    _authController.add(result.record);
    return result;
  }

  @override
  Future<RecordAuth> register(
      String email, String password, String name) async {
    await _pb.collection('users').create(body: {
      'email': email,
      'password': password,
      'passwordConfirm': password,
      'name': name,
    });
    return login(email, password);
  }

  @override
  Future<void> loginWithOAuth2(String provider) async {
    final result = await _pb.collection('users').authWithOAuth2(
          provider,
          (url) async {
            // URL moet geopend worden in een browser.
            // De Flutter app moet dit afhandelen via url_launcher.
          },
        );
    _authController.add(result.record);
  }

  @override
  Future<void> logout() async {
    _pb.authStore.clear();
    _authController.add(null);
  }

  @override
  bool get isAuthenticated => _pb.authStore.isValid;

  @override
  RecordModel? get currentUser => _pb.authStore.record;

  @override
  Stream<RecordModel?> get authStateChanges => _authController.stream;
}
