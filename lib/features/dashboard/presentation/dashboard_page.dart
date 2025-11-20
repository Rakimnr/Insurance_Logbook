import 'package:flutter/material.dart';
import 'package:insurance_logbook/features/customers/data/customer_repository.dart';
import 'package:insurance_logbook/features/leads/data/lead_repository.dart';
import 'package:insurance_logbook/features/customers/domain/customer.dart';
import 'package:insurance_logbook/features/leads/domain/lead.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _customerRepo = CustomerRepository();
  final _leadRepo = LeadRepository();

  bool _isLoading = true;

  int _totalCustomers = 0;
  int _totalLeads = 0;
  int _convertedCustomers = 0;

  // Customer status distribution
  int _custInterested = 0;
  int _custQuotationSent = 0;
  int _custConverted = 0;
  int _custNotInterested = 0;
  int _custFollowUp = 0;

  // Lead status distribution
  int _leadNew = 0;
  int _leadInterested = 0;
  int _leadNotInterested = 0;
  int _leadConverted = 0;
  int _leadFollowUp = 0;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    final List<Customer> customers = await _customerRepo.getAllCustomers();
    final List<Lead> leads = await _leadRepo.getAllLeads();

    // Totals
    final totalCustomers = customers.length;
    final totalLeads = leads.length;

    final convertedCustomers =
        customers.where((c) => c.statusTag == 'Converted').length;

    // Customer status counts
    int custInterested = 0;
    int custQuotationSent = 0;
    int custConverted = 0;
    int custNotInterested = 0;
    int custFollowUp = 0;

    for (final c in customers) {
      switch (c.statusTag) {
        case 'Interested':
          custInterested++;
          break;
        case 'Quotation Sent':
          custQuotationSent++;
          break;
        case 'Converted':
          custConverted++;
          break;
        case 'Not Interested':
          custNotInterested++;
          break;
        case 'Follow-up Needed':
          custFollowUp++;
          break;
      }
    }

    // Lead status counts
    int leadNew = 0;
    int leadInterested = 0;
    int leadNotInterested = 0;
    int leadConverted = 0;
    int leadFollowUp = 0;

    for (final l in leads) {
      switch (l.status) {
        case 'New':
          leadNew++;
          break;
        case 'Interested':
          leadInterested++;
          break;
        case 'Not Interested':
          leadNotInterested++;
          break;
        case 'Converted':
          leadConverted++;
          break;
        case 'Follow-up Needed':
          leadFollowUp++;
          break;
      }
    }

    setState(() {
      _totalCustomers = totalCustomers;
      _totalLeads = totalLeads;
      _convertedCustomers = convertedCustomers;

      _custInterested = custInterested;
      _custQuotationSent = custQuotationSent;
      _custConverted = custConverted;
      _custNotInterested = custNotInterested;
      _custFollowUp = custFollowUp;

      _leadNew = leadNew;
      _leadInterested = leadInterested;
      _leadNotInterested = leadNotInterested;
      _leadConverted = leadConverted;
      _leadFollowUp = leadFollowUp;

      _isLoading = false;
    });
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
        title: const Text('Insurance Logbook – Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top row: KPI cards
            Row(
              children: [
                _DashboardStatCard(
                  label: 'Total Customers',
                  value: _totalCustomers.toString(),
                  icon: Icons.people,
                ),
                const SizedBox(width: 16),
                _DashboardStatCard(
                  label: 'Total Leads',
                  value: _totalLeads.toString(),
                  icon: Icons.call,
                ),
                const SizedBox(width: 16),
                _DashboardStatCard(
                  label: 'Converted Customers',
                  value: _convertedCustomers.toString(),
                  icon: Icons.verified,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bottom row: distributions
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _StatusCard(
                      title: 'Customer Status Breakdown',
                      rows: [
                        _StatusRow(
                          label: 'Interested',
                          value: _custInterested,
                        ),
                        _StatusRow(
                          label: 'Quotation Sent',
                          value: _custQuotationSent,
                        ),
                        _StatusRow(
                          label: 'Converted',
                          value: _custConverted,
                        ),
                        _StatusRow(
                          label: 'Not Interested',
                          value: _custNotInterested,
                        ),
                        _StatusRow(
                          label: 'Follow-up Needed',
                          value: _custFollowUp,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatusCard(
                      title: 'Lead Status Breakdown',
                      rows: [
                        _StatusRow(
                          label: 'New',
                          value: _leadNew,
                        ),
                        _StatusRow(
                          label: 'Interested',
                          value: _leadInterested,
                        ),
                        _StatusRow(
                          label: 'Not Interested',
                          value: _leadNotInterested,
                        ),
                        _StatusRow(
                          label: 'Converted',
                          value: _leadConverted,
                        ),
                        _StatusRow(
                          label: 'Follow-up Needed',
                          value: _leadFollowUp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DashboardStatCard({
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
              Icon(icon, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final List<_StatusRow> rows;

  const _StatusCard({
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int value;

  const _StatusRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
