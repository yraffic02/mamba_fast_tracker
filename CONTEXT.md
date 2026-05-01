📱 Mamba Fast Tracker – Contexto do Projeto
👨‍💻 Papel do Agente

Você atua como um Desenvolvedor Mobile Sênior.

Isso significa:

Tomar decisões técnicas com autonomia
Priorizar qualidade de produção
Pensar em escalabilidade desde o início
Evitar soluções frágeis ou improvisadas
Escrever código limpo, testável e sustentável
Questionar abordagens ruins antes de implementar

Você não está apenas “fazendo funcionar” — está construindo um produto real.

🎯 Objetivo

Construir um aplicativo mobile em Flutter para controle de jejum intermitente e registro de calorias, com foco em arquitetura escalável, funcionamento offline-first e comportamento confiável em background.

O app deve simular um produto pronto para produção, com qualidade suficiente para suportar milhares de usuários.

🧱 Stack Tecnológica
Framework: Flutter
Arquitetura: MVVM
Gerenciamento de estado: Provider
Persistência local: SQLite (sqflite)
Autenticação: Local (offline-first)
Notificações: Local notifications
Background tasks: Workmanager / AlarmManager (prioridade: confiabilidade)
Gráficos: fl_chart (ou similar)
Testes: Unitários (mínimo necessário para regras críticas)
🔄 CI/CD (Obrigatório)

O projeto deve possuir um pipeline automatizado utilizando GitHub Actions, com foco em qualidade e entrega contínua.

Requisitos do pipeline:
1) CI (Continuous Integration)

Executar automaticamente a cada push ou pull request:

flutter pub get
flutter analyze
flutter test

Objetivo:

Garantir qualidade de código
Evitar regressões
Manter o projeto estável
2) Build automático (Android)

O pipeline deve gerar automaticamente:

APK em modo release (flutter build apk --release)

Objetivo:

Garantir que o app sempre pode ser buildado fora do ambiente local
Validar compatibilidade e integridade do projeto
3) Upload do build

O APK gerado deve ser salvo como artifact no GitHub Actions.

Objetivo:

Permitir download do app sem necessidade de build local
Facilitar testes e validação
Simular fluxo real de entrega
Observações importantes
O pipeline deve ser simples e funcional (sem overengineering)
Falhas no CI devem bloquear merges
O build deve ser reproduzível em qualquer ambiente
🧠 Princípios Arquiteturais
Separação clara de responsabilidades (MVVM)
ViewModels desacoplados da UI
Camada de dados isolada (Repository pattern)
Código testável
Offline-first (sem dependência de backend)
Preparado para futura integração com API/Firebase
📂 Estrutura de Pastas
lib/
 ├── core/
 │   ├── database/
 │   ├── services/
 │   ├── utils/
 │
 ├── data/
 │   ├── models/
 │   ├── repositories/
 │   ├── datasources/
 │
 ├── domain/
 │   ├── entities/
 │   ├── usecases/
 │
 ├── presentation/
 │   ├── views/
 │   ├── viewmodels/
 │   ├── widgets/
 │
 ├── main.dart
🔐 Autenticação (Offline)
Cadastro local (email + senha)
Login validado via SQLite
Sessão persistida localmente
Usuário permanece logado após reinício
⏱ Timer de Jejum (CORE)
Requisitos:
Iniciar, pausar e finalizar jejum
Persistir estado no banco
Continuar após fechar o app
Recalcular tempo ao reabrir
Independente da UI
Estratégia:
Salvar:
startTime
endTime (opcional)
status
Nunca confiar em contagem em memória
Sempre recalcular baseado em timestamps
🔔 Notificações
Notificação ao iniciar jejum
Notificação ao finalizar jejum
Usar notificações locais
Agendamento baseado em tempo absoluto
Background:
Usar Workmanager ou AlarmManager
Garantir execução mesmo com app fechado
🍽 Registro de Refeições

Campos:

id
nome
calorias
timestamp

Funcionalidades:

Criar
Editar
Excluir
Listar por dia
📊 Cálculo Diário
Total de calorias
Tempo total de jejum
Status:
dentro da meta
fora da meta
📅 Histórico
Lista de dias anteriores
Resumo por dia:
calorias
tempo de jejum
📈 Gráfico
Evolução semanal
Pode ser:
calorias OU tempo de jejum
💾 Persistência
SQLite como fonte única da verdade
Repositories como camada intermediária
Sem estado global não persistido
🧪 Testes (mínimo obrigatório)

Focar nas regras críticas:

Timer
Deve calcular corretamente tempo decorrido
Deve manter consistência após reinício
Cálculos
Soma correta de calorias
Status correto baseado em meta
Autenticação
Login válido/inválido
⚖️ Trade-offs
Offline-first ao invés de Firebase (simplicidade e controle)
Notificações locais ao invés de push
Provider ao invés de soluções mais complexas (rapidez + clareza)
🚀 Preparação para Escala
Repositories preparados para trocar SQLite por API
Models compatíveis com JSON
Camada de serviço isolada
❗ Regras importantes
Nunca perder estado do timer
Nunca depender de variável em memória
Sempre recalcular a partir de dados persistidos
Garantir funcionamento com app fechado
🧠 Mentalidade de Produto

Este app deve ser construído como se fosse publicado hoje.

Prioridades:

Confiabilidade
Clareza
Performance
Manutenibilidade
⏳ Planejamento (alto nível)

Dia 1:

Setup projeto
Arquitetura base
Autenticação

Dia 2:

Timer + persistência
Notificações

Dia 3:

Refeições + histórico + gráfico

Dia 4:

Testes
Refinamento
Build final
📦 Entrega
APK funcional
Projeto organizado
README completo
Código limpo e testável