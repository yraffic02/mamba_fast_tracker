import '../datasources/user_datasource.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

class UserRepository {
  final UserDataSource _dataSource = UserDataSource();

  Future<int> register(UserEntity user) async {
    final userModel = UserModel.fromEntity(user);
    return await _dataSource.insertUser(userModel);
  }

  Future<bool> login(String email, String password) async {
    return await _dataSource.validateUser(email, password);
  }

  Future<UserEntity?> getUserByEmail(String email) async {
    final userModel = await _dataSource.getUserByEmail(email);
    return userModel?.toEntity();
  }
}
