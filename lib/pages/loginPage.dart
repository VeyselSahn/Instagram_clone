import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:instagram_project/models/Person.dart';
import 'package:instagram_project/pages/composeUser.dart';
import 'package:instagram_project/pages/forgotPass.dart';
import 'package:instagram_project/pages/mainPage.dart';
import 'package:instagram_project/services/AuthorizationService.dart';
import 'package:instagram_project/services/firestoreService.dart';
import 'package:set_state/set_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class loginPage extends StatefulWidget {
  @override
  _loginPageState createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var email, password;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(children: [__loginPageElements(), loadingFunc()]),
    );
  }

  Widget loadingFunc() {
    if (loading)
      return Center(child: CircularProgressIndicator());
    else
      return Center();
  }

  Widget __loginPageElements() {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: 150.0,
          ),
          Container(
            height: 50.0,
            width: 70.0,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage("assets/redlogo.png"),
            )),
          ),
          SizedBox(
            height: 50.0,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20.0),
            child: TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return "Enter a username or email";
                } else
                  return null;
              },
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  errorStyle: TextStyle(
                      fontSize: 13.0,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.normal),
                  hintText: "Email or username",
                  prefixIcon: Icon(Icons.mail_outline)),
              onSaved: (newValue) => email = newValue,
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20.0),
            child: TextFormField(
              validator: (value) {
                if (value.isEmpty)
                  return "Can't be empty";
                else if (value.trim().length < 6)
                  return "Can't be shorter 6 digits ";
                else
                  return null;
              },
              obscureText: true,
              decoration: InputDecoration(
                  errorStyle: TextStyle(
                      fontSize: 13.0,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.normal),
                  hintText: "Password",
                  prefixIcon: Icon(Icons.lock_open)),
              onSaved: (newValue) => password = newValue,
            ),
          ),
          SizedBox(
            height: 25.0,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: FlatButton(
                onPressed: _logInFunc,
                height: 50.0,
                color: Colors.lightBlue[300],
                child: Text(
                  "Log In",
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                )),
          ),
          SizedBox(
            height: 8.0,
          ),
          Center(

            child: InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => forgotPass(),
                  )),
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                    color: Colors.black, fontSize: 14.0),
              ),
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          Center(
            child: SignInButtonBuilder(
              backgroundColor: Colors.white,
              onPressed: () {
                _logInGoogle();
              },
              text: "Sign in with google",
              fontSize: 15.0,
              textColor: Colors.redAccent[700],
              height: 40.0,
              elevation: 0.0,
              image: Image.asset(
                "assets/google.jpg",
                height: 40.0,
                width: 40.0,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 130.0),
              child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => composeUser(),
                      )),
                  child: Text(
                    "Don't Have An Account ?",
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  void _logInFunc() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() {
        loading = true;
      });

      try {
        await AuthorizationService().logInWithMail(email, password);
      } catch (hata) {
        setState(() {
          loading = false;
        });

        showError(code: hata.code);
      }
    }
  }

  void _logInGoogle() async {
    setState(() {
      loading = true;
    });

    try {
      Person person = await AuthorizationService().signInWithGoogle();

      if (person != null) {
        Person firePerson = await firestoreService().getUser(person.id);
        if( firePerson== null) {
          firestoreService().kullaniciOlustur(
            id: person.id,
            mail: person.mail,
            username: person.username,
            pp: person.pp
          );
        }
        }
      }
    catch (hata) {
      setState(() {
        loading = false;
      });

      showError(code: hata.code);
    }
  }

  void showError({code}) {
    String message;
    if (code == "invalid-email") {
      message = "mail is invalid";
    } else if (code == "user-disabled") {
      message = "user disabled";
    } else if (code == "user-not-found") {
      message = "User didnt be found";
    } else if (code == "wrong-password") {
      message = "Wrong Password";
    } else {
      message = "Tanımlanamayan bir hata oluştu $code";
    }

    var snack = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snack);
  }
}
