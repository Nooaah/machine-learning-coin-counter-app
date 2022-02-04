import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthentification {
  final FirebaseAuth _authentificationFirebase = FirebaseAuth.instance;

  Future connexion(String email, String password) async {
    UserCredential authResult = await _authentificationFirebase
        .signInWithEmailAndPassword(email: email, password: password);
    User? user = authResult.user;
    return user!.uid;
  }

  Future inscription(String email, String password) async {
    UserCredential authResult = await _authentificationFirebase
        .createUserWithEmailAndPassword(email: email, password: password);
    User? user = authResult.user;
    return user!.uid;
  }

  Future deconnexion() async {
    return _authentificationFirebase.signOut();
  }

  Future<User?> lireUtilisateur() async {
    User? user = _authentificationFirebase.currentUser;
    return user;
  }
}
