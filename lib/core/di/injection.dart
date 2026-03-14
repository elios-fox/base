import '../auth/auth_repository.dart';
import '../firestore/checklist_repository.dart';
import '../network/api_client.dart';
import '../storage/storage_repository.dart';

final _registry = <Type, Object>{};

void setupDependencies() {
  _registry[ApiClient] = ApiClient();
  _registry[AuthRepository] = FirebaseAuthRepository();
  _registry[ChecklistRepository] = FirebaseChecklistRepository();
  _registry[StorageRepository] = FirebaseStorageRepository();
}

T locate<T extends Object>() {
  final instance = _registry[T];
  if (instance == null) {
    throw StateError('No instance registered for type $T');
  }
  return instance as T;
}
