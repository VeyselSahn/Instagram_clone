import 'package:flutter/material.dart';
import 'package:instagram_project/models/Person.dart';
import 'package:instagram_project/models/Post.dart';
import 'package:instagram_project/pages/editP.dart';
import 'package:instagram_project/services/AuthorizationService.dart';
import 'package:instagram_project/services/firestoreService.dart';
import 'package:instagram_project/widgets/postCard.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  final String profileID;

  const Profile({Key key, this.profileID}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _posts, _followers, _following;
  List<Post> _postList = [];
  Person aperson;
  String _id;
  bool _follow = false;

  String tileStatus = "liste";

  void getFollowers() async {
    int a = await firestoreService().getfollowings(widget.profileID);
    setState(() {
      _followers = a;
    });
  }

  void getFollowings() async {
    int a = await firestoreService().getfollowings(widget.profileID);
    setState(() {
      _following = a;
    });
  }

  void getPost() async {
    List<Post> posts = await firestoreService().getPosts(widget.profileID);
    setState(() {
      _postList = posts;
      _posts = posts.length;
    });
  }

  Future<void> controlFollow() async {
    bool _bool = await firestoreService()
        .controlFollow(ownerID: _id, otherID: widget.profileID);
    setState(() {
      _follow = _bool;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFollowers();
    getFollowings();
    getPost();
    _id = Provider.of<AuthorizationService>(context, listen: false).userId;
    controlFollow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontSize: 20.0),
        ),
        actions: [
          widget.profileID == _id
              ? IconButton(
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Colors.blue,
                  ),
                  onPressed: AuthorizationService().exit)
              : SizedBox(
                  height: 0.0,
                )
        ],
      ),
      body: FutureBuilder(
          future: firestoreService().getUser(widget.profileID),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            aperson = snapshot.data;
            return ListView(
              children: <Widget>[
                _detailPage(snapshot.data),
                _gonderileriGoster(snapshot.data)
              ],
            );
          }),
    );
  }

  Widget _gonderileriGoster(Person profilData) {
    if (tileStatus == "liste") {
      return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.only(bottom: 5.0),
          primary: false,
          itemCount: _postList.length,
          itemBuilder: (context, index) {
            return postCard(
              post: _postList[index],
              person: profilData,
            );
          });
    } else {
      List<GridTile> fayanslar = [];
      _postList.forEach((gonderi) {
        fayanslar.add(_fayansOlustur(gonderi));
      });

      return GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
          childAspectRatio: 1.0,
          physics: NeverScrollableScrollPhysics(),
          children: fayanslar);
    }
  }

  GridTile _fayansOlustur(Post gonderi) {
    if (gonderi != null) {
      return GridTile(
          child: Image.network(
        gonderi.url,
        fit: BoxFit.cover,
      ));
    }
    return null;
  }

  Widget _detailPage(Person user1) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 50.0,
                backgroundImage: user1.pp.isNotEmpty
                    ? NetworkImage(user1.pp)
                    : AssetImage("assets/profile.png"),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _counter("Posts", _posts),
                    _counter("Followers", _followers),
                    _counter("Following", _following)
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          user1.username != null ? Text(user1.username) : Text("Username"),
          SizedBox(
            height: 10.0,
          ),
          Text(user1.regarding),
          SizedBox(
            height: 40.0,
          ),
          widget.profileID == _id
              ? Container(
                  height: 40.0,
                  width: double.infinity,
                  child: OutlineButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => editP(
                          aperson: aperson,
                        ),
                      ));
                    },
                    color: Colors.black,
                    child: Text(
                      "Edit profile",
                      style: TextStyle(color: Colors.black, fontSize: 15.0),
                    ),
                  ),
                )
              : decision()
        ],
      ),
    );
  }

  Widget decision() {
    return _follow == true ? Notfollow() : follow();
  }

  Widget follow() {
    return Container(
      color: Colors.lightBlue,
      height: 40.0,
      width: double.infinity,
      child: OutlineButton(
        onPressed: () {
          firestoreService().follow(ownerID: _id, otherID: widget.profileID);
          setState(() {
            _follow = true;
            _followers = _followers + 1;
          });
        },
        color: Colors.lightBlue,
        child: Text(
          "Follow",
          style: TextStyle(color: Colors.white, fontSize: 15.0),
        ),
      ),
    );
  }

  Widget Notfollow() {
    return Container(
      height: 40.0,
      color: Colors.lightBlue,
      width: double.infinity,
      child: OutlineButton(
        onPressed: () {
          firestoreService().unfollow(ownerID: _id, otherID: widget.profileID);
          setState(() {
            _follow = false;
            _followers = _followers - 1;
          });
        },
        color: Colors.lightBlue,
        child: Text(
          "Unfollow",
          style: TextStyle(color: Colors.white, fontSize: 15.0),
        ),
      ),
    );
  }

  Widget _counter(String title, int amount) {
    return Column(
      children: [
        Text(
          amount.toString(),
          style: TextStyle(color: Colors.black, fontSize: 15.0),
        ),
        Text(
          title,
          style: TextStyle(
              color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
