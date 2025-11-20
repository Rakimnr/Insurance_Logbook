import 'package:hive_flutter/hive_flutter.dart';

import 'package:insurance_logbook/features/customers/domain/customer.dart';
import 'package:insurance_logbook/features/customers/domain/customer_note.dart';
import 'package:insurance_logbook/features/leads/domain/lead.dart';
import 'package:insurance_logbook/features/quotations/domain/quotation.dart';

class AppDatabase {
  static bool _initialized = false;

  // Centralised box name definitions
  static const String customersBoxName = 'customers';
  static const String customerNotesBoxName = 'customer_notes';
  static const String leadsBoxName = 'leads';
  static const String quotationsBoxName = 'quotations';

  static Future<void> init() async {
    if (_initialized) return;

    // Initialise Hive for Flutter
    await Hive.initFlutter();

    // Register all adapters exactly once
    Hive
      ..registerAdapter(CustomerAdapter())       // typeId: 1
      ..registerAdapter(CustomerNoteAdapter())   // typeId: 2
      ..registerAdapter(LeadAdapter())          // typeId: 3
      ..registerAdapter(QuotationAdapter());    // typeId: 4

    // Open all boxes up-front so the rest of the app can just use Hive.box(...)
    await Hive.openBox<Customer>(customersBoxName);
    await Hive.openBox<CustomerNote>(customerNotesBoxName);
    await Hive.openBox<Lead>(leadsBoxName);
    await Hive.openBox<Quotation>(quotationsBoxName);

    _initialized = true;
  }

  // Typed accessors – used by repositories / UI
  static Box<Customer> get customersBox =>
      Hive.box<Customer>(customersBoxName);

  static Box<CustomerNote> get customerNotesBox =>
      Hive.box<CustomerNote>(customerNotesBoxName);

  static Box<Lead> get leadsBox =>
      Hive.box<Lead>(leadsBoxName);

  static Box<Quotation> get quotationBox =>
      Hive.box<Quotation>(quotationsBoxName);
}
