// lib/features/inbox/data/repositories/chat_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations() async {
    try {
      final result = await remoteDataSource.getConversations();
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getChatHistory(String conversationId, {int page = 1}) async {
    try {
      final result = await remoteDataSource.getChatHistory(conversationId, page: page);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String receiverId,
    String? productId,
    required String message,
    String type = 'text',
  }) async {
    try {
      final result = await remoteDataSource.sendMessage(
        receiverId: receiverId,
        productId: productId,
        message: message,
        type: type,
      );
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateFcmToken(String token) async {
    try {
      await remoteDataSource.updateFcmToken(token);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
