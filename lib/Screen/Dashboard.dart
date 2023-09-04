import 'dart:async';
import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/PushNotificationService.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/app_assets.dart';
import 'package:eshop_multivendor/Helper/ccavenue.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Favorite.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:eshop_multivendor/Screen/MyOrder.dart';
import 'package:eshop_multivendor/Screen/MyProfile.dart';
import 'package:eshop_multivendor/Screen/Product_Detail.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import 'All_Category.dart';
import 'Cart.dart';
import 'HomePage.dart';
import 'NotificationLIst.dart';
import 'Sale.dart';
import 'Search.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Dashboard> with TickerProviderStateMixin {
  int _selBottom = 0;
  late TabController _tabController;
  bool _isNetworkAvail = true;

  var pinController = TextEditingController();
  var currentAddress = TextEditingController();
  var latitude;
  var longitude;

  Future<void> getCurrentLoc() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print("checking permission here ${permission}");
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location Not Available');
      }
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var loc = Provider.of<LocationProvider>(context, listen: false);

    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    List<Placemark> placemark = await placemarkFromCoordinates(
        double.parse(latitude!), double.parse(longitude!),
        localeIdentifier: "en");

    pinController.text = placemark[0].postalCode!;
    if (mounted) {
      setState(() {
        pinController.text = placemark[0].postalCode!;
        currentAddress.text =
            "${placemark[0].street}, ${placemark[0].subLocality}, ${placemark[0].locality}";
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
        loc.lng = position.longitude.toString();
        loc.lat = position.latitude.toString();
      });
    }
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    getCurrentLoc();
    super.initState();
    initDynamicLinks();
    _tabController = TabController(
      length: 5,
      vsync: this,
    );

    final pushNotificationService = PushNotificationService(
        context: context, tabController: _tabController);
    pushNotificationService.initialise();

    _tabController.addListener(
      () {
        Future.delayed(Duration(seconds: 0)).then(
          (value) {
            if (_tabController.index == 3) {
              if (CUR_USERID == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
                _tabController.animateTo(0);
              }
            }
          },
        );

        setState(
          () {
            _selBottom = _tabController.index;
          },
        );
      },
    );
  }

  void initDynamicLinks() async {
/*    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      if (deepLink != null) {
        if (deepLink.queryParameters.length > 0) {
          int index = int.parse(deepLink.queryParameters['index']!);

          int secPos = int.parse(deepLink.queryParameters['secPos']!);

          String? id = deepLink.queryParameters['id'];

          String? list = deepLink.queryParameters['list'];

          getProduct(id!, index, secPos, list == "true" ? true : false);
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print(e.message);
    });*/

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      if (deepLink.queryParameters.length > 0) {
        int index = int.parse(deepLink.queryParameters['index']!);

        int secPos = int.parse(deepLink.queryParameters['secPos']!);

        String? id = deepLink.queryParameters['id'];

        // String list = deepLink.queryParameters['list'];

        getProduct(id!, index, secPos, true);
      }
    }
  }

  Future<void> getProduct(String id, int index, int secPos, bool list) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          ID: id,
        };

        // if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        Response response =
            await post(getProductApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          List<Product> items = [];

          items =
              (data as List).map((data) => new Product.fromJson(data)).toList();

          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProductDetail(
                    index: list ? int.parse(id) : index,
                    model: list
                        ? items[0]
                        : sectionList[secPos].productList![index],
                    secPos: secPos,
                    list: list,
                  )));
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      {
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_tabController.index != 0) {
          _tabController.animateTo(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        appBar: _getAppBar(),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            HomePage(),
            AllCategory(),
            //Sale(),
            MyOrder(
              isFromBottom: true,
            ),
            Cart(
              fromBottom: true,
            ),
            MyProfile(),
          ],
        ),
        //fragments[_selBottom],
        // bottomNavigationBar: _getBottomBar(),
        bottomNavigationBar: _getBottomNavigator(),
      ),
    );
  }

  AppBar _getAppBar() {
    String? title;
    if (_selBottom == 1)
      title = getTranslated(context, 'CATEGORY');
    else if (_selBottom == 2)
      title = "MY ORDER";
    else if (_selBottom == 3)
      title = getTranslated(context, 'MYBAG');
    else if (_selBottom == 4) title = getTranslated(context, 'PROFILE');

    return AppBar(
      centerTitle: _selBottom == 0 ? true : false,
      title: _selBottom == 0
          ? Image.asset(
              // 'assets/images/titleicon.png',
              MyAssets.normal_logo,
              //height: 40,

              // width: 150,
              height: 75,

              // color: colors.primary,
              // width: 45,
            )
          : Text(
              title!,
              style: TextStyle(
                  color: colors.primary, fontWeight: FontWeight.normal),
            ),

      leading: _selBottom == 0
          ? InkWell(
              child: Center(
                  child: SvgPicture.asset(
                imagePath + "search.svg",
                height: 20,
                color: colors.primary,
              )),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Search(),
                    ));
              },
            )
          : null,
      // iconTheme: new IconThemeData(color: colors.primary),
      // centerTitle:_curSelected == 0? false:true,
      actions: <Widget>[
        _selBottom == 0 || _selBottom == 4
            ? Container()
            : IconButton(
                icon: SvgPicture.asset(
                  imagePath + "search.svg",
                  height: 20,
                  color: colors.primary,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Search(),
                      ));
                }),
        _selBottom == 4
            ? Container()
            : IconButton(
                icon: SvgPicture.asset(
                  imagePath + "desel_notification.svg",
                  color: colors.primary,
                ),
                onPressed: () {
                  CUR_USERID != null
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationList(),
                          ))
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ));
                },
              ),
        _selBottom == 4
            ? Container()
            : IconButton(
                padding: EdgeInsets.all(0),
                icon: SvgPicture.asset(
                  imagePath + "desel_fav.svg",
                  color: colors.primary,
                ),
                onPressed: () {
                  CUR_USERID != null
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Favorite() //CCAvenueScreen(),
                          ))
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ));
                },
              ),
      ],
      backgroundColor: Theme.of(context).colorScheme.white,
    );
  }

  Widget _getBottomBar() {
    return Material(
        color: Theme.of(context).colorScheme.white,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.white,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).colorScheme.black26, blurRadius: 10)
            ],
          ),
          child: TabBar(
            onTap: (_) {
              if (_tabController.index == 3) {
                if (CUR_USERID == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ),
                  );
                  _tabController.animateTo(0);
                }
              }
            },
            controller: _tabController,
            tabs: [
              Tab(
                icon: _selBottom == 0
                    ? SvgPicture.asset(
                        imagePath + "sel_home.svg",
                        color: colors.primary,
                      )
                    : SvgPicture.asset(
                        imagePath + "desel_home.svg",
                        color: colors.primary,
                      ),
                text:
                    _selBottom == 0 ? getTranslated(context, 'HOME_LBL') : null,
              ),
              Tab(
                icon: _selBottom == 1
                    ? SvgPicture.asset(
                        imagePath + "category01.svg",
                        color: colors.primary,
                      )
                    : SvgPicture.asset(
                        imagePath + "category.svg",
                        color: colors.primary,
                      ),
                text:
                    _selBottom == 1 ? getTranslated(context, 'category') : null,
              ),
              Tab(
                icon: _selBottom == 2
                    ? SvgPicture.asset(
                        imagePath + "pro_myorder.svg",
                        color: colors.primary,
                      )
                    : SvgPicture.asset(
                        imagePath + "pro_myorder.svg",
                        color: colors.primary,
                      ),
                text: _selBottom == 2 ? getTranslated(context, 'SALE') : null,
              ),
              Tab(
                icon: Selector<UserProvider, String>(
                  builder: (context, data, child) {
                    return Stack(
                      children: [
                        Center(
                          child: _selBottom == 3
                              ? SvgPicture.asset(
                                  imagePath + "cart01.svg",
                                  color: colors.primary,
                                )
                              : SvgPicture.asset(
                                  imagePath + "cart.svg",
                                  color: colors.primary,
                                ),
                        ),
                        (data != null && data.isNotEmpty && data != "0")
                            ? new Positioned.directional(
                                bottom: _selBottom == 3 ? 6 : 20,
                                textDirection: Directionality.of(context),
                                end: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colors.primary),
                                  child: new Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(3),
                                      child: new Text(
                                        data,
                                        style: TextStyle(
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .white),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    );
                  },
                  selector: (_, homeProvider) => homeProvider.curCartCount,
                ),
                text: _selBottom == 3 ? getTranslated(context, 'CART') : null,
              ),
              Tab(
                icon: _selBottom == 4
                    ? SvgPicture.asset(
                        imagePath + "profile01.svg",
                        color: colors.primary,
                      )
                    : SvgPicture.asset(
                        imagePath + "profile.svg",
                        color: colors.primary,
                      ),
                text:
                    _selBottom == 4 ? getTranslated(context, 'ACCOUNT') : null,
              ),
            ],
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: colors.primary, width: 5.0),
              insets: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 70.0),
            ),
            labelStyle: TextStyle(fontSize: 9),
            labelColor: colors.primary,
          ),
        ));
  }

  Widget _getBottomNavigator() {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: CurvedNavigationBar(
        height: 50,
        backgroundColor: Colors.transparent,
        items: <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.category, size: 30),
          Icon(Icons.fire_truck_outlined, size: 30),
          Icon(Icons.shopping_cart_outlined, size: 30),
          // Center(
          //           child: SvgPicture.asset(
          //             imagePath + "appbarCart.svg",
          //             color: colors.primary,
          //           ),
          //         ),
          // Selector<UserProvider, String>   (
          //   builder: (context, data, child) {
          //     return IconButton(
          //       icon: Stack(
          //         children: [
          //           Center(
          //             child: SvgPicture.asset(
          //               imagePath + "appbarCart.svg",
          //               color: colors.primary,
          //             ),
          //           ),
          //           (data != null && data.isNotEmpty && data != "0")
          //               ? new Positioned(
          //             bottom: 20,
          //             right: 0,
          //             child: Container(
          //               //  height: 20,
          //               decoration: BoxDecoration(
          //                   shape: BoxShape.circle,
          //                   color: colors.primary),
          //               child: new Center(
          //                 child: Padding(
          //                   padding: EdgeInsets.all(3),
          //                   child: new Text(
          //                     data,
          //                     style: TextStyle(
          //                         fontSize: 7,
          //                         fontWeight: FontWeight.bold,
          //                         color: Theme.of(context)
          //                             .colorScheme
          //                             .white),
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           )
          //               : Container()
          //         ],
          //       ),
          //       // onPressed: () {
          //       //   CUR_USERID != null
          //       //       ? Navigator.push(
          //       //     context,
          //       //     MaterialPageRoute(
          //       //       builder: (context) => Cart(
          //       //         fromBottom: false,
          //       //       ),
          //       //     ),
          //       //   )
          //       //       : Navigator.push(
          //       //     context,
          //       //     MaterialPageRoute(
          //       //       builder: (context) => Login(),
          //       //     ),
          //       //   );
          //       // },
          //     );
          //   },
          //   selector: (_, homeProvider) => homeProvider.curCartCount,
          // ),
          Icon(Icons.person, size: 30),
        ],
        onTap: (index) {
          _tabController.animateTo(index);
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}
