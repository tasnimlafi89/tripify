import 'dart:convert';
import 'package:http/http.dart' as http;

class UnsplashService {
  UnsplashService._();

  static const String _apiKey = 'cB7gGQ-PjGEDZbAlamuMc5TAAyW8COCoQDYseO56Ios';
  static const String _baseUrl = 'https://api.unsplash.com';

  // Searches Unsplash for high-quality landscape images for a given query
  static Future<List<String>> searchImages({
    required String query,
    int perPage = 8,
  }) async {
    final uri = Uri.parse(
        '$_baseUrl/search/photos?query=${Uri.encodeQueryComponent(query)}&per_page=$perPage&orientation=landscape&content_filter=high');
    final response = await http.get(
      uri,
      headers: {
        'Accept-Version': 'v1',
        'Authorization': 'Client-ID $_apiKey',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Unsplash API error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>?) ?? [];
    final urls = results
        .map((e) => (e as Map<String, dynamic>)['urls'] as Map<String, dynamic>?)
        .where((u) => u != null)
        .map((u) => u!['regular'] as String)
        .toList();

    return urls;
  }
}
