import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import './chat_detail_screen.dart';

class ChatListComponent extends StatelessWidget {
  const ChatListComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = _getChats();
    
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Bouton nouveau chat
          Container(
            color: Colors.white,
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
              title: const Text(
                'Nouvelle discussion', 
                style: TextStyle(fontWeight: FontWeight.bold)
              ),
              onTap: () => _startNewChat(context),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Liste des chats
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  return _buildChatItem(context, chats[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, Map<String, dynamic> chat) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: AppTheme.primaryBlue.withOpacity(0.7),
        child: Text(
          chat['name'][0],
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat['name'],
              style: TextStyle(
                fontWeight: chat['unread'] > 0 ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Text(
            chat['time'],
            style: TextStyle(
              color: chat['unread'] > 0 ? AppTheme.primaryBlue : Colors.grey.shade600,
              fontSize: 12,
              fontWeight: chat['unread'] > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          if (chat['isMe']) ...[
            Icon(
              _getMessageStatusIcon(chat['messageStatus']),
              size: 16,
              color: chat['messageStatus'] == 'read' ? AppTheme.primaryBlue : Colors.grey,
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              chat['lastMessage'],
              style: TextStyle(
                color: chat['unread'] > 0 ? Colors.black87 : Colors.grey.shade600,
                fontWeight: chat['unread'] > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (chat['unread'] > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${chat['unread']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () => _openChat(context, chat),
    );
  }

  IconData _getMessageStatusIcon(String status) {
    switch (status) {
      case 'sent':
        return Icons.check;
      case 'delivered':
        return Icons.done_all;
      case 'read':
        return Icons.done_all;
      default:
        return Icons.check;
    }
  }

  List<Map<String, dynamic>> _getChats() {
    return [
      {
        'id': '1',
        'name': 'Marie Diop',
        'lastMessage': 'Salut ! Comment ça va ?',
        'time': '14:30',
        'unread': 2,
        'isMe': false,
        'messageStatus': 'read',
        'avatar': 'M',
        'isOnline': true
      },
      {
        'id': '2',
        'name': 'Ibrahima Fall',
        'lastMessage': 'D\'accord, à tout à l\'heure',
        'time': '13:45',
        'unread': 0,
        'isMe': true,
        'messageStatus': 'read',
        'avatar': 'I',
        'isOnline': false
      },
      {
        'id': '3',
        'name': 'Fatou Seck',
        'lastMessage': 'Merci beaucoup pour ton aide !',
        'time': '12:20',
        'unread': 1,
        'isMe': false,
        'messageStatus': 'delivered',
        'avatar': 'F',
        'isOnline': true
      },
      {
        'id': '4',
        'name': 'Amadou Ndiaye',
        'lastMessage': 'Je suis en route',
        'time': 'hier',
        'unread': 0,
        'isMe': true,
        'messageStatus': 'sent',
        'avatar': 'A',
        'isOnline': false
      },
      {
        'id': '5',
        'name': 'Groupe Services',
        'lastMessage': 'Nouveau service disponible',
        'time': 'hier',
        'unread': 5,
        'isMe': false,
        'messageStatus': 'read',
        'avatar': 'G',
        'isOnline': true
      },
    ];
  }

  void _startNewChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle discussion'),
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
            // Liste de contacts suggérés
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  final contacts = ['Moussa Ba', 'Awa Diallo', 'Omar Sy'];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(contacts[index][0]),
                    ),
                    title: Text(contacts[index]),
                    onTap: () {
                      Navigator.pop(context);
                      // Démarrer discussion avec ce contact
                    },
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

  void _openChat(BuildContext context, Map<String, dynamic> chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          contactName: chat['name'],
          contactId: chat['id'],
          isOnline: chat['isOnline'],
        ),
      ),
    );
  }
}