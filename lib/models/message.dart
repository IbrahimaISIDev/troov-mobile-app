import 'package:troov_app/models/enums.dart';
import 'package:troov_app/models/user.dart';

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime sentAt;
  final MessageStatus status;
  final List<MessageAttachment> attachments;
  final String? replyToId;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.sentAt,
    required this.status,
    this.attachments = const [],
    this.replyToId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
      ),
      sentAt: DateTime.parse(json['sentAt']),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
      ),
      attachments: (json['attachments'] as List?)
          ?.map((e) => MessageAttachment.fromJson(e))
          .toList() ?? [],
      replyToId: json['replyToId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'type': type.toString().split('.').last,
      'sentAt': sentAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'replyToId': replyToId,
    };
  }
}

enum MessageType {
  text,
  image,
  document,
  audio,
  location,
  booking,
  payment
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed
}

class MessageAttachment {
  final String id;
  final String fileName;
  final String fileUrl;
  final AttachmentType type;
  final int fileSize;
  final String? thumbnailUrl;

  MessageAttachment({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.type,
    required this.fileSize,
    this.thumbnailUrl,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      type: AttachmentType.values.firstWhere(
        (e) => e.toString() == 'AttachmentType.${json['type']}',
      ),
      fileSize: json['fileSize'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'type': type.toString().split('.').last,
      'fileSize': fileSize,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
}

enum AttachmentType {
  image,
  document,
  audio,
  video
}

class Conversation {
  final String id;
  final String clientId;
  final String providerId;
  final String? bookingId;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final Message? lastMessage;
  final int unreadCount;
  final bool isActive;
  final User client;
  final User provider;

  Conversation({
    required this.id,
    required this.clientId,
    required this.providerId,
    this.bookingId,
    required this.createdAt,
    required this.lastMessageAt,
    this.lastMessage,
    this.unreadCount = 0,
    this.isActive = true,
    required this.client,
    required this.provider,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      clientId: json['clientId'],
      providerId: json['providerId'],
      bookingId: json['bookingId'],
      createdAt: DateTime.parse(json['createdAt']),
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      lastMessage: json['lastMessage'] != null 
          ? Message.fromJson(json['lastMessage']) 
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      client: User.fromJson(json['client']),
      provider: User.fromJson(json['provider']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'providerId': providerId,
      'bookingId': bookingId,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'isActive': isActive,
      'client': client.toJson(),
      'provider': provider.toJson(),
    };
  }

  User getOtherUser(String currentUserId) {
    return currentUserId == clientId ? provider : client;
  }

  String getConversationTitle(String currentUserId) {
    final otherUser = getOtherUser(currentUserId);
    return otherUser.fullName;
  }

  String? getConversationAvatar(String currentUserId) {
    final otherUser = getOtherUser(currentUserId);
    return otherUser.profileImage;
  }
}

class TypingIndicator {
  final String conversationId;
  final String userId;
  final DateTime startedAt;

  TypingIndicator({
    required this.conversationId,
    required this.userId,
    required this.startedAt,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      conversationId: json['conversationId'],
      userId: json['userId'],
      startedAt: DateTime.parse(json['startedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'userId': userId,
      'startedAt': startedAt.toIso8601String(),
    };
  }

  bool get isExpired {
    return DateTime.now().difference(startedAt).inSeconds > 5;
  }
}

