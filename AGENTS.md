# AGENTS.md - Mamba Fast Tracker

## Build & Verificação

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release  # CI usa release, não debug
```

Requisitos: Flutter 3.38.0 (stable), Java 17 (para build Android)

## Arquitetura

MVVM com Provider. Estrutura de `lib/`:

- `core/` - Banco de dados, serviços, utilitários
- `data/` - Modelos, repositórios, datasources (SQLite via sqflite)
- `domain/` - Entidades, casos de uso
- `presentation/` - Views, viewmodels, widgets

Ponto de entrada: `main.dart` → `SplashScreen` → `AuthViewModel.checkSession()` → direciona para `LoginView` ou `HomeView`

## Convenções Principais

- SQLite é a fonte da verdade; nunca confie em estado de timer em memória
- Todos os timestamps armazenados como strings ISO 8601; recalcular tempo decorrido na leitura
- Offline-first: sem dependência de backend, auth local via SQLite + SharedPreferences
- Sessão persistida via `SessionService` (SharedPreferences)
- `flutter_local_notifications` importado mas pode ter problemas de build no Android

## Testes

Testes exigem `sqflite_common_ffi` (veja `test/critical_rules_test.dart`):

```dart
setUpAll(() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
});
```

Regras críticas em `test/critical_rules_test.dart`:
- Timer de jejum: cálculo de tempo decorrido, consistência após reinício
- Matemática de calorias: somas diárias, status de meta
- Auth: login válido/inválido, busca de usuário

Executar teste único: `flutter test test/critical_rules_test.dart`

## Problemas Conhecidos

- Timer de jejum nunca usa `Timer.periodic` na UI; sempre recalcula a partir do timestamp `start_time`
- Schema do DB em `core/database/database_helper.dart`; versão 1, quatro tabelas (users, fasting_sessions, meals, settings)
- `workmanager` comentado no pubspec.yaml devido a problemas de build
- `NotificationService` precisa de `.initialize()` em `main.dart` antes de usar notificações
