import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sendway/constants.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class ChatScreen extends StatefulWidget {
  static final String id='chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  ScrollController _scrollController=ScrollController();
  TextEditingController messagecontroller=TextEditingController();
  String messagetext;
  final _firebase=FirebaseFirestore.instance;
  final _auth=FirebaseAuth.instance;
  User LoggedInuser;
@override
  void initState() {
    super.initState();
    getcurrentuser();
  }
  void getcurrentuser(){
    try{
    final user=_auth.currentUser;
    LoggedInuser=user;
  }catch(e){
      print(e);
    }}
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  _auth.signOut();
                 Navigator.pop(context);
                }),
          ],
          title: Text('⚡️Chat'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder(
                stream: _firebase.collection('messages').orderBy('timestamp').snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (!snapshot.hasData) {
                      return Column(
                        children: [
                          CircularProgressIndicator(
                            backgroundColor: Colors.lightBlueAccent,
                          )
                        ],);
                    }

                    final messages = snapshot.data.docs;
                    List<Container> messagesList = [];
                    for (var message in messages) {
                      final messagetext = message.data();
                      final messagesingle = messagetext['messagetext'];
                      final sender = messagetext['sender'];
                      final isMe = (sender == LoggedInuser.email);
                      var messageBubble = Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Material(
                              elevation: 4.0,
                              borderRadius: BorderRadius.only(
                                topLeft: isMe ? Radius.circular(16.0) : Radius
                                    .circular(0.0),
                                topRight: isMe ? Radius.circular(0.0) : Radius
                                    .circular(16.0),
                                bottomLeft: Radius.circular(16.0),
                                bottomRight: Radius.circular(16.0),
                              ),
                              color: isMe ? Colors.green : Colors
                                  .white,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 16.0),
                                child: Text(
                                  messagesingle,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black54,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 2.0),
                            Text(
                              sender,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      );
                      messagesList.add(messageBubble);
                    }
                    return Container(
                      child: Expanded(
                        child: ListView.builder(
                        itemCount: messagesList.length, // Replace with the actual item count
                        itemBuilder: (BuildContext context, int index) {
                          // Build your list items here
                          return messagesList[index];
                        },
                      ),
                      ),
                    );
                  },
              ),
              Container(
                decoration: kMessageContainerDecoration,
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messagecontroller,
                        onChanged: (value) {
                          //Do something with the user input.
                          messagetext=value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _firebase.collection('messages').add({'sender':LoggedInuser.email,'messagetext':messagetext,'timestamp':
FieldValue.serverTimestamp()});
                        messagecontroller.clear();
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}
