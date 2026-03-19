import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../services/notification_service.dart';
import '../../services/checklist_service.dart';
import '../../services/team_service.dart';
import '../auth/auth_repository.dart';
import '../supabase/supabase_client.dart';
import '../supabase/supabase_realtime.dart';
import '../supabase/supabase_storage.dart';

final _registry = <Type, Object>{};

void setupDependencies() {
  // Auth (Firebase)
  _registry[AuthRepository] = FirebaseAuthRepository();

  // Supabase
  _registry[SupabaseClientWrapper] = SupabaseClientWrapper.instance;
  _registry[SupabaseRealtime] = SupabaseRealtime();
  _registry[AuthService] = SupaAuthService();
  _registry[TeamService] = SupaTeamService();
  _registry[EventService] = SupaEventService();
  _registry[AttendanceService] = SupaAttendanceService();
  _registry[NotificationService] = SupaNotificationService();
  _registry[ChecklistService] = SupaChecklistService();
  _registry[StorageService] = SupaStorageService();
}

T locate<T extends Object>() {
  final instance = _registry[T];
  if (instance == null) {
    throw StateError('No instance registered for type $T');
  }
  return instance as T;
}
