import '../../domain/entities/user_entity.dart';

class UserModel {
  final int? id;
  final String email;
  final String password;
  final String createdAt;

  UserModel({
    this.id,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      password: entity.password,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      password: password,
      createdAt: DateTime.parse(createdAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'created_at': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      createdAt: map['created_at'],
    );
  }
}
