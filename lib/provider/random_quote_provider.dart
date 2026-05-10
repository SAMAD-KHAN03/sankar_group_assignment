import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/quote_model.dart';
import '../services/quote_service.dart';

class RandomQuoteProvider extends ChangeNotifier {
  final QuoteService _quoteService = QuoteService();

  QuoteModel? _quote;
  bool _isLoading = false;
  String? _error;

  QuoteModel? get quote => _quote;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRandomQuote() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _quoteService.fetchRandomQuote();

      _quote = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
final quoteServiceProvider =
    ChangeNotifierProvider<RandomQuoteProvider>(
  (ref) => RandomQuoteProvider(),
);