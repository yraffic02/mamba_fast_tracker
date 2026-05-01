import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Entrar')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                if (viewModel.errorMessage != null)
                  Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                if (viewModel.isLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final success = await viewModel.login(
                            _emailController.text,
                            _passwordController.text,
                          );
                          if (success && context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeView(),
                              ),
                            );
                          }
                        },
                        child: const Text('Entrar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterView(),
                            ),
                          );
                        },
                        child: const Text('Não tem uma conta? Cadastre-se'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Cadastrar')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                if (viewModel.errorMessage != null)
                  Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                if (viewModel.isLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final success = await viewModel.register(
                            _emailController.text,
                            _passwordController.text,
                          );
                          if (success && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Cadastrar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Já tem uma conta? Entrar'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
