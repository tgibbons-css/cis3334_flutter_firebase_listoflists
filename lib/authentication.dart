import 'package:firebase_core/firebase_core.dart';        // for Firebase
import 'package:firebase_auth/firebase_auth.dart';        // for Firebase Authentication
import 'package:google_sign_in/google_sign_in.dart';

class authenticationStuff {
  // ======== Added for Authentication  ========
  UserCredential userCredential;

  String getUserID() {
    return userCredential.user.uid;
  }

  
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Once signed in, return the UserCredential
    userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential;
  }
}

