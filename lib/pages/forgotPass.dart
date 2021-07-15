import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_project/services/AuthorizationService.dart';

class forgotPass extends StatefulWidget {
  @override
  _forgotPassState createState() => _forgotPassState();
}

class _forgotPassState extends State<forgotPass> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String mail;
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
              "Forgot Password?",
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
            height: 25.0,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: FlatButton(
                onPressed: _inputController,
                height: 50.0,
                color: Colors.lightBlue[300],
                child: Text(
                  "Send Email",
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
        AuthorizationService().forgotP(mail);
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
    if (code == "invalid-email") {
      errorMessage = "Email is invalid";
    } else if (code == "user-not-found") {
      errorMessage = "User is not registered";
    }
    var snack = SnackBar(content: Text(errorMessage));
    _scaffoldKey.currentState.showSnackBar(snack);
  }
}
