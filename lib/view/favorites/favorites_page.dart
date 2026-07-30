import 'package:flutter/material.dart';

import '../../models/user_favorite.dart';
import '../../services/favorite_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _favoriteService = FavoriteService();
  late Future<List<UserFavorite>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _favoriteService.getFavorites();
  }

  Future<void> _reload() async {
    setState(() => _favoritesFuture = _favoriteService.getFavorites());
    await _favoritesFuture;
  }

  Future<void> _remove(UserFavorite favorite) async {
    final success = await _favoriteService.removeFavorite(favorite.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Favorilerden kaldırıldı.' : 'Favori silinemedi.')),
    );
    if (success) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorilerim')),
      body: FutureBuilder<List<UserFavorite>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return _buildErrorState();

          final favorites = snapshot.data ?? [];
          if (favorites.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildFavoriteCard(favorites[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(UserFavorite favorite) {
    final radar = favorite.radarData;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Color(0xFFDC2626)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    radar?.sourceName.isNotEmpty == true ? radar!.sourceName : 'Favori fırsat',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Favorilerden kaldır',
                  onPressed: () => _remove(favorite),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(radar?.title ?? 'Fırsat bilgisi bulunamadı', style: Theme.of(context).textTheme.titleMedium),
            if (radar != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text(radar.country)),
                  Chip(label: Text(radar.category)),
                  if (radar.opportunityScore != null)
                    Chip(label: Text('${radar.opportunityScore!.toStringAsFixed(0)} puan')),
                ],
              ),
            ],
            if (favorite.note != null && favorite.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Not: ${favorite.note}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 56),
            SizedBox(height: 16),
            Text('Henüz favori fırsatınız yok.'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: OutlinedButton.icon(
        onPressed: _reload,
        icon: const Icon(Icons.refresh),
        label: const Text('Favorileri tekrar yükle'),
      ),
    );
  }
}
