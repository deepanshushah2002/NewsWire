// lib/services/bookmark_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class BookmarkService {
  static const String _bookmarksKey = 'bookmarked_articles';

  Future<List<Article>> getBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_bookmarksKey) ?? [];
      return data
          .map((json) => Article.fromJson(jsonDecode(json)))
          .toList()
          .reversed
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isBookmarked(String url) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((a) => a.url == url);
  }

  Future<void> addBookmark(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_bookmarksKey) ?? [];
    // Avoid duplicates
    if (!data.any((json) {
      final decoded = jsonDecode(json);
      return decoded['url'] == article.url;
    })) {
      data.add(jsonEncode(article.toJson()));
      await prefs.setStringList(_bookmarksKey, data);
    }
  }

  Future<void> removeBookmark(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_bookmarksKey) ?? [];
    data.removeWhere((json) {
      final decoded = jsonDecode(json);
      return decoded['url'] == url;
    });
    await prefs.setStringList(_bookmarksKey, data);
  }

  Future<void> toggleBookmark(Article article) async {
    if (await isBookmarked(article.url)) {
      await removeBookmark(article.url);
    } else {
      await addBookmark(article);
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bookmarksKey);
  }
}
