import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return UserModel(
      id: user['_id'] ?? '',
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      role: user['role'] ?? 'USER',
      token: json['token'] ?? '',
    );
  }
}
