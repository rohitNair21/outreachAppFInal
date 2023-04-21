import 'dart:convert';

import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;

class TranslationAPI {
  static final _apiKey = 'AIzaSyAv6LArPtl6CswGITKNpMy5xsYzKZh0kUQ';
  static Future<String> translate(String message, String toLanguage) async {
    final response = await http.post(Uri.parse(
        'https://translation.googleapis.com/language/translate/v2?target=$toLanguage&key=$_apiKey&q=$message'));
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final translations = body['data']['translations'] as List;
      final translation = translations.first;

      return HtmlUnescape().convert(translation['translatedText']);
    } else {
      throw Exception();
    }
  }
}
