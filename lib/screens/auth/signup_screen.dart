// lib/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  final AuthService authService;

  const SignupScreen({super.key, required this.authService});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  void signup() async {
    setState(() => loading = true);

    final success = await widget.authService.signup(
      emailController.text,
      passwordController.text,
    );

    setState(() => loading = false);

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup failed")),
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
              const Text("Signup", style: TextStyle(fontSize: 28)),
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
                onPressed: loading ? null : signup,
                child: Text(loading ? "Loading..." : "Signup"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}