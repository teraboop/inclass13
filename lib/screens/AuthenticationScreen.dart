import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../authservice.dart';

class AuthenticationScreen extends StatefulWidget {
    final AuthService _authService;

    const AuthenticationScreen({super.key, required AuthService authService})
        : this._authService = authService;

    @override
    State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    @override
    void dispose() {
        _emailController.dispose();
        _passwordController.dispose();
        super.dispose();
    }

    bool _isLogin = true;
    bool _loading = false;

    Future<void> _submit() async {
        if (!_formKey.currentState!.validate()) return;
        setState(() => _loading = true);
        try {
            final email = _emailController.text.trim();
            final password = _passwordController.text;
            if (_isLogin) {
                await widget._authService.signIn(email, password);
            } else {
                await widget._authService.register(email, password);
            }
        } on FirebaseAuthException catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message ?? 'Authentication failed')),
            );
        } finally {
            if (mounted) setState(() => _loading = false);
        }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
                child: Column(
                    children: [
                        TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                            validator: (value) {
                                if (value == null || value.isEmpty) return 'Email is required';
                                if (!value.contains('@')) return 'Enter a valid email address';
                                return null;
                            },
                        ),
                        TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                                if (value == null || value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                }
                                return null;
                            },
                        ),
                        ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            child: Text(_isLogin ? 'Sign In' : 'Register'),
                        ),
                        TextButton(
                            onPressed: _loading ? null : () => setState(() => _isLogin = !_isLogin),
                            child: Text(_isLogin
                                ? "Don't have an account? Register"
                                : 'Already have an account? Sign in'),
                        ),
                    ],
                ),
              ),
          ),
        ),
      );
    }
}