import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String? username;

  const ChatPage({Key? key, this.username}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'messages';

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
                          return ListTile(
                            title: Text(data['username'] ?? ''),
                            subtitle: Text(data['message'] ?? ''),
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
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(hintText: 'Type a message'),
                ),
              ),
              ElevatedButton(
                child: Text('Send'),
                onPressed: () {
                  _db.collection(_collectionName).add({
                    'username': widget.username,
                    'message': _textController.text,
                    'timestamp': DateTime.now(),
                  });
                  _textController.clear();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
