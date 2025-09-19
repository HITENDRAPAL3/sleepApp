import 'dart:math';
import 'package:flutter/services.dart';

class QuoteService {
  static List<String>? _quotes;

  static Future<List<String>> loadQuotes() async {
    if (_quotes != null) return _quotes!;

    try {
      final String quotesContent = await rootBundle.loadString('assets/quotes/sleep_quotes.txt');
      _quotes = quotesContent
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
      return _quotes!;
    } catch (e) {
      // Return default quotes if file loading fails
      _quotes = [
        'Sleep is the best meditation. - Dalai Lama',
        'The best cure for insomnia is to get a lot of sleep. - W.C. Fields',
        'Early to bed and early to rise, makes a man healthy, wealthy, and wise. - Benjamin Franklin',
        'Sleep is that golden chain that ties health and our bodies together. - Thomas Dekker',
        'A good laugh and a long sleep are the best cures in the doctor\'s book. - Irish Proverb',
      ];
      return _quotes!;
    }
  }

  static Future<String> getRandomQuote() async {
    final quotes = await loadQuotes();
    final random = Random();
    return quotes[random.nextInt(quotes.length)];
  }
}
