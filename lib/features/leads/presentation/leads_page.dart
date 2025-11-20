import 'package:flutter/material.dart';
import 'package:insurance_logbook/features/customers/data/customer_repository.dart';
import 'package:insurance_logbook/features/customers/domain/customer.dart';

import '../data/lead_repository.dart';
import '../domain/lead.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  final _leadRepo = LeadRepository();
  final _customerRepo = CustomerRepository();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _searchController = TextEditingController();
  String _searchQuery = '';

  String _status = 'New';
  List<Lead> _leads = [];

  Lead? _editingLead; // null = creating, non-null = editing

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    final items = await _leadRepo.getAllLeads();
    setState(() {
      _leads = items;
    });
  }

  List<Lead> get _visibleLeads {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _leads;

    return _leads.where((l) {
      return l.name.toLowerCase().contains(q) ||
          l.phone.toLowerCase().contains(q) ||
          l.description.toLowerCase().contains(q);
    }).toList();
  }

  void _startCreate() {
    setState(() {
      _editingLead = null;
      _nameController.clear();
      _phoneController.clear();
      _descriptionController.clear();
      _status = 'New';
    });
  }

  void _startEdit(Lead lead) {
    setState(() {
      _editingLead = lead;
      _nameController.text = lead.name;
      _phoneController.text = lead.phone;
      _descriptionController.text = lead.description;
      _status = lead.status;
    });
  }

  Future<void> _saveLead() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and phone are required')),
      );
      return;
    }

    final now = DateTime.now();

    if (_editingLead == null) {
      final id = now.millisecondsSinceEpoch.toString();
      final lead = Lead(
        id: id,
        name: name,
        phone: phone,
        description: description,
        status: _status,
        createdAt: now,
      );
      await _leadRepo.addLead(lead);
    } else {
      final updated = Lead(
        id: _editingLead!.id,
        name: name,
        phone: phone,
        description: description,
        status: _status,
        createdAt: _editingLead!.createdAt,
      );
      await _leadRepo.updateLead(updated);
    }

    _startCreate(); // reset form
    await _loadLeads();
  }

  Future<void> _deleteLead(Lead lead) async {
    await _leadRepo.deleteLead(lead.id);
    if (_editingLead?.id == lead.id) {
      _startCreate();
    }
    await _loadLeads();
  }

  Future<void> _convertLeadToCustomer(Lead lead) async {
    // show dialog to capture NIC + optional address
    final nicController = TextEditingController();
    final addressController = TextEditingController();
    String statusTag = 'Interested';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Convert to Customer'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lead: ${lead.name}\nPhone: ${lead.phone}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nicController,
                  decoration: const InputDecoration(
                    labelText: 'NIC (required)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: statusTag,
                  items: const [
                    'Interested',
                    'Quotation Sent',
                    'Converted',
                    'Not Interested',
                    'Follow-up Needed',
                  ].map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      statusTag = value;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Customer Status',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nicController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('NIC is required')),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Create Customer'),
            ),
          ],
        );
      },
    );

    if (result != true) return; // user cancelled

    final nic = nicController.text.trim();
    final address = addressController.text.trim();

    final customerId = DateTime.now().millisecondsSinceEpoch.toString();
    final customer = Customer(
      id: customerId,
      fullName: lead.name,
      nic: nic,
      phone: lead.phone,
      dob: null, // can be edited later
      address: address,
      statusTag: statusTag,
    );

    await _customerRepo.addCustomer(customer);
    await _leadRepo.deleteLead(lead.id); // remove lead after conversion
    await _loadLeads();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead converted to customer')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleLeads;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left panel: create / edit lead
            SizedBox(
              width: 360,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _editingLead == null ? 'Add Lead' : 'Edit Lead',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description / Notes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      items: const [
                        'New',
                        'Interested',
                        'Not Interested',
                        'Converted',
                        'Follow-up Needed',
                      ].map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _status = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveLead,
                            child: Text(
                              _editingLead == null ? 'Save Lead' : 'Update Lead',
                            ),
                          ),
                        ),
                        if (_editingLead != null) ...[
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _startCreate,
                            child: const Text('New'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const VerticalDivider(width: 24),

            // Right panel: list + search
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Saved Leads',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search by name, phone, or description',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: visible.isEmpty
                        ? const Center(
                            child: Text('No leads found.'),
                          )
                        : ListView.builder(
                            itemCount: visible.length,
                            itemBuilder: (context, index) {
                              final l = visible[index];
                              return Card(
                                child: ListTile(
                                  title: Text(l.name),
                                  subtitle: Text(
                                    'Phone: ${l.phone}\n'
                                    'Status: ${l.status}\n'
                                    'Notes: ${l.description}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Convert to customer',
                                        icon: const Icon(Icons.person_add_alt),
                                        onPressed: () =>
                                            _convertLeadToCustomer(l),
                                      ),
                                      IconButton(
                                        tooltip: 'Edit lead',
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () => _startEdit(l),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete lead',
                                        icon: const Icon(
                                            Icons.delete_outline_rounded),
                                        onPressed: () => _deleteLead(l),
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
          ],
        ),
      ),
    );
  }
}
