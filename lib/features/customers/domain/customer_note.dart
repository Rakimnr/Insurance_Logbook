import 'package:hive/hive.dart';

part 'customer_note.g.dart';

@HiveType(typeId: 2) // ⬅️ must be unique across all models
class CustomerNote extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final DateTime createdAt;

  CustomerNote({
    required this.id,
    required this.customerId,
    required this.text,
    required this.createdAt,
  });
}
