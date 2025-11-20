import 'package:hive/hive.dart';

part 'quotation.g.dart';

@HiveType(typeId: 4)
class Quotation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerId;

  /// Full local path to the file we copy into app storage
  @HiveField(2)
  final String filePath;

  /// 'pdf' or 'image'
  @HiveField(3)
  final String fileType;

  @HiveField(4)
  final DateTime uploadedAt;

  Quotation({
    required this.id,
    required this.customerId,
    required this.filePath,
    required this.fileType,
    required this.uploadedAt,
  });
}
