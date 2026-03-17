// lib/features/inbox/data/datasources/chat_remote_data_source.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationModel>> getConversations();
  Future<List<MessageModel>> getChatHistory(String conversationId, {int page = 1, String? productId});
  Future<MessageModel> sendMessage({
    required String receiverId,
    String? productId,
    required String message,
    String type = 'text',
    String? tempId,
  });
  Future<void> updateFcmToken(String token);
  Future<void> deleteConversation(String conversationId);
  Future<void> markAsRead(String conversationId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  ChatRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
  });

  String? get _token => sharedPreferences.getString('CACHED_TOKEN');

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  @override
  Future<List<ConversationModel>> getConversations() async {
    final response = await client.get(
      Uri.parse(ApiEndpoints.getConversations),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List data = jsonResponse['data'] ?? [];
      return data.map((json) => ConversationModel.fromJson(json)).toList();
    } else {
      throw ServerException('Failed to load conversations: ${response.statusCode}');
    }
  }

  @override
  Future<List<MessageModel>> getChatHistory(String conversationId, {int page = 1, String? productId}) async {
    final baseUrl = ApiEndpoints.getChatHistory(conversationId);
    final url = productId != null 
      ? '$baseUrl?page=$page&productId=$productId' 
      : '$baseUrl?page=$page';

    final response = await client.get(
      Uri.parse(url),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List data = jsonResponse['data'] ?? [];
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw ServerException('Failed to load chat history: ${response.statusCode}');
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String receiverId,
    String? productId,
    required String message,
    String type = 'text',
    String? tempId,
  }) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.sendMessage),
      headers: _headers,
      body: json.encode({
        'receiverId': receiverId,
        'productId': productId,
        'message': message,
        'type': type,
        'tempId': tempId,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return MessageModel.fromJson(jsonResponse['data']);
    } else {
      throw ServerException('Failed to send message: ${response.statusCode}');
    }
  }

  @override
  Future<void> updateFcmToken(String token) async {
    final response = await client.patch(
      Uri.parse(ApiEndpoints.updateFcmToken),
      headers: _headers,
      body: json.encode({'fcmToken': token}),
    );

    if (response.statusCode != 200) {
      throw ServerException('Failed to update FCM token: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    final response = await client.delete(
      Uri.parse(ApiEndpoints.deleteConversation(conversationId)),
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ServerException('Failed to delete conversation: ${response.statusCode}');
    }
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.markAsRead(conversationId)),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw ServerException('Failed to mark as read: ${response.statusCode}');
    }
  }
}
