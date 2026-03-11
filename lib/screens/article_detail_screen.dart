import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/article.dart';
import '../providers/news_provider.dart';
import '../utils/theme.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.parse(article.url);
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      try {
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open article. Try again later.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: _buildContent(context),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: article.urlToImage != null ? 280 : 0,
      pinned: true,
      backgroundColor: AppTheme.background,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
        ),
      ),
      actions: [
        Consumer<NewsProvider>(
          builder: (_, provider, __) {
            final isBookmarked = provider.isBookmarked(article.url);
            return GestureDetector(
              onTap: () => provider.toggleBookmark(article),
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: isBookmarked ? AppTheme.accent : AppTheme.textPrimary,
                  size: 20,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: article.urlToImage != null
          ? FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: article.urlToImage!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  Container(color: AppTheme.surfaceElevated),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.background.withOpacity(0.8),
                    AppTheme.background,
                  ],
                  stops: const [0.4, 0.8, 1.0],
                ),
              ),
            ),
          ],
        ),
      )
          : null,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source & time
          Row(
            children: [
              if (article.source != null)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    article.source!.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              const Spacer(),
              if (article.publishedAt != null)
                Text(
                  timeago.format(article.publishedAt!),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            article.title,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: 22, height: 1.3),
          ),
          const SizedBox(height: 12),

          // Author
          if (article.author != null && article.author!.isNotEmpty)
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.accentSecondary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 16,
                    color: AppTheme.accentSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    article.author!.split(',').first.trim(),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 20),
          Container(height: 1, color: AppTheme.border),
          const SizedBox(height: 20),

          // Description
          if (article.description != null)
            Text(
              article.description!,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                height: 1.7,
                letterSpacing: 0.1,
              ),
            ),

          // Content (truncated)
          if (article.content != null) ...[
            const SizedBox(height: 16),
            Text(
              _cleanContent(article.content!),
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 15,
                height: 1.7,
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Read full article CTA
          GestureDetector(
            onTap: () => _openUrl(context),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accent, Color(0xFFFF8A60)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.open_in_new_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Read Full Article',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer<NewsProvider>(
                builder: (_, provider, __) {
                  final isBookmarked = provider.isBookmarked(article.url);
                  return TextButton.icon(
                    onPressed: () => provider.toggleBookmark(article),
                    icon: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color:
                      isBookmarked ? AppTheme.accent : AppTheme.textMuted,
                    ),
                    label: Text(
                      isBookmarked ? 'Saved' : 'Save',
                      style: TextStyle(
                        color: isBookmarked
                            ? AppTheme.accent
                            : AppTheme.textMuted,
                      ),
                    ),
                  );
                },
              ),
              TextButton.icon(
                onPressed: () => _openUrl(context),
                icon: const Icon(Icons.launch_rounded, color: AppTheme.accent),
                label: const Text(
                  'Open Source',
                  style: TextStyle(color: AppTheme.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _cleanContent(String content) {
    return content.replaceAll(RegExp(r'\[\+\d+ chars\]'), '').trim();
  }
}