import 'package:flutter/material.dart';
import 'ChatPage.dart';
import 'TranslationAPI.dart';

class NamePage extends StatefulWidget {
  const NamePage({Key? key}) : super(key: key);

  @override
  _NamePageState createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedLanguage = 'en';
  final List<Map<String, String>> _languageList = [
    {"name": "Amharic", "code": "am"},
    {"name": "Arabic", "code": "ar"},
    {"name": "Basque", "code": "eu"},
    {"name": "Bengali", "code": "bn"},
    {"name": "English (UK)", "code": "en-GB"},
    {"name": "Portuguese (Brazil)", "code": "pt-BR"},
    {"name": "Bulgarian", "code": "bg"},
    {"name": "Catalan", "code": "ca"},
    {"name": "Cherokee", "code": "chr"},
    {"name": "Croatian", "code": "hr"},
    {"name": "Czech", "code": "cs"},
    {"name": "Danish", "code": "da"},
    {"name": "Dutch", "code": "nl"},
    {"name": "English (US)", "code": "en"},
    {"name": "Estonian", "code": "et"},
    {"name": "Filipino", "code": "fil"},
    {"name": "Finnish", "code": "fi"},
    {"name": "French", "code": "fr"},
    {"name": "German", "code": "de"},
    {"name": "Greek", "code": "el"},
    {"name": "Gujarati", "code": "gu"},
    {"name": "Hebrew", "code": "iw"},
    {"name": "Hindi", "code": "hi"},
    {"name": "Hungarian", "code": "hu"},
    {"name": "Icelandic", "code": "is"},
    {"name": "Indonesian", "code": "id"},
    {"name": "Italian", "code": "it"},
    {"name": "Japanese", "code": "ja"},
    {"name": "Kannada", "code": "kn"},
    {"name": "Korean", "code": "ko"},
    {"name": "Latvian", "code": "lv"},
    {"name": "Lithuanian", "code": "lt"},
    {"name": "Malay", "code": "ms"},
    {"name": "Malayalam", "code": "ml"},
    {"name": "Marathi", "code": "mr"},
    {"name": "Norwegian", "code": "no"},
    {"name": "Polish", "code": "pl"},
    {"name": "Portuguese (Portugal)", "code": "pt-PT"},
    {"name": "Romanian", "code": "ro"},
    {"name": "Russian", "code": "ru"},
    {"name": "Serbian", "code": "sr"},
    {"name": "Chinese (PRC)", "code": "zh-CN"},
    {"name": "Slovak", "code": "sk"},
    {"name": "Slovenian", "code": "sl"},
    {"name": "Spanish", "code": "es"},
    {"name": "Swahili", "code": "sw"},
    {"name": "Swedish", "code": "sv"},
    {"name": "Tamil", "code": "ta"},
    {"name": "Telugu", "code": "te"},
    {"name": "Thai", "code": "th"},
    {"name": "Chinese (Taiwan)", "code": "zh-TW"},
    {"name": "Turkish", "code": "tr"},
    {"name": "Urdu", "code": "ur"},
    {"name": "Ukrainian", "code": "uk"},
    {"name": "Vietnamese", "code": "vi"}
  ];
  String _enterChatLabel = 'Enter Chat';

  Future<void> _translateEnterChatLabel() async {
    try {
      final translatedLabel =
          await TranslationAPI.translate(_enterChatLabel, _selectedLanguage!);
      setState(() {
        _enterChatLabel = translatedLabel;
      });
    } catch (e) {
      print('Error translating label: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _translateEnterChatLabel();
  }

  @override
  void didUpdateWidget(covariant NamePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _translateEnterChatLabel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SafeSpace'),
        backgroundColor: Color(0xFF323232),
      ),
      backgroundColor: Color(0xFFD8D8D8),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                fillColor: Color(0xFFFCFCFC),
                filled: true,
                labelStyle: TextStyle(
                  fontFamily: 'Haboro',
                  fontSize: 16,
                ),
              ),
            ),
          ),
          DropdownButton<String>(
            value: _selectedLanguage,
            onChanged: (String? newValue) {
              setState(() {
                _selectedLanguage = newValue;
              });
              _translateEnterChatLabel();
            },
            items: _languageList.map((Map<String, String> language) {
              return DropdownMenuItem<String>(
                value: language['code'],
                child: Text(language['name']!),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            child: Text(_enterChatLabel),
            onPressed: _textController.text.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          username: _textController.text,
                          selectedLanguage: _selectedLanguage!,
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF141414),
            ),
          ),
        ],
      ),
    );
  }
}
