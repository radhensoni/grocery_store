import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocal_for_local/auth/view/login_screen.dart';
import 'package:vocal_for_local/utils/firebase_connection.dart';
import 'package:vocal_for_local/utils/shared_preference.dart';

Future<bool> signout(BuildContext context) async {
  bool isSuccess = false;
  try{
    FirebaseInternetModel googleSignOut = await FirebaseConnection().googleSignOut();
    isSuccess = googleSignOut.isSuccess;
    if(isSuccess){
      Shared_Preference.setBool(SharedPreferenceKeys.isLogin, false);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ));
    }
  }catch(error){
    if (error == "No Internet Connection") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
        action: SnackBarAction(
            label: "Retry",
            onPressed: () {
              signout(context);
            }),
      ));
    }
  }
  return isSuccess;
}
