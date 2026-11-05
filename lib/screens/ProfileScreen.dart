import 'package:flutter/material.dart';
import '../authservice.dart';

class ProfileScreen extends StatelessWidget {
    const ProfileScreen({super.key});

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
                            onPressed: () => authService.signOut(),
                            child: const Text('Log out'),
                        ),
                    ],
                ),
            ),
        );
    }
}