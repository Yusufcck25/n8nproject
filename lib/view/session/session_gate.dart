import 'package:flutter/material.dart';

import '../../core/utils/storage_service.dart';
import '../auth/auth_page.dart';
import '../radar/radar_page.dart';

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  final _storageService = StorageService();
  bool? _hasSession;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final token = await _storageService.getToken();
    if (mounted) setState(() => _hasSession = token != null && token.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSession == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _hasSession!
        ? RadarPage(onLogout: () => setState(() => _hasSession = false))
        : AuthPage(onAuthenticated: () => setState(() => _hasSession = true));
  }
}
