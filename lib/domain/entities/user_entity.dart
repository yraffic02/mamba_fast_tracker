class UserEntity {
  final int? id;
  final String email;
  final String password;
  final DateTime createdAt;

  UserEntity({
    this.id,
    required this.email,
    required this.password,
    required this.createdAt,
  });
}
