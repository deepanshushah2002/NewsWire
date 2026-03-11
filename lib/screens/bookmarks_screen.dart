// lib/screens/bookmarks_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/article_card.dart';
import '../utils/theme.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Saved Articles',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Bookmarks',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      if (provider.bookmarks.isNotEmpty)
                        GestureDetector(
                          onTap: () => _confirmClearAll(context, provider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Clear All',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Count badge
                if (provider.bookmarks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentSecondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${provider.bookmarks.length} article${provider.bookmarks.length != 1 ? 's' : ''} saved',
                        style: const TextStyle(
                          color: AppTheme.accentSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Content
                Expanded(
                  child: provider.bookmarks.isEmpty
                      ? _buildEmpty(context)
                      : ListView.builder(
                          itemCount: provider.bookmarks.length,
                          itemBuilder: (_, index) => ArticleCard(
                            article: provider.bookmarks[index],
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_outline_rounded,
              size: 44,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No bookmarks yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the bookmark icon on any\narticle to save it here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, NewsProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear All Bookmarks?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'This will remove all saved articles. This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              provider.clearAllBookmarks();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
