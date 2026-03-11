import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsException implements Exception {
  final String message;
  final int? statusCode;

  NewsException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NewsService {
  static const String _apiKey = '59f74cfddefd410fb6bab12e19cc209b';
  static const String _baseUrl = 'https://newsapi.org/v2';

  static bool get _useMockData => _apiKey == 'YOUR_API_KEY_HERE';

  Future<List<Article>> getTopHeadlines({
    String? category,
    String? query,
    String country = 'us',
    int page = 1,
    int pageSize = 20,
  }) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockArticles(category: category, query: query);
    }

    try {
      final queryParams = {
        'apiKey': _apiKey,
        'country': country,
        'pageSize': pageSize.toString(),
        'page': page.toString(),
        if (category != null && category != 'all') 'category': category,
        if (query != null && query.isNotEmpty) 'q': query,
      };

      final uri = Uri.parse('$_baseUrl/top-headlines')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw NewsException('Request timed out'),
      );

      return _parseResponse(response);
    } on SocketException {
      throw NewsException('No internet connection. Please check your network.');
    } on NewsException {
      rethrow;
    } catch (e) {
      throw NewsException('Failed to fetch news: ${e.toString()}');
    }
  }

  Future<List<Article>> searchArticles(String query) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _getMockArticles(query: query);
    }

    try {
      final uri = Uri.parse('$_baseUrl/everything').replace(queryParameters: {
        'apiKey': _apiKey,
        'q': query,
        'sortBy': 'publishedAt',
        'pageSize': '20',
        'language': 'en',
      });

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw NewsException('Request timed out'),
      );

      return _parseResponse(response);
    } on SocketException {
      throw NewsException('No internet connection.');
    } on NewsException {
      rethrow;
    } catch (e) {
      throw NewsException('Search failed: ${e.toString()}');
    }
  }

  List<Article> _parseResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] == 'ok') {
        final articles = (data['articles'] as List)
            .map((json) => Article.fromJson(json))
            .where((a) => a.title != '[Removed]' && a.url.isNotEmpty)
            .toList();
        return articles;
      } else {
        throw NewsException(data['message'] ?? 'API error');
      }
    } else if (response.statusCode == 401) {
      throw NewsException('Invalid API key. Please check your NewsAPI key.',
          statusCode: 401);
    } else if (response.statusCode == 429) {
      throw NewsException('Rate limit exceeded. Please try again later.',
          statusCode: 429);
    } else {
      throw NewsException('Server error: ${response.statusCode}',
          statusCode: response.statusCode);
    }
  }

  // ── Mock Data for Demo ──────────────────────────────────────────────────────
  List<Article> _getMockArticles({String? category, String? query}) {
    final all = _mockArticles;
    if (query != null && query.isNotEmpty) {
      return all
          .where((a) =>
              a.title.toLowerCase().contains(query.toLowerCase()) ||
              (a.description?.toLowerCase().contains(query.toLowerCase()) ??
                  false))
          .toList();
    }
    if (category != null && category != 'all') {
      return all.where((a) => a.source?.name == category).toList().isEmpty
          ? all.take(6).toList()
          : all;
    }
    return all;
  }

  final List<Article> _mockArticles = [
    Article(
      id: '1',
      title: 'AI Breakthrough: New Model Surpasses Human Performance on Complex Reasoning Tasks',
      description: 'Researchers at a leading AI lab have unveiled a new large language model that demonstrates unprecedented capabilities in mathematical reasoning and scientific problem solving.',
      url: 'https://example.com/ai-breakthrough',
      urlToImage: 'https://picsum.photos/seed/ai1/800/450',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      author: 'Sarah Johnson',
      source: Source(id: 'tech-news', name: 'Tech News'),
      content: 'In a landmark development for artificial intelligence, researchers have published findings showing their newest model achieving human-level performance across a broad range of cognitive tasks...',
    ),
    Article(
      id: '2',
      title: 'Global Markets Rally as Inflation Data Shows Promising Signs of Cooling',
      description: 'Stock markets around the world surged today after fresh economic data suggested that inflation pressures may finally be easing across major economies.',
      url: 'https://example.com/markets-rally',
      urlToImage: 'https://picsum.photos/seed/finance1/800/450',
      publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      author: 'Michael Chen',
      source: Source(id: 'business', name: 'Business Daily'),
      content: 'Wall Street celebrated today as the S&P 500 climbed nearly 2% following the release of consumer price index data...',
    ),
    Article(
      id: '3',
      title: 'Scientists Discover New Species of Deep-Sea Creature in the Pacific Ocean',
      description: 'Marine biologists exploring the Mariana Trench have documented a previously unknown organism that challenges our understanding of life in extreme environments.',
      url: 'https://example.com/deep-sea',
      urlToImage: 'https://picsum.photos/seed/science1/800/450',
      publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
      author: 'Dr. Emily Waters',
      source: Source(id: 'science', name: 'Science Today'),
      content: 'A team of deep-sea explorers using advanced submersible technology has made a remarkable discovery...',
    ),
    Article(
      id: '4',
      title: 'Championship Finals: Underdog Team Stuns Favorites in Historic Victory',
      description: 'In what many are calling the upset of the decade, the Riverside Rockets defeated the top-seeded Hawks in a thrilling overtime finish.',
      url: 'https://example.com/sports-finals',
      urlToImage: 'https://picsum.photos/seed/sports1/800/450',
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      author: 'James Rodriguez',
      source: Source(id: 'sports', name: 'Sports Hub'),
      content: 'Nobody gave them a chance. But the Riverside Rockets proved everyone wrong last night...',
    ),
    Article(
      id: '5',
      title: 'New Study Links Mediterranean Diet to Reduced Risk of Cognitive Decline',
      description: 'A comprehensive 10-year study involving over 50,000 participants has found strong correlations between dietary habits and long-term brain health.',
      url: 'https://example.com/health-diet',
      urlToImage: 'https://picsum.photos/seed/health1/800/450',
      publishedAt: DateTime.now().subtract(const Duration(hours: 10)),
      author: 'Dr. Lisa Park',
      source: Source(id: 'health', name: 'Health & Wellness'),
      content: 'Researchers at Harvard Medical School have published findings from their landmark longitudinal study...',
    ),
    Article(
      id: '6',
      title: 'Electric Vehicle Sales Hit Record High in Q3, Challenging Traditional Automakers',
      description: 'The electric vehicle market has seen explosive growth this quarter with sales surpassing projections by 40%, forcing legacy manufacturers to accelerate their EV strategies.',
      url: 'https://example.com/ev-sales',
      urlToImage: 'https://picsum.photos/seed/auto1/800/450',
      publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
      author: 'Tom Harrison',
      source: Source(id: 'business', name: 'Business Daily'),
      content: 'The automotive industry is undergoing its most significant transformation in over a century...',
    ),
    Article(
      id: '7',
      title: 'Archaeologists Unearth Ancient City Hidden Beneath Amazon Rainforest',
      description: 'Using cutting-edge LiDAR technology, researchers have mapped an extensive pre-Columbian urban complex that could reshape our understanding of ancient civilizations.',
      url: 'https://example.com/amazon-city',
      urlToImage: 'https://picsum.photos/seed/arch1/800/450',
      publishedAt: DateTime.now().subtract(const Duration(hours: 14)),
      author: 'Prof. Ana Souza',
      source: Source(id: 'science', name: 'Science Today'),
      content: 'Hidden beneath the dense canopy of the Amazon rainforest for centuries, an ancient city has finally revealed its secrets...',
    ),
    Article(
      id: '8',
      title: 'Breakthrough in Quantum Computing Achieves 1000-Qubit Milestone',
      description: 'Tech giant announces the world\'s first commercially viable 1000-qubit quantum processor, potentially unlocking solutions to problems previously unsolvable by classical computers.',
      url: 'https://example.com/quantum',
      urlToImage: 'https://picsum.photos/seed/quantum1/800/450',
      publishedAt: DateTime.now().subtract(const Duration(hours: 16)),
      author: 'Dr. Raj Patel',
      source: Source(id: 'tech-news', name: 'Tech News'),
      content: 'The race to practical quantum computing has reached a defining moment...',
    ),
    Article(
      id: '9',
      title: 'UN Climate Summit Reaches Landmark Agreement on Fossil Fuel Phase-Out',
      description: 'World leaders have signed a historic accord committing to a accelerated timeline for transitioning away from fossil fuels, with binding targets for 2030 and 2050.',
      url: 'https://example.com/climate-summit',
      urlToImage: 'https://picsum.photos/seed/climate1/800/450',
      publishedAt: DateTime.now().subtract(const Duration(hours: 18)),
      author: 'Claire Dupont',
      source: Source(id: 'world', name: 'World Affairs'),
      content: 'After two weeks of intense negotiations, delegates from 195 countries reached a breakthrough agreement...',
    ),
    Article(
      id: '10',
      title: 'Golden Globe Winners Announced: Surprise Upsets Dominate Ceremony',
      description: 'The entertainment industry gathered last night for the annual Golden Globe Awards, with several unexpected wins shaking up the early Oscar season predictions.',
      url: 'https://example.com/golden-globes',
      urlToImage: 'https://picsum.photos/seed/entertainment1/800/450',
      publishedAt: DateTime.now().subtract(const Duration(hours: 20)),
      author: 'Lisa Monroe',
      source: Source(id: 'entertainment', name: 'Entertainment Weekly'),
      content: 'Hollywood\'s awards season kicked into high gear last night as the Golden Globes delivered several shocking results...',
    ),
  ];
}
