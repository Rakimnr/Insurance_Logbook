import 'package:hive/hive.dart';
import 'package:insurance_logbook/infrastructure/db/hive_initializer.dart';
import 'package:insurance_logbook/features/quotations/domain/quotation.dart';

class QuotationRepository {
  Box<Quotation> get _box => AppDatabase.quotationBox;

  Future<List<Quotation>> getForCustomer(String customerId) async {
    final list =
        _box.values.where((q) => q.customerId == customerId).toList();
    list.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return list;
  }

  Future<void> addQuotation(Quotation quotation) async {
    await _box.put(quotation.id, quotation);
  }

  Future<void> deleteQuotation(String id) async {
    await _box.delete(id);
  }
}
