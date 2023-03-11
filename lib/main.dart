import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocal_for_local/dashboard/view/dashboard.dart';
import 'package:vocal_for_local/utils/colors.dart';
import 'package:vocal_for_local/utils/shared_preference.dart';
import 'auth/view/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Shared_Preference.init();
  // initializing the firebase app
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocal for local',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: ThemeColors.primaryColor,
        fontFamily: 'noto_sans',
        textTheme: const TextTheme(
          headline2: TextStyle(
              fontFamily: "noto_sans", fontSize: 16, color: Colors.amberAccent),
        ),
      ),
      home: LoaderOverlay(
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 250),
        child: Shared_Preference.getBool(SharedPreferenceKeys.isLogin) == true
            ? const Dashboard()
            : const LoginScreen(),
      ),
    );
  }
}

// class NetworkConnectivity {
//   NetworkConnectivity._();
//   static final _instance = NetworkConnectivity._();
//   static NetworkConnectivity get instance => _instance;
//   final _networkConnectivity = Connectivity();
//   final _controller = StreamController.broadcast();
//   Stream get myStream => _controller.stream;
//   void initialise() async {
//     ConnectivityResult result = await _networkConnectivity.checkConnectivity();
//     _checkStatus(result);
//     _networkConnectivity.onConnectivityChanged.listen((result) {
//       print(result);
//       _checkStatus(result);
//     });
//   }
//   void _checkStatus(ConnectivityResult result) async {
//     bool isOnline = false;
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } on SocketException catch (_) {
//       isOnline = false;
//     }
//     _controller.sink.add({result: isOnline});
//   }
//   void disposeStream() => _controller.close();
// }

//
// class ConnectivityCheck extends StatefulWidget {
//   const ConnectivityCheck({Key? key}) : super(key: key);
//
//   @override
//   State<ConnectivityCheck> createState() => _ConnectivityCheckState();
// }
//
// class _ConnectivityCheckState extends State<ConnectivityCheck> {
//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription<ConnectivityResult> _connectivitySubscription;
//
//   @override
//   void initState() {
//     _connectivitySubscription =
//         _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
//     initConnectivity();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold();
//   }
//   void _updateConnectionStatus(ConnectivityResult result) async {
//     if (result == ConnectivityResult.none) {
//       connectivityResult: result;
//     } else {
//       if (state.connectivityResult == ConnectivityResult.none) {
//         emit(ConnectivityRestored(connectivityResult: result));
//         await Future.delayed(const Duration(seconds: 5));
//         emit(ConnectivityOnline(connectivityResult: result));
//       } else {
//         emit(ConnectivityOnline(connectivityResult: result));
//       }
//     }
//   }
//
//   Future<void> initConnectivity() async {
//     late ConnectivityResult result;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     try {
//       result = await _connectivity.checkConnectivity();
//     } on PlatformException {
//       return;
//     }
//     return _updateConnectionStatus(result);
//   }
// }
