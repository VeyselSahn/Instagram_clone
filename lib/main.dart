import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram_project/services/AuthorizationService.dart';
import 'package:instagram_project/services/NavigatorService.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthorizationService>(
      create: (_) => AuthorizationService(),
      child: MaterialApp(
        title: 'Instagram Project',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: NavigatorService(),
      ),
    );
  }
}
