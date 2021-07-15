import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_project/models/Person.dart';
import 'package:instagram_project/pages/loginPage.dart';
import 'package:instagram_project/pages/mainPage.dart';
import 'package:instagram_project/services/AuthorizationService.dart';
import 'package:provider/provider.dart';
import 'package:set_state/set_state.dart';

class NavigatorService extends StatelessWidget {
  String ID;
  final _scKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final _yetkilendirmeServisi =
        Provider.of<AuthorizationService>(context, listen: false);

    return StreamBuilder(
        key: _scKey,
        stream: AuthorizationService().chaseStatus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return CircularProgressIndicator();

          if (snapshot.hasData) {
            Person person = snapshot.data;
            _yetkilendirmeServisi.userId = person.id;

            return mainPage();
          } else
            return loginPage();
        });
  }
}
