class SleepQuote {
  final String quote;
  final String author;

  const SleepQuote({
    required this.quote,
    required this.author,
  });

  factory SleepQuote.fromJson(Map<String, dynamic> json) {
    return SleepQuote(
      quote: json['quote'] as String,
      author: json['author'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quote': quote,
      'author': author,
    };
  }
}
