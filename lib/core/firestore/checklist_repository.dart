import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/checklist.dart';

abstract class ChecklistRepository {
  Stream<List<Checklist>> checklists(String ownerUid);
  Future<Checklist?> getChecklist(String id);
  Future<void> saveChecklist(Checklist checklist);
  Future<void> deleteChecklist(String checklistId);
}

class FirebaseChecklistRepository implements ChecklistRepository {
  FirebaseChecklistRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('checklists');

  @override
  Stream<List<Checklist>> checklists(String ownerUid) {
    return _collection
        .where('ownerUid', isEqualTo: ownerUid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map(Checklist.fromFirestore).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<Checklist?> getChecklist(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Checklist.fromFirestore(doc);
  }

  @override
  Future<void> saveChecklist(Checklist checklist) async {
    await _collection.doc(checklist.id).set(checklist.toFirestore());
  }

  @override
  Future<void> deleteChecklist(String checklistId) async {
    await _collection.doc(checklistId).delete();
  }
}
