import 'package:flutter/material.dart';

import '../../models/radar_opportunity.dart';
import '../../services/auth_service.dart';
import '../../services/favorite_service.dart';
import '../../services/radar_service.dart';
import '../../services/saved_search_service.dart';
import '../admin/sync_logs_page.dart';
import '../favorites/favorites_page.dart';
import '../saved_searches/saved_searches_page.dart';

class RadarPage extends StatefulWidget {
  const RadarPage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> {
  static const _pageSize = 10;

  final _radarService = RadarService();
  final _authService = AuthService();
  final _favoriteService = FavoriteService();
  final _savedSearchService = SavedSearchService();
  final _searchController = TextEditingController();
  final _countryController = TextEditingController();
  final _categoryController = TextEditingController();
  final _scoreController = TextEditingController();
  final _savedSearchNameController = TextEditingController();

  RadarPageResult? _result;
  String? _error;
  bool _isLoading = true;
  bool _isAdmin = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadOpportunities();
    _loadCurrentUserRole();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _countryController.dispose();
    _categoryController.dispose();
    _scoreController.dispose();
    _savedSearchNameController.dispose();
    super.dispose();
  }

  Future<void> _loadOpportunities({int? page}) async {
    final requestedPage = page ?? _currentPage;
    final score = double.tryParse(_scoreController.text.trim());

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _radarService.getOpportunities(
        page: requestedPage,
        pageSize: _pageSize,
        country: _countryController.text,
        category: _categoryController.text,
        searchTerm: _searchController.text,
        minOpportunityScore: score,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _currentPage = result.page;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Fırsatlar yüklenemedi. Bağlantınızı kontrol edip tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearFilters() {
    _searchController.clear();
    _countryController.clear();
    _categoryController.clear();
    _scoreController.clear();
    _currentPage = 1;
    _loadOpportunities(page: 1);
  }

  Future<void> _logout() async {
    await _authService.logout();
    widget.onLogout();
  }

  Future<void> _loadCurrentUserRole() async {
    final user = await _authService.getCurrentUser();
    if (!mounted || user == null) return;
    setState(() => _isAdmin = user['role'] == 'Admin');
  }

  Future<void> _openSyncLogs() async {
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SyncLogsPage()));
  }

  Map<String, dynamic> _currentFilters() {
    return {
      'searchTerm': _searchController.text.trim(),
      'country': _countryController.text.trim(),
      'category': _categoryController.text.trim(),
      'minOpportunityScore': double.tryParse(_scoreController.text.trim()),
    };
  }

  Future<void> _addFavorite(RadarOpportunity opportunity) async {
    final success = await _favoriteService.addFavorite(opportunity.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Fırsat favorilerinize eklendi.' : 'Favori eklenemedi.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openFavorites() async {
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const FavoritesPage()));
  }

  Future<void> _openSavedSearches() async {
    final filters = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const SavedSearchesPage()),
    );
    if (filters == null) return;

    _searchController.text = filters['searchTerm'] as String? ?? '';
    _countryController.text = filters['country'] as String? ?? '';
    _categoryController.text = filters['category'] as String? ?? '';
    _scoreController.text = filters['minOpportunityScore']?.toString() ?? '';
    _loadOpportunities(page: 1);
  }

  Future<void> _saveCurrentSearch() async {
    final filters = _currentFilters();
    final hasActiveFilter = filters.values.any(
      (value) => value != null && value.toString().trim().isNotEmpty,
    );
    if (!hasActiveFilter) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kaydetmek için en az bir arama kriteri girin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final name = _savedSearchNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıtlı arama için bir ad girin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await _savedSearchService.saveSearch(name, filters);
    if (!mounted) return;
    if (success) _savedSearchNameController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Arama kaydedildi.' : 'Arama kaydedilemedi.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final totalPages = result == null || result.totalCount == 0
        ? 1
        : (result.totalCount / _pageSize).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export Radar'),
            Text('Pazar fırsatları', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          if (_isAdmin)
            IconButton(
              tooltip: 'Senkronizasyon logları',
              onPressed: _openSyncLogs,
              icon: const Icon(Icons.receipt_long_outlined),
            ),
          IconButton(
            tooltip: 'Favorilerim',
            onPressed: _openFavorites,
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            tooltip: 'Kayıtlı aramalar',
            onPressed: _openSavedSearches,
            icon: const Icon(Icons.bookmark_outline),
          ),
          IconButton(
            tooltip: 'Yenile',
            onPressed: _isLoading ? null : _loadOpportunities,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Çıkış yap',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOpportunities,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Text('İhracat için doğru pazarı bulun', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            const Text('Güncel talepleri arayın, filtreleyin ve fırsatları değerlendirin.'),
            const SizedBox(height: 20),
            _buildFilterCard(),
            const SizedBox(height: 20),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _buildErrorState()
            else if (result == null || result.items.isEmpty)
              _buildEmptyState()
            else ...[
              Text('${result.totalCount} fırsat bulundu', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...result.items.map(_buildOpportunityCard),
              const SizedBox(height: 8),
              _buildPagination(totalPages),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _loadOpportunities(page: 1),
              decoration: const InputDecoration(
                labelText: 'Fırsat ara',
                hintText: 'Başlık veya kaynak adı',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _countryController,
                    decoration: const InputDecoration(labelText: 'Ülke', prefixIcon: Icon(Icons.public)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Kategori', prefixIcon: Icon(Icons.category_outlined)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _scoreController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Minimum fırsat puanı',
                hintText: 'Örn. 70',
                prefixIcon: Icon(Icons.insights_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : () => _loadOpportunities(page: 1),
                    icon: const Icon(Icons.tune),
                    label: const Text('Filtrele'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _isLoading ? null : _clearFilters,
                  child: const Text('Temizle'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _savedSearchNameController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _saveCurrentSearch(),
              decoration: const InputDecoration(
                labelText: 'Kaydedilecek arama adı',
                hintText: 'Örn. Almanya tekstil',
                prefixIcon: Icon(Icons.bookmark_add_outlined),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _isLoading ? null : _saveCurrentSearch,
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Bu aramayı kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunityCard(RadarOpportunity item) {
    final score = item.opportunityScore;
    final scoreText = score == null ? 'Puan yok' : '${score.toStringAsFixed(0)} puan';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.sourceName.isEmpty ? 'Bilinmeyen kaynak' : item.sourceName,
                      style: Theme.of(context).textTheme.labelLarge),
                ),
                Chip(
                  label: Text(scoreText),
                  avatar: const Icon(Icons.star_outline, size: 18),
                ),
                IconButton(
                  tooltip: 'Favorilere ekle',
                  onPressed: () => _addFavorite(item),
                  icon: const Icon(Icons.favorite_border),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(icon: Icons.location_on_outlined, label: item.country),
                _InfoChip(icon: Icons.sell_outlined, label: item.category),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Önceki sayfa',
          onPressed: _currentPage > 1 ? () => _loadOpportunities(page: _currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('Sayfa $_currentPage / $totalPages'),
        IconButton(
          tooltip: 'Sonraki sayfa',
          onPressed: _currentPage < totalPages ? () => _loadOpportunities(page: _currentPage + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 72),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.radar_outlined, size: 56),
            SizedBox(height: 16),
            Text('Bu filtrelerle eşleşen fırsat bulunamadı.'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _loadOpportunities, child: const Text('Tekrar dene')),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label.isEmpty ? 'Belirtilmemiş' : label),
      visualDensity: VisualDensity.compact,
    );
  }
}
