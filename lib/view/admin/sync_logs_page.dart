import 'package:flutter/material.dart';

import '../../models/sync_log.dart';
import '../../services/sync_log_service.dart';

class SyncLogsPage extends StatefulWidget {
  const SyncLogsPage({super.key});

  @override
  State<SyncLogsPage> createState() => _SyncLogsPageState();
}

class _SyncLogsPageState extends State<SyncLogsPage> {
  final _syncLogService = SyncLogService();
  int _count = 20;
  late Future<List<SyncLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = _syncLogService.getLogs(_count);
  }

  Future<void> _reload() async {
    setState(() => _logsFuture = _syncLogService.getLogs(_count));
    await _logsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Senkronizasyon logları'),
        actions: [
          IconButton(tooltip: 'Yenile', onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Expanded(child: Text('Gösterilecek son kayıt sayısı')),
                DropdownButton<int>(
                  value: _count,
                  items: const [10, 20, 50, 100]
                      .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _count = value;
                      _logsFuture = _syncLogService.getLogs(_count);
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<SyncLog>>(
              future: _logsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.error is AdminAccessDenied) return _buildAccessDenied();
                if (snapshot.hasError) return _buildError();

                final logs = snapshot.data ?? [];
                if (logs.isEmpty) return _buildEmptyState();

                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildLogCard(logs[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(SyncLog log) {
    final statusColor = switch (log.status.toLowerCase()) {
      'success' => const Color(0xFF15803D),
      'failed' => const Color(0xFFB91C1C),
      'running' => const Color(0xFFB45309),
      _ => const Color(0xFF475467),
    };
    final date = '${log.loggedAt.day.toString().padLeft(2, '0')}.${log.loggedAt.month.toString().padLeft(2, '0')}.${log.loggedAt.year} '
        '${log.loggedAt.hour.toString().padLeft(2, '0')}:${log.loggedAt.minute.toString().padLeft(2, '0')}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(log.workflowName, style: Theme.of(context).textTheme.titleMedium)),
                Chip(
                  label: Text(log.status),
                  labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
                  side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 18),
                const SizedBox(width: 6),
                Text('${log.processedCount} kayıt işlendi'),
                const Spacer(),
                const Icon(Icons.schedule_outlined, size: 18),
                const SizedBox(width: 6),
                Text(date),
              ],
            ),
            if (log.errorMessage != null && log.errorMessage!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Hata: ${log.errorMessage}', style: const TextStyle(color: Color(0xFFB91C1C))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccessDenied() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings_outlined, size: 56),
            SizedBox(height: 16),
            Text('Bu ekran yalnızca yönetici kullanıcılar içindir.'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync_disabled_outlined, size: 56),
          SizedBox(height: 16),
          Text('Henüz senkronizasyon kaydı yok.'),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: OutlinedButton.icon(
        onPressed: _reload,
        icon: const Icon(Icons.refresh),
        label: const Text('Logları tekrar yükle'),
      ),
    );
  }
}
