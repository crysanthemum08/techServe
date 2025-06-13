import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Sign in
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign up
  Future<UserCredential> signUpWithEmailAndPassword(String email,
      String password, String confirmPassword, String selectedRole) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store the selected role in Firestore under the 'users' collection
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': selectedRole, // Save the selected role, e.g., 'admin' or 'user'
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

// Check if the current user is an admin
  // Check if the current user is an admin
  Future<bool> isAdmin() async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) {
      print("No user logged in");
      return false;
    }

    try {
      // Fetch the user's role from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        String role = userDoc.get('role')?.toString().toLowerCase() ??
            ''; // Ensure case-insensitive check
        print("User role: $role"); // Check what role is retrieved
        return role == 'admin'; // Compare against lowercase 'admin'
      } else {
        print("User document does not exist in Firestore");
        return false;
      }
    } catch (e) {
      print("Error retrieving role: $e");
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }
}
