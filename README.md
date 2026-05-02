# Mamba Fast Tracker

Aplicativo mobile para controle de jejum intermitente e registro de calorias, desenvolvido em Flutter como um produto pronto para produção.

## Como rodar o projeto

### Pré-requisitos
- Flutter 3.38.0 (stable)
- Dart SDK ^3.10.0
- Java 17 (para build Android)
- Android Studio / VS Code com plugins Flutter

### Passo a passo
```bash
# Clone o repositório
git clone https://github.com/yraffic02/mamba_fast_tracker.git
cd mamba_fast_tracker

# Instale as dependências
flutter pub get

# Execute o analisador
flutter analyze

# Rode os testes
flutter test

# Execute no emulador/dispositivo
flutter run

# Build de release para Android
flutter build apk --release
```

## Stack escolhida

- **Framework:** Flutter 3.38.0 (Dart)
- **Arquitetura:** MVVM (Model-View-ViewModel) com Provider
- **Persistência:** SQLite (sqflite) + SharedPreferences
- **Gráficos:** fl_chart
- **Notificações:** flutter_local_notifications + timezone
- **ORM/Database:** SQFlite com repositórios e datasources

## Arquitetura utilizada

```
lib/
├── core/
│   ├── database/          # DatabaseHelper (SQLite)
│   ├── services/         # NotificationService, SessionService
│   └── utils/
├── data/
│   ├── datasources/      # FastingDataSource, MealDataSource, UserDataSource
│   ├── models/           # FastingSessionModel, MealModel, UserModel
│   └── repositories/     # Repositórios que isolam a camada de dados
├── domain/
│   ├── entities/         # FastingSessionEntity, MealEntity, UserEntity
│   └── usecases/         # Casos de uso (StartFasting, GetMeals, etc.)
└── presentation/
    ├── views/             # Screens (HomeView, LoginView, SettingsView, etc.)
    ├── viewmodels/        # ViewModels (FastingViewModel, MealViewModel)
    └── widgets/           # FastingChart, CaloriesChart
```

### Padrões importantes
- **MVVM:** Views observam ViewModels via Provider/Consumer
- **Repository Pattern:** Camada intermediária entre usecases e datasources
- **Offline-first:** SQLite é a fonte da verdade
- **Estado de timer:** Calculado a partir de timestamps persistidos, nunca em memória

## Decisões técnicas

1. **SQLite como fonte única da verdade**
   - Todos os timestamps armazenados como strings ISO 8601
   - Timer recalcula tempo decorrido lendo do banco
   - App pode ser fechado e reaberto sem perda de estado

2. **Protocolos de jejum configuráveis**
   - 12:12, 16:8, 18:6, 20:4, 24h, OMAD
   - Horário de início agendado (data + hora)
   - Impede início sem horário definido

3. **Notificações agendadas (4 eventos)**
   - 5 minutos antes de começar
   - Na hora de começar
   - 5 minutos antes de terminar
   - Na hora de terminar

4. **Timer em tempo real**
   - Timer.periodic de 1 segundo no ViewModel
   - Atualiza UI com tempo decorrido, restante e progresso
   - Notifica quando meta é atingida

5. **Status de meta (dentro/fora)**
   - Margem de tolerância: 3 minutos
   - Verde (dentro): Iniciou no horário ou finalizou com tempo exato
   - Amarelo (fora): Atraso > 3min ou não atingiu meta

## Bibliotecas utilizadas

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1           # Gerenciamento de estado
  sqflite: ^2.3.0           # SQLite local
  path: ^1.8.3
  path_provider: ^2.1.1
  shared_preferences: ^2.2.2  # Persistência de configurações
  flutter_local_notifications: ^19.4.0  # Notificações locais
  timezone: ^0.10.1            # Fusos horários para agendamento
  fl_chart: ^0.68.0           # Gráficos
  intl: ^0.19.0               # Formatação de datas
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mockito: ^5.4.4
  build_runner: ^2.4.8
  sqflite_common_ffi: ^2.3.0  # Para testes
```

## Trade-offs considerados

1. **Provider vs BLoC/Redux**
   - Escolhido Provider: simplicidade e rapidez de implementação
   - BLoC seria melhor para apps muito complexos, mas overhead desnecessário aqui

2. **SQLite vs Hive/SharedPreferences**
   - SQLite: estruturado, suporta queries complexas, ideal para histórico
   - Alternativas (Hive) seriam mais rápidas, mas menos flexíveis para relatórios

3. **flutter_local_notifications vs Firebase Cloud Messaging**
   - Local: suficiente para necessidades atuais (offline-first)
   - Firebase seria necessário apenas para notificações push remotas

4. **Timer.periodic vs Stream/Isolate**
   - Timer.periodic: simples e suficiente para atualização de UI
   - Stream seria overkill para um timer de 1 segundo

5. **workmanager desabilitado**
   - build issues no Android
   - Solução atual (agendamento via timezone) funciona bem para o propósito

## O que melhoraria com mais tempo

1. **Testes abrangentes**
   - Widget tests para toda a UI
   - Integration tests com `integration_test`
   - Aumentar cobertura de usecases e repositórios

2. **Widgets personalizados**
   - UI mais polida (animations, transições)
   - Temas claro/escuro automático
   - Material 3 completo

3. **Recuperação de senha**
   - Atualmente apenas auth local
   - Implementar reset de senha (se fosse Firebase)

4. **Sincronização em nuvem**
   - Repositórios preparados para trocar SQLite por API
   - Implementar cache local + sync

5. **Mais protocolos e personalização**
   - Protocolos customizados pelo usuário
   - Lembretes personalizados

6. **CI/CD melhorado**
   - Build automático para iOS
   - Deploy automático para stores (Fastlane)
   - Testes de integração no pipeline

## Tempo gasto no desafio

- **Dia 1 (4h):** Setup inicial, arquitetura base, autenticação
- **Dia 2 (6h):** Timer de jejum, protocolos, notificações
- **Dia 3 (5h):** Refeições, histórico, gráficos, UI
- **Dia 4 (3h):** Testes, correções, CI/CD, documentação, refinamento

**Total:** ~18 horas

## Build Android

O pipeline CI/CD gera automaticamente o APK em modo release:
- Push para `main` → Executa testes → Build APK → Upload como artifact
- APK gerado: `build/app/outputs/flutter-apk/app-release.apk`
