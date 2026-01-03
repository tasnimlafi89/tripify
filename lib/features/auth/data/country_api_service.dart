import 'dart:convert';
import 'package:frontend/features/home/presentation/pages/add_trip_page.dart';
import 'package:http/http.dart' as http;

class CountryApiService {
  static const _baseUrl = 'https://restcountries.com/v3.1';

  Future<List<CountryData>> searchCountries(String query) async {
    if (query.isEmpty) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/name/$query'),
    );

    if (response.statusCode != 200) {
      return [];
    }

    final List data = jsonDecode(response.body);

    return data.map((json) => CountryData.fromApi(json)).toList();
  }

  
}
