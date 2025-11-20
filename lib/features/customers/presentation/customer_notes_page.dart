import 'package:flutter/material.dart';
import '../data/customer_note_repository.dart';
import '../domain/customer.dart';
import '../domain/customer_note.dart';

class CustomerNotesPage extends StatefulWidget {
  final Customer customer;

  const CustomerNotesPage({super.key, required this.customer});

  @override
  State<CustomerNotesPage> createState() => _CustomerNotesPageState();
}

class _CustomerNotesPageState extends State<CustomerNotesPage> {
  final _repo = CustomerNoteRepository();
  final _noteController = TextEditingController();

  List<CustomerNote> _notes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final items = await _repo.getNotesForCustomer(widget.customer.id);
    setState(() {
      _notes = items;
      _isLoading = false;
    });
  }

  Future<void> _addNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    await _repo.addNote(
      customerId: widget.customer.id,
      text: text,
    );
    _noteController.clear();
    await _loadNotes();
  }

  Future<void> _deleteNote(CustomerNote note) async {
    await _repo.deleteNote(note.id);
    await _loadNotes();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes – ${c.fullName}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Quick notes about this customer',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                    ? const Center(child: Text('No notes yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          final note = _notes[index];
                          return Card(
                            child: ListTile(
                              title: Text(note.text),
                              subtitle: Text(
                                '${note.createdAt}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteNote(note),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const Divider(height: 1),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Type a note and press Add',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addNote,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
