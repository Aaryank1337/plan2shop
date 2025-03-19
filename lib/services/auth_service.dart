// import 'package:firebase_auth/firebase_auth.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Sign Up
//   Future<User?> signUp(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       return userCredential.user;
//     } catch (e) {
//       print("Error: $e");
//       return null;
//     }
//   }

//   // Login
//   Future<User?> login(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);
//       return userCredential.user;
//     } catch (e) {
//       print("Error: $e");
//       return null;
//     }
//   }

//   // Logout
//   Future<void> logout() async {
//     await _auth.signOut();
//   }

//   // Get current user
//   User? get currentUser => _auth.currentUser;
// }
