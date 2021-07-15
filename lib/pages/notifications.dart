import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:instagram_project/models/Notification.dart';
import 'package:instagram_project/models/Person.dart';
import 'package:instagram_project/pages/alonepost.dart';
import 'package:instagram_project/pages/profile.dart';
import 'package:instagram_project/services/AuthorizationService.dart';
import 'package:instagram_project/services/firestoreService.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<Duyuru> notfs = [];
  String activeID;
  bool loading = true;
  Person person;

  Future<void> getNotfs(String id) async {
    List<Duyuru> list = await firestoreService().getNotfs(id);
    if (mounted) {
      setState(() {
        notfs = list;
        loading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    activeID = Provider.of<AuthorizationService>(context, listen: false).userId;
    getNotfs(activeID);
  }

  Widget showNotfs() {
    if (loading == true) return Center(child: Text("Loading"));

    if (notfs.isEmpty) return emptyStatus();

    return RefreshIndicator(
      onRefresh: () => getNotfs(activeID),
      child: ListView.builder(
        itemCount: notfs.length,
        itemBuilder: (context, index) {
          Duyuru d = notfs[index];
          return notfsList(d);
        },
      ),
    );
  }

  Widget notfsList(Duyuru duyuru) {
    String message = messages(duyuru.typeActivity);
    return FutureBuilder(
      future: firestoreService().getUser(duyuru.didWho),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {return SizedBox(height: 0,);}

        Person p = snapshot.data;
        return Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ListTile(
            leading: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return Profile(
                      profileID: p.id,
                    );
                  },
                ));
              },
              child: CircleAvatar(
                backgroundImage: p.pp != null
                    ? NetworkImage(p.pp)
                    : AssetImage("assets/profile.png"),
                radius: 30.0,
              ),
            ),
            title: RichText(
              text: TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return Profile(
                            profileID: p.id,
                          );
                        },
                      ));
                    },
                  text: "${p.username}  ",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: "$message",
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.normal))
                  ]),
            ),
            subtitle: Text(
              timeago.format(duyuru.time.toDate(), locale: "en"),
              style: TextStyle(color: Colors.grey, fontSize: 12.0),
            ),
            trailing: showPost(duyuru),
          ),
        );
      },
    );
  }

  Widget showPost(Duyuru ntfc) {
    if (ntfc.typeActivity == "following")
      return SizedBox(
        height: 0.0,
      );
    else if (ntfc.typeActivity == "comment" || ntfc.typeActivity == "like") {
      return InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AlonePost(id: ntfc.didWho, postID: ntfc.postID);
            }));
          },
          child: ntfc.postUrl != null
              ? Image.network(
                  ntfc.postUrl,
                  fit: BoxFit.cover,
                  height: 50.0,
                  width: 50.0,
                )
              : Image.asset("assets/prof.jpg"));
    }
  }

  String messages(String type) {
    if (type == "like")
      return " liked your post";
    else if (type == "comment")
      return " commented your post";
    else if (type == "following") return " followed you";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        leading: null,
        centerTitle: true,
        title: Text(
          "Activities",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: showNotfs(),
    );
  }

  Widget emptyStatus() {
    return Center(
      child: FutureBuilder(
          future: firestoreService().getUser(activeID),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            Person pers = snapshot.data;
            return Container(
              height: 300.0,
              width: 270.0,
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: pers.pp != null
                        ? NetworkImage(pers.pp)
                        : Image.asset("assets/emptypage.jpg",fit: BoxFit.cover,),
                    radius: 50.0,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    "Activity On Your Posts",
                    style: TextStyle(color: Colors.black, fontSize: 17.0),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Text(
                      "When one of your posts is taken likes or comments , you'll see it here ",
                      style: TextStyle(color: Colors.grey[600], fontSize: 15.0))
                ],
              ),
            );
          }),
    );
  }
}
