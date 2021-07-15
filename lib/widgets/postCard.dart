import 'package:flutter/material.dart';
import 'package:instagram_project/models/Person.dart';
import 'package:instagram_project/models/Post.dart';
import 'package:instagram_project/pages/commentPage.dart';
import 'package:instagram_project/pages/profile.dart';
import 'package:instagram_project/services/AuthorizationService.dart';
import 'package:instagram_project/services/firestoreService.dart';
import 'package:provider/provider.dart';

class postCard extends StatefulWidget {
  final Post post;
  final Person person;

  const postCard({Key key, this.post, this.person}) : super(key: key);

  @override
  _postCardState createState() => _postCardState();
}

class _postCardState extends State<postCard> {
  int _likeA = 0;
  bool _liked = false;
  String _activeID;

  @override
  void initState() {
    super.initState();
    _activeID =
        Provider.of<AuthorizationService>(context, listen: false).userId;

    _likeA = widget.post.likeA;
    isLiked();
  }

  isLiked() async {
    bool lk = await firestoreService().isLiked(widget.post, _activeID);
    if (lk) {
      setState(() {
        _liked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Column(
        children: [title(), picture(), bottomSection()],
      ),
    );
  }

  Future<Widget> uploaded() {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text("Options"),
        children: [
         
          SimpleDialogOption(
            child: Text("Delete",style: TextStyle(color: Colors.redAccent[700]),),
            onPressed: () {
             firestoreService().deletePost(post: widget.post,userID: _activeID);
             Navigator.pop(context);
            },
          ),
          SimpleDialogOption(
            child: Text("Back"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }


  Widget title() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(profileID: widget.post.ownerID,),)),
          child: CircleAvatar(
              backgroundImage: widget.person != null
                  ? NetworkImage(widget.person.pp)
                  : NetworkImage("assets/prof.jpg")),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(profileID: widget.post.ownerID,),)),
            child: Text(
              widget.person.username,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            widget.post.location,
            style: TextStyle(
                color: Colors.grey[800],
                fontSize: 12.0,
                fontWeight: FontWeight.normal),
          )
        ],
      ),
      
      
      
      trailing: widget.person.id == _activeID ? IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: () {uploaded();},
        color: Colors.black,
      ) : Text(""),
      contentPadding: EdgeInsets.all(0.0),
    );
  }
  

  Widget picture() {
    if (widget.post != null) {
      return GestureDetector(
        onDoubleTap: _likeFunc,
        child: Image.network(
          widget.post.url,
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
        ),
      );
    }
    return null;
  }

  Widget bottomSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: _liked
                  ? Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                  : Icon(Icons.favorite_border),
              onPressed: _likeFunc,
            ),
            IconButton(
              icon: Icon(Icons.comment),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CommentPage(post: widget.post),
                ));
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text("$_likeA liked",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0)),
        ),
        SizedBox(
          height: 4.0,
        ),
        widget.post.explanation.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: RichText(
                  text: TextSpan(
                      text: widget.person.username + "  ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                          color: Colors.black),
                      children: [
                        TextSpan(
                            text: widget.post.explanation,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 13.0,
                                fontWeight: FontWeight.normal))
                      ]),
                ),
              )
            : SizedBox(
                height: 0.0,
              ),
      ],
    );
  }

  void _likeFunc() {
    if (_liked) {
      setState(() {
        _liked = false;
        _likeA = _likeA - 1;
      });
      firestoreService().dislikewithFirebase(widget.post, _activeID);
    } else {
      setState(() {
        _liked = true;
        _likeA = _likeA + 1;
      });
      firestoreService().likewithFirebase(widget.post, _activeID);
    }
  }
}
