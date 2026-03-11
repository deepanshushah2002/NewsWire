// lib/models/article.dart

class Article {
  final String? id;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;
  final Source? source;

  Article({
    this.id,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.source,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['url'] ?? '',
      author: json['author'],
      title: json['title'] ?? 'No Title',
      description: json['description'],
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,
      content: json['content'],
      source: json['source'] != null ? Source.fromJson(json['source']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt?.toIso8601String(),
      'content': content,
      'source': source?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Article && url == other.url;

  @override
  int get hashCode => url.hashCode;
}

class Source {
  final String? id;
  final String name;

  Source({this.id, required this.name});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
