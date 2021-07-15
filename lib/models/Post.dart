import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String url;
  final String explanation;
  final String ownerID;
  final String location;
  final int likeA;

  Post(
      {this.id,
      this.url,
      this.explanation,
      this.ownerID,
      this.location,
      this.likeA});

  factory Post.producingDoc(DocumentSnapshot doc) {
    var docData = doc.data();
    return Post(
      id: doc.id,
      url: docData['url'],
      explanation: docData['explanation'],
      ownerID: docData['ownerID'],
      location: docData['location'],
      likeA: docData['likeA'],
    );
  }
}
