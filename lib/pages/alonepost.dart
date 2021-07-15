import 'package:flutter/material.dart';
import 'package:instagram_project/models/Person.dart';
import 'package:instagram_project/models/Post.dart';
import 'package:instagram_project/services/firestoreService.dart';
import 'package:instagram_project/widgets/postCard.dart';

class AlonePost extends StatefulWidget {
  final String postID;
  final String id;

  const AlonePost({Key key, this.postID, this.id}) : super(key: key);
  
  @override
  _AlonePostState createState() => _AlonePostState();
}

class _AlonePostState extends State<AlonePost> {
  Post _post;
  Person _user;
  bool _loading = true;
  
  getUserPost() async{
    Person person=await firestoreService().getUser(widget.id);
   Post post =await firestoreService().getPost(postId: widget.postID,userID: widget.id);
   setState(() {
     _post = post;
     _user = person;
     _loading =false;
   });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserPost();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text("Post"),
        backgroundColor: Colors.blueGrey[300],
        iconTheme: IconThemeData(color: Colors.white),
        
      ) ,
      body: !_loading ? postCard(person: _user,post: _post,): Center(child: CircularProgressIndicator())
    );
  }
}
