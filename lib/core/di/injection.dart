import '../auth/auth_repository.dart';
import '../network/api_client.dart';

final _registry = <Type, Object>{};

void setupDependencies() {
  _registry[ApiClient] = ApiClient();
  _registry[AuthRepository] = FirebaseAuthRepository();
}

T locate<T extends Object>() {
  final instance = _registry[T];
  if (instance == null) {
    throw StateError('No instance registered for type $T');
  }
  return instance as T;
}
