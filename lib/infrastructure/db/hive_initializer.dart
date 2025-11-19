import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

import 'package:insurance_logbook/features/customers/domain/customer.dart';

/// Central place to initialize the local database (Hive).
class AppDatabase {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    // Initialize Hive for Flutter (works on Windows + Android)
    await Hive.initFlutter();

    // Register all model adapters here
    Hive.registerAdapter(CustomerAdapter());

    // Optionally open boxes we know we'll use often
    await Hive.openBox<Customer>('customers');

    _initialized = true;
  }
}
