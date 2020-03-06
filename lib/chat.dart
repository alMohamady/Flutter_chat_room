import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Chat extends StatefulWidget {

  static const String id = "CHAT";
  final FirebaseUser user;

  const Chat( {Key key, this.user}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  TextEditingController messageController = TextEditingController(); 
  ScrollController scrollController = ScrollController();

  Future<void> callBack() async {
   if (messageController.text.length > 0){
     await _firestore.collection("messages").add({
       'text': messageController.text, 
       'from': widget.user.email,
       'date': DateTime.now().toIso8601String().toString()
     });
     messageController.clear();
     scrollController.animateTo(
         scrollController.position.maxScrollExtent,
         duration: const Duration(milliseconds: 3000),
         curve: Curves.easeOut);
   }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Hero(
          tag: 'logo',
          child: Container(
            height: 40,
            child: Image.asset("assets/images/chat.png"),
          ),
        ),
        title: Text("My Chat Room"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: (){
              _auth.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection("messages").orderBy('date').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  List<DocumentSnapshot> docs = snapshot.data.documents;
                  
                  List<Widget> messages = docs.map((doc) => Message(
                    from: doc.data["from"],
                    text: doc.data["text"],
                    me: widget.user.email == doc.data["from"]
                  )).toList();

                  return ListView(
                    controller: scrollController,
                    children: <Widget>[
                      ...messages,
                    ],
                  );
                },
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "Enter your message ......",
                        border: const OutlineInputBorder()
                      ),
                      onSubmitted: (value) => callBack(),
                    ),
                  ),
                  SendButton(
                    text: 'Send',
                    callback: callBack,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


class SendButton extends StatelessWidget {

  final String text;
  final VoidCallback callback;

  const SendButton({ Key key, this.text, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FlatButton(
      color: Colors.orange,
      onPressed: callback,
      child: Text(text),
    );
  }
}

class Message extends StatelessWidget {

  final String from;
  final String text;
  final bool me;

  const Message({Key key, this.from, this.text, this.me}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: me? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(from),
          Material(
            color: me ? Colors.teal : Colors.red,
            borderRadius: BorderRadius.circular(10),
            elevation: 6,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Text(
                text
              ),
            ),
          )
        ],
      ),
    );
  }
}


