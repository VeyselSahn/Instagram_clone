import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String ownerID;
  final String content;
  final Timestamp time;

  Comment({this.id, this.ownerID, this.content, this.time});

  factory Comment.producingDoc(DocumentSnapshot doc) {
    var docData = doc.data();
    return Comment(
      id: doc.id,
      ownerID: docData['ownerID'],
      content: docData['content'],
      time: docData['time'],
    );
  }
}
