import 'package:flutter/material.dart';
import 'package:insurance_logbook/infrastructure/db/hive_initializer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Behaviour / UX toggles (in-memory for now)
  bool _notificationsEnabled = true;
  bool _dailySummaryEnabled = true;
  bool _showBirthdaysOnDashboard = true;
  bool _showLeadsOnDashboard = true;

  bool _compactLayout = false;
  bool _confirmBeforeDelete = true;
  bool _autoArchiveConvertedLeads = false;

  // Data snapshot
  bool _isLoadingSnapshot = true;
  bool _isClearing = false;

  int _customerCount = 0;
  int _leadCount = 0;
  int _noteCount = 0;
  int _quotationCount = 0;

  DateTime? _lastDataClear;

  @override
  void initState() {
    super.initState();
    _loadSnapshot();
  }

  Future<void> _loadSnapshot() async {
    setState(() {
      _isLoadingSnapshot = true;
    });

    try {
      final customersBox = AppDatabase.customersBox;
      final notesBox = AppDatabase.customerNotesBox;
      final leadsBox = AppDatabase.leadsBox;
      final quotationsBox = AppDatabase.quotationBox;

      setState(() {
        _customerCount = customersBox.length;
        _noteCount = notesBox.length;
        _leadCount = leadsBox.length;
        _quotationCount = quotationsBox.length;
        _isLoadingSnapshot = false;
      });
    } catch (_) {
      setState(() {
        _isLoadingSnapshot = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear all CRM data?'),
          content: const Text(
            'This will remove all customers, notes, leads and quotations '
            'stored locally on this device.\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear data'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isClearing = true;
    });

    try {
      await AppDatabase.customersBox.clear();
      await AppDatabase.customerNotesBox.clear();
      await AppDatabase.leadsBox.clear();
      await AppDatabase.quotationBox.clear();

      _lastDataClear = DateTime.now();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All local CRM data has been cleared.'),
        ),
      );

      await _loadSnapshot();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear data: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isClearing = false;
        });
      }
    }
  }

  void _resetVisualPreferences() {
    setState(() {
      _compactLayout = false;
      _showBirthdaysOnDashboard = true;
      _showLeadsOnDashboard = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Visual preferences reset to defaults.'),
      ),
    );
  }

  void _resetBehaviourPreferences() {
    setState(() {
      _notificationsEnabled = true;
      _dailySummaryEnabled = true;
      _confirmBeforeDelete = true;
      _autoArchiveConvertedLeads = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Behaviour settings reset to defaults.'),
      ),
    );
  }

  void _showNotImplementedMessage(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName is not enabled in this demo build.'),
      ),
    );
  }

  String _formatLastClear() {
    final ts = _lastDataClear;
    if (ts == null) {
      return 'Never cleared';
    }
    return 'Last cleared: '
        '${ts.year.toString().padLeft(4, '0')}-'
        '${ts.month.toString().padLeft(2, '0')}-'
        '${ts.day.toString().padLeft(2, '0')} '
        '${ts.hour.toString().padLeft(2, '0')}:'
        '${ts.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final content = _buildContent(textTheme);

          if (!isWide) {
            return content;
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: content,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(TextTheme textTheme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeaderCard(textTheme),
        const SizedBox(height: 24),
        _buildSectionTitle('Dashboard & Visuals'),
        _buildVisualSettingsCard(),
        const SizedBox(height: 24),
        _buildSectionTitle('Behaviour & Workflow'),
        _buildBehaviourSettingsCard(),
        const SizedBox(height: 24),
        _buildSectionTitle('Data & Storage'),
        _buildDataSettingsCard(),
        const SizedBox(height: 24),
        _buildSectionTitle('Support & About'),
        _buildSupportCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeaderCard(TextTheme textTheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.dashboard_customize_outlined,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Insurance Logbook',
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Version 1.0.0+1 • Offline CRM workspace for insurance advisors',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoadingSnapshot
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildHeaderChip(
                        icon: Icons.person_outline,
                        label: 'Customers',
                        value: _customerCount.toString(),
                      ),
                      _buildHeaderChip(
                        icon: Icons.leaderboard_outlined,
                        label: 'Leads',
                        value: _leadCount.toString(),
                      ),
                      _buildHeaderChip(
                        icon: Icons.note_alt_outlined,
                        label: 'Notes',
                        value: _noteCount.toString(),
                      ),
                      _buildHeaderChip(
                        icon: Icons.picture_as_pdf_outlined,
                        label: 'Quotations',
                        value: _quotationCount.toString(),
                      ),
                    ],
                  ),
            const SizedBox(height: 12),
            Text(
              _formatLastClear(),
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildVisualSettingsCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dashboard_outlined),
            title: const Text('Show birthdays on dashboard'),
            subtitle: const Text(
              'Display upcoming birthdays as a compact panel on the main dashboard.',
            ),
            value: _showBirthdaysOnDashboard,
            onChanged: (value) {
              setState(() {
                _showBirthdaysOnDashboard = value;
              });
            },
          ),
          const Divider(height: 0),
          SwitchListTile(
            secondary: const Icon(Icons.view_list_outlined),
            title: const Text('Show lead pipeline on dashboard'),
            subtitle: const Text(
              'Include lead status breakdown on the main dashboard view.',
            ),
            value: _showLeadsOnDashboard,
            onChanged: (value) {
              setState(() {
                _showLeadsOnDashboard = value;
              });
            },
          ),
          const Divider(height: 0),
          SwitchListTile(
            secondary: const Icon(Icons.view_compact_alt_outlined),
            title: const Text('Compact layout'),
            subtitle: const Text(
              'Reduce padding in list rows to show more content on screen, useful on smaller laptops.',
            ),
            value: _compactLayout,
            onChanged: (value) {
              setState(() {
                _compactLayout = value;
              });
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.restore_outlined),
            title: const Text('Reset visual preferences'),
            subtitle: const Text(
              'Revert dashboard and layout settings to defaults.',
            ),
            onTap: _resetVisualPreferences,
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviourSettingsCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Enable reminders'),
            subtitle: const Text(
              'Allow the app to surface in-app reminders for birthdays and follow-ups while it is open.',
            ),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(height: 0),
          SwitchListTile(
            secondary: const Icon(Icons.summarize_outlined),
            title: const Text('Daily summary banner'),
            subtitle: const Text(
              'Show a quick summary of today\'s key actions when you open the app.',
            ),
            value: _dailySummaryEnabled,
            onChanged: (value) {
              setState(() {
                _dailySummaryEnabled = value;
              });
            },
          ),
          const Divider(height: 0),
          SwitchListTile(
            secondary: const Icon(Icons.warning_amber_outlined),
            title: const Text('Confirm before deleting records'),
            subtitle: const Text(
              'Ask for confirmation before deleting customers, leads or notes.',
            ),
            value: _confirmBeforeDelete,
            onChanged: (value) {
              setState(() {
                _confirmBeforeDelete = value;
              });
            },
          ),
          const Divider(height: 0),
          SwitchListTile(
            secondary: const Icon(Icons.archive_outlined),
            title: const Text('Auto-archive converted leads'),
            subtitle: const Text(
              'When a lead is marked as converted, automatically move it out of the active pipeline view.',
            ),
            value: _autoArchiveConvertedLeads,
            onChanged: (value) {
              setState(() {
                _autoArchiveConvertedLeads = value;
              });
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Reset behaviour settings'),
            subtitle: const Text(
              'Revert reminders and workflow rules to defaults.',
            ),
            onTap: _resetBehaviourPreferences,
          ),
        ],
      ),
    );
  }

  Widget _buildDataSettingsCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Export data snapshot'),
            subtitle: const Text(
              'Planned feature to export customers, notes, leads and quotations to a file.',
            ),
            onTap: () => _showNotImplementedMessage('Data export'),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.sync_alt_outlined),
            title: const Text('Sync with cloud (future)'),
            subtitle: const Text(
              'In a cloud-enabled edition this would sync your local workspace to a secure backend.',
            ),
            onTap: () => _showNotImplementedMessage('Cloud sync'),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Clear all local data'),
            subtitle: Text(
              'Remove all CRM data from this device. ${_formatLastClear()}',
            ),
            trailing: _isClearing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _isClearing ? null : _clearAllData,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Quick usage tips'),
            subtitle: const Text(
              'View a short overview of how to use customers, leads, notes and quotations together.',
            ),
            onTap: () => _showNotImplementedMessage('Usage tips'),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send feedback'),
            subtitle: const Text(
              'In a production version this would open your email client with a pre-filled support template.',
            ),
            onTap: () => _showNotImplementedMessage('Feedback'),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Insurance Logbook'),
            subtitle: const Text(
              'Built as an offline, lightweight CRM companion for insurance advisors to manage customers, leads and policy follow-ups.',
            ),
          ),
        ],
      ),
    );
  }
}
