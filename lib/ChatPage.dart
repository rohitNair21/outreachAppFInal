//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'TranslationAPI.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:grouped_list/grouped_list.dart';

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
  ScrollController _scrollController = ScrollController();
  bool _firstAutoscrollExecuted = false;
  bool _shouldAutoscroll = false;

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

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void _scrollListener() {
    _firstAutoscrollExecuted = true;

    if (_scrollController.hasClients &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      _shouldAutoscroll = true;
    } else {
      _shouldAutoscroll = false;
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
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
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
    _scrollController.addListener(_scrollListener);
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection(_collectionName)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              final data = snapshot.data!.docs
                  .map((DocumentSnapshot document) =>
                      document.data() as Map<String, dynamic>)
                  .toList();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
              return GroupedListView<dynamic, String>(
                controller: _scrollController,
                order: GroupedListOrder.DESC,
                elements: data,
                groupBy: (element) => DateFormat.yMMMMd()
                    .format((element['timestamp'] as Timestamp).toDate()),
                groupComparator: (value1, value2) => (value2.compareTo(value1)),
                itemComparator: (item1, item2) =>
                    (item2['timestamp'] as Timestamp)
                        .compareTo(item1['timestamp'] as Timestamp),
                useStickyGroupSeparators: true,
                groupSeparatorBuilder: (String value) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                itemBuilder: (context, dynamic element) {
                  final isOutgoingMessage =
                      element['username'] == widget.username;
                  final messageFuture =
                      element['translated_message'] ?? element['message'];
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
                    child: Row(
                      mainAxisAlignment: isOutgoingMessage
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: isOutgoingMessage
                                  ? Colors.grey
                                  : Colors.green,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomLeft: !isOutgoingMessage
                                    ? Radius.circular(0)
                                    : Radius.circular(15),
                                bottomRight: isOutgoingMessage
                                    ? Radius.circular(0)
                                    : Radius.circular(15),
                              )),
                          padding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10.0),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75),
                          child: Column(
                            crossAxisAlignment: isOutgoingMessage
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                element['username'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              FutureBuilder<String>(
                                future: _translateMessage(
                                    messageFuture, widget.selectedLanguage),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      snapshot.data!,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    );
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                },
                              ),
                              SizedBox(height: 4),
                              Text(
                                DateFormat('HH:mm').format(
                                    (element['timestamp'] as Timestamp)
                                        .toDate()),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF141414),
        child: Container(
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
      ),
    );
  }
}
