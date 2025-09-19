import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/sleep_quote.dart';

class QuoteService {
  static List<SleepQuote>? _quotes;

  static Future<List<SleepQuote>> _loadQuotes() async {
    if (_quotes != null) return _quotes!;

    try {
      final String quotesJson = await rootBundle.loadString('assets/data/sleep_quotes.json');
      final List<dynamic> quotesData = json.decode(quotesJson);
      _quotes = quotesData.map((json) => SleepQuote.fromJson(json)).toList();
      return _quotes!;
    } catch (e) {
      // Fallback quotes in case of error
      _quotes = [
        const SleepQuote(
          quote: "Sleep is the golden chain that ties health and our bodies together.",
          author: "Thomas Dekker",
        ),
        const SleepQuote(
          quote: "A good laugh and a long sleep are the best cures in the doctor's book.",
          author: "Irish Proverb",
        ),
        const SleepQuote(
          quote: "Sleep is the best meditation.",
          author: "Dalai Lama",
        ),
      ];
      return _quotes!;
    }
  }

  static Future<SleepQuote> getRandomQuote() async {
    final quotes = await _loadQuotes();
    final random = Random();
    return quotes[random.nextInt(quotes.length)];
  }

  static Future<List<SleepQuote>> getAllQuotes() async {
    return await _loadQuotes();
  }
}