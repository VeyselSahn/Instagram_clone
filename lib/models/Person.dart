import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Person {
  final String id;
  final String username;
  final String pp;
  final String mail;
  final String regarding;

  Person(
      {@required this.id, this.username, this.pp, this.mail, this.regarding});

  factory Person.producingFirebase(User kullanici) {
    return Person(
      id: kullanici.uid,
      username: kullanici.displayName,
      pp: kullanici.photoURL,
      mail: kullanici.email,
    );
  }

  factory Person.producingDoc(DocumentSnapshot doc) {
    var docData = doc.data();
    return Person(
      id: doc.id,
      username: docData['username'],
      mail: docData['mail'],
      pp: docData['pp'],
      regarding: docData['regarding'],
    );
  }
}
