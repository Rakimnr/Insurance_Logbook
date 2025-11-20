import 'package:hive/hive.dart';
import '../domain/customer_note.dart';

class CustomerNoteRepository {
  static const String _boxName = 'customer_notes';

  Future<Box<CustomerNote>> _openBox() async {
    return Hive.isBoxOpen(_boxName)
        ? Hive.box<CustomerNote>(_boxName)
        : Hive.openBox<CustomerNote>(_boxName);
  }

  /// Get all notes across all customers, newest first
  Future<List<CustomerNote>> getAllNotes() async {
    final box = await _openBox();
    final notes = box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
    return notes;
  }

  Future<List<CustomerNote>> getNotesForCustomer(String customerId) async {
    final box = await _openBox();
    final notes = box.values
        .where((n) => n.customerId == customerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
    return notes;
  }

  Future<void> addNote({
    required String customerId,
    required String text,
  }) async {
    final box = await _openBox();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final note = CustomerNote(
      id: id,
      customerId: customerId,
      text: text,
      createdAt: DateTime.now(),
    );
    await box.put(id, note);
  }

  Future<void> deleteNote(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
}
