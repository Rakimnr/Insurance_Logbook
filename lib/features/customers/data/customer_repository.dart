import 'package:hive/hive.dart';
import '../domain/customer.dart';

class CustomerRepository {
  static const String _boxName = 'customers';

  Future<Box<Customer>> _openBox() async {
    return Hive.isBoxOpen(_boxName)
        ? Hive.box<Customer>(_boxName)
        : Hive.openBox<Customer>(_boxName);
  }

  Future<List<Customer>> getAllCustomers() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> addCustomer(Customer customer) async {
    final box = await _openBox();
    await box.put(customer.id, customer);
  }

  Future<void> deleteCustomer(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
}
