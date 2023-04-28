// ignore_for_file: must_be_immutable, non_constant_identifier_names, unnecessary_null_comparison

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_facebook_keyhash/flutter_facebook_keyhash.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gromartstore/constants.dart';
import 'package:gromartstore/main.dart';
import 'package:gromartstore/model/User.dart';
import 'package:gromartstore/model/VendorModel.dart';
import 'package:gromartstore/services/FirebaseHelper.dart';
import 'package:gromartstore/services/helper.dart';
import 'package:gromartstore/ui/Language/language_choose_screen.dart';
import 'package:gromartstore/ui/SpecialOffer/specialOfferScreen.dart';
import 'package:gromartstore/ui/add_store/add_store.dart';
import 'package:gromartstore/ui/auth/AuthScreen.dart';
import 'package:gromartstore/ui/bank_details/bank_details_Screen.dart';
import 'package:gromartstore/ui/manageProductsScreen/ManageProductsScreen.dart';
import 'package:gromartstore/ui/offer/offers.dart';
import 'package:gromartstore/ui/ordersScreen/OrdersScreen.dart';
import 'package:gromartstore/ui/profile/ProfileScreen.dart';
import 'package:gromartstore/ui/wallet/walletScreen.dart';

enum DrawerSelection { Orders, ManageProducts, AddRestauarnt, Offers, SpecialOffer, Profile, Wallet, BankInfo, chooseLanguage, Logout }

class ContainerScreen extends StatefulWidget {
  final User? user;

  final Widget currentWidget;
  final String appBarTitle;
  final DrawerSelection drawerSelection;
  String? userId = "";

  ContainerScreen({Key? key, this.user, this.userId, appBarTitle, currentWidget, this.drawerSelection = DrawerSelection.Orders})
      : this.appBarTitle = appBarTitle ?? 'Orders'.tr(),
        this.currentWidget = currentWidget ?? OrdersScreen(),
        super(key: key);

  @override
  _ContainerScreen createState() {
    return _ContainerScreen();
  }
}

class _ContainerScreen extends State<ContainerScreen> {
  User? user;
  late String _appBarTitle;
  final fireStoreUtils = FireStoreUtils();
  Widget _currentWidget = OrdersScreen();
  DrawerSelection _drawerSelection = DrawerSelection.Orders;
  String _keyHash = 'Unknown';
  VendorModel? vendorModel;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getKeyHash() async {
    String keyHash;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      keyHash = await FlutterFacebookKeyhash.getFaceBookKeyHash ?? 'Unknown platform KeyHash';
    } on PlatformException {
      keyHash = 'Failed to get Kay Hash.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _keyHash = keyHash;
      print("::::KEYHASH::::");
      print(_keyHash);
    });
  }

  final audioPlayer = AudioPlayer(playerId: "playerId");

  @override
  void initState() {
    super.initState();
    //user = widget.user;
    FireStoreUtils.getCurrentUser(MyAppState.currentUser == null ? widget.userId! : MyAppState.currentUser!.userID).then((value) {
      setState(() {
        user = value!;
        MyAppState.currentUser = value;
      });
    });
    getSpecialDiscount();

    //getKeyHash();

    _appBarTitle = 'Orders'.tr();
    fireStoreUtils.getplaceholderimage();
    // print(MyAppState.currentUser!.vendorID);

    /// On iOS, we request notification permissions, Does nothing and returns null on Android
    FireStoreUtils.firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  bool specialDiscountEnable = false;

  getSpecialDiscount() async {
    await FirebaseFirestore.instance.collection(Setting).doc('specialDiscountOffer').get().then((value) {
      if (value != null) {
        specialDiscountEnable = value.data()!['isEnable'];
      }
    });
    FireStoreUtils.getVendor(MyAppState.currentUser!.vendorID).then((value) {
      if (value != null) {
        vendorModel = value;
        vendorModel!.specialDiscountEnable = specialDiscountEnable;

        FireStoreUtils.updateVendor(vendorModel!).then((value) {
          if (value != null) {
            vendorModel = value;
            setState(() {});
          }
        });
        setState(() {});
      }
    });
  }

  DateTime pre_backpress = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: _drawerSelection == DrawerSelection.Wallet ? true : false,
      backgroundColor: isDarkMode(context) ? Color(COLOR_DARK) : null,
      drawer: Drawer(
          child: Container(
        color: isDarkMode(context) ? Color(COLOR_DARK) : null,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            user == null
                ? Container()
                : DrawerHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        displayCircleImage(user!.profilePictureURL, 75, false),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            user!.fullName(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              user!.email,
                              style: TextStyle(color: Colors.white),
                            )),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Color(COLOR_PRIMARY),
                    ),
                  ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.Orders,
                title: Text('Orders').tr(),
                onTap: () {
                  Navigator.pop(context);
                  setState(
                    () {
                      _drawerSelection = DrawerSelection.Orders;
                      _appBarTitle = 'Orders'.tr();
                      _currentWidget = OrdersScreen();
                    },
                  );
                },
                leading: Image.asset(
                  'assets/images/order.png',
                  color: _drawerSelection == DrawerSelection.Orders
                      ? Color(COLOR_PRIMARY)
                      : isDarkMode(context)
                          ? Colors.grey.shade200
                          : Colors.grey.shade600,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.AddRestauarnt,
                leading: Icon(Icons.restaurant_outlined),
                title: Text('addStore').tr(),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _drawerSelection = DrawerSelection.AddRestauarnt;
                    _appBarTitle = 'addStore'.tr();
                    _currentWidget = AddStoreScreen();
                  });
                },
              ),
            ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.ManageProducts,
                leading: FaIcon(FontAwesomeIcons.pizzaSlice),
                title: Text('Manage Products').tr(),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _drawerSelection = DrawerSelection.ManageProducts;
                    _appBarTitle = 'Your Products'.tr();
                    _currentWidget = ManageProductsScreen();
                  });
                },
              ),
            ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.Offers,
                leading: Icon(Icons.local_offer_outlined),
                title: Text('offers').tr(),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _drawerSelection = DrawerSelection.Offers;
                    _appBarTitle = 'offers'.tr();
                    _currentWidget = OffersScreen();
                  });
                },
              ),
            ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.SpecialOffer,
                leading: Icon(Icons.local_offer_outlined),
                title: Text('Special Offer').tr(),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    if (specialDiscountEnable) {
                      _drawerSelection = DrawerSelection.SpecialOffer;
                      _appBarTitle = 'Special Offer'.tr();
                      _currentWidget = SpecialOfferScreen();
                    } else {
                      final snackBar = SnackBar(
                        content: const Text('This feature is not enable by admin.'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  });
                },
              ),
            ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.Profile,
                leading: Icon(CupertinoIcons.person),
                title: Text('Profile').tr(),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _drawerSelection = DrawerSelection.Profile;
                    _appBarTitle = 'Profile'.tr();
                    _currentWidget = ProfileScreen(
                      user: user!,
                    );
                  });
                },
              ),
            ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.Wallet,
                leading: Icon(Icons.account_balance_wallet_sharp),
                title: Text('wallet').tr(),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _drawerSelection = DrawerSelection.Wallet;
                    _appBarTitle = 'wallet'.tr();
                    _currentWidget = WalletScreen();
                  });
                },
              ),
            ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.BankInfo,
                leading: Icon(Icons.account_balance),
                title: Text('bankDetails').tr(),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _drawerSelection = DrawerSelection.BankInfo;
                    _appBarTitle = 'bankInfo'.tr();
                    _currentWidget = BankDetailsScreen();
                  });
                },
              ),
            ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.chooseLanguage,
                leading: Icon(
                  Icons.language,
                  color: _drawerSelection == DrawerSelection.chooseLanguage
                      ? Color(COLOR_PRIMARY)
                      : isDarkMode(context)
                          ? Colors.grey.shade200
                          : Colors.grey.shade600,
                ),
                title: const Text('language').tr(),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _drawerSelection = DrawerSelection.chooseLanguage;
                    _appBarTitle = 'language'.tr();
                    _currentWidget = LanguageChooseScreen(
                      isContainer: true,
                    );
                  });
                },
              ),
            ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.Logout,
                leading: Icon(Icons.logout),
                title: Text('Log out').tr(),
                onTap: () async {
                  audioPlayer.stop();
                  Navigator.pop(context);
                  //user.active = false;
                  user!.lastOnlineTimestamp = Timestamp.now();
                  await FireStoreUtils.firestore.collection(USERS).doc(user!.userID).update({"fcmToken": ""});
                  if (user!.vendorID != null && user!.vendorID.isNotEmpty) {
                    await FireStoreUtils.firestore.collection(VENDORS).doc(user!.vendorID).update({"fcmToken": ""});
                  }
                  // await FireStoreUtils.updateCurrentUser(user);
                  await auth.FirebaseAuth.instance.signOut();
                  await FacebookAuth.instance.logOut();
                  MyAppState.currentUser = null;
                  pushAndRemoveUntil(context, AuthScreen(), false);
                },
              ),
            ),
          ],
        ),
      )),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: _drawerSelection == DrawerSelection.Wallet
              ? Colors.white
              : isDarkMode(context)
                  ? Colors.white
                  : Colors.black,
        ),
        centerTitle: _drawerSelection == DrawerSelection.Wallet ? true : false,
        backgroundColor: _drawerSelection == DrawerSelection.Wallet
            ? Colors.transparent
            : isDarkMode(context)
                ? Color(DARK_VIEWBG_COLOR)
                : Colors.white,
        actions: [
          // if (_currentWidget is ManageProductsScreen)
          // IconButton(
          //   icon: Icon(
          //     CupertinoIcons.add_circled,
          //     color: Color(COLOR_PRIMARY),
          //   ),
          //   onPressed: () => push(
          //     context,
          //     AddOrUpdateProductScreen(product: null),
          //   ),
          // ),
        ],
        title: Text(
          _appBarTitle,
          style: TextStyle(
            fontSize: 20,
            color: _drawerSelection == DrawerSelection.Wallet
                ? Colors.white
                : isDarkMode(context)
                    ? Colors.white
                    : Colors.black,
          ),
        ),
      ),
      body: WillPopScope(
          onWillPop: () async {
            final timegap = DateTime.now().difference(pre_backpress);
            final cantExit = timegap >= Duration(seconds: 2);
            pre_backpress = DateTime.now();
            if (cantExit) {
              //show snackbar
              final snack = SnackBar(
                content: Text(
                  'pressBackButtonAgainToExit'.tr(),
                  style: TextStyle(color: Colors.white),
                ),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.black,
              );
              ScaffoldMessenger.of(context).showSnackBar(snack);
              return false; // false will do nothing when back press
            } else {
              return true; // true will exit the app
            }
          },
          child: _currentWidget),
    );
  }
}
