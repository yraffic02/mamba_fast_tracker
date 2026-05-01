# Tasks - Mamba Fast Tracker

## Pendências Identificadas

### 1. Timer de Jejum em Tempo Real
**Status:** Pendente
**Descrição:** O timer não atualiza em tempo real quando o usuário está dentro do app. O `elapsedTime` no `FastingViewModel` é calculado uma vez e não atualiza automaticamente.
**O que fazer:**
- Implementar um `Timer.periodic` no `FastingViewModel` que atualiza o `elapsedTime` a cada segundo quando há uma sessão ativa
- Fazer o `notifyListeners()` periódico para reconstruir a UI
- Limpar o timer no `dispose()`
**Branch:** `feature/realtime-fasting-timer`

### 2. Protocolos de Jejum
**Status:** Pendente
**Descrição:** Não existem protocolos de jejum (16:8, 18:6, OMAD, etc.) com metas configuráveis.
**O que fazer:**
- Criar modelo `FastingProtocol` com tipos predefinidos (16:8, 18:6, 20:4, 24h, OMAD)
- Armazenar protocolo selecionado nas `settings`
- Mostrar meta de tempo no timer
- Notificar quando atingir a meta
**Branch:** `feature/fasting-protocols`

### 3. Notificações Agendadas
**Status:** Pendente
**Descrição:** O `NotificationService` só envia notificações imediatas. Falta agendar notificação para quando o jejum terminar.
**O que fazer:**
- Implementar `zonedSchedule` do `flutter_local_notifications` para agendar notificação de fim de jejum
- Cancelar notificação agendada se o usuário finalizar jejum antes da hora
- Configurar fuso horário correto
**Branch:** `feature/scheduled-notifications`

### 4. Tela de Listagem de Refeições
**Status:** Pendente
**Descrição:** As refeições estão sendo mostradas na Home, mas o usuário quer uma tela dedicada para listagem de comidas.
**O que fazer:**
- Criar `MealsListView` (tela dedicada)
- Adicionar navegação na Home via botão ou tab
- Mostrar lista completa com data/hora
**Branch:** `feature/meals-list-view`

### 5. Editar e Excluir Refeições
**Status:** Pendente
**Descrição:** O app já tem as funções no `MealViewModel` (`updateMeal`, `deleteMeal`), mas não há UI para usar essas funções.
**O que fazer:**
- Adicionar botões de editar/excluir em cada item da lista de refeições
- Criar `EditMealView` (reutilizar `AddMealView` ou criar específica)
- Confirmar exclusão via dialog
- Atualizar lista após editar/excluir
**Branch:** `feature/edit-delete-meals`

### 6. CI/CD Only on Main
**Status:** Pendente
**Descrição:** O pipeline CI/CD atual roda em pushes para `main` e `develop`. Deve rodar apenas quando houver merge para `main`.
**O que fazer:**
- Atualizar `.github/workflows/ci-cd.yml`
- Remover `develop` do trigger de push
- Manter validação de PRs para main
**Branch:** `feature/ci-cd-main-only`

## Ordem Sugerida
1. `feature/realtime-fasting-timer` (base para notificações)
2. `feature/fasting-protocols`
3. `feature/scheduled-notifications`
4. `feature/meals-list-view`
5. `feature/edit-delete-meals`
6. `feature/ci-cd-main-only`
