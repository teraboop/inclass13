import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../authservice.dart';

class ProfileScreen extends StatelessWidget {
    const ProfileScreen({super.key});

    Future<void> _showResetPasswordDialog(
        BuildContext context,
        AuthService authService,
    ) async {
        final controller = TextEditingController();
        final formKey = GlobalKey<FormState>();

        final newPassword = await showDialog<String>(
            context: context,
            builder: (dialogContext) {
                return AlertDialog(
                    title: const Text('Reset Password'),
                    content: Form(
                        key: formKey,
                        child: TextFormField(
                            controller: controller,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: 'New password'),
                            validator: (value) {
                                if (value == null || value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                }
                                return null;
                            },
                        ),
                    ),
                    actions: [
                        TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Cancel'),
                        ),
                        TextButton(
                            onPressed: () {
                                if (formKey.currentState!.validate()) {
                                    Navigator.of(dialogContext).pop(controller.text);
                                }
                            },
                            child: const Text('Submit'),
                        ),
                    ],
                );
            },
        );

        if (newPassword == null) return;

        try {
            await authService.changePassword(newPassword);
            if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password updated successfully')),
                );
            }
        } on FirebaseAuthException catch (e) {
            if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message ?? 'Failed to update password')),
                );
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        final authService = AuthService();
        final email = authService.currentUser?.email ?? 'Unknown user';

        return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Center(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Text(email, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: () => _showResetPasswordDialog(context, authService),
                            child: const Text('Reset Password'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                            onPressed: () => authService.signOut(),
                            child: const Text('Log out'),
                        ),
                    ],
                ),
            ),
        );
    }
}