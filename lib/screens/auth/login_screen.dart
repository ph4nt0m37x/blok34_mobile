import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;

  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  void login() async {
    setState(() => loading = true);

    final success = await widget.authService.login(
      emailController.text,
      passwordController.text,
    );

    setState(() => loading = false);

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Login", style: TextStyle(fontSize: 28)),
              const SizedBox(height: 20),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),

              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : login,
                child: Text(loading ? "Loading..." : "Login"),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SignupScreen(authService: widget.authService),
                    ),
                  );
                },
                child: const Text("Go to Signup"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}