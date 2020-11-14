import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class BaseAuth {
  Stream<User> get onAuthStateChanged;

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password);

  Future<UserCredential> signUpWithEmailAndPassword(String fullName,
      String email, String password);

   signOut();

  Future<void> resetPassword(String email);

  Future<UserCredential> signInWithGoogle();

  User get currentUser;
}

class AuthFireBase extends ChangeNotifier implements BaseAuth {

  static AuthFireBase _instance;

  AuthFireBase._internal() {
    _instance = this;
  }

  factory AuthFireBase() => _instance ?? AuthFireBase._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  User get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<User> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges();
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    return _firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword(String email,
      String password) async {
    return _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Future<UserCredential> signUpWithEmailAndPassword(String fullName,
      String email,
      String password) async {
    return _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password).then((userCred) {
      User user = userCred.user;
      user.sendEmailVerification();
      user.updateProfile(displayName: fullName).then((onValue) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'email': email, 'displayName': fullName});
      });

      return userCred;
    });

  }

  @override
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }


}
