import 'package:flutter/material.dart';
import '../services/safety_checkin_service.dart';
import '../services/fake_call_service.dart';
import 'history_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _checkInEnabled = false;
  int _checkInInterval = 4;
  String _selectedFakeContact = 'Mom';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final status = await SafetyCheckInService.getCheckInStatus();
    setState(() {
      _checkInEnabled = status['isEnabled'] as bool;
      _checkInInterval = status['intervalHours'] as int;
    });
  }

  Future<void> _toggleCheckIn(bool value) async {
    if (value) {
      await SafetyCheckInService.enableCheckIns(_checkInInterval);
    } else {
      await SafetyCheckInService.disableCheckIns();
    }
    setState(() => _checkInEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Features'),
        backgroundColor: Colors.red.shade700,
      ),
      body: ListView(
        children: [
          // Safety Check-in Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Text(
                          'Safety Check-in',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Get reminders to check in at regular intervals',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Enable Check-ins',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Switch(
                          value: _checkInEnabled,
                          onChanged: _toggleCheckIn,
                          activeThumbColor: Colors.green,
                        ),
                      ],
                    ),
                    if (_checkInEnabled) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Check-in Interval: $_checkInInterval hours',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Slider(
                        value: _checkInInterval.toDouble(),
                        min: 1,
                        max: 12,
                        divisions: 11,
                        label: '$_checkInInterval hours',
                        onChanged: (value) async {
                          setState(() => _checkInInterval = value.toInt());
                          await SafetyCheckInService.enableCheckIns(
                            _checkInInterval,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Fake Call Feature
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Text(
                          'Fake Incoming Call',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Simulate an incoming call to get out of uncomfortable situations',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedFakeContact,
                      items: FakeCallService.getFakeContactNames()
                          .map(
                            (name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedFakeContact = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          FakeCallService.startFakeCall(
                            contactName: _selectedFakeContact,
                            context: context,
                            onCallAnswered: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Call answered'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            onCallRejected: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Call from $_selectedFakeContact ended',
                                  ),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                            },
                          );
                        },
                        child: const Text('Start Fake Call'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // History Section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.history, color: Colors.orange.shade700),
                title: const Text('View Alert History'),
                subtitle: const Text('See all recorded emergency alerts'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              ),
            ),
          ),

          // About Section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Women Safety App v1.0.0',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your personal safety companion with emergency alerts, shake detection, and location sharing.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
