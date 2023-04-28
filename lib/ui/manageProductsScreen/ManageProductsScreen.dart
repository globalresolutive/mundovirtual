// ignore_for_file: non_constant_identifier_names

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gromartstore/constants.dart';
import 'package:gromartstore/main.dart';
import 'package:gromartstore/model/ProductModel.dart';
import 'package:gromartstore/services/FirebaseHelper.dart';
import 'package:gromartstore/services/helper.dart';
import 'package:gromartstore/ui/addOrUpdateProduct/AddOrUpdateProductScreen.dart';

class ManageProductsScreen extends StatefulWidget {
  @override
  _ManageProductsScreenState createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  FireStoreUtils fireStoreUtils = FireStoreUtils();
  Stream<List<ProductModel>>? productsStream;
  late ProductModel futureproduct;
  late bool publish;
  var product;

  @override
  void initState() {
    // product = futureproduct;
    //   product = ProductModel;
    //  publish = product.publish;
    /*  productsStream =
        fireStoreUtils.getProductsStream(MyAppState.currentUser!.vendorID);*/

    super.initState();

    productsStream = fireStoreUtils.getProductsStream(MyAppState.currentUser!.vendorID).asBroadcastStream();
  }

  @override
  void dispose() {
    fireStoreUtils.closeProductsStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDarkMode(context) ? Color(COLOR_DARK) : null,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            backgroundColor: isDarkMode(context) ? Color(COLOR_DARK) : null,
            elevation: 10,
            onPressed: () {
              if (MyAppState.currentUser!.vendorID.isEmpty) {
                final snackBar = SnackBar(
                  content: Text('addStoreFirst'.tr()),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                push(
                  context,
                  AddOrUpdateProductScreen(product: null),
                );
              }
            },
            child: Image(
              image: AssetImage('assets/images/plus.png'),
              width: 55,
            ),
          ),
        ),
        body: SingleChildScrollView(
            child: Container(
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Stack(children: [
            StreamBuilder<List<ProductModel>>(
              stream: productsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) if (fireStoreUtils.isShowLoader == true) {
                } else {
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    alignment: Alignment.center,
                    child: showEmptyState('noProduct'.tr(), 'yourProductWillShowHere'.tr()),
                  );
                } else {
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (context, index) => buildRow(snapshot.data![index]));
                }
              },
            ),
          ]),
        )));
  }

  Widget buildRow(ProductModel productModel) {
    // publish = productModel.publish;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => push(
        context,
        AddOrUpdateProductScreen(
          product: productModel,
        ),
      ),
      // onLongPress: () => showProductOptionsSheet(productModel),
      child: Container(
        margin: EdgeInsets.fromLTRB(7, 7, 7, 7),
        child: Card(
          color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Container(
            height: 185,
            child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 8.0,
                ),
                child: SingleChildScrollView(
                  child: Column(children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            height: MediaQuery.of(context).size.height * 0.1,
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15), image: DecorationImage(image: NetworkImage(productModel.photo), fit: BoxFit.cover))),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  productModel.name,
                                  style:
                                      TextStyle(fontSize: 17, fontFamily: "Poppins", color: isDarkMode(context) ? Colors.white : Color.fromRGBO(0, 0, 0, 100)),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  productModel.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 15, fontFamily: "Poppins", color: isDarkMode(context) ? Colors.white : Color(0xff5E5C5C)),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Visibility(
                                      visible: productModel.disPrice.toString() != "0",
                                      child: Row(
                                        children: [
                                          Text(
                                            symbol != ''
                                                ? symbol + double.parse(productModel.disPrice.toString()).toStringAsFixed(decimal)
                                                : '$symbol${double.parse(productModel.disPrice.toString()).toDouble().toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: "Poppinssm",
                                              fontWeight: FontWeight.bold,
                                              color: Color(COLOR_PRIMARY),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 7,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      symbol != ''
                                          ? symbol + double.parse(productModel.price.toString()).toStringAsFixed(decimal)
                                          : '$symbol${double.parse(productModel.price.toString()).toDouble().toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          decoration: productModel.disPrice.toString() != "0" ? TextDecoration.lineThrough : null,
                                          fontFamily: "Poppinssm",
                                          color: productModel.disPrice.toString() == "0" ? Color(COLOR_PRIMARY) : Colors.grey),
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible: (productModel.size.length != 0 || productModel.addOnsTitle.length != 0),
                                  child: GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                          context: context,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          backgroundColor: Colors.white,
                                          enableDrag: true,
                                          isScrollControlled: true,
                                          builder: (context) {
                                            return bottomsheet_view_all(context, productModel);
                                          });
                                    },
                                    child: Column(
                                      children: [
                                        SizedBox(height: 8),
                                        Text(
                                          "viewSizeAndAddons".tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.w400,
                                            color: Color(COLOR_PRIMARY),
                                          ),
                                        )
                                        // Text("("+productModel.size.join(",")+")"),
                                      ],
                                    ),
                                  ),
                                ),
                                /* Visibility(
                                  visible: productModel.addOnsTitle.length!=0,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 8),
                                      Text("("+productModel.addOnsTitle.join(",")+")")

                                    ],
                                  ),
                                ),*/
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Padding(padding: EdgeInsets.fromLTRB(0, 5, 0,0)),
                    Divider(color: Color(0xFFC8D2DF), height: 0.1),
                    Padding(
                        padding: EdgeInsets.only(top: 0, left: 0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () => showProductOptionsSheet(productModel),
                                        icon: Image(
                                          image: AssetImage('assets/images/delete.png'),
                                          width: 20,
                                        )),
                                    Text(
                                      "delete".tr(),
                                      style: TextStyle(fontSize: 15, color: isDarkMode(context) ? Colors.white : Color(0XFF768296), fontFamily: "Poppins"),
                                    )
                                  ],
                                ),
                              ),

                              Container(
                                margin: EdgeInsets.only(right: 0),
                                child: Image(
                                  image: AssetImage("assets/images/verti_divider.png"),
                                  height: 30,
                                ),
                              ),
                              // SizedBox(width: 0,),
                              /*VerticalDivider(
                                  color: Colors.amber, thickness: 2, width: 10),*/
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SwitchListTile.adaptive(
                                      contentPadding: EdgeInsets.zero,
                                      activeColor: Color(COLOR_ACCENT),
                                      title: Text('publish'.tr(),
                                          textAlign: TextAlign.end,
                                          style: TextStyle(fontSize: 15, color: isDarkMode(context) ? Colors.white : Color(0XFF768296), fontFamily: "Poppins")),
                                      value: productModel.publish,
                                      onChanged: (bool newValue) async {
                                        productModel.publish = newValue;
                                        await fireStoreUtils.addOrUpdateProduct(productModel);

                                        setState(() {});
                                      })
                                ],
                              ))
                            ]))
                  ]),
                )),
          ),
        ),
      ),
    );
  }

  Widget bottomsheet_view_all(BuildContext context, ProductModel productModel) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 7,
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Stack(children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        productModel.name,
                        style: TextStyle(fontFamily: "Poppinsb", fontSize: 17, color: Color(0xff000000)),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Visibility(
                            visible: productModel.disPrice.toString() != "0",
                            child: Row(
                              children: [
                                Text(
                                  symbol != ''
                                      ? symbol + double.parse(productModel.disPrice.toString()).toStringAsFixed(decimal)
                                      : '$symbol${double.parse(productModel.disPrice.toString()).toDouble().toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "Poppinssm",
                                    fontWeight: FontWeight.bold,
                                    color: Color(COLOR_PRIMARY),
                                  ),
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            symbol != ''
                                ? symbol + double.parse(productModel.price.toString()).toStringAsFixed(decimal)
                                : '$symbol${double.parse(productModel.price.toString()).toDouble().toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 18,
                                decoration: productModel.disPrice.toString() != "0" ? TextDecoration.lineThrough : null,
                                fontFamily: "Poppinssm",
                                color: productModel.disPrice.toString() == "0" ? Color(COLOR_PRIMARY) : Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        productModel.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, fontFamily: "Poppinsm", color: isDarkMode(context) ? Colors.white : Color(0xff5E5C5C)),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Visibility(
                        visible: productModel.size.isNotEmpty,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "customisation".tr(),
                              style: TextStyle(fontFamily: "Poppinsb", fontSize: 15, color: Color(0xff000000)),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: productModel.size
                                      .map((data) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Text(data,
                                                style: TextStyle(fontSize: 18, fontFamily: "Poppins", fontWeight: FontWeight.normal, color: Colors.grey)),
                                          ))
                                      .toList(),
                                ),
                                Expanded(child: SizedBox()),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: productModel.sizePrice
                                      .map((data) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Text(symbol + data,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontFamily: "Poppinssm",
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(COLOR_PRIMARY),
                                                )),
                                          ))
                                      .toList(),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Visibility(
                        visible: productModel.addOnsTitle.isNotEmpty,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "addons".tr(),
                              style: TextStyle(fontFamily: "Poppinsb", fontSize: 15, color: Color(0xff000000)),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: productModel.addOnsTitle
                                      .map((data) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Text(data,
                                                style: TextStyle(fontSize: 18, fontFamily: "Poppins", fontWeight: FontWeight.normal, color: Colors.grey)),
                                          ))
                                      .toList(),
                                ),
                                Expanded(child: SizedBox()),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: productModel.addOnsPrice
                                      .map((data) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Text(symbol + data,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontFamily: "Poppinssm",
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(COLOR_PRIMARY),
                                                )),
                                          ))
                                      .toList(),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ]),
            ),
          ),
          Align(
            alignment: Alignment(0, -1.35),
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                margin: EdgeInsets.only(right: 10, left: 10),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15), image: DecorationImage(image: NetworkImage(productModel.photo), fit: BoxFit.cover))),
          ),
        ],
      ),
    );
  }

  showProductOptionsSheet(ProductModel productModel) {
    final action = CupertinoActionSheet(
      message: Text(
        'areYouSureYouWantToDeleteProduct',
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      title: Text(
        '${productModel.name}',
        style: TextStyle(fontSize: 17.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('yesSureDelete').tr(),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            fireStoreUtils.deleteProduct(productModel.id);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }
}
