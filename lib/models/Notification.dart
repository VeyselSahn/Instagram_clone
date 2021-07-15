import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Duyuru {
  final String id;
  final String didWho;
  final String typeActivity;
  final String postID;
  final String postUrl;
  final String comment;

  final Timestamp time;

  Duyuru(
      {@required this.postUrl,
      this.comment,
      this.typeActivity,
      this.postID,
      this.didWho,
      this.time,
      this.id});

  factory Duyuru.producingDoc(DocumentSnapshot doc) {
    var docData = doc.data();
    return Duyuru(
      id: doc.id,
      didWho: docData['didWho'],
      typeActivity: docData['typeActivity'],
      postID: docData['postID'],
      postUrl: docData['postUrl'],
      comment: docData['comment'],
      time: docData['time'],
    );
  }
}
