import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../services/notification_service.dart';
import '../../services/checklist_service.dart';
import '../../services/team_service.dart';
import '../auth/auth_repository.dart';
import '../firestore/checklist_repository.dart';
import '../firestore/team_repository.dart';
import '../network/api_client.dart';
import '../supabase/supabase_client.dart';
import '../supabase/supabase_realtime.dart';
import '../storage/storage_repository.dart';

final _registry = <Type, Object>{};

void setupDependencies() {
  // Legacy Firebase
  _registry[ApiClient] = ApiClient();
  _registry[AuthRepository] = FirebaseAuthRepository();
  _registry[ChecklistRepository] = FirebaseChecklistRepository();
  _registry[TeamRepository] = FirebaseTeamRepository();
  _registry[StorageRepository] = FirebaseStorageRepository();

  // Supabase
  _registry[SupabaseClientWrapper] = SupabaseClientWrapper.instance;
  _registry[SupabaseRealtime] = SupabaseRealtime();
  _registry[AuthService] = SupaAuthService();
  _registry[TeamService] = SupaTeamService();
  _registry[EventService] = SupaEventService();
  _registry[AttendanceService] = SupaAttendanceService();
  _registry[NotificationService] = SupaNotificationService();
  _registry[ChecklistService] = SupaChecklistService();
}

T locate<T extends Object>() {
  final instance = _registry[T];
  if (instance == null) {
    throw StateError('No instance registered for type $T');
  }
  return instance as T;
}
