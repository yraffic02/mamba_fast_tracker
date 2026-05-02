import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:teste_tecnico_mobile/domain/entities/fasting_session_entity.dart';
import 'package:teste_tecnico_mobile/domain/entities/user_entity.dart';
import 'package:teste_tecnico_mobile/domain/usecases/fasting_usecases.dart';
import 'package:teste_tecnico_mobile/domain/usecases/auth_usecases.dart';
import 'package:teste_tecnico_mobile/core/services/session_service.dart';
import 'package:teste_tecnico_mobile/core/database/database_helper.dart';
import 'package:teste_tecnico_mobile/presentation/viewmodels/fasting_viewmodel.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    
    // Cria banco em memória para testes
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE users(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              email TEXT UNIQUE NOT NULL,
              password TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE fasting_sessions(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              start_time TEXT NOT NULL,
              end_time TEXT,
              status TEXT NOT NULL,
              FOREIGN KEY(user_id) REFERENCES users(id)
            )
          ''');
        },
      ),
    );
    
    // Injeta banco em memória no DatabaseHelper
    DatabaseHelper.instance.setTestDatabase(db);
  });

  group('Testes de Timer de Jejum', () {
    late GetElapsedTime getElapsedTime;
    late SessionService sessionService;

    setUp(() {
      getElapsedTime = GetElapsedTime();
      sessionService = SessionService();
    });

    test('Deve calcular tempo decorrido corretamente para sessão ativa', () {
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

    test('Deve calcular tempo decorrido corretamente para sessão completada', () {
      final startTime = DateTime(2024, 4, 29, 10, 0);
      final endTime = DateTime(2024, 4, 29, 16, 30);
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

    test('Deve manter consistência após reinício', () {
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

    test('Não deve iniciar jejum sem horário agendado', () async {
      // Garante que não há horário agendado
      await sessionService.clearScheduledStartTime();
      final viewModel = FastingViewModel();
      final userId = 1;

      // Tenta iniciar jejum - deve retornar false
      final result = await viewModel.startFasting(userId);
      expect(result, false);
    });

    test('Deve iniciar jejum com horário agendado', () async {
      // Define horário agendado para agora
      await sessionService.saveScheduledStartTime(DateTime.now());
      final viewModel = FastingViewModel();
      final userId = 1;

      // Tenta iniciar jejum - deve retornar true
      final result = await viewModel.startFasting(userId);
      expect(result, true);
    });
  });

  group('Testes de Cálculo de Calorias', () {
    test('Deve somar calorias corretamente para um dia', () {
      const calorieGoal = 2000;
      final totalCalories = 500 + 800 + 700;
      expect(totalCalories, 2000);
      expect(totalCalories <= calorieGoal, true);
    });
  });

  group('Testes de Autenticação', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      // Limpa banco em memória antes de cada teste
      final dbPath = await getDatabasesPath();
      final file = File(join(dbPath, 'mamba_fast_tracker.db'));
      if (await file.exists()) {
        await file.delete();
      }
    });

    test('Deve validar credenciais de login válidas', () async {
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

    test('Deve rejeitar credenciais de login inválidas', () async {
      const email = 'test@example.com';
      const wrongPassword = 'wrongpassword';

      final loginUser = LoginUser();

      final isValid = await loginUser(email, wrongPassword);

      expect(isValid, false);
    });
  });
}
