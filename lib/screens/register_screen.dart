import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/auth/auth_header.dart';
import '../widgets/auth/auth_input_field.dart';
import '../widgets/auth/auth_submit_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful! Please login."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Register Account", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const AuthHeader(
                title: "Create Account",
                subtitle: "Join Sastra Film and enjoy unlimited streaming",
              ),
              AuthInputField(
                controller: _nameController,
                labelText: "Name",
                prefixIcon: Icons.person_outline,
                validator: (val) => Validators.required(val, "Name"),
              ),
              AuthInputField(
                controller: _emailController,
                labelText: "Email",
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: Validators.email,
              ),
              AuthInputField(
                controller: _passwordController,
                labelText: "Password",
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: (val) => Validators.password(val, minLength: 6),
              ),
              AuthInputField(
                controller: _confirmPasswordController,
                labelText: "Confirm Password",
                obscureText: true,
                prefixIcon: Icons.lock_reset_outlined,
                validator: (val) => Validators.confirmPassword(val, _passwordController.text),
              ),
              const SizedBox(height: 24),
              AuthSubmitButton(
                label: "Register",
                isLoading: authProvider.isLoading,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: authProvider.isLoading ? null : () => Navigator.pop(context),
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}