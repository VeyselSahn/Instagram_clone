import 'package:flutter/material.dart';
import 'package:instagram_project/models/Comment.dart';
import 'package:instagram_project/models/Person.dart';
import 'package:instagram_project/models/Post.dart';
import 'package:instagram_project/services/AuthorizationService.dart';
import 'package:instagram_project/services/firestoreService.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentPage extends StatefulWidget {
  final Post post;

  const CommentPage({Key key, this.post}) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  TextEditingController content = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Comments",
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Column(
          children: [_commentSection(), input()],
        ));
  }

  Widget _commentSection() {
    return Expanded(
      child: StreamBuilder(
        stream: firestoreService().getComments(widget.post.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              Comment comment = Comment.producingDoc(snapshot.data.docs[index]);

              return _pageStruc(comment);
            },
          );
        },
      ),
    );
  }

  Widget _pageStruc(Comment comment) {
    return FutureBuilder<Person>(
        future: firestoreService().getUser(comment.ownerID),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return SizedBox(height: 0,);
          Person p = snapshot.data;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.lightBlue,
              backgroundImage: NetworkImage(p.pp),
              radius: 40.0,
            ),
            title: RichText(
              text: TextSpan(
                  text: p.username + "   ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.black),
                  children: [
                    TextSpan(
                        text: comment.content,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal))
                  ]),
            ),
            subtitle: Text(
              timeago.format(comment.time.toDate(), locale: "en"),
              style: TextStyle(color: Colors.grey[700], fontSize: 12.0),
            ),
          );
        });
  }
  Widget input() {
    return Container(
      margin: EdgeInsets.all(8),
      child: Row(
        children: [
          Flexible(
            child: TextFormField(
              controller: content,
              minLines: 1,
              maxLines: 4,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w400),
              onChanged: (textValue) {
                setState(() {});
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.emoji_emotions_outlined,
                    color: Colors.white),
                fillColor: Colors.blue,
                filled: true,
                hintText: 'Enter your comment',
                hintStyle: TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.grey[200])),
                enabledBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(color: Colors.grey[200]),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            child: GestureDetector(
              onTap: () {
                sendComm();
              },
              child: ClipOval(
                child: Container(
                    color: Colors.blue,
                    padding: EdgeInsets.all(10),
                    child: Icon( Icons.send,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void sendComm() {
    String id =
        Provider.of<AuthorizationService>(context, listen: false).userId;

    if(content.text.isEmpty) return null;

    firestoreService()
        .addComment(content: content.text, ownerID: id, post: widget.post);
    content.clear();
  }
}
