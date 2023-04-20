import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
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
              stream: _db.collection(_collectionName).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    return ListView(
                      reverse: true,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(
                            '${data['username']}: ${data['message']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    );
                }
              },
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(hintText: 'Username'),
                    ),
                    TextFormField(
                      controller: _textController,
                      decoration: InputDecoration(hintText: 'Type a message'),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                child: Text('Send'),
                onPressed: () {
                  _db.collection(_collectionName).add({
                    'username': _usernameController.text,
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
