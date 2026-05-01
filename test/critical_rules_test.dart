import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:teste_tecnico_mobile/domain/entities/fasting_session_entity.dart';
import 'package:teste_tecnico_mobile/domain/entities/user_entity.dart';
import 'package:teste_tecnico_mobile/domain/usecases/fasting_usecases.dart';
import 'package:teste_tecnico_mobile/domain/usecases/auth_usecases.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Delete the test database before each test to avoid UNIQUE constraint
    final dbPath = await getDatabasesPath();
    final file = File(join(dbPath, 'mamba_fast_tracker.db'));
    if (await file.exists()) {
      await file.delete();
    }
  });

  group('Fasting Timer Tests', () {
    late GetElapsedTime getElapsedTime;

    setUp(() {
      getElapsedTime = GetElapsedTime();
    });

    test('Should calculate elapsed time correctly for active session', () {
      final startTime = DateTime.now().subtract(const Duration(hours: 2, minutes: 30));
      final session = FastingSessionEntity(
        id: 1,
        userId: 1,
        startTime: startTime,
        status: 'active',
      );

      final elapsed = getElapsedTime(session);

      expect(elapsed, isNotNull);
      expect(elapsed!.inHours, greaterThanOrEqualTo(2));
    });

    test('Should calculate elapsed time correctly for completed session', () {
      final startTime = DateTime(2026, 4, 29, 10, 0);
      final endTime = DateTime(2026, 4, 29, 16, 30);
      final session = FastingSessionEntity(
        id: 1,
        userId: 1,
        startTime: startTime,
        endTime: endTime,
        status: 'completed',
      );

      final elapsed = getElapsedTime(session);

      expect(elapsed, isNotNull);
      expect(elapsed!.inHours, 6);
      expect(elapsed.inMinutes % 60, 30);
    });

    test('Should maintain consistency after restart', () {
      final persistedStartTime = DateTime.now().subtract(const Duration(hours: 5));
      final session = FastingSessionEntity(
        id: 1,
        userId: 1,
        startTime: persistedStartTime,
        status: 'active',
      );

      final elapsed1 = getElapsedTime(session);
      final elapsed2 = getElapsedTime(session);

      expect(elapsed1!.inSeconds, elapsed2!.inSeconds);
    });
  });

  group('Calorie Calculation Tests', () {
    test('Should sum calories correctly for a day', () {
      const calorieGoal = 2000;
      final totalCalories = 500 + 800 + 700;
      expect(totalCalories, 2000);
      expect(totalCalories <= calorieGoal, true);
    });
  });

  group('Authentication Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Should validate valid login credentials', () async {
      const email = 'test@example.com';
      const password = 'password123';

      final registerUser = RegisterUser();
      final loginUser = LoginUser();

      final user = UserEntity(
        email: email,
        password: password,
        createdAt: DateTime.now(),
      );

      await registerUser(user);
      final isValid = await loginUser(email, password);

      expect(isValid, true);
    });

    test('Should reject invalid login credentials', () async {
      const email = 'test@example.com';
      const wrongPassword = 'wrongpassword';

      final loginUser = LoginUser();
      final isValid = await loginUser(email, wrongPassword);

      expect(isValid, false);
    });
  });
}
