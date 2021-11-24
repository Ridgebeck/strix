import 'package:flutter/cupertino.dart';

import 'authorization_abstract.dart';
import 'package:strix/services/service_locator.dart';
import 'package:strix/services/database/user_doc_abstract.dart';
import 'package:firebase_auth/firebase_auth.dart';

// interaction with game document on Firestore
class AuthorizationFirebase implements Authorization {
  final UserDoc _userDoc = serviceLocator<UserDoc>();

  @override
  Future<void> signInUserAnonymous() async {
    // sign in user into app
    try {
      // fetch user credentials
      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      // create or update user document
      _userDoc.updateUserSignIn(uid: userCredential.user!.uid);
    } catch (e) {
      debugPrint('Sign in anonymously failed. Error code: $e');
      // TODO: inform user about not being able to sign in
    }
  }

  @override
  String getCurrentUserID() {
    // TODO: error handling with getting UID
    return FirebaseAuth.instance.currentUser!.uid;
  }
}
