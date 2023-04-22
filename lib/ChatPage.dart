import 'dart:html';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'TranslationAPI.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatPage extends StatefulWidget {
  final String? username;
  final String selectedLanguage;

  const ChatPage(
      {Key? key, required this.username, required this.selectedLanguage})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'messages';

  String _liveChatLabel = 'Live Chat';
  String _typeMessageLabel = 'Type a message';
  String _sendLabel = 'SEND';

  Future<void> _translateLiveChatLabel() async {
    try {
      final translatedLabel = await TranslationAPI.translate(
          _liveChatLabel, widget.selectedLanguage);
      setState(() {
        _liveChatLabel = translatedLabel;
      });
    } catch (e) {
      print('Error translating label: $e');
    }
  }

  Future<void> _translateMessageLabel() async {
    try {
      final translatedLabel = await TranslationAPI.translate(
          _typeMessageLabel, widget.selectedLanguage);
      setState(() {
        _typeMessageLabel = translatedLabel;
      });
    } catch (e) {
      print('Error translating label: $e');
    }
  }

  Future<void> _translateSendLabel() async {
    try {
      final translatedLabel =
          await TranslationAPI.translate(_sendLabel, widget.selectedLanguage);
      setState(() {
        _sendLabel = translatedLabel;
      });
    } catch (e) {
      print('Error translating label: $e');
    }
  }

  Future<void> _sendMessage() async {
    final originalMessage = _textController.text;
    final translatedMessage = await TranslationAPI.translate(
        originalMessage, widget.selectedLanguage);
    _db.collection(_collectionName).add({
      'username': widget.username,
      'message': originalMessage,
      'translated_message': translatedMessage,
      'timestamp': DateTime.now(),
    });
    _textController.clear();
  }

  Future<String> _translateMessage(
      String message, String selectedLanguage) async {
    final translatedMessage =
        await TranslationAPI.translate(message, selectedLanguage);
    return translatedMessage;
  }

  @override
  void initState() {
    super.initState();
    _translateMessageLabel();
    _translateLiveChatLabel();
    _translateSendLabel();
  }

  @override
  void didUpdateWidget(covariant ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _translateMessageLabel();
    _translateLiveChatLabel();
    _translateSendLabel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _liveChatLabel,
          style: TextStyle(
            color: Color(0xffffffff),
          ),
        ),
        backgroundColor: Color(0xff323232),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection(_collectionName)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    return Scrollbar(
                      child: ListView(
                        reverse: true,
                        shrinkWrap: true,
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          final isOutgoingMessage =
                              data['username'] == widget.username;
                          final message = data['translated_message'] ??
                              data['message'] ??
                              '';
                          final subtitle = isOutgoingMessage
                              ? data['message']
                              : data['translated_message'] ?? '';
                          return ListTile(
                            title: Text(data['username'] ?? ''),
                            subtitle: FutureBuilder(
                              future: _translateMessage(
                                  subtitle, widget.selectedLanguage),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.hasData) {
                                  return Text(snapshot.data!);
                                } else {
                                  return Text('');
                                }
                              },
                            ),
                            trailing: Text(DateFormat('HH:mm')
                                .format(data['timestamp'].toDate())),
                          );
                        }).toList(),
                      ),
                    );
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Color(0xFF323232),
              border: Border(
                top: BorderSide(
                  color: Color(0xFFD8D8D8),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: _typeMessageLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      filled: true,
                      fillColor: Color(0xFFfcfcfc),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                MaterialButton(
                  onPressed: _sendMessage,
                  color: Color(0xFF141414),
                  textColor: Colors.white,
                  child: Text(_sendLabel),
                  minWidth: 80.0,
                  height: 40.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
