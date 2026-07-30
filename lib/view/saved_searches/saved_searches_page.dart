import 'package:flutter/material.dart';

import '../../models/saved_search.dart';
import '../../services/saved_search_service.dart';

class SavedSearchesPage extends StatefulWidget {
  const SavedSearchesPage({super.key});

  @override
  State<SavedSearchesPage> createState() => _SavedSearchesPageState();
}

class _SavedSearchesPageState extends State<SavedSearchesPage> {
  final _savedSearchService = SavedSearchService();
  late Future<List<SavedSearch>> _searchesFuture;

  @override
  void initState() {
    super.initState();
    _searchesFuture = _savedSearchService.getSavedSearches();
  }

  Future<void> _reload() async {
    setState(() => _searchesFuture = _savedSearchService.getSavedSearches());
    await _searchesFuture;
  }

  Future<void> _delete(SavedSearch search) async {
    final success = await _savedSearchService.deleteSavedSearch(search.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Kayıtlı arama silindi.' : 'Kayıtlı arama silinemedi.')),
    );
    if (success) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıtlı aramalar')),
      body: FutureBuilder<List<SavedSearch>>(
        future: _searchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return _buildErrorState();

          final searches = snapshot.data ?? [];
          if (searches.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: searches.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildSearchCard(searches[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchCard(SavedSearch search) {
    final filters = search.filters;
    final labels = <String>[
      if ((filters['searchTerm'] as String? ?? '').isNotEmpty) filters['searchTerm'] as String,
      if ((filters['country'] as String? ?? '').isNotEmpty) filters['country'] as String,
      if ((filters['category'] as String? ?? '').isNotEmpty) filters['category'] as String,
      if (filters['minOpportunityScore'] != null) 'Min. puan: ${filters['minOpportunityScore']}',
    ];

    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.bookmark_outline)),
        title: Text(search.name),
        subtitle: Text(labels.isEmpty ? 'Filtre bilgisi yok' : labels.join(' • ')),
        onTap: () => Navigator.pop(context, filters),
        trailing: IconButton(
          tooltip: 'Kaydı sil',
          onPressed: () => _delete(search),
          icon: const Icon(Icons.delete_outline),
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
            Icon(Icons.bookmarks_outlined, size: 56),
            SizedBox(height: 16),
            Text('Henüz kayıtlı aramanız yok.'),
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
        label: const Text('Aramaları tekrar yükle'),
      ),
    );
  }
}
