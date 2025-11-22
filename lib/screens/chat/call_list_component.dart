import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import './call_screen.dart';

class CallListComponent extends StatelessWidget {
  const CallListComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final calls = _getCalls();
    
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Bouton nouvel appel
          Container(
            color: Colors.white,
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call, color: Colors.white, size: 24),
              ),
              title: const Text(
                'Nouvel appel', 
                style: TextStyle(fontWeight: FontWeight.bold)
              ),
              onTap: () => _startNewCall(context),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Liste des appels
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: calls.length,
                itemBuilder: (context, index) {
                  return _buildCallItem(context, calls[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallItem(BuildContext context, Map<String, dynamic> call) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: AppTheme.primaryBlue.withOpacity(0.7),
        child: Text(
          call['name'][0],
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      title: Text(
        call['name'], 
        style: const TextStyle(fontWeight: FontWeight.w500)
      ),
      subtitle: Row(
        children: [
          Icon(
            call['type'] == 'incoming' ? Icons.call_received : Icons.call_made,
            size: 16,
            color: call['missed'] ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            '${call['time']} - ${call['duration'] ?? 'Manqué'}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _makeCall(context, call, false),
            icon: const Icon(Icons.call, color: AppTheme.primaryBlue),
          ),
          IconButton(
            onPressed: () => _makeCall(context, call, true),
            icon: const Icon(Icons.videocam, color: AppTheme.primaryBlue),
          ),
        ],
      ),
      onTap: () => _showCallOptions(context, call),
    );
  }

  List<Map<String, dynamic>> _getCalls() {
    return [
      {
        'id': '1',
        'name': 'Marie Diop',
        'time': 'il y a 1h',
        'type': 'incoming',
        'missed': false,
        'isVideo': false,
        'duration': '5:32'
      },
      {
        'id': '2',
        'name': 'Ibrahima Fall',
        'time': 'il y a 3h',
        'type': 'outgoing',
        'missed': false,
        'isVideo': true,
        'duration': '12:45'
      },
      {
        'id': '3',
        'name': 'Fatou Seck',
        'time': 'hier',
        'type': 'incoming',
        'missed': true,
        'isVideo': false,
        'duration': null
      },
      {
        'id': '4',
        'name': 'Amadou Ndiaye',
        'time': 'il y a 2 jours',
        'type': 'outgoing',
        'missed': false,
        'isVideo': false,
        'duration': '2:15'
      },
      {
        'id': '5',
        'name': 'Service Client',
        'time': 'il y a 3 jours',
        'type': 'incoming',
        'missed': false,
        'isVideo': false,
        'duration': '8:22'
      },
    ];
  }

  void _startNewCall(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvel appel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher un contact...',
                prefixIcon: Icon(Icons.person_search),
              ),
            ),
            const SizedBox(height: 16),
            // Liste de contacts pour appel
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  final contacts = [
                    'Moussa Ba', 'Awa Diallo', 'Omar Sy', 
                    'Khadija Thiam', 'Cheikh Ndao'
                  ];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(contacts[index][0]),
                    ),
                    title: Text(contacts[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _makeCall(context, {
                              'id': 'new_$index',
                              'name': contacts[index]
                            }, false);
                          },
                          icon: const Icon(Icons.call, color: Colors.green),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _makeCall(context, {
                              'id': 'new_$index',
                              'name': contacts[index]
                            }, true);
                          },
                          icon: const Icon(Icons.videocam, color: AppTheme.primaryBlue),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _makeCall(BuildContext context, Map<String, dynamic> contact, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          contactName: contact['name'],
          contactId: contact['id'],
          isVideo: isVideo,
          isIncoming: false,
        ),
      ),
    );
  }

  void _showCallOptions(BuildContext context, Map<String, dynamic> call) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.call, color: Colors.green),
              title: Text('Appeler ${call['name']}'),
              onTap: () {
                Navigator.pop(context);
                _makeCall(context, call, false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: AppTheme.primaryBlue),
              title: Text('Appel vidéo avec ${call['name']}'),
              onTap: () {
                Navigator.pop(context);
                _makeCall(context, call, true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: AppTheme.primaryBlue),
              title: Text('Envoyer un message à ${call['name']}'),
              onTap: () {
                Navigator.pop(context);
                // Navigation vers la discussion
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: Text('Détails de ${call['name']}'),
              onTap: () {
                Navigator.pop(context);
                _showContactDetails(context, call);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContactDetails(BuildContext context, Map<String, dynamic> call) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(call['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dernier appel: ${call['time']}'),
            if (call['duration'] != null)
              Text('Durée: ${call['duration']}'),
            Text('Type: ${call['type'] == 'incoming' ? 'Entrant' : 'Sortant'}'),
            if (call['missed'])
              const Text('Statut: Manqué', style: TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}