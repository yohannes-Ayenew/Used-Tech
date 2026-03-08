// lib/features/inbox/domain/repositories/chat_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ConversationEntity>>> getConversations();
  Future<Either<Failure, List<MessageEntity>>> getChatHistory(String conversationId, {int page = 1});
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String receiverId,
    String? productId,
    required String message,
    String type = 'text',
  });
  Future<Either<Failure, void>> updateFcmToken(String token);
}
