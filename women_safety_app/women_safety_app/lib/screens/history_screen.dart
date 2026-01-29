import 'package:flutter/material.dart';
import '../services/incident_history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<IncidentEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = IncidentHistoryService.getHistory();
  }

  String _getIncidentTypeLabel(String type) {
    switch (type) {
      case 'sos':
        return 'SOS Button';
      case 'shake':
        return 'Shake Detection';
      case 'manual':
        return 'Manual Alert';
      default:
        return type;
    }
  }

  Color _getIncidentTypeColor(String type) {
    switch (type) {
      case 'sos':
        return Colors.red;
      case 'shake':
        return Colors.orange;
      case 'manual':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Alerts History'),
        backgroundColor: Colors.red.shade700,
      ),
      body: FutureBuilder<List<IncidentEntry>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading history: ${snapshot.error}'),
            );
          }

          final incidents = snapshot.data ?? [];

          if (incidents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No alerts recorded yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: incidents.length,
            reverse: true,
            itemBuilder: (context, index) {
              final incident = incidents[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getIncidentTypeColor(
                      incident.type,
                    ).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    incident.type == 'sos'
                        ? Icons.emergency
                        : incident.type == 'shake'
                        ? Icons.vibration
                        : Icons.touch_app,
                    color: _getIncidentTypeColor(incident.type),
                  ),
                ),
                title: Text(_getIncidentTypeLabel(incident.type)),
                subtitle: Text(
                  '${incident.timestamp.hour}:${incident.timestamp.minute.toString().padLeft(2, '0')} - ${incident.timestamp.day}/${incident.timestamp.month}/${incident.timestamp.year}',
                ),
                trailing: Text(
                  '${incident.contactsNotified.length} contacts',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
