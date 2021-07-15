import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_project/models/Person.dart';
import 'package:instagram_project/services/AuthorizationService.dart';
import 'package:instagram_project/services/StorageService.dart';
import 'package:instagram_project/services/firestoreService.dart';
import 'package:provider/provider.dart';

class editP extends StatefulWidget {
  final Person aperson;

  const editP({Key key, this.aperson}) : super(key: key);

  @override
  _editPState createState() => _editPState();
}

class _editPState extends State<editP> {
  Person personm;
  String username, regard;
  File file;
  bool _loading = false;
  var _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
            print("Clicked Exit");
          },
        ),
        backgroundColor: Colors.grey[200],
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 15.0),
            icon: Icon(
              Icons.check,
              size: 30.0,
            ),
            color: Colors.black,
            alignment: Alignment.centerRight,
            onPressed: () => _save(),
          ),
        ],
      ),
      body: ListView(
        children: [
          _loading
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.0,
                ),
          profileS(),
          textS()
        ],
      ),
    );
  }

  _save() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _loading = true;
      });
      _formKey.currentState.save();

      String photoUrl;
      if (file == null) {
        photoUrl = widget.aperson.pp;
      } else {
        photoUrl = await StorageService().profileStorage(file);
      }

      final _id =
          Provider.of<AuthorizationService>(context, listen: false).userId;
      firestoreService().updateUser(
          id: _id, username: username, regarding: regard, url: photoUrl);
    }
    setState(() {
      _loading = false;
    });

    Navigator.pop(context);
  }

  void chooseGallery() async {
    final _picker = ImagePicker();
    var image = await _picker.getImage(
        source: ImageSource.gallery,
        maxHeight: 400,
        maxWidth: 600,
        imageQuality: 100);
    setState(() {
      file = File(image.path);
    });
  }

  Widget profileS() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Center(
        child: InkWell(
          onTap: () => chooseGallery(),
          child: CircleAvatar(
            radius: 55.0,
            backgroundImage: file == null
                ? NetworkImage(widget.aperson.pp)
                : FileImage(file),
          ),
        ),
      ),
    );
  }

  Widget textS() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(
              height: 20.0,
            ),
            TextFormField(
              initialValue: widget.aperson.username,
              decoration: InputDecoration(labelText: "Username"),
              validator: (value) {
                if (value.trim().length < 4)
                  return "Username must be longer 4";
                else if (value.trim().length > 50)
                  return "Username can't be longer 50 ";
                else
                  return null;
              },
              onSaved: (newValue) => username = newValue,
            ),
            SizedBox(
              height: 20.0,
            ),
            TextFormField(
              initialValue: widget.aperson.regarding,
              decoration: InputDecoration(labelText: "Regarding"),
              validator: (value) {
                if (value != null) {
                  return null;
                } else
                  return "Regarding can't be empty";
              },
              onSaved: (newValue) => regard = newValue,
            ),
          ],
        ),
      ),
    );
  }
}
