import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

abstract class StorageRepository {
  Future<String> uploadImage(String path, File file);
}

class FirebaseStorageRepository implements StorageRepository {
  FirebaseStorageRepository({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<String> uploadImage(String path, File file) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}