import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:insurance_logbook/features/customers/domain/customer.dart';
import 'package:insurance_logbook/features/quotations/data/quotation_repository.dart';
import 'package:insurance_logbook/features/quotations/domain/quotation.dart';

class CustomerQuotationsPage extends StatefulWidget {
  final Customer customer;

  const CustomerQuotationsPage({super.key, required this.customer});

  @override
  State<CustomerQuotationsPage> createState() =>
      _CustomerQuotationsPageState();
}

class _CustomerQuotationsPageState extends State<CustomerQuotationsPage> {
  final _repo = QuotationRepository();
  bool _loading = true;
  List<Quotation> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _repo.getForCustomer(widget.customer.id);
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _addQuotation() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    final sourcePath = picked.path;
    if (sourcePath == null) return;

    final ext = p.extension(sourcePath).toLowerCase().replaceFirst('.', '');
    final fileType = ext == 'pdf' ? 'pdf' : 'image';

    final appDir = await getApplicationDocumentsDirectory();
    final quotationsDir = Directory(p.join(appDir.path, 'quotations'));

    if (!await quotationsDir.exists()) {
      await quotationsDir.create(recursive: true);
    }

    final fileName =
        '${widget.customer.id}_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final destPath = p.join(quotationsDir.path, fileName);

    await File(sourcePath).copy(destPath);

    final quotation = Quotation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: widget.customer.id,
      filePath: destPath,
      fileType: fileType,
      uploadedAt: DateTime.now(),
    );

    await _repo.addQuotation(quotation);
    await _load();
  }

  Future<void> _openQuotation(Quotation q) async {
    await OpenFilex.open(q.filePath);
  }

  Future<void> _deleteQuotation(Quotation q) async {
    final f = File(q.filePath);
    if (await f.exists()) {
      await f.delete();
    }
    await _repo.deleteQuotation(q.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quotations – ${widget.customer.fullName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add quotation',
            onPressed: _addQuotation,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No quotations yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final q = _items[index];
                    final isPdf = q.fileType == 'pdf';

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          isPdf
                              ? Icons.picture_as_pdf_outlined
                              : Icons.image_outlined,
                        ),
                        title: Text(
                          p.basename(q.filePath),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${q.fileType.toUpperCase()} · '
                          '${q.uploadedAt.toLocal()}',
                        ),
                        onTap: () => _openQuotation(q),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete',
                          onPressed: () => _deleteQuotation(q),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
