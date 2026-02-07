import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token; // We store the JWT here for now

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  @override
  List<Object?> get props => [id, email, role];
}
