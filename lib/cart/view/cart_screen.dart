import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:vocal_for_local/utils/shared_preference.dart';

import '../../home/view/homepage_display_item.dart';
import '../../utils/custom_fuctions.dart';

class CartScreen extends StatefulWidget {
  CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    // currentOrderID = Shared_Preference.getString("currentOrderId");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print("aaa${currentOrderID}build method");
    return Column(
      children: [
        const SizedBox(
          height: 100,
        ),
        ElevatedButton(
            onPressed: () async {
              // QuerySnapshot a = await FirebaseFirestore.instance
              //     .collection('cart').where("order_id", isEqualTo: Shared_Preference.getString("currentOrderId")).get();
              // // fetch current cart data
              // print(Shared_Preference.getString("currentOrderId")+"hhh");
              FirebaseFirestore.instance
                  .collection('cart')
                  .doc(Shared_Preference.getString("currentOrderId"))
                  .delete();
              Shared_Preference.remove("currentOrderId");
            },
            child: const Text("Clear cart")),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('cart')
              .where("order_id",
                  isEqualTo: Shared_Preference.getString("currentOrderId"))
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            // print("aaa${currentOrderID}stream function");
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs != null && snapshot.data!.docs.isNotEmpty) {
              Map<String, dynamic> productList =
                  snapshot.data!.docs.first.data()! as Map<String, dynamic>;
              return SizedBox(
                height: MediaQuery.of(context).size.height - 300,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  children: productList["product_list"].map<Widget>(
                    (document) {
                      return ListTile(
                        leading: Image.network(document["image"]),
                        title: Row(
                          children: [
                            Text(document["name"]),
                            Spacer(),
                            Text("Rs.${document["price"]}"),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () async {
                                  context.loaderOverlay.show();
                                  DocumentSnapshot currentCartOrder =
                                      await FirebaseFirestore.instance
                                          .collection("cart")
                                          .doc(Shared_Preference.getString(
                                              "currentOrderId"))
                                          .get();
                                  Map<String, dynamic> currentOrderMap =
                                      currentCartOrder.data()
                                          as Map<String, dynamic>;
                                  bool checkProductExist =
                                      currentOrderMap["product_list"].any(
                                          (element) => element.values
                                                  .contains(document["id"])
                                              as bool);
                                  if (checkProductExist) {
                                    var element =
                                        currentOrderMap["product_list"]
                                            .firstWhere(
                                                (k) => k.values.contains(
                                                    document["id"]) as bool,
                                                orElse: () => {});
                                    var index =
                                        currentOrderMap["product_list"]
                                            .indexOf(element);
                                    element.update("count",
                                        (v) => element["count"] + 1);
                                    currentOrderMap["product_list"][index] =
                                        element;
                                    FirebaseFirestore.instance
                                        .collection("cart")
                                        .doc(Shared_Preference.getString(
                                            "currentOrderId"))
                                        .update({
                                      "product_list":
                                          currentOrderMap["product_list"]
                                    });
                                    // Future.delayed(Duration(seconds: 1));
                                    context.loaderOverlay.hide();
                                  }
                                },
                                icon: const Icon(Icons.add),),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text("${document["count"]}"),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                if (document["count"] > 1) {
                                  context.loaderOverlay.show();
                                  DocumentSnapshot currentCartOrder =
                                      await FirebaseFirestore.instance
                                          .collection("cart")
                                          .doc(Shared_Preference.getString(
                                              "currentOrderId"))
                                          .get();
                                  Map<String, dynamic> currentOrderMap =
                                      currentCartOrder.data()
                                          as Map<String, dynamic>;
                                  bool checkProductExist =
                                      currentOrderMap["product_list"].any(
                                          (element) => element.values
                                                  .contains(document["id"])
                                              as bool);
                                  if (checkProductExist) {
                                    var element = currentOrderMap["product_list"].firstWhere((k) => k.values.contains(document["id"]) as bool, orElse: () => {});
                                    int index = currentOrderMap["product_list"].indexOf(element);
                                    element.update("count", (v) => element["count"] - 1);
                                    currentOrderMap["product_list"][index] = element;
                                    FirebaseFirestore.instance
                                        .collection("cart")
                                        .doc(Shared_Preference.getString(
                                            "currentOrderId"))
                                        .update({
                                      "product_list":
                                          currentOrderMap["product_list"]
                                    });
                                    // Future.delayed(Duration(seconds: 1));
                                    context.loaderOverlay.hide();
                                  }
                                }else{
                                  context.loaderOverlay.show();
                                  DocumentSnapshot currentCartOrder =
                                  await FirebaseFirestore.instance
                                      .collection("cart")
                                      .doc(Shared_Preference.getString(
                                      "currentOrderId"))
                                      .get();
                                  Map<String, dynamic> currentOrderMap =
                                  currentCartOrder.data()
                                  as Map<String, dynamic>;
                                  bool checkProductExist =
                                  currentOrderMap["product_list"].any(
                                          (element) => element.values
                                          .contains(document["id"])
                                      as bool);
                                  if (checkProductExist) {
                                    List allProductsInCart = [];
                                    Map<String,dynamic> element = currentOrderMap["product_list"].firstWhere((k) => k.values.contains(document["id"]) as bool, orElse: () => {});
                                    int index = currentOrderMap["product_list"].indexOf(element);
                                    allProductsInCart = currentOrderMap["product_list"];
                                    allProductsInCart.removeAt(index);
                                    currentOrderMap["product_list"] = allProductsInCart;
                                    FirebaseFirestore.instance
                                        .collection("cart")
                                        .doc(Shared_Preference.getString(
                                        "currentOrderId"))
                                        .update({
                                      "product_list":
                                      currentOrderMap["product_list"]
                                    });
                                    // Future.delayed(Duration(seconds: 1));
                                    context.loaderOverlay.hide();
                                  }
                                }
                              },
                              icon: document["count"] == 1? const Icon(Icons.delete):Container(margin: EdgeInsets.only(bottom: 15),child: Icon(Icons.minimize)),
                            )
                          ],
                        ),
                      );
                      // return HomePageDisplayItem(
                      //   productImagePath: document["image"],
                      //   productName: document["name"],
                      //   productPrice: document["price"],
                      //   onTap: () {
                      //     log(CustomFunction().getCurrentTimeInInt());
                      //   },
                      // );
                    },
                  ).toList(),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }
}
