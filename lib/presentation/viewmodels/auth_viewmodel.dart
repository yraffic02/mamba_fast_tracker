import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../core/services/session_service.dart';

class AuthViewModel extends ChangeNotifier {
  final RegisterUser _registerUser = RegisterUser();
  final LoginUser _loginUser = LoginUser();
  final GetUserByEmail _getUserByEmail = GetUserByEmail();
  final SessionService _sessionService = SessionService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => false;

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final existingUser = await _getUserByEmail(email);
      if (existingUser != null) {
        _errorMessage = 'Email já cadastrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = UserEntity(
        email: email,
        password: password,
        createdAt: DateTime.now(),
      );

      await _registerUser(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Falha no cadastro: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _loginUser(email, password);
      if (success) {
        final user = await _getUserByEmail(email);
        if (user != null) {
          await _sessionService.saveSession(user.id!, user.email);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Email ou senha inválidos';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Falha no login: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _sessionService.clearSession();
    notifyListeners();
  }

  Future<bool> checkSession() async {
    return await _sessionService.isLoggedIn();
  }

  Future<int?> getLoggedUserId() async {
    return await _sessionService.getLoggedUserId();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
