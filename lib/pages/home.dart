import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_project/models/Person.dart';
import 'package:instagram_project/models/Post.dart';
import 'package:instagram_project/services/AuthorizationService.dart';
import 'package:instagram_project/services/firestoreService.dart';
import 'package:instagram_project/widgets/postCard.dart';
import 'package:instagram_project/widgets/undeletable.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Post> _gonderiler = [];

  _akisGonderileriniGetir() async {
    String aktifKullaniciId =
        Provider.of<AuthorizationService>(context, listen: false).userId;

    List<Post> gonderiler =
        await firestoreService().getFlowPosts(aktifKullaniciId);
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _akisGonderileriniGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          "MemetonS",
          style: TextStyle(color: Colors.blue,fontStyle: FontStyle.italic),
        ),
        centerTitle: false,
        actions: [IconButton(icon: Icon(Icons.send,color: Colors.grey.shade800,), onPressed: (){})],
      ),
      body: ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: _gonderiler.length,
          itemBuilder: (context, index) {
            Post post = _gonderiler[index];

            return Undeletable(
                future: firestoreService().getUser(post.ownerID),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox(
                      height: 0.0,
                    );
                  }
                  Person person = snapshot.data;

                  return postCard(
                    post: post,
                    person: person,
                  );
                });
          }),
    );
  }
}
