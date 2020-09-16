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

  Future<void> signOut();

  Future<void> resetPassword(String email);

  Future signInWithGoogle();

  Future<User> get currentUserFuture;
}

class AuthFireBase extends ChangeNotifier implements BaseAuth {

  static AuthFireBase _instance;

  AuthFireBase._internal() {
    _instance = this;
    getCurrentUser();
  }

  User get currentUser => _currentUser;


  Future<void> getCurrentUser() async {
    _currentUser = await currentUserFuture;

    _firebaseAuth.authStateChanges().listen((user) {
      _currentUser = user;
    });
  }

  factory AuthFireBase() => _instance ?? AuthFireBase._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User _currentUser;


  @override
  Stream<User> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges();
  }

  @override
  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount =
    await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    final UserCredential authResult =
    await _firebaseAuth.signInWithCredential(credential);
    final User user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = await _firebaseAuth.currentUser;
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword(String email,
      String password) async {
    // FirebaseUser user = (await _firebaseAuth.signInWithEmailAndPassword(
    //     email: email, password: password)).user;
    // print("User is Verified: ${user.isEmailVerified}");
    // if (user.isEmailVerified) return user.uid;
    // return null;
    return _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<void> signOut() {
    _firebaseAuth.signOut();
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

  @override
  Future<User> get currentUserFuture async =>
      await _firebaseAuth.currentUser;
}
