import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';

abstract class StorageService {
  Future<String> uploadImage(String path, File file);
}

class SupaStorageService implements StorageService {
  SupaStorageService({SupabaseClientWrapper? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  final SupabaseClientWrapper _client;

  SupabaseClient get _supabase => _client.client;

  @override
  Future<String> uploadImage(String path, File file) async {
    await _supabase.storage.from('uploads').upload(
      path,
      file,
      fileOptions: const FileOptions(upsert: true),
    );
    return _supabase.storage.from('uploads').getPublicUrl(path);
  }
}
