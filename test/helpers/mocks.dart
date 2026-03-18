import 'package:base/core/auth/auth_bloc.dart';
import 'package:base/core/auth/auth_repository.dart';
import 'package:base/core/firestore/checklist_repository.dart';
import 'package:base/core/firestore/team_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockChecklistRepository extends Mock implements ChecklistRepository {}

class MockTeamRepository extends Mock implements TeamRepository {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
