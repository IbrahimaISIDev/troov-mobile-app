import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:troov_app/models/message.dart';
import 'auth_service.dart';

class ChatService {
  static const String baseUrl = 'https://troov.api.com';
  final AuthService _authService = AuthService();

  // Obtenir toutes les conversations
  Future<List<Conversation>> getConversations() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.get(
        Uri.parse('$baseUrl/chat/conversations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['conversations'] as List)
            .map((e) => Conversation.fromJson(e))
            .toList();
      } else {
        throw Exception('Erreur de chargement des conversations');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Obtenir les messages d'une conversation
  Future<List<Message>> getMessages(String conversationId, {int page = 1, int limit = 50}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final uri = Uri.parse('$baseUrl/chat/conversations/$conversationId/messages').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['messages'] as List)
            .map((e) => Message.fromJson(e))
            .toList();
      } else {
        throw Exception('Erreur de chargement des messages');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Envoyer un message texte
  Future<Message> sendTextMessage(String conversationId, String content, {String? replyToId}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.post(
        Uri.parse('$baseUrl/chat/conversations/$conversationId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'type': 'text',
          'content': content,
          'replyToId': replyToId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Message.fromJson(data);
      } else {
        throw Exception('Erreur d\'envoi du message');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Envoyer un fichier
  Future<Message> sendFileMessage(String conversationId, String filePath, MessageType type) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/chat/conversations/$conversationId/files'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['type'] = type.toString().split('.').last;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        return Message.fromJson(data);
      } else {
        throw Exception('Erreur d\'envoi du fichier');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Marquer les messages comme lus
  Future<void> markMessagesAsRead(String conversationId, List<String> messageIds) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.patch(
        Uri.parse('$baseUrl/chat/conversations/$conversationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'messageIds': messageIds}),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur de marquage des messages');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Créer une nouvelle conversation
  Future<Conversation> createConversation(String otherUserId, {String? bookingId}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.post(
        Uri.parse('$baseUrl/chat/conversations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'otherUserId': otherUserId,
          'bookingId': bookingId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Conversation.fromJson(data);
      } else {
        throw Exception('Erreur de création de conversation');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Marquer une conversation comme lue
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.patch(
        Uri.parse('$baseUrl/chat/conversations/$conversationId/read-all'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur de marquage de conversation');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Désactiver les notifications d'une conversation
  Future<void> muteConversation(String conversationId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.patch(
        Uri.parse('$baseUrl/chat/conversations/$conversationId/mute'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur de désactivation des notifications');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Archiver une conversation
  Future<void> archiveConversation(String conversationId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.patch(
        Uri.parse('$baseUrl/chat/conversations/$conversationId/archive'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur d\'archivage de conversation');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Supprimer une conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.delete(
        Uri.parse('$baseUrl/chat/conversations/$conversationId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur de suppression de conversation');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Envoyer un indicateur de frappe
  Future<void> sendTypingIndicator(String conversationId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.post(
        Uri.parse('$baseUrl/chat/conversations/$conversationId/typing'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        // Ignorer les erreurs d'indicateur de frappe
      }
    } catch (e) {
      // Ignorer les erreurs d'indicateur de frappe
    }
  }

  // Arrêter l'indicateur de frappe
  Future<void> stopTypingIndicator(String conversationId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.delete(
        Uri.parse('$baseUrl/chat/conversations/$conversationId/typing'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        // Ignorer les erreurs d'indicateur de frappe
      }
    } catch (e) {
      // Ignorer les erreurs d'indicateur de frappe
    }
  }

  // Rechercher dans les messages
  Future<List<Message>> searchMessages(String query, {String? conversationId}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      Map<String, String> params = {'query': query};
      if (conversationId != null) {
        params['conversationId'] = conversationId;
      }

      final uri = Uri.parse('$baseUrl/chat/search').replace(queryParameters: params);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['messages'] as List)
            .map((e) => Message.fromJson(e))
            .toList();
      } else {
        throw Exception('Erreur de recherche');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Obtenir les statistiques de chat
  Future<Map<String, dynamic>> getChatStats() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.get(
        Uri.parse('$baseUrl/chat/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur de chargement des statistiques');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}

