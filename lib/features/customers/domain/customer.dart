import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 1) // keep this unique per model type
class Customer extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String nic;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final DateTime? dob;

  @HiveField(5)
  final String address;

  @HiveField(6)
  final String statusTag; // Interested, Converted, etc.

  Customer({
    required this.id,
    required this.fullName,
    required this.nic,
    required this.phone,
    required this.dob,
    required this.address,
    required this.statusTag,
  });
}
