// lib/widgets/article_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/article.dart';
import '../providers/news_provider.dart';
import '../screens/article_detail_screen.dart';
import '../utils/theme.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final bool isFeatured;

  const ArticleCard({
    super.key,
    required this.article,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return isFeatured
        ? _FeaturedCard(article: article)
        : _RegularCard(article: article);
  }
}

// ── Featured (Hero) Card ──────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final Article article;
  const _FeaturedCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openArticle(context),
      child: Container(
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppTheme.surface,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Image
            Positioned.fill(
              child: article.urlToImage != null
                  ? CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _ImagePlaceholder(),
                    )
                  : _ImagePlaceholder(),
            ),
            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.2, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.source != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
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
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatTime(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        _BookmarkButton(article: article),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime() {
    if (article.publishedAt == null) return '';
    return timeago.format(article.publishedAt!);
  }

  void _openArticle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
    );
  }
}

// ── Regular Article Card ──────────────────────────────────────────────────────
class _RegularCard extends StatelessWidget {
  final Article article;
  const _RegularCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleDetailScreen(article: article),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 90,
                height: 90,
                child: article.urlToImage != null
                    ? CachedNetworkImage(
                        imageUrl: article.urlToImage!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _ImagePlaceholder(),
                      )
                    : _ImagePlaceholder(),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.source != null)
                    Text(
                      article.source!.name.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 15,
                          height: 1.35,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatMeta(),
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _BookmarkButton(article: article, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMeta() {
    final parts = <String>[];
    if (article.author != null && article.author!.isNotEmpty) {
      final author = article.author!.split(',').first.trim();
      if (author.length < 40) parts.add(author);
    }
    if (article.publishedAt != null) {
      parts.add(timeago.format(article.publishedAt!));
    }
    return parts.join(' · ');
  }
}

// ── Bookmark Button ────────────────────────────────────────────────────────────
class _BookmarkButton extends StatelessWidget {
  final Article article;
  final double size;

  const _BookmarkButton({required this.article, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (_, provider, __) {
        final isBookmarked = provider.isBookmarked(article.url);
        return GestureDetector(
          onTap: () => provider.toggleBookmark(article),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                key: ValueKey(isBookmarked),
                size: size,
                color: isBookmarked ? AppTheme.accent : AppTheme.textMuted,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Image Placeholder ─────────────────────────────────────────────────────────
class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceElevated,
      child: const Center(
        child: Icon(
          Icons.newspaper_rounded,
          color: AppTheme.border,
          size: 28,
        ),
      ),
    );
  }
}

// ── Shimmer Loading Card ───────────────────────────────────────────────────────
class ShimmerArticleCard extends StatelessWidget {
  const ShimmerArticleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          _shimmerBox(90, 90, borderRadius: 12),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(60, 10),
                const SizedBox(height: 8),
                _shimmerBox(double.infinity, 14),
                const SizedBox(height: 4),
                _shimmerBox(double.infinity, 14),
                const SizedBox(height: 4),
                _shimmerBox(140, 14),
                const SizedBox(height: 10),
                _shimmerBox(80, 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height, {double borderRadius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
