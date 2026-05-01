import '../../data/repositories/user_repository.dart';
import '../../domain/entities/user_entity.dart';

class RegisterUser {
  final UserRepository _repository = UserRepository();

  Future<int> call(UserEntity user) async {
    return await _repository.register(user);
  }
}

class LoginUser {
  final UserRepository _repository = UserRepository();

  Future<bool> call(String email, String password) async {
    return await _repository.login(email, password);
  }
}

class GetUserByEmail {
  final UserRepository _repository = UserRepository();

  Future<UserEntity?> call(String email) async {
    return await _repository.getUserByEmail(email);
  }
}
