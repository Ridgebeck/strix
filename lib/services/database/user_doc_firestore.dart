import 'user_doc_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// interaction with game document on Firestore
class UserDocFirestore implements UserDoc {
  @override
  Future<void> updateUserSignIn({required String uid}) async {
    // Create a doc ref to the user document
    final DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    // create user UID if it does not exist
    userRef.get().then((docSnapshot) => {
          // check if document does not exist
          if (!docSnapshot.exists)
            {
              // create new user document
              userRef.set({
                'created': DateTime.now(),
                'lastAppStart': DateTime.now(),
              })
            }
          else
            {
              // update existing user document
              userRef.update({
                'lastAppStart': DateTime.now(),
              })
            }
        });
  }
}
