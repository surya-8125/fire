import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/constants.dart';

class LoginProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  User? _user;
  User? get user => _user;

  // Sign Up
  Future<void> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      _isSuccess = true;
      Constants.username = email;
    } catch (e) {
      _isSuccess = false;
      print('Error signing up: $e');
    }
    notifyListeners();
  }

  // Sign In
  Future<void> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      _isSuccess = true;
      Constants.username = email;
    } catch (e) {
      print('Error signing in: $e');
      _isSuccess = false;
    }
    notifyListeners();
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _user = null;
    _isSuccess = false;
    notifyListeners();
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _isSuccess = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await _auth.signInWithCredential(credential);

      _user = userCredential.user;
      _isSuccess = true;
      Constants.username = googleUser.email;
    } catch (e) {
      print('Error signing in with Google: $e');
      _isSuccess = false;
    }
    notifyListeners();
  }
}
