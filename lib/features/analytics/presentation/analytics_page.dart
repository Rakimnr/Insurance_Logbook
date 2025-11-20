import 'package:flutter/material.dart';

import 'package:insurance_logbook/features/customers/data/customer_repository.dart';
import 'package:insurance_logbook/features/customers/data/customer_note_repository.dart';
import 'package:insurance_logbook/features/customers/domain/customer.dart';
import 'package:insurance_logbook/features/leads/data/lead_repository.dart';
import 'package:insurance_logbook/features/leads/domain/lead.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final _customerRepo = CustomerRepository();
  final _noteRepo = CustomerNoteRepository();
  final _leadRepo = LeadRepository();

  bool _isLoading = true;

  // Headline KPIs
  int _customersWithDob = 0;
  int _birthdaysThisMonth = 0;
  int _customersWithNotes = 0;
  int _totalNotes = 0;

  int _newCustomersLast30 = 0;
  int _newLeadsLast30 = 0;

  // Top customers by engagement (note count)
  List<_CustomerNoteCount> _topCustomersByNotes = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    final customers = await _customerRepo.getAllCustomers();
    final notes = await _noteRepo.getAllNotes();
    final List<Lead> leads = await _leadRepo.getAllLeads(); // <-- explicit type

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final since30Days = today.subtract(const Duration(days: 30));

    // 1) DOB / Birthday coverage
    _customersWithDob = customers.where((c) => c.dob != null).length;
    _birthdaysThisMonth = customers.where((c) {
      if (c.dob == null) return false;
      return c.dob!.month == now.month;
    }).length;

    // 2) Notes footprint
    _totalNotes = notes.length;

    final Map<String, int> notesPerCustomer = {};
    for (final n in notes) {
      notesPerCustomer.update(n.customerId, (v) => v + 1, ifAbsent: () => 1);
    }
    _customersWithNotes = notesPerCustomer.length;

    // Lookup: customerId -> Customer
    final Map<String, Customer> customerById = {
      for (final c in customers) c.id: c,
    };

    // Build top customers list
    final List<_CustomerNoteCount> topList = [];
    notesPerCustomer.forEach((customerId, count) {
      final c = customerById[customerId];
      if (c != null) {
        topList.add(_CustomerNoteCount(customer: c, count: count));
      }
    });
    topList.sort((a, b) => b.count.compareTo(a.count));
    _topCustomersByNotes = topList.take(5).toList();

    // 3) Recent activity (last 30 days) using timestamp-based IDs
    int newCustomers = 0;
    for (final c in customers) {
      final created = _timestampFromIdOrNull(c.id);
      if (created != null && created.isAfter(since30Days)) {
        newCustomers++;
      }
    }
    _newCustomersLast30 = newCustomers;

    int newLeads = 0;
    for (final l in leads) {
      final created = _timestampFromIdOrNull(l.id);
      if (created != null && created.isAfter(since30Days)) {
        newLeads++;
      }
    }
    _newLeadsLast30 = newLeads;

    setState(() {
      _isLoading = false;
    });
  }

  /// Our IDs are generated from DateTime.now().millisecondsSinceEpoch,
  /// so we can reverse them back to DateTime for basic analytics.
  DateTime? _timestampFromIdOrNull(String id) {
    try {
      final ms = int.parse(id);
      if (ms <= 0) return null;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Insights'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: DOB coverage / birthdays
            Row(
              children: [
                _AnalyticsStatCard(
                  label: 'Customers with DOB',
                  value: _customersWithDob.toString(),
                  icon: Icons.cake_outlined,
                ),
                const SizedBox(width: 16),
                _AnalyticsStatCard(
                  label: 'Birthdays this Month',
                  value: _birthdaysThisMonth.toString(),
                  icon: Icons.event,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Row 2: Notes usage
            Row(
              children: [
                _AnalyticsStatCard(
                  label: 'Customers with Notes',
                  value: _customersWithNotes.toString(),
                  icon: Icons.note_alt_outlined,
                ),
                const SizedBox(width: 16),
                _AnalyticsStatCard(
                  label: 'Total Notes',
                  value: _totalNotes.toString(),
                  icon: Icons.sticky_note_2_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Row 3: Recent activity
            Row(
              children: [
                _AnalyticsStatCard(
                  label: 'New Customers (30 days)',
                  value: _newCustomersLast30.toString(),
                  icon: Icons.person_add_alt_1_outlined,
                ),
                const SizedBox(width: 16),
                _AnalyticsStatCard(
                  label: 'New Leads (30 days)',
                  value: _newLeadsLast30.toString(),
                  icon: Icons.trending_up_outlined,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Top customers by notes
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Customers by Notes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _topCustomersByNotes.isEmpty
                        ? const Text(
                            'No customer notes yet. Start logging interactions to see insights here.',
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _topCustomersByNotes.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 8),
                            itemBuilder: (context, index) {
                              final item = _topCustomersByNotes[index];
                              final c = item.customer;
                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  child: Text(
                                    c.fullName.isNotEmpty
                                        ? c.fullName[0].toUpperCase()
                                        : '?',
                                  ),
                                ),
                                title: Text(c.fullName),
                                subtitle: Text(c.phone),
                                trailing: Text(
                                  '${item.count} notes',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _AnalyticsStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerNoteCount {
  final Customer customer;
  final int count;

  _CustomerNoteCount({
    required this.customer,
    required this.count,
  });
}
