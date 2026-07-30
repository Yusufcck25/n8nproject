import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class SessionHomePage extends StatefulWidget {
  const SessionHomePage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<SessionHomePage> createState() => _SessionHomePageState();
}

class _SessionHomePageState extends State<SessionHomePage> {
  final _authService = AuthService();
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _authService.getCurrentUser();
  }

  Future<void> _logout() async {
    await _authService.logout();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Radar'),
        actions: [
          IconButton(
            tooltip: 'Çıkış yap',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 48),
                    const SizedBox(height: 16),
                    const Text('Oturum doğrulanamadı.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        setState(() => _profileFuture = _authService.getCurrentUser());
                      },
                      child: const Text('Tekrar dene'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user_outlined, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    'Merhaba, ${user['fullName'] ?? user['email']}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Oturumunuz güvenli şekilde doğrulandı.'),
                  const SizedBox(height: 24),
                  const Text('Radar ekranı bir sonraki aşamada eklenecek.'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
