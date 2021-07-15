import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_project/services/AuthorizationService.dart';
import 'package:instagram_project/services/StorageService.dart';
import 'package:instagram_project/services/firestoreService.dart';
import 'package:provider/provider.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File file;
  TextEditingController explanationController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  bool loading;
  @override
  Widget build(BuildContext context) {
    return file == null ? uploadButton() : uploading();
  }

  Widget uploadButton() {
    return IconButton(
        icon: Icon(
          Icons.file_upload,
          size: 50.0,
          color: Colors.black,
        ),
        onPressed: () {
          option(context);
        });
  }

  Widget uploading() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "New Post",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                file = null;
              });
            }),
        actions: [
          IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.black,
            ),
            onPressed: sender,
          )
        ],
      ),
      body: bodyPart(),
    );
  }

  void sender() async {
    setState(() {
      loading = true;
    });
    String url = await StorageService().postStorage(file);

    String id =
        Provider.of<AuthorizationService>(context, listen: false).userId;

    firestoreService().createPost(
        url: url,
        expla: explanationController.text,
        location: locationController.text,
        id: id);

    print(url);

    setState(() {
      explanationController.clear();
      locationController.clear();
      loading = false;
      file = null;
    });
  }

  Widget bodyPart() {
    return ListView(
      children: [
        AspectRatio(
          aspectRatio: 10.0 / 12.0,
          child: Image.file(
            file,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: 25.0,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0, left: 12.0),
          child: TextFormField(
            controller: explanationController,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(12.0),
                hintText: "Enter an explanation "),
          ),
        ),
        SizedBox(
          height: 25.0,
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextFormField(
            controller: locationController,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(12.0),
                hintText: "You can enter your location "),
          ),
        ),
      ],
    );
  }
  option(BuildContext context) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    camera();
                    Navigator.pop(context);
                  },
                  leading: Icon(
                    Icons.camera,
                    color: Colors.teal,
                  ),
                  title: Text(
                    "Take a photo",
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ),
                ListTile(
                  onTap: () {
                    gallery();
                    Navigator.pop(context);
                  },
                  leading: Icon(
                    Icons.image,
                    color: Colors.teal,
                  ),
                  title: Text(
                    "Choose on gallery",
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ),
              ],
            )));
  }

  Future<Widget> uploaded() {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text("Create A Post"),
        children: [
          SimpleDialogOption(
            child: Text("Choose at gallery"),
            onPressed: () {
              chooseGallery();
            },
          ),
          SimpleDialogOption(
            child: Text("Take photo"),
            onPressed: () {
              takePhoto();
            },
          ),
          SimpleDialogOption(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  void takePhoto() async {
    Navigator.pop(context);
    final _picker = ImagePicker();
    var image = await _picker.getImage(
        source: ImageSource.camera,
        maxHeight: 400,
        maxWidth: 600,
        imageQuality: 100);
    setState(() {
      file = File(image.path);
    });
  }

  void chooseGallery() async {
    Navigator.pop(context);
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

  void gallery() async {
    final _picker = ImagePicker();
    var image =
    await _picker.getImage(source: ImageSource.gallery, imageQuality: 100);
    if (image != null) {
      setState(() {
        file = File(image.path);
      });
    } else
      print("null");
  }

  void camera() async {
    final _picker = ImagePicker();
    var image =
    await _picker.getImage(source: ImageSource.camera, imageQuality: 100);
    if (image != null) {
      setState(() {
        file = File(image.path);
      });
    } else
      print("null");
  }
}
