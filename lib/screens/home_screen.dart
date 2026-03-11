// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/article_card.dart';
import '../widgets/category_chips.dart';
import '../widgets/search_bar_widget.dart';
import '../utils/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().initialize();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<NewsProvider>().fetchNews(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<NewsProvider>(
          builder: (_, provider, __) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, provider),
                // Search bar
                const SearchBarWidget(),
                // Category chips
                const CategoryChips(),
                const SizedBox(height: 8),
                // Content area
                Expanded(
                  child: _buildContent(provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NewsProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  provider.isSearching
                      ? 'Search Results'
                      : _getCategoryTitle(provider.selectedCategory),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          // Live indicator
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.accentGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: AppTheme.accentGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(NewsProvider provider) {
    switch (provider.loadingState) {
      case LoadingState.loading:
        return _buildShimmer();
      case LoadingState.error:
        return _buildError(provider);
      case LoadingState.loaded:
        return _buildArticleList(provider);
      case LoadingState.idle:
        return _buildShimmer();
    }
  }

  Widget _buildArticleList(NewsProvider provider) {
    final articles = provider.articles;

    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 52, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(
              provider.isSearching
                  ? 'No results for "${provider.searchQuery}"'
                  : 'No articles found',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different search or category',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Featured card (first article) + list of the rest
    final hasFeatured = !provider.isSearching && articles.isNotEmpty;
    final listArticles = hasFeatured ? articles.skip(1).toList() : articles;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.accent,
      backgroundColor: AppTheme.surface,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (hasFeatured)
            SliverToBoxAdapter(
              child: ArticleCard(article: articles.first, isFeatured: true),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, index) => ArticleCard(article: listArticles[index]),
              childCount: listArticles.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => const ShimmerArticleCard(),
    );
  }

  Widget _buildError(NewsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to Load',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => provider.fetchNews(forceRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'Try Again',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }

  String _getCategoryTitle(String category) {
    final cat = NewsProvider.categories.firstWhere(
      (c) => c['id'] == category,
      orElse: () => {'label': 'News'},
    );
    return '${cat['label']} News';
  }
}
