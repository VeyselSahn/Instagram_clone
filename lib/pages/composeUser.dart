import 'dart:math';

import 'package:flutter/material.dart';
import 'package:instagram_project/models/Person.dart';
import 'package:instagram_project/pages/mainPage.dart';
import 'package:instagram_project/services/AuthorizationService.dart';
import 'package:instagram_project/services/firestoreService.dart';

class composeUser extends StatefulWidget {
  @override
  _composeUserState createState() => _composeUserState();
}

class _composeUserState extends State<composeUser> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String username, mail, passw;
  bool linearLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        title: Text(
          "MemetonS",
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
      ),
      body: Stack(children: [_compoteUserElements(), loadingFunc()]),
    );
  }

  Widget loadingFunc() {
    if (linearLoading)
      return (LinearProgressIndicator());
    else
      return Center();
  }

  Widget _compoteUserElements() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.only(top: 60.0, right: 20.0, left: 20.0),
        children: [
          Center(
            child: Text(
              "Create An Account",
              style: TextStyle(color: Colors.lightBlue, fontSize: 18.0),
            ),
          ),
          SizedBox(
            height: 12.0,
          ),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value.isEmpty)
                return "Must enter an email";
              else if (!value.contains("@") || (!value.contains(".")))
                return "Must own '@' and '.'";
              else
                return null;
            },
            decoration: InputDecoration(
                hintText: "Enter an email", prefixIcon: Icon(Icons.mail)),
            onSaved: (newValue) => mail = newValue,
          ),
          SizedBox(
            height: 40.0,
          ),
          TextFormField(
            keyboardType: TextInputType.name,
            autocorrect: true,
            validator: (value) {
              if (value.isEmpty)
                return "Must enter an name";
              else
                return null;
            },
            decoration: InputDecoration(
              hintText: "Name Surname",
              prefixIcon: Icon(Icons.person),
            ),
            onSaved: (newValue) => username = newValue,
          ),
          SizedBox(
            height: 40.0,
          ),
          TextFormField(
            obscureText: true,
            validator: (value) {
              if (value.isEmpty)
                return "Must enter an password";
              else if (value.trim().length < 6)
                return "Can't be shorter 6 digits";
              else
                return null;
            },
            decoration: InputDecoration(
                hintText: "Password", prefixIcon: Icon(Icons.local_parking)),
            onSaved: (newValue) => passw = newValue,
          ),
          SizedBox(
            height: 25.0,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: FlatButton(
                onPressed: _inputController,
                height: 50.0,
                color: Colors.lightBlue[300],
                child: Text(
                  "Join Us",
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                )),
          ),
        ],
      ),
    );
  }

  void _inputController() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        linearLoading = true;
      });

      try {
        Person a =
            await AuthorizationService().signUpWithMail(mail, passw, username);
        if (a != null) {
          firestoreService()
              .kullaniciOlustur(id: a.id, mail: mail, username: username);
          print("ok!!!");
        }

        Navigator.pop(context);
      } catch (error) {
        setState(() {
          linearLoading = false;
        });
        showError(code: error.code);
      }
    }
  }

  void showError({code}) {
    String errorMessage;
    if (code == "email-already-in-use") {
      errorMessage = "This email used by other ";
    } else if (code == "invalid-email") {
      errorMessage = "Email is not email";
    } else if (code == "operation-not-allowed") {
      errorMessage = "now ı cant find";
    } else if (code == "weak-password") {
      errorMessage = "Enter an strong password";
    }
    var snack = SnackBar(content: Text(errorMessage));
    _scaffoldKey.currentState.showSnackBar(snack);
  }
}
