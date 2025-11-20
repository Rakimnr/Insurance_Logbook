import 'package:hive/hive.dart';
import '../domain/lead.dart';

class LeadRepository {
  static const String _boxName = 'leads';

  Future<Box<Lead>> _openBox() async {
    return Hive.isBoxOpen(_boxName)
        ? Hive.box<Lead>(_boxName)
        : Hive.openBox<Lead>(_boxName);
  }

  Future<List<Lead>> getAllLeads() async {
    final box = await _openBox();
    final items = box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
    return items;
  }

  Future<void> addLead(Lead lead) async {
    final box = await _openBox();
    await box.put(lead.id, lead);
  }

  Future<void> deleteLead(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<void> updateLead(Lead lead) async {
    final box = await _openBox();
    await box.put(lead.id, lead);
  }
}
