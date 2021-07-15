import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instagram_project/models/Person.dart';
import 'package:instagram_project/services/NavigatorService.dart';

class AuthorizationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userId;

  Person _composeUser(User user) {
    return user == null ? null : Person.producingFirebase(user);
  }

  Stream<Person> get chaseStatus {
    return _auth.authStateChanges().map(_composeUser);
  }

  Future<Person> signUpWithMail(mail, password, username) async {
    var card = await _auth.createUserWithEmailAndPassword(
        email: mail, password: password);
    return _composeUser(card.user);
  }

  Future<Person> logInWithMail(mail, password) async {
    var card =
        await _auth.signInWithEmailAndPassword(email: mail, password: password);
    return _composeUser(card.user);
  }

  Future<Person> signInWithGoogle() async {
    GoogleSignInAccount accountGoogle = await GoogleSignIn().signIn();
    GoogleSignInAuthentication cardAuth = await accountGoogle.authentication;
    OAuthCredential passwless = GoogleAuthProvider.credential(
        idToken: cardAuth.idToken, accessToken: cardAuth.accessToken);
    UserCredential cardLog = await _auth.signInWithCredential(passwless);
    return _composeUser(cardLog.user);
  }

  Future<void> forgotP(String email) async{
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> exit() {
    return _auth.signOut();

  }
}
