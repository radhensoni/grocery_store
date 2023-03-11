import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vocal_for_local/auth/model/logged_in_user_model.dart';
import 'package:vocal_for_local/dashboard/view/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocal_for_local/utils/firebase_connection.dart';
import 'package:vocal_for_local/utils/firebase_consts.dart';
import 'package:vocal_for_local/utils/shared_preference.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

Future<bool> signup(BuildContext context) async {
  bool isSuccess = false;
  try {
    FirebaseInternetModel googleResponse =
        await FirebaseConnection().googleSignIn();
    isSuccess = googleResponse.isSuccess;
    if (isSuccess) {
      Shared_Preference.setBool(SharedPreferenceKeys.isLogin, true);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Dashboard()));
    } else {
      print("something went wrong");
    }
  } catch (error) {
    if (error == "No Internet Connection") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
        action: SnackBarAction(
            label: "Retry",
            onPressed: () {
              signup(context);
            }),
      ));
    }
  }
  return isSuccess;
}

/*

Map<String,dynamic> demo = {

};
* */
