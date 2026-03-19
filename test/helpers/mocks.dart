import 'package:base/core/auth/auth_bloc.dart';
import 'package:base/core/auth/auth_repository.dart';
import 'package:base/core/supabase/supabase_storage.dart';
import 'package:base/services/attendance_service.dart';
import 'package:base/services/checklist_service.dart';
import 'package:base/services/event_service.dart';
import 'package:base/services/team_service.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockChecklistService extends Mock implements ChecklistService {}

class MockTeamService extends Mock implements TeamService {}

class MockEventService extends Mock implements EventService {}

class MockAttendanceService extends Mock implements AttendanceService {}

class MockStorageService extends Mock implements StorageService {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
