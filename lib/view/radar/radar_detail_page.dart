import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/radar_opportunity.dart';
import '../../services/favorite_service.dart';
import '../../services/radar_service.dart';

class RadarDetailPage extends StatefulWidget {
  const RadarDetailPage({super.key, required this.opportunityId});

  final int opportunityId;

  @override
  State<RadarDetailPage> createState() => _RadarDetailPageState();
}

class _RadarDetailPageState extends State<RadarDetailPage> {
  final _radarService = RadarService();
  final _favoriteService = FavoriteService();
  late Future<RadarOpportunity> _opportunityFuture;
  bool _isAddingFavorite = false;

  @override
  void initState() {
    super.initState();
    _opportunityFuture = _radarService.getOpportunityById(widget.opportunityId);
  }

  Future<void> _addFavorite(RadarOpportunity opportunity) async {
    setState(() => _isAddingFavorite = true);
    final success = await _favoriteService.addFavorite(opportunity.id);
    if (!mounted) return;
    setState(() => _isAddingFavorite = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Fırsat favorilerinize eklendi.' : 'Favori eklenemedi.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fırsat detayı')),
      body: FutureBuilder<RadarOpportunity>(
        future: _opportunityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) return _buildErrorState();

          final opportunity = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(opportunity.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(avatar: const Icon(Icons.public, size: 18), label: Text(opportunity.country)),
                  Chip(avatar: const Icon(Icons.category_outlined, size: 18), label: Text(opportunity.category)),
                  Chip(
                    avatar: const Icon(Icons.star_outline, size: 18),
                    label: Text(
                      opportunity.opportunityScore == null
                          ? 'Puan yok'
                          : '${opportunity.opportunityScore!.toStringAsFixed(0)} puan',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailSection(
                icon: Icons.source_outlined,
                title: 'Kaynak',
                child: Text(opportunity.sourceName.isEmpty ? 'Belirtilmemiş' : opportunity.sourceName),
              ),
              const SizedBox(height: 16),
              _DetailSection(
                icon: Icons.schedule_outlined,
                title: 'Kayıt tarihi',
                child: Text(_formatDate(opportunity.createdAt)),
              ),
              const SizedBox(height: 16),
              _DetailSection(
                icon: Icons.data_object_outlined,
                title: 'Ham veri',
                child: SelectableText(_formatRawData(opportunity.rawData)),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isAddingFavorite ? null : () => _addFavorite(opportunity),
                icon: _isAddingFavorite
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.favorite_border),
                label: const Text('Favorilere ekle'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () {
          setState(() => _opportunityFuture = _radarService.getOpportunityById(widget.opportunityId));
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Detayı tekrar yükle'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatRawData(String rawData) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonDecode(rawData));
    } catch (_) {
      return rawData.isEmpty ? 'Veri yok.' : rawData;
    }
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.icon, required this.title, required this.child});

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
