import 'package:flutter/material.dart';
import 'package:blok34_mobile/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:blok34_mobile/providers/auth_state_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  Future<void> _register() async {
    // Validate input
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your name';
      });
      return;
    }

    if (_usernameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a username';
      });
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return;
    }

    if (!_emailController.text.contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a password';
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.register(
        _nameController.text.trim(),
        _usernameController.text.trim().toLowerCase(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (result == "Success!") {
        await context.read<AuthStateProvider>().loadCurrentUser();

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        setState(() {
          _errorMessage = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F1A),
              Color(0xFF1A1A3E),
              Color(0xFF2D1B69),
              Color(0xFF4A0E4E),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo with bubbles
                    Column(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 60,
                          child: CustomPaint(
                            painter: RegisterLogoPainter(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "blok34",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Hero Text - Centered
                    const Text(
                      "Skopje is happening.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Are you?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan.shade300,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Join the community and never miss an event in Skopje.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Error Message
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade300, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade300,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Form Fields - Centered with max width
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        children: [
                          _buildInputField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            hint: 'John Doe',
                          ),
                          const SizedBox(height: 16),

                          _buildInputField(
                            controller: _usernameController,
                            label: 'Username',
                            icon: Icons.alternate_email,
                            hint: 'johndoe',
                          ),
                          const SizedBox(height: 16),

                          _buildInputField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            hint: 'john@example.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          _buildInputField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            hint: '••••••••',
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildInputField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            icon: Icons.lock_outline,
                            hint: '••••••••',
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Register Button - Centered with max width
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: _isLoading ? null : _register,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.cyan.shade400.withValues(alpha: 0.2),
                                Colors.purple.shade400.withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.cyan.shade400.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Center(
                            child: _isLoading
                                ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.cyan.shade300,
                              ),
                            )
                                : Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.cyan.shade200,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              color: Colors.cyan.shade300,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.6)),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

// Custom painter for register logo
class RegisterLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gradient1 = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [Color(0xFF4B0082), Color(0xFF6a0dad)],
    );

    final rect1 = Rect.fromLTWH(15, 12, 25, 40);
    final rect1Paint = Paint()..shader = gradient1.createShader(rect1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect1, const Radius.circular(4)),
      rect1Paint,
    );

    final rect2Paint = Paint()..color = const Color(0xFF5D3FD3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(40, 20, 20, 32),
        const Radius.circular(3),
      ),
      rect2Paint,
    );

    final rect3Paint = Paint()..color = const Color(0xFF4B0082);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(60, 28, 15, 24),
        const Radius.circular(2),
      ),
      rect3Paint,
    );

    final purplePaint1 = Paint()..color = const Color(0xFF4B0082);
    final purplePaint2 = Paint()..color = const Color(0xFF5D3FD3);
    final purplePaint3 = Paint()..color = const Color(0xFF6a0dad);

    canvas.drawCircle(const Offset(25, 22), 4, purplePaint1);
    canvas.drawCircle(const Offset(38, 18), 4, purplePaint2);
    canvas.drawCircle(const Offset(52, 25), 4, purplePaint3);
    canvas.drawCircle(const Offset(68, 28), 4, purplePaint1);
    canvas.drawCircle(const Offset(82, 22), 4, purplePaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}