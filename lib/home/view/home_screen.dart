import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:vocal_for_local/utils/colors.dart';
import 'package:vocal_for_local/utils/shared_preference.dart';
import 'package:vocal_for_local/utils/size_constants.dart';
import '../../utils/custom_fuctions.dart';
import 'banner_widget.dart';
import 'drawer_widget.dart';
import 'homepage_display_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.scaffoldBackgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            Text(
              "Hi, ",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(color: Colors.grey, fontSize: 14),
            ),
            Text(
              FirebaseAuth.instance.currentUser?.displayName!.split(" ")[0] ??
                  "",
              style: Theme.of(context)
                  .textTheme
                  .headline2
                  ?.copyWith(color: Colors.black),
            ),
          ],
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        actions: [
          // IconButton(
          //     onPressed: () {
          //       RangeValues _currentRangeValues = const RangeValues(10, 50);
          //       showModalBottomSheet(
          //         context: context,
          //         builder: (BuildContext context) {
          //           return StatefulBuilder(
          //             builder: (context, bottomSheetSetState) {
          //               return SizedBox(
          //                 height: 200,
          //                 child: Center(
          //                   child: Column(
          //                     mainAxisAlignment: MainAxisAlignment.center,
          //                     children: <Widget>[
          //                       RangeSlider(
          //                         min: 10.0,
          //                         max: 100.0,
          //                         values: _currentRangeValues,
          //                         labels: RangeLabels(
          //                           _currentRangeValues.start
          //                               .round()
          //                               .toString(),
          //                           _currentRangeValues.end.round().toString(),
          //                         ),
          //                         onChanged: (RangeValues values) {
          //                           bottomSheetSetState(() {
          //                             _currentRangeValues = values;
          //                           });
          //                           print(
          //                               "start ${_currentRangeValues.start.round().toString()} == end ${_currentRangeValues.end.round().toString()}");
          //                         },
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               );
          //             },
          //           );
          //         },
          //       );
          //     },
          //     icon: const Icon(Icons.filter_list_sharp))
        ],
      ),
      drawer: customDrawer(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const BannerCrousel(),
            HomepageDisplayProdutcs(productListName: "Featured Product"),
            // const HomepageDisplayProdutcs(productListName: "Liked Products"),
          ],
        ),
      ),
    );
  }
}

class HomepageDisplayProdutcs extends StatefulWidget {
  HomepageDisplayProdutcs({
    Key? key,
    required this.productListName,
  }) : super(key: key);

  final String productListName;

  @override
  State<HomepageDisplayProdutcs> createState() =>
      _HomepageDisplayProdutcsState();
}

class _HomepageDisplayProdutcsState extends State<HomepageDisplayProdutcs> {
  RangeValues _currentRangeValues = const RangeValues(10, 50);

  Stream<QuerySnapshot>? _productsStream ;

  @override
  Widget build(BuildContext context) {
    _productsStream = FirebaseFirestore.instance.collection('products').where("price",isGreaterThanOrEqualTo: _currentRangeValues.start.round().toString()).where("price",isLessThanOrEqualTo: _currentRangeValues.end.round().toString()).orderBy("price").orderBy("name",descending: false).snapshots();
    return Padding(
      padding: EdgeInsets.all(SizeConstants.appPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RangeSlider(
            min: 10.0,
            max: 100.0,
            values: _currentRangeValues,
            labels: RangeLabels(
              _currentRangeValues.start
                  .round()
                  .toString(),
              _currentRangeValues.end.round().toString(),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
              });
              print(
                  "start ${_currentRangeValues.start.round().toString()} == end ${_currentRangeValues.end.round().toString()}");
            },
          ),
          Text(widget.productListName,
              style: Theme.of(context).textTheme.subtitle1),
          const SizedBox(
            height: 10,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _productsStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.315,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    List typesList = data["type"];
                    return typesList.contains("featured")?HomePageDisplayItem(
                      productImagePath: data["image"],
                      productName: data["name"],
                      productPrice: data["price"],
                      onTap: () async {
                        context.loaderOverlay.show();
                        String currentOrderId =
                            Shared_Preference.getString("currentOrderId");
                        if (currentOrderId == "N/A") {
                        Map<String, dynamic> passDataToCart = {};
                          currentOrderId =
                              CustomFunction().getCurrentTimeInInt();
                          Shared_Preference.setString(
                              "currentOrderId", currentOrderId);
                          data["count"] = 1;
                          passDataToCart = {
                            "order_id": currentOrderId,
                            "product_list": [data],
                          };
                          FirebaseFirestore.instance
                              .collection("cart")
                              .doc(currentOrderId)
                              .set(passDataToCart);
                          context.loaderOverlay.hide();
                        } else {
                          DocumentSnapshot currentCartOrder =
                              await FirebaseFirestore.instance
                                  .collection("cart")
                                  .doc(currentOrderId)
                                  .get();
                          Map<String, dynamic> currentOrderMap =
                              currentCartOrder.data() as Map<String, dynamic>;
                          bool checkProductExist =
                              currentOrderMap["product_list"].any((element) =>
                                  element.values.contains(data["id"]) as bool);
                          if (checkProductExist) {
                            var element = currentOrderMap["product_list"]
                                .firstWhere(
                                    (k) =>
                                        k.values.contains(data["id"]) as bool,
                                    orElse: () => {});
                            var index = currentOrderMap["product_list"]
                                .indexOf(element);
                            print("index");
                            print(index);
                            element.update(
                                "count", (v) => element["count"] + 1);
                            currentOrderMap["product_list"][index] = element;
                            FirebaseFirestore.instance
                                .collection("cart")
                                .doc(currentOrderId)
                                .update({
                              "product_list": currentOrderMap["product_list"]
                            });
                            context.loaderOverlay.hide();

                          } else {
                            data["count"] = 1;
                            currentOrderMap["product_list"].add(data);
                            FirebaseFirestore.instance
                                .collection("cart")
                                .doc(currentOrderId)
                                .update({
                              "product_list": currentOrderMap["product_list"]
                            });
                            context.loaderOverlay.hide();
                            return;
                          }
                        }

                        /*data["name"] = "product4";
                        data["price"] = "40";
                        FirebaseFirestore.instance
                            .collection("products")
                            .add(data);*/
                      },
                    ):SizedBox();
                  }).toList(),
                ),
              );
            },
          ),
          Text("new products",
              style: Theme.of(context).textTheme.subtitle1),
          const SizedBox(
            height: 10,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _productsStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.315,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    List typesList = data["type"];
                    return typesList.contains("new")?HomePageDisplayItem(
                      productImagePath: data["image"],
                      productName: data["name"],
                      productPrice: data["price"],
                      onTap: () async {
                        context.loaderOverlay.show();
                        String currentOrderId =
                            Shared_Preference.getString("currentOrderId");
                        if (currentOrderId == "N/A") {
                        Map<String, dynamic> passDataToCart = {};
                          currentOrderId =
                              CustomFunction().getCurrentTimeInInt();
                          Shared_Preference.setString(
                              "currentOrderId", currentOrderId);
                          data["count"] = 1;
                          passDataToCart = {
                            "order_id": currentOrderId,
                            "product_list": [data],
                          };
                          FirebaseFirestore.instance
                              .collection("cart")
                              .doc(currentOrderId)
                              .set(passDataToCart);
                          context.loaderOverlay.hide();
                        } else {
                          DocumentSnapshot currentCartOrder =
                              await FirebaseFirestore.instance
                                  .collection("cart")
                                  .doc(currentOrderId)
                                  .get();
                          Map<String, dynamic> currentOrderMap =
                              currentCartOrder.data() as Map<String, dynamic>;
                          bool checkProductExist =
                              currentOrderMap["product_list"].any((element) =>
                                  element.values.contains(data["id"]) as bool);
                          if (checkProductExist) {
                            var element = currentOrderMap["product_list"]
                                .firstWhere(
                                    (k) =>
                                        k.values.contains(data["id"]) as bool,
                                    orElse: () => {});
                            var index = currentOrderMap["product_list"]
                                .indexOf(element);
                            print("index");
                            print(index);
                            element.update(
                                "count", (v) => element["count"] + 1);
                            currentOrderMap["product_list"][index] = element;
                            FirebaseFirestore.instance
                                .collection("cart")
                                .doc(currentOrderId)
                                .update({
                              "product_list": currentOrderMap["product_list"]
                            });
                            context.loaderOverlay.hide();

                          } else {
                            data["count"] = 1;
                            currentOrderMap["product_list"].add(data);
                            FirebaseFirestore.instance
                                .collection("cart")
                                .doc(currentOrderId)
                                .update({
                              "product_list": currentOrderMap["product_list"]
                            });
                            context.loaderOverlay.hide();
                            return;
                          }
                        }

                        /*data["name"] = "product4";
                        data["price"] = "40";
                        FirebaseFirestore.instance
                            .collection("products")
                            .add(data);*/
                      },
                    ):SizedBox();
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
