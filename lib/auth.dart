import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class BaseAuth {
  Stream<String> get onAuthStateChanged;

  Future<String> signInWithEmailAndPassword(String email, String passord);

  Future<String> signUpWithEmailAndPassword(
      String fullname, String email, String password);

  Future<void> signOut();

  Future<void> resetPassword(String email);

  Future signInWithGoogle();

  Future<FirebaseUser> get currentUser;
}

class AuthFireBase implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Stream<String> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged
        .map((FirebaseUser user) => user?.uid);
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
  Future<String> signInWithEmailAndPassword(
      String email, String passord) async {
    FirebaseUser user = (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: passord))
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
  Future<String> signUpWithEmailAndPassword(
      String fullName, String email, String password) async {
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
  Future<FirebaseUser> get currentUser async =>
      await _firebaseAuth.currentUser();
}
