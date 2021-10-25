import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'database/game_doc_abstract.dart';
import 'database/game_doc_firestore.dart';
import 'database/user_doc_abstract.dart';
import 'database/user_doc_firestore.dart';
import 'authorization/authorization_abstract.dart';
import 'authorization/authorization_firebase.dart';

// allow global access to instance via get it
GetIt serviceLocator = GetIt.instance;

Future<void> setupServices() async {
  // initialize connection to Firebase
  await Firebase.initializeApp();
  // TODO: error handling during initialization

  // register services
  // interact with game doc via firestore
  serviceLocator.registerLazySingleton<GameDoc>(() => GameDocFirestore());
  // interact with user doc via firestore
  serviceLocator.registerLazySingleton<UserDoc>(() => UserDocFirestore());
  // handle authorization via firebase auth
  serviceLocator
      .registerLazySingleton<Authorization>(() => AuthorizationFirebase());
}
