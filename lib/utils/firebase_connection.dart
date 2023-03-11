import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../auth/model/logged_in_user_model.dart';
import 'firebase_consts.dart';

class FirebaseInternetModel {
  bool isSuccess;
  dynamic body;

  FirebaseInternetModel(
    this.isSuccess,
    this.body,
  );
}

class FirebaseConnection {
  final FirebaseAuth authInstance = FirebaseAuth.instance;

  Future<FirebaseInternetModel> googleSignIn() async {
    bool isSuccess = false;
    if (await _checkStatus()) {
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleSignInAccount =
            await googleSignIn.signIn();
        if (googleSignInAccount != null) {
          final GoogleSignInAuthentication googleSignInAuthentication =
              await googleSignInAccount.authentication;
          final AuthCredential authCredential = GoogleAuthProvider.credential(
              idToken: googleSignInAuthentication.idToken,
              accessToken: googleSignInAuthentication.accessToken);
          // Getting users credential
          UserCredential result =
              await authInstance.signInWithCredential(authCredential);
          // User? user = result.user;

          LoggedInUserModel loginUser = LoggedInUserModel();
          loginUser.id = result.user?.uid ?? "";
          loginUser.name = result.user?.displayName ?? "";
          loginUser.email = result.user?.email ?? "";
          loginUser.profilePicture = result.user?.photoURL ?? "";
          loginUser.createdAt = DateTime.now().toString();

          CollectionReference users = FirebaseFirestore.instance
              .collection(FirebaseCollections.userCollection);

          users.doc(result.user?.uid).set(loginUser.toJson());

          if (result != null) {
            isSuccess = true;
          }
        }
      } catch (error) {
        isSuccess = false;
        print(error.toString());
      }
    }
    return FirebaseInternetModel(isSuccess, null);
  }

  Future<FirebaseInternetModel> googleSignOut() async {
    bool isSuccess = false;
    if (await _checkStatus()) {
      try {
        await FirebaseAuth.instance.signOut();
        isSuccess = true;
      } catch (error) {
        isSuccess = false;
        print(error.toString());
      }
    }
    return FirebaseInternetModel(isSuccess, null);
  }


}

Future<bool> _checkStatus() async {
  bool isOnline = false;
  try {
    final result = await InternetAddress.lookup('google.com');
    isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    isOnline = false;
    throw "No Internet Connection";
  }
  return isOnline;
}
