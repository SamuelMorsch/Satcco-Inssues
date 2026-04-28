import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  static Future<UserCredential> createUser(String email, String password) =>
      _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

  static Future<void> signOut() => _auth.signOut();
}
