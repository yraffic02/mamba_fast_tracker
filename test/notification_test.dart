import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz_init;
import 'package:timezone/timezone.dart' as tz;
import 'package:teste_tecnico_mobile/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz_init.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

  await NotificationService.instance.initialize();

  // Teste 1: Notificação imediata
  await NotificationService.instance.showNotification(
    'Teste Imediato',
    'Esta notificação deve aparecer agora',
  );
  print('Teste 1: Notificação imediata enviada');

  // Teste 2: Notificação agendada para 2 minutos à frente
  final scheduled = DateTime.now().add(const Duration(minutes: 2));
  await NotificationService.instance.scheduleOneTimeNotification(
    id: 1,
    title: 'Teste Agendado',
    body: 'Esta notificação deve aparecer em 2 minutos',
    scheduledDate: scheduled,
  );
  print('Teste 2: Notificação agendada para $scheduled');

  // Teste 3: Notificação diária às 22:33
  await NotificationService.instance.scheduleDailyNotification(
    id: 2,
    title: 'Teste Diário',
    body: 'Esta notificação deve aparecer todos os dias às 22:33',
    hour: 22,
    minute: 33,
  );
  print('Teste 3: Notificação diária agendada para 22:33');

  int testId = 100;
  
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Verifique as notificações!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await NotificationService.instance.showNotification(
                  'Teste Botão',
                  'Notificação via botão',
                );
              },
              child: const Text('Enviar Notificação Agora'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await NotificationService.instance.cancelAllNotifications();
                print('Todas as notificações canceladas');
              },
              child: const Text('Cancelar Todas'),
            ),
          ],
        ),
      ),
    ),
  ));
}
