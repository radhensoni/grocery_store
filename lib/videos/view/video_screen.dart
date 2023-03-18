import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vocal_for_local/videos/view/video_detail_screen.dart';
import 'package:logger/logger.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  DocumentSnapshot? currentUser;
  Map<String, dynamic>? currentUserMap;
  List? authVideoListId;
  Razorpay? _razorpay;
  Map<String, dynamic> selectedVideoData = {};

  fetchCurrentUser(BuildContext context) async {
    context.loaderOverlay.show();
    currentUser = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    currentUserMap = currentUser!.data() as Map<String, dynamic>;
    authVideoListId = currentUserMap!["auth_videos_id"];
    context.loaderOverlay.hide();
    setState(() {});
  }

  @override
  void initState() {
    fetchCurrentUser(this.context);
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay!.clear();
  }

  void openCheckout(BuildContext context) async {
    context.loaderOverlay.show();
    var options = {
      'key': 'rzp_test_NNbwJ9tmM0fbxj',
      'amount': int.parse(selectedVideoData['price'].toString()) * 100,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'description': 'Payment',
      'prefill': {
        'contact': FirebaseAuth.instance.currentUser!.phoneNumber,
        'email': FirebaseAuth.instance.currentUser!.email
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      debugPrint(e.toString());
      context.loaderOverlay.hide();
    }
    context.loaderOverlay.hide();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    this.context.loaderOverlay.show();
    Logger().d(
      "SUCCESS: ${response.paymentId}",
    );
    authVideoListId!.add(selectedVideoData["id"]);
    setState(() {});
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({"auth_videos_id": authVideoListId});
    this.context.loaderOverlay.hide();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoDetailScreen(
          videoUrl: selectedVideoData["video_url"],
          description: selectedVideoData["description"],
          title: selectedVideoData["title"],
        ),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Purchase Error'),
          content: Text("${response.message}"),
          actions: <Widget>[
            TextButton(
              child: const Text('ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    Logger().d("ERROR: ${response.code} - ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Logger().d(
      "EXTERNAL_WALLET: ${response.walletName}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("video"),
      ),
      body: context.loaderOverlay.visible
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('videos').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading");
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return ListTile(
                      onTap: () async {
                        //implement auth video logic
                        if (!authVideoListId!.contains(data["id"])) {
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Purchase video'),
                                content: Text("${data["title"]}is paid video to view the video you need to purchase it, Do you want to Purchase?"),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('No'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Pay Rs.${data['price']}'),
                                    onPressed: () {
                                      Navigator.pop(this.context);
                                      selectedVideoData = data;
                                      openCheckout(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoDetailScreen(
                                videoUrl: data["video_url"],
                                description: data["description"],
                                title: data["title"],
                              ),
                            ),
                          );
                        }
                      },
                      title: Text(data["title"]),
                      trailing: authVideoListId!.contains(data["id"])
                          ? const Icon(Icons.lock_open)
                          : const Icon(Icons.lock),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
