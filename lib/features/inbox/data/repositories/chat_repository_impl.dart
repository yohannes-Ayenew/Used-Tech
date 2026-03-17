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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Data processing error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getChatHistory(String conversationId, {int page = 1, String? productId}) async {
    try {
      final result = await remoteDataSource.getChatHistory(conversationId, page: page, productId: productId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Data processing error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String receiverId,
    String? productId,
    required String message,
    String type = 'text',
    String? tempId,
  }) async {
    try {
      final result = await remoteDataSource.sendMessage(
        receiverId: receiverId,
        productId: productId,
        message: message,
        type: type,
        tempId: tempId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Data processing error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateFcmToken(String token) async {
    try {
      await remoteDataSource.updateFcmToken(token);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(String conversationId) async {
    try {
      await remoteDataSource.deleteConversation(conversationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Data processing error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String conversationId) async {
    try {
      await remoteDataSource.markAsRead(conversationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Data processing error: ${e.toString()}'));
    }
  }
}
