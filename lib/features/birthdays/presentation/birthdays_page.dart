import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:insurance_logbook/features/customers/data/customer_repository.dart';
import 'package:insurance_logbook/features/customers/domain/customer.dart';
import 'package:insurance_logbook/features/customers/presentation/customer_notes_page.dart';

class BirthdaysPage extends StatefulWidget {
  const BirthdaysPage({super.key});

  @override
  State<BirthdaysPage> createState() => _BirthdaysPageState();
}

class _BirthdaysPageState extends State<BirthdaysPage> {
  final _customerRepo = CustomerRepository();

  bool _isLoading = true;

  List<_BirthdayItem> _today = [];
  List<_BirthdayItem> _thisWeek = [];
  List<_BirthdayItem> _thisMonth = [];

  @override
  void initState() {
    super.initState();
    _loadBirthdays();
  }

  Future<void> _loadBirthdays() async {
    setState(() {
      _isLoading = true;
    });

    final customers = await _customerRepo.getAllCustomers();
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    final List<_BirthdayItem> todayList = [];
    final List<_BirthdayItem> weekList = [];
    final List<_BirthdayItem> monthList = [];

    for (final c in customers) {
      if (c.dob == null) continue;

      final dob = c.dob!;
      // Next birthday (this year or next)
      DateTime next = DateTime(today.year, dob.month, dob.day);
      if (next.isBefore(todayDateOnly)) {
        next = DateTime(today.year + 1, dob.month, dob.day);
      }

      final days = next.difference(todayDateOnly).inDays;
      final ageTurning = next.year - dob.year;

      final item = _BirthdayItem(
        customer: c,
        nextBirthday: next,
        daysUntil: days,
        ageTurning: ageTurning,
      );

      if (days == 0) {
        todayList.add(item);
      } else if (days > 0 && days <= 7) {
        weekList.add(item);
      } else if (days > 7 &&
          next.year == today.year &&
          next.month == today.month) {
        monthList.add(item);
      }
    }

    todayList.sort((a, b) => a.customer.fullName.compareTo(b.customer.fullName));
    weekList.sort((a, b) => a.nextBirthday.compareTo(b.nextBirthday));
    monthList.sort((a, b) => a.nextBirthday.compareTo(b.nextBirthday));

    setState(() {
      _today = todayList;
      _thisWeek = weekList;
      _thisMonth = monthList;
      _isLoading = false;
    });
  }

  Future<void> _openWhatsApp(Customer c) async {
    // Very simple cleaning – keep digits and +
    final cleanedPhone = c.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanedPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid phone number for WhatsApp')),
      );
      return;
    }

    final uri = Uri.parse('https://wa.me/$cleanedPhone');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp')),
      );
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
        title: const Text('Upcoming Birthdays'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadBirthdays,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _BirthdaySection(
                title: 'Today',
                items: _today,
                emptyText: 'No birthdays today.',
                onWhatsApp: _openWhatsApp,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _BirthdaySection(
                title: 'This Week',
                items: _thisWeek,
                emptyText: 'No birthdays in the next 7 days.',
                onWhatsApp: _openWhatsApp,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _BirthdaySection(
                title: 'This Month',
                items: _thisMonth,
                emptyText: 'No more birthdays this month.',
                onWhatsApp: _openWhatsApp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BirthdayItem {
  final Customer customer;
  final DateTime nextBirthday;
  final int daysUntil;
  final int ageTurning;

  _BirthdayItem({
    required this.customer,
    required this.nextBirthday,
    required this.daysUntil,
    required this.ageTurning,
  });
}

class _BirthdaySection extends StatelessWidget {
  final String title;
  final List<_BirthdayItem> items;
  final String emptyText;
  final Future<void> Function(Customer) onWhatsApp;

  const _BirthdaySection({
    required this.title,
    required this.items,
    required this.emptyText,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        emptyText,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final c = item.customer;
                        final dateStr =
                            '${item.nextBirthday.day}/${item.nextBirthday.month}';
                        final dobStr = c.dob != null
                            ? '${c.dob!.day}/${c.dob!.month}/${c.dob!.year}'
                            : '—';

                        String subtitle =
                            'Next birthday: $dateStr\n'
                            'DOB: $dobStr\n'
                            'Turning: ${item.ageTurning} years';

                        if (item.daysUntil > 0) {
                          subtitle += '\nIn ${item.daysUntil} day(s)';
                        }

                        return Card(
                          child: ListTile(
                            title: Text(c.fullName),
                            subtitle: Text(subtitle),
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                IconButton(
                                  tooltip: 'Open notes',
                                  icon: const Icon(Icons.note_alt_outlined),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CustomerNotesPage(customer: c),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'WhatsApp',
                                  icon: const Icon(Icons.chat_outlined), // or Icons.message, Icons.send
                                  onPressed: () => onWhatsApp(c),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
