import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  String get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env');
    }
    return key;
  }

  String get apiKey => _apiKey;
}
