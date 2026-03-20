import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/checklist.dart';
import '../../../core/models/checklist_item.dart';
import '../../../core/supabase/supabase_storage.dart';
import '../../../services/checklist_service.dart';

part 'checklist_create_event.dart';
part 'checklist_create_state.dart';

class ChecklistCreateBloc
    extends Bloc<ChecklistCreateEvent, ChecklistCreateState> {
  ChecklistCreateBloc({
    required ChecklistService checklistService,
    required StorageService storageService,
    required String ownerUid,
    this.teamId,
  })  : _checklistService = checklistService,
        _storageService = storageService,
        _ownerUid = ownerUid,
        super(const ChecklistCreateState()) {
    on<ChecklistCreateStarted>(_onStarted);
    on<ChecklistCreateTitleChanged>(_onTitleChanged);
    on<ChecklistCreateItemAdded>(_onItemAdded);
    on<ChecklistCreateItemRemoved>(_onItemRemoved);
    on<ChecklistCreateItemUpdated>(_onItemUpdated);
    on<ChecklistCreateItemPhotoSelected>(_onItemPhotoSelected);
    on<ChecklistCreateItemReordered>(_onItemReordered);
    on<ChecklistCreateSubmitted>(_onSubmitted);
  }

  final ChecklistService _checklistService;
  final StorageService _storageService;
  final String _ownerUid;
  final String? teamId;
  String? _existingId;

  Future<void> _onStarted(
    ChecklistCreateStarted event,
    Emitter<ChecklistCreateState> emit,
  ) async {
    if (event.existingId != null) {
      emit(state.copyWith(status: ChecklistCreateStatus.loading));
      final checklist =
          await _checklistService.getChecklist(event.existingId!);
      if (checklist != null) {
        _existingId = checklist.id;
        emit(state.copyWith(
          status: ChecklistCreateStatus.initial,
          title: checklist.title,
          items: checklist.items,
        ));
      } else {
        emit(state.copyWith(
          status: ChecklistCreateStatus.failure,
          errorMessage: 'Checklist niet gevonden.',
        ));
      }
    }
  }

  void _onTitleChanged(
    ChecklistCreateTitleChanged event,
    Emitter<ChecklistCreateState> emit,
  ) {
    emit(state.copyWith(title: event.title));
  }

  void _onItemAdded(
    ChecklistCreateItemAdded event,
    Emitter<ChecklistCreateState> emit,
  ) {
    emit(state.copyWith(items: [...state.items, event.item]));
  }

  void _onItemRemoved(
    ChecklistCreateItemRemoved event,
    Emitter<ChecklistCreateState> emit,
  ) {
    final items = [...state.items]..removeAt(event.index);
    emit(state.copyWith(items: items));
  }

  void _onItemUpdated(
    ChecklistCreateItemUpdated event,
    Emitter<ChecklistCreateState> emit,
  ) {
    final items = [...state.items];
    items[event.index] = event.item;
    emit(state.copyWith(items: items));
  }

  Future<void> _onItemPhotoSelected(
    ChecklistCreateItemPhotoSelected event,
    Emitter<ChecklistCreateState> emit,
  ) async {
    final item = state.items[event.index];
    final checklistId =
        _existingId ?? DateTime.now().millisecondsSinceEpoch.toString();
    _existingId ??= checklistId;

    final path = 'checklists/$checklistId/${item.id}.jpg';
    final url = await _storageService.uploadImage(path, event.photo);

    final items = [...state.items];
    items[event.index] = item.copyWith(photoUrl: () => url);
    emit(state.copyWith(items: items));
  }

  void _onItemReordered(
    ChecklistCreateItemReordered event,
    Emitter<ChecklistCreateState> emit,
  ) {
    final items = [...state.items];
    var oldIndex = event.oldIndex;
    var newIndex = event.newIndex;
    if (newIndex > oldIndex) newIndex--;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    // Update order values
    final reordered = [
      for (var i = 0; i < items.length; i++) items[i].copyWith(order: i),
    ];
    emit(state.copyWith(items: reordered));
  }

  Future<void> _onSubmitted(
    ChecklistCreateSubmitted event,
    Emitter<ChecklistCreateState> emit,
  ) async {
    if (state.title.trim().isEmpty) {
      emit(state.copyWith(
        status: ChecklistCreateStatus.failure,
        errorMessage: 'Titel is verplicht.',
      ));
      return;
    }

    emit(state.copyWith(status: ChecklistCreateStatus.saving));

    try {
      if (_existingId == null) {
        await _checklistService.createChecklist(
          title: state.title.trim(),
          ownerUid: _ownerUid,
          teamId: teamId,
          items: state.items,
        );
      } else {
        final checklist = Checklist(
          id: _existingId!,
          title: state.title.trim(),
          ownerUid: _ownerUid,
          createdAt: DateTime.now(),
          teamId: teamId,
          items: state.items,
        );
        await _checklistService.updateChecklist(checklist);
      }
      emit(state.copyWith(status: ChecklistCreateStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: ChecklistCreateStatus.failure,
        errorMessage: 'Opslaan mislukt. Controleer je internetverbinding.',
      ));
    }
  }
}
