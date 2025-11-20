import 'package:hive/hive.dart';

part 'lead.g.dart';

@HiveType(typeId: 3) // 1 = Customer, 2 = CustomerNote, 3 = Lead
class Lead extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String status; // e.g. New, Interested, Not Interested, Converted

  @HiveField(5)
  final DateTime createdAt;

  Lead({
    required this.id,
    required this.name,
    required this.phone,
    required this.description,
    required this.status,
    required this.createdAt,
  });
}
