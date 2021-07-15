import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  String id;
  Reference _storage = FirebaseStorage.instance.ref();

  Future<String> postStorage(File image) async {
    id = Uuid().v4();
    UploadTask task = _storage.child("images/posts/post$id.jpg").putFile(image);
    TaskSnapshot snapshot = await task;
    String url = await snapshot.ref.getDownloadURL();

    return url;
  }

  Future<String> profileStorage(File image) async {
    id = Uuid().v4();
    UploadTask task = _storage.child("images/profile/pp$id.jpg").putFile(image);
    TaskSnapshot snapshot = await task;
    String url = await snapshot.ref.getDownloadURL();

    return url;
  }

  void deletePost(String url){
    RegExp search = RegExp(r"post.+\.jpg");
    var connect = search.firstMatch(url);
    String nameable = connect[0];

    if(nameable != null){_storage.child(
        "images/posts/$nameable").delete();
    }
  }
}
