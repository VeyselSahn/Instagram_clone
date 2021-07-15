import 'package:flutter/material.dart';
import 'package:instagram_project/models/Person.dart';
import 'package:instagram_project/pages/profile.dart';
import 'package:instagram_project/services/firestoreService.dart';

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  TextEditingController _controller = TextEditingController();
  List<String> _postList = [
    "https://cdn.pixabay.com/photo/2020/10/07/18/40/dog-5635960_960_720.jpg",
    "https://cdn.pixabay.com/photo/2021/06/18/12/57/spoonbill-6346118_960_720.jpg",
    "https://cdn.pixabay.com/photo/2017/08/01/08/29/woman-2563491_960_720.jpg",
    "https://cdn.pixabay.com/photo/2015/09/02/13/24/girl-919048_960_720.jpg",
    "https://cdn.pixabay.com/photo/2015/01/27/09/58/man-613601_960_720.jpg",
    "https://cdn.pixabay.com/photo/2016/05/23/23/32/human-1411499_960_720.jpg",

  ];
  List<GridTile> fayanslar = [];
  Future<List<Person>> _list;
  @override
  void initState() {
    super.initState();
    _postList.forEach((gonderi) {
      fayanslar.add(_fayansOlustur(gonderi));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarS(),
      body: _list != null ? _resultS() : gridview(),
    );
  }


  AppBar _appBarS() {
    return AppBar(
        titleSpacing: 0.0,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.all(10),
          child: TextFormField(
            controller: _controller,
            onFieldSubmitted: (value) {
              setState(() {
                _list = firestoreService().searchUser(value);
              });
            },
            decoration: InputDecoration(
              fillColor: Colors.grey.shade200,
              filled: true,
              border: InputBorder.none,
              hintText: "Search",
              hintStyle: TextStyle(color: Colors.black),
              focusedBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.white)),
              enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.white),
              ),
              prefixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.black,

                  ),
                  onPressed: () => _controller.clear(),),
            ),
          ),
        ));
  }

  Widget _resultS() {
    return FutureBuilder<List<Person>>(
      future: _list,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data.length == 0) {
          return Text("No result found");
        }

        return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              Person person = snapshot.data[index];
              return listing(person);
            });
      },
    );
  }

  Widget listing(Person person) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Profile(
          profileID: person.id,
        ),
      )),
      child: ListTile(
        leading: CircleAvatar(
          radius: 40.0,
          backgroundImage: person.pp != null
              ? NetworkImage(person.pp)
              : AssetImage("assets/prof.jpg"),
        ),
        title: Text(
          person.username,
          style: TextStyle(color: Colors.black, fontSize: 15.0),
        ),
        subtitle: Text(
          person.regarding,
          style: TextStyle(color: Colors.grey, fontSize: 12.0),
        ),
      ),
    );
  }

  Widget gridview() {
    return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0,
        childAspectRatio: 1.0,

        children: fayanslar);
  }

  GridTile _fayansOlustur(String text) {
    if (text != null) {
      return GridTile(
          child: Image.network(
        text,
        fit: BoxFit.cover,
      ));
    }
    return null;
  }
}
