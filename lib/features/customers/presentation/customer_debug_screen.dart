import 'package:flutter/material.dart';
import '../data/customer_repository.dart';
import '../domain/customer.dart';

class CustomerDebugScreen extends StatefulWidget {
  const CustomerDebugScreen({super.key});

  @override
  State<CustomerDebugScreen> createState() => _CustomerDebugScreenState();
}

class _CustomerDebugScreenState extends State<CustomerDebugScreen> {
  final _repo = CustomerRepository();

  final _nameController = TextEditingController();
  final _nicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // 🔍 search
  final _searchController = TextEditingController();
  String _searchQuery = '';

  String _statusTag = 'Interested';
  DateTime? _dob;
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final all = await _repo.getAllCustomers();
    setState(() {
      _customers = all;
    });
  }

  // List visible after applying search
  List<Customer> get _visibleCustomers {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _customers;

    return _customers.where((c) {
      return c.fullName.toLowerCase().contains(q) ||
          c.nic.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
      });
    }
  }

  Future<void> _addCustomer() async {
    final name = _nameController.text.trim();
    final nic = _nicController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || nic.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, NIC and phone are required')),
      );
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final customer = Customer(
      id: id,
      fullName: name,
      nic: nic,
      phone: phone,
      dob: _dob,
      address: address,
      statusTag: _statusTag,
    );

    await _repo.addCustomer(customer);

    _nameController.clear();
    _nicController.clear();
    _phoneController.clear();
    _addressController.clear();
    setState(() {
      _dob = null;
      _statusTag = 'Interested';
    });

    await _loadCustomers();
  }

  Future<void> _deleteCustomer(Customer c) async {
    await _repo.deleteCustomer(c.id);
    await _loadCustomers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleCustomers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insurance Customers Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left panel: form
            SizedBox(
              width: 360,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Customer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nicController,
                      decoration: const InputDecoration(
                        labelText: 'NIC',
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
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _statusTag,
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
                                setState(() {
                                  _statusTag = value;
                                });
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _pickDob,
                          child: Text(
                            _dob == null
                                ? 'Pick DOB'
                                : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addCustomer,
                        child: const Text('Save Customer'),
                      ),
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
                        'Saved Customers',
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
                            hintText: 'Search by name, NIC, or phone',
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
                            child: Text('No customers match your search.'),
                          )
                        : ListView.builder(
                            itemCount: visible.length,
                            itemBuilder: (context, index) {
                              final c = visible[index];
                              return Card(
                                child: ListTile(
                                  title: Text(c.fullName),
                                  subtitle: Text(
                                    'NIC: ${c.nic}\nPhone: ${c.phone}\nStatus: ${c.statusTag}',
                                  ),
                                  trailing: IconButton(
                                    icon:
                                        const Icon(Icons.delete_outline_rounded),
                                    onPressed: () => _deleteCustomer(c),
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
