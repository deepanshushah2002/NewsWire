// lib/providers/news_provider.dart

import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import '../services/bookmark_service.dart';

enum LoadingState { idle, loading, loaded, error }

class NewsProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();
  final BookmarkService _bookmarkService = BookmarkService();

  // ── State ────────────────────────────────────────────────────────────────────
  List<Article> _articles = [];
  List<Article> _bookmarks = [];
  Set<String> _bookmarkedUrls = {};

  LoadingState _loadingState = LoadingState.idle;
  LoadingState _bookmarkLoadingState = LoadingState.idle;
  String _errorMessage = '';

  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isSearching = false;

  // ── Getters ──────────────────────────────────────────────────────────────────
  List<Article> get articles => _articles;
  List<Article> get bookmarks => _bookmarks;
  LoadingState get loadingState => _loadingState;
  LoadingState get bookmarkLoadingState => _bookmarkLoadingState;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  bool get isLoading => _loadingState == LoadingState.loading;

  bool isBookmarked(String url) => _bookmarkedUrls.contains(url);

  // ── Categories ───────────────────────────────────────────────────────────────
  static const List<Map<String, String>> categories = [
    {'id': 'all', 'label': 'All', 'emoji': '🌐'},
    {'id': 'technology', 'label': 'Tech', 'emoji': '💻'},
    {'id': 'business', 'label': 'Business', 'emoji': '📈'},
    {'id': 'science', 'label': 'Science', 'emoji': '🔬'},
    {'id': 'health', 'label': 'Health', 'emoji': '❤️'},
    {'id': 'sports', 'label': 'Sports', 'emoji': '⚽'},
    {'id': 'entertainment', 'label': 'Culture', 'emoji': '🎬'},
    {'id': 'general', 'label': 'World', 'emoji': '🌍'},
  ];

  // ── Actions ──────────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    await fetchNews();
    await loadBookmarks();
    await _loadBookmarkedUrls();
  }

  Future<void> fetchNews({bool forceRefresh = false}) async {
    _setLoadingState(LoadingState.loading);

    try {
      if (_isSearching && _searchQuery.isNotEmpty) {
        _articles = await _newsService.searchArticles(_searchQuery);
      } else {
        _articles = await _newsService.getTopHeadlines(
          category: _selectedCategory == 'all' ? null : _selectedCategory,
        );
      }
      _setLoadingState(LoadingState.loaded);
    } on NewsException catch (e) {
      _errorMessage = e.message;
      _setLoadingState(LoadingState.error);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _setLoadingState(LoadingState.error);
    }
  }

  Future<void> selectCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _isSearching = false;
    _searchQuery = '';
    notifyListeners();
    await fetchNews();
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    _isSearching = query.isNotEmpty;
    notifyListeners();
    if (query.isEmpty) {
      await fetchNews();
    } else {
      await fetchNews();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
    fetchNews();
  }

  Future<void> toggleBookmark(Article article) async {
    try {
      await _bookmarkService.toggleBookmark(article);
      if (_bookmarkedUrls.contains(article.url)) {
        _bookmarkedUrls.remove(article.url);
        _bookmarks.removeWhere((a) => a.url == article.url);
      } else {
        _bookmarkedUrls.add(article.url);
        _bookmarks.insert(0, article);
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadBookmarks() async {
    _bookmarkLoadingState = LoadingState.loading;
    notifyListeners();

    try {
      _bookmarks = await _bookmarkService.getBookmarks();
      _bookmarkLoadingState = LoadingState.loaded;
    } catch (_) {
      _bookmarkLoadingState = LoadingState.error;
    }
    notifyListeners();
  }

  Future<void> clearAllBookmarks() async {
    await _bookmarkService.clearAll();
    _bookmarks.clear();
    _bookmarkedUrls.clear();
    notifyListeners();
  }

  Future<void> _loadBookmarkedUrls() async {
    final bookmarks = await _bookmarkService.getBookmarks();
    _bookmarkedUrls = bookmarks.map((a) => a.url).toSet();
    notifyListeners();
  }

  void _setLoadingState(LoadingState state) {
    _loadingState = state;
    notifyListeners();
  }
}
