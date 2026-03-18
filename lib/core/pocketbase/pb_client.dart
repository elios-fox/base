import 'package:pocketbase/pocketbase.dart';

import '../config/app_config.dart';

class PbClient {
  PbClient._() : pb = PocketBase(AppConfig.pbUrl);

  static PbClient? _instance;

  static PbClient get instance {
    _instance ??= PbClient._();
    return _instance!;
  }

  final PocketBase pb;

  bool get isAuthenticated => pb.authStore.isValid;

  String? get userId => pb.authStore.record?.id;

  String? get userDisplayName => pb.authStore.record?.getStringValue('name');

  String? get userEmail => pb.authStore.record?.getStringValue('email');
}
