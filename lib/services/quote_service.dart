// lib/services/quote_service.dart

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/quote_model.dart';

class QuoteService {
  static const String _baseUrl = 'https://api.quotable.io/random';

  /// Fetch a random motivational quote
  Future<QuoteModel> fetchRandomQuote() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 100));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return QuoteModel.fromJson(data);
      } else {
        throw Exception('Failed to load quote: ${response.statusCode}');
      }
    } catch (e) {
      log("the error in fetching is ${e.toString()}");
      throw Exception('Could not fetch quote. Check your internet connection.');
    }
  }
}
