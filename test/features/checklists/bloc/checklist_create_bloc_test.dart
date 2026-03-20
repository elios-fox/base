import 'package:base/core/models/checklist.dart';
import 'package:base/core/models/checklist_item.dart';
import 'package:base/features/checklists/bloc/checklist_create_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockChecklistService mockChecklistService;
  late MockStorageService mockStorageService;

  const ownerUid = 'user-1';
  const teamId = 'team-1';

  final item = const ChecklistItem(id: 'item-1', title: 'Item 1', order: 0);

  setUpAll(() {
    registerFallbackValue(
      Checklist(
        id: '',
        title: '',
        ownerUid: '',
        createdAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    mockChecklistService = MockChecklistService();
    mockStorageService = MockStorageService();
  });

  ChecklistCreateBloc buildBloc({String? existingTeamId}) =>
      ChecklistCreateBloc(
        checklistService: mockChecklistService,
        storageService: mockStorageService,
        ownerUid: ownerUid,
        teamId: existingTeamId ?? teamId,
      );

  group('ChecklistCreateBloc', () {
    test('initial state is correct', () {
      final bloc = buildBloc();
      expect(bloc.state.status, ChecklistCreateStatus.initial);
      expect(bloc.state.title, '');
      expect(bloc.state.items, isEmpty);
      expect(bloc.state.errorMessage, '');
    });

    group('submit', () {
      blocTest<ChecklistCreateBloc, ChecklistCreateState>(
        'emits failure when title is empty',
        build: buildBloc,
        act: (bloc) => bloc.add(const ChecklistCreateSubmitted()),
        expect: () => [
          const ChecklistCreateState(
            status: ChecklistCreateStatus.failure,
            errorMessage: 'Titel is verplicht.',
          ),
        ],
      );

      blocTest<ChecklistCreateBloc, ChecklistCreateState>(
        'emits [saving, success] when create succeeds',
        build: () {
          when(() => mockChecklistService.createChecklist(
                title: any(named: 'title'),
                ownerUid: any(named: 'ownerUid'),
                teamId: any(named: 'teamId'),
                items: any(named: 'items'),
              )).thenAnswer((_) async => Checklist(
                id: 'new-1',
                title: 'Mijn lijst',
                ownerUid: ownerUid,
                createdAt: DateTime(2026),
              ));
          return buildBloc();
        },
        seed: () =>
            const ChecklistCreateState(title: 'Mijn lijst', items: []),
        act: (bloc) => bloc.add(const ChecklistCreateSubmitted()),
        expect: () => [
          const ChecklistCreateState(
            status: ChecklistCreateStatus.saving,
            title: 'Mijn lijst',
          ),
          const ChecklistCreateState(
            status: ChecklistCreateStatus.success,
            title: 'Mijn lijst',
          ),
        ],
        verify: (_) {
          verify(() => mockChecklistService.createChecklist(
                title: 'Mijn lijst',
                ownerUid: ownerUid,
                teamId: teamId,
                items: const [],
              )).called(1);
        },
      );

      blocTest<ChecklistCreateBloc, ChecklistCreateState>(
        'emits [saving, failure, initial] when create fails — resets for retry',
        build: () {
          when(() => mockChecklistService.createChecklist(
                title: any(named: 'title'),
                ownerUid: any(named: 'ownerUid'),
                teamId: any(named: 'teamId'),
                items: any(named: 'items'),
              )).thenThrow(Exception('network error'));
          return buildBloc();
        },
        seed: () =>
            const ChecklistCreateState(title: 'Mijn lijst', items: []),
        act: (bloc) => bloc.add(const ChecklistCreateSubmitted()),
        expect: () => [
          const ChecklistCreateState(
            status: ChecklistCreateStatus.saving,
            title: 'Mijn lijst',
          ),
          const ChecklistCreateState(
            status: ChecklistCreateStatus.failure,
            title: 'Mijn lijst',
            errorMessage:
                'Opslaan mislukt. Controleer je internetverbinding.',
          ),
          const ChecklistCreateState(
            status: ChecklistCreateStatus.initial,
            title: 'Mijn lijst',
            errorMessage:
                'Opslaan mislukt. Controleer je internetverbinding.',
          ),
        ],
      );

      blocTest<ChecklistCreateBloc, ChecklistCreateState>(
        'can retry after failure — second submit succeeds',
        build: () {
          var callCount = 0;
          when(() => mockChecklistService.createChecklist(
                title: any(named: 'title'),
                ownerUid: any(named: 'ownerUid'),
                teamId: any(named: 'teamId'),
                items: any(named: 'items'),
              )).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) throw Exception('network error');
            return Checklist(
              id: 'new-1',
              title: 'Mijn lijst',
              ownerUid: ownerUid,
              createdAt: DateTime(2026),
            );
          });
          return buildBloc();
        },
        seed: () =>
            const ChecklistCreateState(title: 'Mijn lijst', items: []),
        act: (bloc) async {
          bloc.add(const ChecklistCreateSubmitted());
          await Future<void>.delayed(const Duration(milliseconds: 50));
          bloc.add(const ChecklistCreateSubmitted());
        },
        expect: () => [
          // First attempt: saving -> failure -> initial
          const ChecklistCreateState(
            status: ChecklistCreateStatus.saving,
            title: 'Mijn lijst',
          ),
          const ChecklistCreateState(
            status: ChecklistCreateStatus.failure,
            title: 'Mijn lijst',
            errorMessage:
                'Opslaan mislukt. Controleer je internetverbinding.',
          ),
          const ChecklistCreateState(
            status: ChecklistCreateStatus.initial,
            title: 'Mijn lijst',
            errorMessage:
                'Opslaan mislukt. Controleer je internetverbinding.',
          ),
          // Second attempt: saving -> success
          const ChecklistCreateState(
            status: ChecklistCreateStatus.saving,
            title: 'Mijn lijst',
            errorMessage:
                'Opslaan mislukt. Controleer je internetverbinding.',
          ),
          const ChecklistCreateState(
            status: ChecklistCreateStatus.success,
            title: 'Mijn lijst',
            errorMessage:
                'Opslaan mislukt. Controleer je internetverbinding.',
          ),
        ],
      );
    });

    group('title', () {
      blocTest<ChecklistCreateBloc, ChecklistCreateState>(
        'emits updated title on TitleChanged',
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const ChecklistCreateTitleChanged('Nieuwe titel')),
        expect: () => [
          const ChecklistCreateState(title: 'Nieuwe titel'),
        ],
      );
    });

    group('items', () {
      blocTest<ChecklistCreateBloc, ChecklistCreateState>(
        'adds item on ItemAdded',
        build: buildBloc,
        act: (bloc) => bloc.add(ChecklistCreateItemAdded(item)),
        expect: () => [
          ChecklistCreateState(items: [item]),
        ],
      );

      blocTest<ChecklistCreateBloc, ChecklistCreateState>(
        'removes item on ItemRemoved',
        build: buildBloc,
        seed: () => ChecklistCreateState(items: [item]),
        act: (bloc) => bloc.add(const ChecklistCreateItemRemoved(0)),
        expect: () => [
          const ChecklistCreateState(items: []),
        ],
      );
    });

    group('load existing', () {
      blocTest<ChecklistCreateBloc, ChecklistCreateState>(
        'loads existing checklist on Started with existingId',
        build: () {
          when(() => mockChecklistService.getChecklist('existing-1'))
              .thenAnswer((_) async => Checklist(
                    id: 'existing-1',
                    title: 'Bestaande lijst',
                    ownerUid: ownerUid,
                    createdAt: DateTime(2026),
                    items: [item],
                  ));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
            const ChecklistCreateStarted(existingId: 'existing-1')),
        expect: () => [
          const ChecklistCreateState(status: ChecklistCreateStatus.loading),
          ChecklistCreateState(
            status: ChecklistCreateStatus.initial,
            title: 'Bestaande lijst',
            items: [item],
          ),
        ],
      );

      blocTest<ChecklistCreateBloc, ChecklistCreateState>(
        'emits failure when existing checklist not found',
        build: () {
          when(() => mockChecklistService.getChecklist('missing'))
              .thenAnswer((_) async => null);
          return buildBloc();
        },
        act: (bloc) =>
            bloc.add(const ChecklistCreateStarted(existingId: 'missing')),
        expect: () => [
          const ChecklistCreateState(status: ChecklistCreateStatus.loading),
          const ChecklistCreateState(
            status: ChecklistCreateStatus.failure,
            errorMessage: 'Checklist niet gevonden.',
          ),
        ],
      );
    });
  });
}
