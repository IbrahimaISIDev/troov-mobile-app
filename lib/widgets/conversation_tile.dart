import 'package:flutter/material.dart';
import 'package:troov_app/models/enums.dart';
import '../models/message.dart';
import '../utils/theme.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ConversationTile({
    Key? key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final otherUser = conversation.getOtherUser(currentUserId);
    final hasUnread = conversation.unreadCount > 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: hasUnread 
            ? AppTheme.primaryBlue.withOpacity(0.05)
            : Colors.transparent,
      ),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
              backgroundImage: otherUser.profileImage != null
                  ? NetworkImage(otherUser.profileImage!)
                  : null,
              child: otherUser.profileImage == null
                  ? Text(
                      otherUser.firstName[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    )
                  : null,
            ),
            // Indicateur en ligne (pour les prestataires)
            if (otherUser.role == UserRole.provider)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green, // TODO: Récupérer le statut en ligne
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                otherUser.fullName,
                style: TextStyle(
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatTime(conversation.lastMessageAt),
              style: TextStyle(
                fontSize: 12,
                color: hasUnread ? AppTheme.primaryBlue : Colors.grey[600],
                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                _getLastMessagePreview(),
                style: TextStyle(
                  color: hasUnread ? Colors.black87 : Colors.grey[600],
                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasUnread)
              Container(
                margin: EdgeInsets.only(left: 8),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  conversation.unreadCount > 99 
                      ? '99+' 
                      : conversation.unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: conversation.lastMessage?.status == MessageStatus.failed
            ? Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 20,
              )
            : null,
      ),
    );
  }

  String _getLastMessagePreview() {
    if (conversation.lastMessage == null) {
      return 'Aucun message';
    }

    final message = conversation.lastMessage!;
    final isFromCurrentUser = message.senderId == currentUserId;
    final prefix = isFromCurrentUser ? 'Vous: ' : '';

    switch (message.type) {
      case MessageType.text:
        return '$prefix${message.content}';
      case MessageType.image:
        return '${prefix}📷 Photo';
      case MessageType.document:
        return '${prefix}📄 Document';
      case MessageType.audio:
        return '${prefix}🎵 Audio';
      case MessageType.location:
        return '${prefix}📍 Position';
      case MessageType.booking:
        return '${prefix}📅 Réservation';
      case MessageType.payment:
        return '${prefix}💳 Paiement';
      default:
        return '${prefix}Message';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Aujourd'hui - afficher l'heure
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays == 1) {
      // Hier
      return 'Hier';
    } else if (difference.inDays < 7) {
      // Cette semaine - afficher le jour
      final weekdays = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
      return weekdays[dateTime.weekday % 7];
    } else {
      // Plus ancien - afficher la date
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

