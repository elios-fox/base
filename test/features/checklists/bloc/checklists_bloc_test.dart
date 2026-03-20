import 'package:base/core/models/checklist.dart';
import 'package:base/features/checklists/bloc/checklists_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockChecklistService mockChecklistService;

  setUp(() {
    mockChecklistService = MockChecklistService();
  });

  ChecklistsBloc buildBloc() =>
      ChecklistsBloc(checklistService: mockChecklistService);

  group('ChecklistsBloc', () {
    final checklists = [
      Checklist(
        id: '1',
        title: 'Checklist 1',
        ownerUid: 'user-1',
        createdAt: DateTime(2026),
      ),
      Checklist(
        id: '2',
        title: 'Checklist 2',
        ownerUid: 'user-1',
        createdAt: DateTime(2026),
      ),
    ];

    test('initial state is correct', () {
      final bloc = buildBloc();
      expect(bloc.state.status, ChecklistsStatus.initial);
      expect(bloc.state.checklists, isEmpty);
    });

    blocTest<ChecklistsBloc, ChecklistsState>(
      'emits [loading, loaded] when load succeeds',
      build: () {
        when(() => mockChecklistService.getChecklists('user-1'))
            .thenAnswer((_) => Stream.value(checklists));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const ChecklistsLoadRequested(ownerUid: 'user-1')),
      expect: () => [
        const ChecklistsState(status: ChecklistsStatus.loading),
        ChecklistsState(
          status: ChecklistsStatus.loaded,
          checklists: checklists,
        ),
      ],
    );

    blocTest<ChecklistsBloc, ChecklistsState>(
      'emits [loading, failure] when load fails',
      build: () {
        when(() => mockChecklistService.getChecklists('user-1'))
            .thenAnswer((_) => Stream.error(Exception('fail')));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const ChecklistsLoadRequested(ownerUid: 'user-1')),
      expect: () => [
        const ChecklistsState(status: ChecklistsStatus.loading),
        const ChecklistsState(status: ChecklistsStatus.failure),
      ],
    );

    blocTest<ChecklistsBloc, ChecklistsState>(
      'reloads checklists when ChecklistsLoadRequested is dispatched again',
      build: () {
        var callCount = 0;
        when(() => mockChecklistService.getChecklists('user-1'))
            .thenAnswer((_) {
          callCount++;
          if (callCount == 1) {
            return Stream.value(checklists);
          }
          return Stream.value([
            ...checklists,
            Checklist(
              id: '3',
              title: 'Checklist 3',
              ownerUid: 'user-1',
              createdAt: DateTime(2026),
            ),
          ]);
        });
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const ChecklistsLoadRequested(ownerUid: 'user-1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ChecklistsLoadRequested(ownerUid: 'user-1'));
      },
      expect: () => [
        const ChecklistsState(status: ChecklistsStatus.loading),
        ChecklistsState(
          status: ChecklistsStatus.loaded,
          checklists: checklists,
        ),
        ChecklistsState(
          status: ChecklistsStatus.loading,
          checklists: checklists,
        ),
        ChecklistsState(
          status: ChecklistsStatus.loaded,
          checklists: [
            ...checklists,
            Checklist(
              id: '3',
              title: 'Checklist 3',
              ownerUid: 'user-1',
              createdAt: DateTime(2026),
            ),
          ],
        ),
      ],
    );

    blocTest<ChecklistsBloc, ChecklistsState>(
      'calls deleteChecklist on ChecklistDeleted',
      build: () {
        when(() => mockChecklistService.deleteChecklist('1'))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const ChecklistsChecklistDeleted(id: '1')),
      verify: (_) {
        verify(() => mockChecklistService.deleteChecklist('1')).called(1);
      },
    );
  });
}
