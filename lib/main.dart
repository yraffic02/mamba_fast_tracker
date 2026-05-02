import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/services/notification_service.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/fasting_viewmodel.dart';
import 'presentation/viewmodels/meal_viewmodel.dart';
import 'presentation/views/auth_view.dart';
import 'presentation/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    log(e.toString());
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => FastingViewModel()),
        ChangeNotifierProvider(create: (_) => MealViewModel()),
      ],
      child: MaterialApp(
        title: 'Mamba Fast Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final isLoggedIn = await authViewModel.checkSession();

    if (!mounted) return;

    // Teste de notificação imediata
    await NotificationService.instance.showNotification(
      'App Iniciado',
      'Teste de notificação imediata',
    );

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
