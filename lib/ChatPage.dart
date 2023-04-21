import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'TranslationAPI.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Chat')),
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
          Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                ElevatedButton(
                  child: Text('Send'),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
