import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class BaseAuth {
  Stream<FirebaseUser> get onAuthStateChanged;

  Future<String> signInWithEmailAndPassword(String email, String password);

  Future<String> signUpWithEmailAndPassword(
      String fullName, String email, String password);

  Future<void> signOut();

  Future<void> resetPassword(String email);

  Future signInWithGoogle();

  Future<FirebaseUser> get currentUserFuture;
}

class AuthFireBase extends ChangeNotifier implements BaseAuth {

  static AuthFireBase _instance;

  AuthFireBase._internal() {
    _instance = this;
    getCurrentUser();
  }

  FirebaseUser get currentUser => _currentUser;

  Future<void> getCurrentUser() async {
    _currentUser = await currentUserFuture;

    _firebaseAuth.onAuthStateChanged.listen((user) {
      _currentUser = user;
    });
  }

  factory AuthFireBase() => _instance ?? AuthFireBase._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseUser _currentUser;


  @override
  Stream<FirebaseUser> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged;
  }

  @override
  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount =
    await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    final AuthResult authResult =
    await _firebaseAuth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
  }

  @override
  Future<String> signInWithEmailAndPassword(String email,
      String password) async {
    FirebaseUser user = (await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password))
        .user;
    print("User is Verified: ${user.isEmailVerified}");
    if (user.isEmailVerified) return user.uid;
    return null;
  }

  @override
  Future<void> signOut() {
    _firebaseAuth.signOut();
  }

  @override
  Future<String> signUpWithEmailAndPassword(String fullName, String email,
      String password) async {
    FirebaseUser user = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password))
        .user;

    UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
    userUpdateInfo.displayName = fullName;

    await user.updateProfile(userUpdateInfo).then((onValue) {
      Firestore.instance
          .collection('users')
          .document(user.uid)
          .setData({'email': email, 'displayName': fullName});
    });

    try {
      await user.sendEmailVerification();
      return user.uid;
    } catch (e) {
      print("An Error occurred while trying to send email verification");
      print(e.message);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<FirebaseUser> get currentUserFuture async =>
      await _firebaseAuth.currentUser();
}
