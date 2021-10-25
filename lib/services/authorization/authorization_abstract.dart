// Using an abstract class like this allows to swap concrete implementations.
// This is useful for separating architectural layers.
// It also makes testing and development easier because you can provide
// a mock implementation or fake data.
abstract class Authorization {
  // sign in user anonymously
  Future<void> signInUserAnonymous();

  // get current user ID
  String getCurrentUserID();
}
