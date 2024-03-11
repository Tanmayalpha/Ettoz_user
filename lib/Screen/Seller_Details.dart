import 'dart:async';
import 'dart:convert';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Model/favRestaurantModel.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import '../Provider/CartProvider.dart';
import '../Provider/FavoriteProvider.dart';
import '../Provider/UserProvider.dart';
import 'Cart.dart';
import 'Login.dart';
import 'Product_Detail.dart';

class SellerProfile extends StatefulWidget {
  String? sellerID,
      catId,
      sellerName,
      sellerImage,
      sellerRating,
      storeDesc,
      sellerStoreName,
      subCatId;
  final sellerData;
  final search;
  final extraData;
  final bool? fromSearch;

  SellerProfile(
      {Key? key,
      this.sellerID,
      this.sellerName,
      this.sellerImage,
      this.fromSearch = false,
      this.catId,
      this.sellerRating,
      this.storeDesc,
      this.sellerStoreName,
      this.subCatId,
      this.sellerData,
      this.search,
      this.extraData})
      : super(key: key);

  @override
  State<SellerProfile> createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  late TabController _tabController;
  bool _isNetworkAvail = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isDescriptionVisible = false;
  int offset = 0;
  int total = 0;
  int newQty = 1;
  bool categoryChange = false;
  String sortBy = 'p.id', orderBy = "DESC";
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    Future.delayed(Duration(milliseconds: 300), () {
      return getSubCategory();
    });
    getFavorite();
    Future.delayed(Duration(milliseconds: 400), () {
      return getProduct("0", "");
    });
  }

  List<String> favList = [];

  FavRestaurantModel? favRestaurantModel;

  getFavorite() async {
    var headers = {
      'Cookie': 'ci_session=c7c206a79f404e9650f05602a43825258241a0ec'
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('${baseUrl}get_favourite_restaurant'));
    request.fields.addAll({
      'user_id': CUR_USERID.toString(),
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();
      final jsonResponse =
          FavRestaurantModel.fromJson(json.decode(finalResult));
      setState(() {
        favRestaurantModel = jsonResponse;
      });

      for (var i = 0; i < favRestaurantModel!.data!.length; i++) {
        favList.add(favRestaurantModel!.data![i].id.toString());
      }

      print(" checking fav here ${favList}");
    } else {
      print(response.reasonPhrase);
    }
  }

  removeRestaurant(id) async {
    var headers = {
      'Cookie': 'ci_session=8452a86ab7a629953bc9a7f2a3d2efe0af57f669'
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('${baseUrl}remove_favourite_restaurant'));
    request.fields
        .addAll({'user_id': CUR_USERID.toString(), 'res_id': id.toString()});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      getFavorite();
      var finalResult = await response.stream.bytesToString();
      final jsonResponse = json.decode(finalResult);
      setState(() {
        setSnackbar("${jsonResponse['message']}", context);
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  addFavRestaurant(String id) async {
    var headers = {
      'Cookie': 'ci_session=6c3ab0048d71d50cabc8b0bad51b80f6796bbe79'
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('${baseUrl}favourite_restaurant'));
    request.fields.addAll({
      'user_id': CUR_USERID.toString(),
      'res_id': id.toString(),
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      getFavorite();
      var finalResponse = await response.stream.bytesToString();
      final jsonResponse = json.decode(finalResponse);
      setState(() {
        setSnackbar("${jsonResponse['message']}", context);
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  bool _isLoading = true;
  List<Product> productList = [];
  dynamic subCatData = [];
  var imageBase = "";
  bool loading = false;
  bool mount = false;
  var newSubId;
  getSubCategory() async {
    var parm = {};
    // if (catId != null) {
    // parm = {"seller_id": "$sellerId", "cat_id": "$catId"};
    // } else {
    //   parm = {"seller_id": "$sellerId"};
    // }
    parm = {"seller_id": "${widget.sellerID}"};
    print(
        "checking new api parameters here ${parm} and ${getSubCatBySellerId}");
    apiBaseHelper.postAPICall(getSubCatBySellerId, parm).then((value) {
      setState(() {
        subCatData = value["recommend_products"];
        imageBase = value["image_path"];
        mount = true;
      });
    });
  }

  String? fType;
  String selId = "";
  RangeValues? _currentRangeValues;
  bool _isFirstLoad = true;
  var filterList;
  String minPrice = "0", maxPrice = "0";
  List<Product> tempList = [];
  bool isLoadingmore = true;
  List<String>? tagList = [];
  String? totalProduct;
  List<TextEditingController> _controller = [];
  bool _isProgress = false;
  bool listType = true;
  ScrollController controller = new ScrollController();

  void getProduct(String top, String id) {
    print("sub cat id here ${id}");
    //_currentRangeValues.start.round().toString(),
    // _currentRangeValues.end.round().toString(),
    Map parameter = {
      SORT: sortBy,
      ORDER: orderBy,
      SUB_CAT_ID: id == "" || id == null ? widget.subCatId : id,
      LIMIT: perPage.toString(),
      OFFSET: "0",
      TOP_RETAED: top,
      'indicator': fType == "null" || fType == null ? "0" : fType.toString()
    };
    if (selId != null && selId != "") {
      parameter[ATTRIBUTE_VALUE_ID] = selId;
    }
    // if (widget.tag!) parameter[TAG] = widget.name!;
    //  if () {
    parameter["seller_id"] = widget.sellerID.toString();
    //}
    // else {
    //   parameter[CATID] = widget.id ?? '';
    // }
    if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;

    parameter[DISCOUNT] = "";

    // if (_currentRangeValues != null &&
    //     _currentRangeValues!.start.round().toString() != "0") {
    //   parameter[MINPRICE] = _currentRangeValues!.start.round().toString();
    // }
    //
    // if (_currentRangeValues != null &&
    //     _currentRangeValues!.end.round().toString() != "0") {
    //   parameter[MAXPRICE] = _currentRangeValues!.end.round().toString();
    // }

    print("new paremters here ${parameter} and ${getProductApi}");
    apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      setState(() {
        tempList.clear();
      });
      if (error == false) {
        total = int.parse(getdata["total"]);

        if (_isFirstLoad) {
          filterList = getdata["filters"];

          minPrice = getdata[MINPRICE].toString();
          maxPrice = getdata[MAXPRICE].toString();
          _currentRangeValues =
              RangeValues(double.parse(minPrice), double.parse(maxPrice));
          _isFirstLoad = false;
        }

        //   if ((offset) < total) {

        setState(() {});
        tempList.clear();

        var data = getdata["data"];
        tempList =
            (data as List).map((data) => new Product.fromJson(data)).toList();

        if (getdata.containsKey(TAG)) {
          List<String> tempList = List<String>.from(getdata[TAG]);
          if (tempList != null && tempList.length > 0) tagList = tempList;
        }

        getAvailVarient();

        offset = offset + perPage;
        // } else {
        //   if (msg != "Products Not Found !") setSnackbar(msg!, context);
        //   isLoadingmore = false;
        // }
      } else {
        setState(() {
          tempList.clear();
        });
        // getAvailVarient();
        isLoadingmore = false;
        if (msg != "Products Not Found !") setSnackbar(msg!, context);
      }

      setState(() {
        _isLoading = false;
      });
      // context.read<ProductListProvider>().setProductLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      setState(() {
        _isLoading = false;
      });
      //context.read<ProductListProvider>().setProductLoading(false);
    });
  }

  void getAvailVarient() {
    productList.clear();
    print("variant data here now ");
    for (int j = 0; j < tempList.length; j++) {
      if (tempList[j].stockType == "2") {
        for (int i = 0; i < tempList[j].prVarientList!.length; i++) {
          if (tempList[j].prVarientList![i].availability == "1") {
            tempList[j].selVarient = i;
            break;
          }
        }
      }
    }
    productList.addAll(tempList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          backgroundColor: colors.whiteTemp,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: colors.primary,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            Selector<UserProvider, String>(
              builder: (context, data, child) {
                return IconButton(
                  icon: Stack(
                    children: [
                      Center(
                        child: SvgPicture.asset(
                          imagePath + "appbarCart.svg",
                          color: colors.primary,
                        ),
                      ),
                      (data != null && data.isNotEmpty && data != "0")
                          ? new Positioned(
                              bottom: 20,
                              right: 0,
                              child: Container(
                                //  height: 20,
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
                  ),
                  onPressed: () {
                    CUR_USERID != null
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Cart(
                                fromBottom: false,
                              ),
                            ),
                          )
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Login(),
                            ),
                          );
                  },
                );
              },
              selector: (_, homeProvider) => homeProvider.curCartCount,
            ),
          ],
          title:
              //widget.search?
              Text(
            "${widget.sellerStoreName}",
            style: TextStyle(color: colors.primary),
          )
          //Text("${widget.sellerData.store_name}" , style: TextStyle(color: colors.primary),),
          ),
      body: Material(
        child: Column(
          children: [
            // widget.search
            //     ? Card(
            //       shape:
            //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            //       child: Container(
            //         width: MediaQuery.of(context).size.width,
            //         decoration: BoxDecoration(
            //             image: DecorationImage(image: NetworkImage(widget.sellerImage.toString()),fit: BoxFit.cover)
            //         ),
            //         child: Column(children: [
            //           ListTile(
            //             // leading: CircleAvatar(
            //             //   backgroundImage: NetworkImage(widget.sellerImage.toString()),
            //             // ),
            //             title: Text("${widget.sellerStoreName}".toUpperCase()),
            //             subtitle: Text(
            //               "${widget.storeDesc}",
            //               maxLines: 2,
            //             ),
            //           ),
            //           Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.end,
            //               children: [
            //                 Column(
            //                   crossAxisAlignment: CrossAxisAlignment.end,
            //                   children: [
            //                     widget.extraData["rating"] == "" ? SizedBox() :    Icon(
            //                       Icons.star_rounded,
            //                       color: colors.primary,
            //                     ),
            //                     widget.extraData["rating"] == "" ? SizedBox() : Text("${widget.extraData["rating"]}"),
            //                     widget.extraData["estimated_time"] == "" ? SizedBox() : Text("Delivery Time"),
            //                     widget.extraData["estimated_time"]  == "" ? SizedBox() : Text(
            //                       "${widget.extraData["estimated_time"]} Minutes",
            //                       style: TextStyle(color: Colors.green),
            //                     ),
            //                   ],
            //                 ),
            //                 // widget.extraData["food_person"] !=""?
            //                 // Column(
            //                 //   children: [
            //                 //     Text("₹/Person"),
            //                 //     Text("${widget.extraData["food_person"]}"),
            //                 //   ],
            //                 // ):Container()
            //               ],),
            //           ),
            //         ],),
            //       ),
            //     )
            //     :
            widget.fromSearch == true
                ? Stack(
                    children: [
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    '${imageUrl}${widget.sellerData['logo']}'),
                                fit: BoxFit.fill)),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: MediaQuery.of(context).size.width * 0.35,
                          color: Colors.black.withOpacity(0.5),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      '${imageUrl}${widget.sellerData['logo']}'),
                                ),
                                title: Text(
                                  "${widget.sellerData['store_name']}"
                                      .toUpperCase(),
                                  style: TextStyle(color: colors.whiteTemp),
                                ),
                                subtitle: Text(
                                  "${widget.sellerData['store_description']}",
                                  maxLines: 2,
                                  style: TextStyle(color: colors.whiteTemp),
                                ),
                              ),

                              // ListTile(title: Text("Address"), subtitle: Text("${widget.sellerData.address}"),),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Column(
                                    //   crossAxisAlignment: CrossAxisAlignment.end,
                                    //   children: [
                                    //     Icon(
                                    //       Icons.star_rounded,
                                    //       color: colors.primary,
                                    //     ),
                                    //     Text("${widget.sellerData.seller_rating}",
                                    //       style: TextStyle(
                                    //           color: colors.whiteTemp
                                    //       ),
                                    //     )
                                    //   ],
                                    // ),
                                    widget.sellerData['estimated_time'] != ""
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              widget.sellerData[
                                                              'seller_rating'] ==
                                                          "" ||
                                                      widget.sellerData[
                                                              'seller_rating'] ==
                                                          null
                                                  ? SizedBox()
                                                  : Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Icon(
                                                          Icons.star_rounded,
                                                          color: colors.primary,
                                                        ),
                                                        Text(
                                                          "${widget.sellerData['seller_rating']}",
                                                          style: TextStyle(
                                                              color: colors
                                                                  .whiteTemp),
                                                        )
                                                      ],
                                                    ),
                                              Text(
                                                "Delivery Time",
                                                style: TextStyle(
                                                    color: colors.whiteTemp),
                                              ),
                                              Text(
                                                "${widget.sellerData['estimated_time']} minutes",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              widget.sellerData['indicator'] ==
                                                      "1"
                                                  ? Image.asset(
                                                      "assets/images/vegImage.png",
                                                      height: 15,
                                                      width: 15,
                                                    )
                                                  : widget.sellerData[
                                                              'indicator'] ==
                                                          "2"
                                                      ? Image.asset(
                                                          "assets/images/non-vegImage.png",
                                                          height: 15,
                                                          width: 15,
                                                        )
                                                      : Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Image.asset(
                                                              "assets/images/vegImage.png",
                                                              height: 15,
                                                              width: 15,
                                                            ),
                                                            Image.asset(
                                                              "assets/images/non-vegImage.png",
                                                              height: 15,
                                                              width: 15,
                                                            )
                                                          ],
                                                        )
                                            ],
                                          )
                                        : Container(),

                                    // widget.sellerData.food_person !=""?
                                    // Column(
                                    //   children: [
                                    //     Text("₹/Person",
                                    //       style: TextStyle(
                                    //           color: colors.whiteTemp
                                    //       ),
                                    //     ),
                                    //     Text("${widget.sellerData.food_person}",
                                    //       style: TextStyle(
                                    //           color: colors.whiteTemp
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ):Container()
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 1,
                        right: 1,
                        child: Padding(
                          padding: EdgeInsets.only(right: 5, top: 5),
                          child: Card(
                            elevation: 1,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.favorite_border,
                                color: Colors.red,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
                      widget.sellerData['address'] == null ||
                              widget.sellerData['address'] == ""
                          ? Container()
                          : Positioned(
                              bottom: 1,
                              child: Padding(
                                  padding:
                                      EdgeInsets.only(left: 10, bottom: 20),
                                  child: Text(
                                    "${widget.sellerData['address']}",
                                    style: TextStyle(color: Colors.white),
                                  )),
                            )
                    ],
                  )
                : Stack(
                    children: [
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    widget.sellerData.seller_profile ?? ''),
                                fit: BoxFit.fill)),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: MediaQuery.of(context).size.width * 0.35,
                          color: Colors.black.withOpacity(0.5),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      widget.sellerData.seller_profile ?? ''),
                                ),
                                title: Text(
                                  "${widget.sellerData.store_name!}"
                                      .toUpperCase(),
                                  style: TextStyle(color: colors.whiteTemp),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${widget.sellerData.store_description}",
                                      maxLines: 2,
                                      style: TextStyle(color: colors.whiteTemp),
                                    ),
                                  ],
                                ),
                              ),

                              // ListTile(title: Text("Address"), subtitle: Text("${widget.sellerData.address}"),),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Column(
                                    //   crossAxisAlignment: CrossAxisAlignment.end,
                                    //   children: [
                                    //     Icon(
                                    //       Icons.star_rounded,
                                    //       color: colors.primary,
                                    //     ),
                                    //     Text("${widget.sellerData.seller_rating}",
                                    //       style: TextStyle(
                                    //           color: colors.whiteTemp
                                    //       ),
                                    //     )
                                    //   ],
                                    // ),
                                    // widget.sellerData.estimated_time != ""
                                    //     ?
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              color: colors.primary,
                                            ),
                                            Text(
                                              "${widget.sellerData.seller_rating}",
                                              style: TextStyle(
                                                  color: colors.whiteTemp),
                                            )
                                          ],
                                        ),
                                        Text(
                                          "Delivery Time",
                                          style: TextStyle(
                                              color: colors.whiteTemp),
                                        ),
                                        Text(
                                          "${widget.sellerData.estimated_time} Minutes",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        widget.sellerData.storeIndicator == "1"
                                            ? Image.asset(
                                                "assets/images/vegImage.png",
                                                height: 15,
                                                width: 15,
                                              )
                                            : widget.sellerData
                                                        .storeIndicator ==
                                                    "2"
                                                ? Image.asset(
                                                    "assets/images/non-vegImage.png",
                                                    height: 15,
                                                    width: 15,
                                                  )
                                                : Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Image.asset(
                                                        "assets/images/vegImage.png",
                                                        height: 15,
                                                        width: 15,
                                                      ),
                                                      Image.asset(
                                                        "assets/images/non-vegImage.png",
                                                        height: 15,
                                                        width: 15,
                                                      )
                                                    ],
                                                  )
                                      ],
                                    )
                                    // : Container(),

                                    // widget.sellerData.food_person !=""?
                                    // Column(
                                    //   children: [
                                    //     Text("₹/Person",
                                    //       style: TextStyle(
                                    //           color: colors.whiteTemp
                                    //       ),
                                    //     ),
                                    //     Text("${widget.sellerData.food_person}",
                                    //       style: TextStyle(
                                    //           color: colors.whiteTemp
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ):Container()
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 1,
                        right: 1,
                        child: Padding(
                          padding: EdgeInsets.only(right: 5, top: 5),
                          child: InkWell(
                            onTap: () {
                              if (favList
                                  .contains(widget.sellerID.toString())) {
                                removeRestaurant(widget.sellerID.toString());
                                favList.remove(widget.sellerID.toString());
                                setState(() {});
                              } else {
                                addFavRestaurant(widget.sellerID.toString());
                                setState(() {});
                              }
                            },
                            child: Card(
                              elevation: 1,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: favList
                                          .contains(widget.sellerID.toString())
                                      ? Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 25,
                                        )
                                      : Icon(
                                          Icons.favorite_border,
                                          color: Colors.red,
                                          size: 25,
                                        )),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        child: Padding(
                            padding: EdgeInsets.only(left: 10, bottom: 20),
                            child: Text(
                              "${widget.sellerData.address}",
                              style: TextStyle(color: Colors.white),
                            )),
                      )
                    ],
                  ),
            SizedBox(
              height: 10,
            ),
            subCatData == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : subCatData.isNotEmpty
                    ? Container(
                        height: 40,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: subCatData.length,
                            itemBuilder: (c, i) {
                              print(
                                  "checking both id here ${subCatData[i]['id']} and ${widget.subCatId}");
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    productList.clear();
                                    widget.subCatId = subCatData[i]['id'];
                                    newSubId = subCatData[i]['id'];
                                    categoryChange = true;
                                    fType = "";
                                    getProduct("0", newSubId);
                                  });

                                  print(
                                      "okokok ${widget.subCatId} and ${categoryChange}");
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color:
                                          widget.subCatId == subCatData[i]['id']
                                              ? colors.primary
                                              : colors.whiteTemp,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      "${subCatData[i]['name']}",
                                      style: TextStyle(
                                          color: widget.subCatId ==
                                                  subCatData[i]['id']
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      )
                    : Container(
                        child: Text("No data to show"),
                      ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              // child: newSubId == '' || newSubId == null ? ProductList(
              //   fromSeller: true,
              //   name: "",
              //   id: widget.sellerID,
              //   subCatId: widget.subCatId,
              //   tag: false,
              // ) : ProductList(
              //   fromSeller: true,
              //   name: "",
              //   id: widget.sellerID,
              //   subCatId:newSubId,
              //   tag: false,
              // ),
              child: _showForm(context),
            )
          ],
        ),
      ),
    );

    // DefaultTabController(
    //   length: 2,
    //   child: Scaffold(
    //     appBar: getAppBar(getTranslated(context, 'SELLER_DETAILS')!, context),
    //     body: Container(
    //       child: Column(
    //         mainAxisSize: MainAxisSize.max,
    //         children: [
    //           TabBar(
    //             controller: _tabController,
    //             tabs: [
    //               Tab(text: getTranslated(context, 'DETAILS')!),
    //               Tab(text: getTranslated(context, 'PRODUCTS')),
    //             ],
    //           ),
    //           Expanded(
    //             child: TabBarView(
    //               controller: _tabController,
    //               children: [
    //                 detailsScreen(),
    //                 ProductList(
    //                   fromSeller: true,
    //                   name: "",
    //                   id: widget.sellerID,
    //                   tag: false,
    //                 )
    //               ],
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //     // bottomNavigationBar:
    //   ),
    // );
  }

  // Future fetchSellerDetails() async {
  //   var parameter = {};
  //   final sellerData = await apiBaseHelper.postAPICall(getSellerApi, parameter);
  //   List<Seller> sellerDetails = [];
  //   bool error = sellerData["error"];
  //   String? msg = sellerData["message"];
  //   if (!error) {
  //     var data = sellerData["data"];
  //     sellerDetails =
  //         (data as List).map((data) => Seller.fromJson(data)).toList();
  //   } else {
  //     setSnackbar(msg!, context);
  //   }
  //
  //   return sellerDetails;
  // }

  void sortDialog() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.white,
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                        padding:
                            EdgeInsetsDirectional.only(top: 19.0, bottom: 16.0),
                        child: Text(
                          getTranslated(context, 'SORT_BY')!,
                          style: Theme.of(context).textTheme.headline6,
                        )),
                  ),
                  InkWell(
                    onTap: () {
                      sortBy = '';
                      orderBy = 'DESC';
                      if (mounted)
                        setState(() {
                          _isLoading = true;
                          total = 0;
                          offset = 0;
                          productList.clear();
                        });
                      getProduct("1", "");
                      Navigator.pop(context, 'option 1');
                    },
                    child: Container(
                      width: deviceWidth,
                      color: sortBy == ''
                          ? colors.primary
                          : Theme.of(context).colorScheme.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(getTranslated(context, 'TOP_RATED')!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color: sortBy == ''
                                      ? Theme.of(context).colorScheme.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .fontColor)),
                    ),
                  ),
                  InkWell(
                      child: Container(
                          width: deviceWidth,
                          color: sortBy == 'p.date_added' && orderBy == 'DESC'
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: Text(getTranslated(context, 'F_NEWEST')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                      color: sortBy == 'p.date_added' &&
                                              orderBy == 'DESC'
                                          ? Theme.of(context).colorScheme.white
                                          : Theme.of(context)
                                              .colorScheme
                                              .fontColor))),
                      onTap: () {
                        sortBy = 'p.date_added';
                        orderBy = 'DESC';
                        if (mounted)
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                        getProduct("0", "");
                        Navigator.pop(context, 'option 1');
                      }),
                  InkWell(
                      child: Container(
                          width: deviceWidth,
                          color: sortBy == 'p.date_added' && orderBy == 'ASC'
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: Text(
                            getTranslated(context, 'F_OLDEST')!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(
                                    color: sortBy == 'p.date_added' &&
                                            orderBy == 'ASC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                          )),
                      onTap: () {
                        sortBy = 'p.date_added';
                        orderBy = 'ASC';
                        if (mounted)
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                        getProduct("0", "");
                        Navigator.pop(context, 'option 2');
                      }),
                  InkWell(
                      child: Container(
                          width: deviceWidth,
                          color: sortBy == 'pv.price' && orderBy == 'ASC'
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: new Text(
                            getTranslated(context, 'F_LOW')!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(
                                    color: sortBy == 'pv.price' &&
                                            orderBy == 'ASC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                          )),
                      onTap: () {
                        sortBy = 'pv.price';
                        orderBy = 'ASC';
                        if (mounted)
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                        getProduct("0", "");
                        Navigator.pop(context, 'option 3');
                      }),
                  InkWell(
                      child: Container(
                          width: deviceWidth,
                          color: sortBy == 'pv.price' && orderBy == 'DESC'
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: new Text(
                            getTranslated(context, 'F_HIGH')!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(
                                    color: sortBy == 'pv.price' &&
                                            orderBy == 'DESC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                          )),
                      onTap: () {
                        sortBy = 'pv.price';
                        orderBy = 'DESC';
                        if (mounted)
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                        getProduct("0", "");
                        Navigator.pop(context, 'option 4');
                      }),
                ]),
          );
        });
      },
    );
  }

  void foodDialog() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.white,
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                        padding:
                            EdgeInsetsDirectional.only(top: 19.0, bottom: 16.0),
                        child: Text(
                          "Select Food Type",
                          // getTranslated(context, 'SORT_BY')!,
                          style: Theme.of(context).textTheme.headline6,
                        )),
                  ),
                  ListTile(
                    title: Text('Veg'),
                    leading: Radio(
                      value: "1",
                      groupValue: fType,
                      onChanged: (String? value) {
                        setState(() {
                          fType = value;
                          tempList.clear();
                          productList.clear();
                          getProduct("0", "");
                        });
                        print(" selected value 1 ${fType}");
                        getProduct("0", "");
                        Navigator.pop(context);
                        getProduct("0", "");
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Non-Veg'),
                    leading: Radio(
                      value: '2',
                      groupValue: fType,
                      onChanged: (String? value) {
                        setState(() {
                          fType = value;
                          tempList.clear();
                          productList.clear();
                          getProduct("0", "");
                        });
                        getProduct("0", "");
                        Navigator.pop(context);
                        getProduct("0", "");

                        print(" selected value 2 ${fType}");
                      },
                    ),
                  ),
                  // InkWell(
                  //   onTap: () {
                  //     sortBy = '';
                  //     orderBy = 'DESC';
                  //     if (mounted)
                  //       setState(() {
                  //         _isLoading = true;
                  //         total = 0;
                  //         offset = 0;
                  //         productList.clear();
                  //       });
                  //     getProduct("1");
                  //     Navigator.pop(context, 'option 1');
                  //   },
                  //   child: Container(
                  //     width: deviceWidth,
                  //     color: sortBy == ''
                  //         ? colors.primary
                  //         : Theme.of(context).colorScheme.white,
                  //     padding:
                  //     EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  //     child: Text(getTranslated(context, 'TOP_RATED')!,
                  //         style: Theme.of(context)
                  //             .textTheme
                  //             .subtitle1!
                  //             .copyWith(
                  //             color: sortBy == ''
                  //                 ? Theme.of(context).colorScheme.white
                  //                 : Theme.of(context)
                  //                 .colorScheme
                  //                 .fontColor)),
                  //   ),
                  // ),
                  // InkWell(
                  //     child: Container(
                  //         width: deviceWidth,
                  //         color: sortBy == 'p.date_added' && orderBy == 'DESC'
                  //             ? colors.primary
                  //             : Theme.of(context).colorScheme.white,
                  //         padding: EdgeInsets.symmetric(
                  //             horizontal: 20, vertical: 15),
                  //         child: Text(getTranslated(context, 'F_NEWEST')!,
                  //             style: Theme.of(context)
                  //                 .textTheme
                  //                 .subtitle1!
                  //                 .copyWith(
                  //                 color: sortBy == 'p.date_added' &&
                  //                     orderBy == 'DESC'
                  //                     ? Theme.of(context).colorScheme.white
                  //                     : Theme.of(context)
                  //                     .colorScheme
                  //                     .fontColor))),
                  //     onTap: () {
                  //       sortBy = 'p.date_added';
                  //       orderBy = 'DESC';
                  //       if (mounted)
                  //         setState(() {
                  //           _isLoading = true;
                  //           total = 0;
                  //           offset = 0;
                  //           productList.clear();
                  //         });
                  //       getProduct("0");
                  //       Navigator.pop(context, 'option 1');
                  //     }),
                  // InkWell(
                  //     child: Container(
                  //         width: deviceWidth,
                  //         color: sortBy == 'p.date_added' && orderBy == 'ASC'
                  //             ? colors.primary
                  //             : Theme.of(context).colorScheme.white,
                  //         padding: EdgeInsets.symmetric(
                  //             horizontal: 20, vertical: 15),
                  //         child: Text(
                  //           getTranslated(context, 'F_OLDEST')!,
                  //           style: Theme.of(context)
                  //               .textTheme
                  //               .subtitle1!
                  //               .copyWith(
                  //               color: sortBy == 'p.date_added' &&
                  //                   orderBy == 'ASC'
                  //                   ? Theme.of(context).colorScheme.white
                  //                   : Theme.of(context)
                  //                   .colorScheme
                  //                   .fontColor),
                  //         )),
                  //     onTap: () {
                  //       sortBy = 'p.date_added';
                  //       orderBy = 'ASC';
                  //       if (mounted)
                  //         setState(() {
                  //           _isLoading = true;
                  //           total = 0;
                  //           offset = 0;
                  //           productList.clear();
                  //         });
                  //       getProduct("0");
                  //       Navigator.pop(context, 'option 2');
                  //     }),
                  // InkWell(
                  //     child: Container(
                  //         width: deviceWidth,
                  //         color: sortBy == 'pv.price' && orderBy == 'ASC'
                  //             ? colors.primary
                  //             : Theme.of(context).colorScheme.white,
                  //         padding: EdgeInsets.symmetric(
                  //             horizontal: 20, vertical: 15),
                  //         child: new Text(
                  //           getTranslated(context, 'F_LOW')!,
                  //           style: Theme.of(context)
                  //               .textTheme
                  //               .subtitle1!
                  //               .copyWith(
                  //               color: sortBy == 'pv.price' &&
                  //                   orderBy == 'ASC'
                  //                   ? Theme.of(context).colorScheme.white
                  //                   : Theme.of(context)
                  //                   .colorScheme
                  //                   .fontColor),
                  //         )),
                  //     onTap: () {
                  //       sortBy = 'pv.price';
                  //       orderBy = 'ASC';
                  //       if (mounted)
                  //         setState(() {
                  //           _isLoading = true;
                  //           total = 0;
                  //           offset = 0;
                  //           productList.clear();
                  //         });
                  //       getProduct("0");
                  //       Navigator.pop(context, 'option 3');
                  //     }),
                  // InkWell(
                  //     child: Container(
                  //         width: deviceWidth,
                  //         color: sortBy == 'pv.price' && orderBy == 'DESC'
                  //             ? colors.primary
                  //             : Theme.of(context).colorScheme.white,
                  //         padding: EdgeInsets.symmetric(
                  //             horizontal: 20, vertical: 15),
                  //         child: new Text(
                  //           getTranslated(context, 'F_HIGH')!,
                  //           style: Theme.of(context)
                  //               .textTheme
                  //               .subtitle1!
                  //               .copyWith(
                  //               color: sortBy == 'pv.price' &&
                  //                   orderBy == 'DESC'
                  //                   ? Theme.of(context).colorScheme.white
                  //                   : Theme.of(context)
                  //                   .colorScheme
                  //                   .fontColor),
                  //         )),
                  //     onTap: () {
                  //       sortBy = 'pv.price';
                  //       orderBy = 'DESC';
                  //       if (mounted)
                  //         setState(() {
                  //           _isLoading = true;
                  //           total = 0;
                  //           offset = 0;
                  //           productList.clear();
                  //         });
                  //       getProduct("0");
                  //       Navigator.pop(context, 'option 4');
                  //     }),
                ]),
          );
        });
      },
    );
  }

  filterOptions() {
    return Container(
      color: Theme.of(context).colorScheme.gray,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
              onPressed: foodDialog,
              icon: Icon(
                Icons.filter_list,
                color: colors.primary,
              ),
              label: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/images/vegImage.png",
                    height: 15,
                    width: 15,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Image.asset(
                    "assets/images/non-vegImage.png",
                    height: 15,
                    width: 15,
                  )
                ],
              )),

          TextButton.icon(
            onPressed: sortDialog,
            icon: Icon(
              Icons.swap_vert,
              color: colors.primary,
            ),
            label: Text(
              getTranslated(context, 'SORT_BY')!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
              ),
            ),
          ),
          // InkWell(
          //   child: Icon(
          //     listType ? Icons.grid_view : Icons.list,
          //     color: colors.primary,
          //   ),
          //   onTap: () {
          //     productList.length != 0
          //         ? setState(() {
          //             listType = !listType;
          //           })
          //         : null;
          //   },
          // ),
        ],
      ),
    );
  }

  removeFromCart(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted)
          setState(() {
            _isProgress = true;
          });

        int qty;

        qty =
            /*      (int.parse(productList[index]
                .prVarientList![productList[index].selVarient!]
                .cartCount!)*/
            (int.parse(_controller[index].text) -
                int.parse(productList[index].qtyStepSize!));

        if (qty < productList[index].minOrderQuntity!) {
          qty = 0;
        }

        var parameter = {
          PRODUCT_VARIENT_ID: productList[index]
              .prVarientList![productList[index].selVarient!]
              .id,
          USER_ID: CUR_USERID,
          QTY: qty.toString(),
          'seller_id': widget.sellerID.toString()
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String? qty = data['total_quantity'];
            // CUR_CART_COUNT = ;

            context.read<UserProvider>().setCartCount(data['cart_count']);
            productList[index]
                .prVarientList![productList[index].selVarient!]
                .cartCount = qty.toString();

            var cart = getdata["cart"];
            List<SectionModel> cartList = (cart as List)
                .map((cart) => new SectionModel.fromCart(cart))
                .toList();
            context.read<CartProvider>().setCartlist(cartList);
          } else {
            setSnackbar(msg!, context);
          }

          if (mounted)
            setState(() {
              _isProgress = false;
            });
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          setState(() {
            _isProgress = false;
          });
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  Future<void> addToCart(
      int index, String qty, List<AddQtyModel> addList) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted)
          setState(() {
            _isProgress = true;
          });

        if (int.parse(qty) < productList[index].minOrderQuntity!) {
          qty = productList[index].minOrderQuntity.toString();

          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
        }
        int index1 = 0;
        List<SectionModel> cartList = context.read<CartProvider>().cartList;
        if (int.parse(qty) > 1) {
          index1 = cartList.indexWhere((element) =>
              element.varientId ==
              productList[index]
                  .prVarientList![productList[index].selVarient!]
                  .id);
        }
        List<String> idList = [];
        List<String> qtyList = [];
        addIdList.forEach((element) {
          idList.add(element.id);
          qtyList.add(element.qty);
        });
        setState(() {
          newQty = int.parse(qty.toString());
        });
        var parameter = {
          USER_ID: CUR_USERID,
          'seller_id': widget.sellerID.toString(),
          PRODUCT_VARIENT_ID: productList[index]
              .prVarientList![productList[index].selVarient!]
              .id,
          QTY: qty,
          "add_on_id": index1 != -1 && int.parse(qty) > 1
              ? cartList[index1].add_on_id
              : idList.length > 0
                  ? idList.toString().replaceAll("[", "").replaceAll("]", "")
                  : "",
          "add_on_qty": index1 != -1 && int.parse(qty) > 1
              ? cartList[index1].add_on_qty
              : idList.length > 0
                  ? qtyList.toString().replaceAll("[", "").replaceAll("]", "")
                  : "",
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String? qty = data['total_quantity'];
            // CUR_CART_COUNT = data['cart_count'];

            context.read<UserProvider>().setCartCount(data['cart_count']);
            productList[index]
                .prVarientList![productList[index].selVarient!]
                .cartCount = qty.toString();

            var cart = getdata["cart"];
            List<SectionModel> cartList = (cart as List)
                .map((cart) => new SectionModel.fromCart(cart))
                .toList();
            context.read<CartProvider>().setCartlist(cartList);
          } else {
            setSnackbar(msg!, context);
          }
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  _setFav(int index, Product model) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = true
                : productList[index].isFavLoading = true;
          });

        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};
        print(parameter);
        Response response =
            await post(setFavoriteApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          index == -1 ? model.isFav = "1" : productList[index].isFav = "1";

          context.read<FavoriteProvider>().addFavItem(model);
        } else {
          setSnackbar(msg!, context);
        }

        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = false
                : productList[index].isFavLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  _removeFav(int index, Product model) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = true
                : productList[index].isFavLoading = true;
          });

        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};
        Response response =
            await post(removeFavApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          index == -1 ? model.isFav = "0" : productList[index].isFav = "0";
          context
              .read<FavoriteProvider>()
              .removeFavItem(model.prVarientList![0].id!);
        } else {
          setSnackbar(msg!, context);
        }

        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = false
                : productList[index].isFavLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  Widget listItem(int index) {
    if (index < productList.length) {
      Product model = productList[index];
      totalProduct = model.total;
      print("final addon list here ${model.addOnList} and ${model.id}");
      if (_controller.length < index + 1)
        _controller.add(new TextEditingController());

      _controller[index].text =
          model.prVarientList![model.selVarient!].cartCount!;

      List att = [], val = [];
      if (model.prVarientList![model.selVarient!].attr_name != null) {
        att = model.prVarientList![model.selVarient!].attr_name!.split(',');
        val = model.prVarientList![model.selVarient!].varient_value!.split(',');
      }

      // double price =
      //     double.parse(model.prVarientList![model.selVarient!].disPrice!);
      // print("ssssss ${price}");
      // if (price == 0) {
      //   price = double.parse(model.prVarientList![model.selVarient!].price!);
      //   print("bbbbb ${price}");
      // }
      // print(
      //     "checking price are here ${price} and ${model.prVarientList![model.selVarient!].disPrice}");
      // double off = 0;
      // if (model.prVarientList![model.selVarient!].disPrice! != "0") {
      //   off = (double.parse(model.prVarientList![model.selVarient!].price!) -
      //           double.parse(model.prVarientList![model.selVarient!].disPrice!))
      //       .toDouble();
      //   print("ooo ${off}");
      //   off = off *
      //       100 /
      //       double.parse(model.prVarientList![model.selVarient!].price!);
      // }

      double price =
          double.parse(model.prVarientList![model.selVarient!].disPrice!);
      print("checking price here now ${price}");
      if (price == 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }

      double off = 0;
      if (model.prVarientList![model.selVarient!].disPrice! != "0") {
        off = (double.parse(model.prVarientList![model.selVarient!].price!) -
                double.parse(model.prVarientList![model.selVarient!].disPrice!))
            .toDouble();
        off = off *
            100 /
            double.parse(model.prVarientList![model.selVarient!].price!);
      }
      print("checking off here now ${off} ssfsfsfsfs ${model.indicator}");
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                child: Stack(children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Hero(
                          tag: "ProList$index${model.id}",
                          child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10)),
                              child: Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 80,
                                        width: 85,
                                        child: FadeInImage(
                                          image: CachedNetworkImageProvider(
                                              model.image!),
                                          height: 50.0,
                                          width: 50.0,
                                          fit: BoxFit.fill,
                                          imageErrorBuilder:
                                              (context, error, stackTrace) =>
                                                  erroWidget(125),
                                          placeholder: placeHolder(125),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned.fill(
                                      child: model.availability == "0"
                                          ? Container(
                                              height: 55,
                                              color: Colors.white70,
                                              // width: double.maxFinite,
                                              padding: EdgeInsets.all(2),
                                              child: Center(
                                                child: Text(
                                                  getTranslated(context,
                                                      'OUT_OF_STOCK_LBL')!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption!
                                                      .copyWith(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            )
                                          : Container()),
                                  (off != 0 || off != 0.0 || off != 0.00)
                                      ? Container(
                                          decoration: BoxDecoration(
                                              color: colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              off.toStringAsFixed(2) + "%",
                                              style: TextStyle(
                                                  color: colors.whiteTemp,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 9),
                                            ),
                                          ),
                                          margin: EdgeInsets.all(5),
                                        )
                                      : Container()
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //       color: colors.red,
                                  //       borderRadius:
                                  //           BorderRadius.circular(10)),
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.all(5.0),
                                  //     child: Text(
                                  //       off.toStringAsFixed(2) + "%",
                                  //       style: TextStyle(
                                  //           color: colors.whiteTemp,
                                  //           fontWeight: FontWeight.bold,
                                  //           fontSize: 9),
                                  //     ),
                                  //   ),
                                  //   margin: EdgeInsets.all(5),
                                  // )
                                ],
                              ))),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            //mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width/1.7,
                                    child: Text(
                                      model.name!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .lightBlack),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  model.indicator == "1"
                                      ? Image.asset(
                                          "assets/images/vegImage.png",
                                          height: 15,
                                          width: 15,
                                        )
                                      : model.indicator == "2"
                                          ? Image.asset(
                                              "assets/images/non-vegImage.png",
                                              height: 15,
                                              width: 15,
                                            )
                                          : Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  "assets/images/vegImage.png",
                                                  height: 15,
                                                  width: 15,
                                                ),
                                                Image.asset(
                                                  "assets/images/non-vegImage.png",
                                                  height: 15,
                                                  width: 15,
                                                )
                                              ],
                                            )
                                ],
                              ),
                              model.prVarientList![model.selVarient!]
                                              .attr_name !=
                                          null &&
                                      model.prVarientList![model.selVarient!]
                                          .attr_name!.isNotEmpty
                                  ? ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:
                                          att.length >= 2 ? 2 : att.length,
                                      itemBuilder: (context, index) {
                                        return Row(children: [
                                          Flexible(
                                            child: Text(
                                              att[index].trim() + ":",
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .lightBlack),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(
                                                start: 5.0),
                                            child: Text(
                                              val[index],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .lightBlack,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          )
                                        ]);
                                      })
                                  : Container(),
                              (model.rating! == "0" || model.rating! == "0.0")
                                  ? Container()
                                  : Row(
                                      children: [
                                        RatingBarIndicator(
                                          rating: double.parse(model.rating!),
                                          itemBuilder: (context, index) => Icon(
                                            Icons.star_rate_rounded,
                                            color: Colors.amber,
                                            //color: colors.primary,
                                          ),
                                          unratedColor:
                                              Colors.grey.withOpacity(0.5),
                                          itemCount: 5,
                                          itemSize: 18.0,
                                          direction: Axis.horizontal,
                                        ),
                                        Text(
                                          " (" + model.noOfRating! + ")",
                                          style: Theme.of(context)
                                              .textTheme
                                              .overline,
                                        )
                                      ],
                                    ),
                              Row(
                                children: <Widget>[
                                  Text(
                                      CUR_CURRENCY! +
                                          " " +
                                          price.toString() +
                                          " ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                              fontWeight: FontWeight.bold)),
                                  Text(
                                    double.parse(model
                                                .prVarientList![
                                                    model.selVarient!]
                                                .disPrice!) !=
                                            0
                                        ? CUR_CURRENCY! +
                                            "" +
                                            model
                                                .prVarientList![
                                                    model.selVarient!]
                                                .price!
                                        : "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .overline!
                                        .copyWith(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            letterSpacing: 0),
                                  ),
                                ],
                              ),
                              // Row(
                              //   children: <Widget>[
                              //     Text(
                              //         CUR_CURRENCY! +
                              //             " " +
                              //             price.toString() +
                              //             " ",
                              //         style: Theme.of(context)
                              //             .textTheme
                              //             .subtitle2!
                              //             .copyWith(
                              //                 color: Theme.of(context)
                              //                     .colorScheme
                              //                     .fontColor,
                              //                 fontWeight: FontWeight.bold)),
                              //     off == 0.0 || off == "0.0" || off == ""
                              //         ? SizedBox.shrink()
                              //         : Text(
                              //             double.parse(model
                              //                         .prVarientList![
                              //                             model.selVarient!]
                              //                         .disPrice!) !=
                              //                     0
                              //                 ? CUR_CURRENCY! +
                              //                     "" +
                              //                     model
                              //                         .prVarientList![
                              //                             model.selVarient!]
                              //                         .price!
                              //                 : "",
                              //             style: Theme.of(context)
                              //                 .textTheme
                              //                 .overline!
                              //                 .copyWith(
                              //                     decoration: TextDecoration
                              //                         .lineThrough,
                              //                     letterSpacing: 0),
                              //           ),
                              //   ],
                              // ),
                              _controller[index].text != "0"
                                  ? Row(
                                      children: [
                                        //Spacer(),
                                        model.availability == "0"
                                            ? Container()
                                            : cartBtnList
                                                ? Row(
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          GestureDetector(
                                                            child: Card(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Icon(
                                                                  Icons.remove,
                                                                  size: 15,
                                                                ),
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              if (_isProgress ==
                                                                      false &&
                                                                  (int.parse(_controller[
                                                                              index]
                                                                          .text) >
                                                                      0))
                                                                removeFromCart(
                                                                    index);
                                                            },
                                                          ),
                                                          Container(
                                                            width: 26,
                                                            height: 20,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: colors
                                                                  .white70,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: TextField(
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              readOnly: true,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .fontColor),
                                                              controller:
                                                                  _controller[
                                                                      index],
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                              ),
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            child: Card(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Icon(
                                                                  Icons.add,
                                                                  size: 15,
                                                                ),
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              if (_isProgress ==
                                                                  false)
                                                                addToCart(
                                                                    index,
                                                                    (int.parse(model.prVarientList![model.selVarient!].cartCount!) +
                                                                            int.parse(model.qtyStepSize!))
                                                                        .toString(),
                                                                    []);
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                : Container(),
                                      ],
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  // model.availability == "0"
                  //     ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                  //         style: Theme.of(context)
                  //             .textTheme
                  //             .subtitle2!
                  //             .copyWith(
                  //                 color: Colors.red,
                  //                 fontWeight: FontWeight.bold))
                  //     : Container(),
                ]),
                onTap: () {
                  Product model = productList[index];

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => ProductDetail(
                              model: model,
                              sellerId: widget.sellerID,
                              index: index,
                              preQty: newQty,
                              secPos: 0,
                              list: true,
                            )),
                  );
                },
              ),
            ),
            _controller[index].text == "0"
                ? Positioned.directional(
                    textDirection: Directionality.of(context),
                    bottom: -15,
                    end: 45,
                    child: InkWell(
                      onTap: () {
                        if (_isProgress == false) {
                          print(
                              "checking addon data here ${model.addOnList!.length}");
                          if (model.addOnList!.length > 0) {
                            showBottom(model, index);
                            return;
                          }
                          addToCart(
                              index,
                              (int.parse(_controller[index].text) +
                                      int.parse(model.qtyStepSize!))
                                  .toString(),
                              []);
                        }
                      },
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
            Positioned.directional(
                textDirection: Directionality.of(context),
                bottom: -15,
                end: 0,
                child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: model.isFavLoading!
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 0.7,
                                )),
                          )
                        : Selector<FavoriteProvider, List<String?>>(
                            builder: (context, data, child) {
                              return InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    !data.contains(model.id)
                                        ? Icons.favorite_border
                                        : Icons.favorite,
                                    size: 20,
                                  ),
                                ),
                                onTap: () {
                                  if (CUR_USERID != null) {
                                    !data.contains(model.id)
                                        ? _setFav(-1, model)
                                        : _removeFav(-1, model);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()),
                                    );
                                  }
                                },
                              );
                            },
                            selector: (_, provider) => provider.favIdList,
                          )))
          ],
        ),
      );
    } else
      return Container();
  }

  Future<bool> back() async {
    Navigator.pop(context);
    setState(() {
      persistentBottomSheetController = null;
    });
    return Future.value();
  }

  _showForm(BuildContext context) {
    return /*RefreshIndicator(
        key: _refreshIndicatorKey,
        //onRefresh: _refresh,
        child: */
        Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.white,
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              // if (true) Container() else _tags(),
              filterOptions(),
            ],
          ),
        ),
        Expanded(
          child: productList.length == 0
              ? getNoItem(context)
              : listType
                  ? ListView.builder(
                      controller: controller,
                      itemCount: (offset < total)
                          ? productList.length + 1
                          : productList.length,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return (index == productList.length && isLoadingmore)
                            ? singleItemSimmer(context)
                            : listItem(index);
                      },
                    )
                  : GridView.count(
                      padding: EdgeInsetsDirectional.only(top: 5),
                      crossAxisCount: 2,
                      controller: controller,
                      childAspectRatio: 0.78,
                      physics: AlwaysScrollableScrollPhysics(),
                      children: List.generate(
                        (offset < total)
                            ? productList.length + 1
                            : productList.length,
                        (index) {
                          return (index == productList.length && isLoadingmore)
                              ? simmerSingleProduct(context)
                              : productItem(
                                  index, index % 2 == 0 ? true : false);
                        },
                      )),
        ),
      ],
    );
  }

  List<AddQtyModel> addIdList = [];
  PersistentBottomSheetController? persistentBottomSheetController;
  showBottom(Product model, int index) async {
    bool? available, outOfStock;
    addIdList.clear();
    int? selectIndex = 0;
    //selList--selected list
    //sinList---single attribute list for compare

    List<String> selList =
        model.prVarientList![model.selVarient!].attribute_value_ids!.split(",");
    if (model.stockType == "0" || model.stockType == "1") {
      if (model.availability == "1") {
        available = true;
        outOfStock = false;
      } else {
        available = false;
        outOfStock = true;
      }
    } else if (model.stockType == "null") {
      available = true;
      outOfStock = false;
    } else if (model.stockType == "2") {
      if (model.prVarientList![model.selVarient!].availability == "1") {
        available = true;
        outOfStock = false;
      } else {
        available = false;
        outOfStock = true;
      }
    }
    double priceAdd =
        double.parse(model.prVarientList![model.selVarient!].disPrice!);
    if (priceAdd == 0) {
      priceAdd = double.parse(model.prVarientList![model.selVarient!].price!);
    }
    setState(() {
      addIdList.clear();
    });
    persistentBottomSheetController =
        await _scaffoldKey.currentState!.showBottomSheet(
      (context) {
        return WillPopScope(
          onWillPop: back,
          child: SingleChildScrollView(
            child: Container(
              color: Theme.of(context).cardColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add-on",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Column(
                          children: model.addOnList!.map<Widget>((e) {
                            if (e.price == "" || e.price == null) {
                              return SizedBox.shrink();
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ChoiceChip(
                                      selected: addIdList.indexWhere(
                                                  (element) =>
                                                      element.id == e.id!) !=
                                              -1
                                          ? true
                                          : false,
                                      label: Row(
                                        children: [
                                          Icon(
                                            addIdList.indexWhere((element) =>
                                                        element.id == e.id!) !=
                                                    -1
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank,
                                            color: addIdList.contains(e.id)
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(e.name.toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor)),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            CUR_CURRENCY! +
                                                " " +
                                                e.price.toString(),
                                            //style: Theme.of(context).textTheme.headline6,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      selectedColor:
                                          Theme.of(context).cardColor,
                                      avatar: Icon(
                                        Icons.radio_button_checked_sharp,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      // Container(
                                      //   // height: 80,
                                      //   //   width: 80,
                                      //     child: Image.network(e.image.toString()),height: 80,),
                                      // Icon(
                                      //   Icons.radio_button_checked_sharp,
                                      //   color: Colors.green,
                                      //   size: 16,
                                      // ),
                                      backgroundColor:
                                          Theme.of(context).cardColor,
                                      labelPadding: EdgeInsets.all(0),
                                      //selectedColor: Theme.of(context).colorScheme.fontColor.withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        /*side: BorderSide(
                                        color: _selectedIndex[index] == (i)
                                            ? colors.primary
                                            : colors.black12,
                                        width: 1.5),*/
                                      ),
                                      onSelected: (bool selected) {
                                        print(selected);
                                        if (selected) {
                                          if (mounted) {
                                            persistentBottomSheetController!
                                                .setState!(() {
                                              e.cartCount = "1";
                                              addIdList
                                                  .add(AddQtyModel(e.id!, "1"));
                                              priceAdd +=
                                                  double.parse(e.price!);
                                            });
                                          }
                                        } else {
                                          persistentBottomSheetController!
                                              .setState!(() {
                                            if (addIdList.indexWhere(
                                                    (element) =>
                                                        element.id == e.id!) !=
                                                -1) {
                                              e.cartCount = "0";
                                              addIdList.removeAt(addIdList
                                                  .indexWhere((element) =>
                                                      element.id == e.id!));
                                              priceAdd -=
                                                  double.parse(e.price!);
                                            }
                                          });
                                        }
                                      },
                                    ),
                                    addIdList.indexWhere((element) =>
                                                element.id == e.id!) !=
                                            -1
                                        ? Row(
                                            children: [
                                              /*IconButton(
                                                  onPressed: () {
                                                    persistentBottomSheetController!
                                                        .setState!(() {
                                                      print(e.cartCount);
                                                      e.cartCount = (int.parse(e
                                                                  .cartCount!) +
                                                              1)
                                                          .toString();
                                                      if (addIdList.indexWhere(
                                                              (element) =>
                                                                  element.id ==
                                                                  e.id!) !=
                                                          -1) {
                                                        addIdList[addIdList
                                                                .indexWhere(
                                                                    (element) =>
                                                                        element
                                                                            .id ==
                                                                        e.id!)]
                                                            .qty = e.cartCount!;
                                                      }
                                                      priceAdd += double.parse(
                                                          e.price!);
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.add,
                                                  )),*/
                                              Text(e.cartCount.toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .fontColor)),
                                              /*IconButton(
                                                  onPressed: () {
                                                    persistentBottomSheetController!
                                                        .setState!(() {
                                                      if (e.cartCount != "1") {
                                                        e.cartCount = (int.parse(
                                                                    e.cartCount!) -
                                                                1)
                                                            .toString();
                                                        if (addIdList.indexWhere(
                                                                (element) =>
                                                                    element
                                                                        .id ==
                                                                    e.id!) !=
                                                            -1) {
                                                          addIdList[addIdList
                                                                  .indexWhere(
                                                                      (element) =>
                                                                          element
                                                                              .id ==
                                                                          e.id!)]
                                                              .qty = e.cartCount!;
                                                        }
                                                        priceAdd -=
                                                            double.parse(
                                                                e.price!);
                                                      }
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.remove,
                                                  )),*/
                                            ],
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              );
                            }
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  available == false || outOfStock == true
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            outOfStock == true
                                ? 'Out of Stock'
                                : "This varient doesn't available.",
                            style: TextStyle(color: Colors.red),
                          ),
                        ))
                      : Container(),
                  !loading
                      ? CupertinoButton(
                          padding: EdgeInsets.all(0),
                          child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 30.0),
                              alignment: FractionalOffset.center,
                              height: 55,
                              decoration: BoxDecoration(
                                gradient: available!
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                            Colors.green,
                                            Colors.green,
                                          ],
                                        stops: [
                                            0,
                                            1
                                          ])
                                    : null,
                                color: available!
                                    ? null
                                    : Theme.of(context).colorScheme.gray,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "Item total ${CUR_CURRENCY! + priceAdd.toString()}",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .button!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .white,
                                          )),
                                  Text("ADD ITEM",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .button!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .white,
                                          )),
                                ],
                              )),
                          onPressed: available
                              ? () {
                                  print(
                                      "model===${model}index====${index}Addlist====${addIdList}");
                                  /*   if(addIdList.length>0){
                        persistentBottomSheetController!.setState!((){
                          loading =true;
                        });
                        for(int i=0;i<addIdList.length;i++){
                          addToCart(
                              int.parse(addIdList[i]), 1.toString(),status: "yes");
                        }
                      }*/
                                  persistentBottomSheetController!.setState!(
                                      () {
                                    loading = false;
                                  });
                                  applyVarient(
                                      model, index, addIdList.toList());
                                  // Navigator.pop(context);
                                }
                              : null,
                          // onPressed: available ? applyVarient : null,
                        )
                      : Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  applyVarient(model, index, addList) {
    print("index value here now ${index}");
    Navigator.of(context).pop();

    if (mounted)
      setState(() {
        persistentBottomSheetController = null;
      });
    addToCart(
        index,
        (int.parse(_controller[index].text) + int.parse(model.qtyStepSize!))
            .toString(),
        addList);
  }

  Widget productItem(int index, bool pad) {
    print("working here now");
    if (index < productList.length) {
      Product model = productList[index];

      double price =
          double.parse(model.prVarientList![model.selVarient!].price!);
      if (price == 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }
      print(
          "checking price here ${price} and ${model.prVarientList![model.selVarient!].disPrice}");
      double off = 0;
      if (model.prVarientList![model.selVarient!].disPrice! != "0") {
        off = (double.parse(model.prVarientList![model.selVarient!].price!) -
                double.parse(model.prVarientList![model.selVarient!].disPrice!))
            .toDouble();
        off = off *
            100 /
            double.parse(model.prVarientList![model.selVarient!].price!);
      }

      if (_controller.length < index + 1)
        _controller.add(new TextEditingController());

      _controller[index].text =
          model.prVarientList![model.selVarient!].cartCount!;

      List att = [], val = [];
      if (model.prVarientList![model.selVarient!].attr_name != null) {
        att = model.prVarientList![model.selVarient!].attr_name!.split(',');
        val = model.prVarientList![model.selVarient!].varient_value!.split(',');
      }
      double width = deviceWidth! * 0.5;

      return InkWell(
        child: Card(
          elevation: 0.2,
          margin: EdgeInsetsDirectional.only(
              bottom: 10, end: 10, start: pad ? 10 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      child: Hero(
                        tag: "ProGrid$index${model.id}",
                        child: FadeInImage(
                          fadeInDuration: Duration(milliseconds: 150),
                          image: CachedNetworkImageProvider(model.image!),
                          height: 50.0,
                          width: 50.0,
                          fit: extendImg ? BoxFit.fill : BoxFit.fitHeight,
                          placeholder: placeHolder(width),
                          imageErrorBuilder: (context, error, stackTrace) =>
                              erroWidget(width),
                        ),
                      ),
                    ),
                    Positioned.fill(
                        child: model.availability == "0"
                            ? Container(
                                height: 55,
                                color: Colors.white70,
                                // width: double.maxFinite,
                                padding: EdgeInsets.all(2),
                                child: Center(
                                  child: Text(
                                    getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : Container()),
                    // Align(
                    //   alignment: AlignmentDirectional.center,
                    //   child: model.availability == "0"
                    //       ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                    //           style: Theme.of(context)
                    //               .textTheme
                    //               .subtitle2!
                    //               .copyWith(
                    //                   color: Colors.red,
                    //                   fontWeight: FontWeight.bold))
                    //       : Container(),
                    // ),
                    (off != 0 || off != 0.0 || off != 0.00)
                        ? Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: colors.red,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  off.toStringAsFixed(2) + "%",
                                  style: TextStyle(
                                      color: colors.whiteTemp,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9),
                                ),
                              ),
                              margin: EdgeInsets.all(5),
                            ),
                          )
                        : Container(),

                    // Align(
                    //   alignment: Alignment.topLeft,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //         color: colors.red,
                    //         borderRadius: BorderRadius.circular(10)),
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(5.0),
                    //       child: Text(
                    //         off.toStringAsFixed(2) + "%",
                    //         style: TextStyle(
                    //             color: colors.whiteTemp,
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 9),
                    //       ),
                    //     ),
                    //     margin: EdgeInsets.all(5),
                    //   ),
                    // ),
                    Divider(
                      height: 1,
                    ),
                    Positioned.directional(
                      textDirection: Directionality.of(context),
                      end: 0,
                      // bottom: -18,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //Todo undo comment

                          model.availability == "0" && !cartBtnList
                              ? Container()
                              : _controller[index].text == "0"
                                  ? InkWell(
                                      onTap: () {
                                        if (_isProgress == false) {
                                          if (model.addOnList!.length > 0) {
                                            showBottom(model, index);
                                            return;
                                          }
                                          addToCart(
                                              index,
                                              (int.parse(_controller[index]
                                                          .text) +
                                                      int.parse(
                                                          model.qtyStepSize!))
                                                  .toString(),
                                              []);
                                        }
                                      },
                                      child: Card(
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.shopping_cart_outlined,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          start: 3.0, bottom: 5, top: 3),
                                      child: Row(
                                        children: <Widget>[
                                          GestureDetector(
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              if (_isProgress == false &&
                                                  (int.parse(_controller[index]
                                                          .text) >
                                                      0)) removeFromCart(index);
                                            },
                                          ),
                                          Container(
                                            width: 26,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: colors.white70,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: TextField(
                                              textAlign: TextAlign.center,
                                              readOnly: true,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor),
                                              controller: _controller[index],
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ), // ),
                                          GestureDetector(
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              if (_isProgress == false)
                                                addToCart(
                                                    index,
                                                    (int.parse(_controller[
                                                                    index]
                                                                .text) +
                                                            int.parse(model
                                                                .qtyStepSize!))
                                                        .toString(),
                                                    []);
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                          Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: model.isFavLoading!
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: 15,
                                          width: 15,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 0.7,
                                          )),
                                    )
                                  : Selector<FavoriteProvider, List<String?>>(
                                      builder: (context, data, child) {
                                        return InkWell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              !data.contains(model.id)
                                                  ? Icons.favorite_border
                                                  : Icons.favorite,
                                              size: 15,
                                            ),
                                          ),
                                          onTap: () {
                                            if (CUR_USERID != null) {
                                              !data.contains(model.id)
                                                  ? _setFav(-1, model)
                                                  : _removeFav(-1, model);
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Login()),
                                              );
                                            }
                                          },
                                        );
                                      },
                                      selector: (_, provider) =>
                                          provider.favIdList,
                                    )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              (model.rating! == "0" || model.rating! == "0.0")
                  ? Container()
                  : Row(
                      children: [
                        RatingBarIndicator(
                          rating: double.parse(model.rating!),
                          itemBuilder: (context, index) => Icon(
                            Icons.star_rate_rounded,
                            color: Colors.amber,
                            //color: colors.primary,
                          ),
                          unratedColor: Colors.grey.withOpacity(0.5),
                          itemCount: 5,
                          itemSize: 12.0,
                          direction: Axis.horizontal,
                          itemPadding: EdgeInsets.all(0),
                        ),
                        Text(
                          " (" + model.noOfRating! + ")",
                          style: Theme.of(context).textTheme.overline,
                        )
                      ],
                    ),
              Row(
                children: [
                  Text(" " + CUR_CURRENCY! + " " + price.toString() + " ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold)),
                  double.parse(model
                              .prVarientList![model.selVarient!].disPrice!) !=
                          0
                      ? Flexible(
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  double.parse(model
                                              .prVarientList![model.selVarient!]
                                              .disPrice!) !=
                                          0
                                      ? CUR_CURRENCY! +
                                          "" +
                                          model
                                              .prVarientList![model.selVarient!]
                                              .disPrice!
                                      : "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline!
                                      .copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          letterSpacing: 0),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container()
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: [
                    Expanded(
                      child: model.prVarientList![model.selVarient!]
                                      .attr_name !=
                                  null &&
                              model.prVarientList![model.selVarient!].attr_name!
                                  .isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: att.length >= 2 ? 2 : att.length,
                              itemBuilder: (context, index) {
                                return Row(children: [
                                  Flexible(
                                    child: Text(
                                      att[index].trim() + ":",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .lightBlack),
                                    ),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.only(
                                          start: 5.0),
                                      child: Text(
                                        val[index],
                                        maxLines: 1,
                                        overflow: TextOverflow.visible,
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightBlack,
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                ]);
                              })
                          : Container(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.only(start: 5.0, bottom: 5),
                child: Text(
                  "${model.name}",
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          //),
        ),
        onTap: () {
          Product model = productList[index];
          Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => ProductDetail(
                      model: model,
                      index: index,
                      preQty: newQty,
                      secPos: 0,
                      list: true,
                    )),
          );
        },
      );
    } else
      return Container();
  }

  Widget detailsScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: CircleAvatar(
              radius: 80,
              backgroundColor: colors.primary,
              backgroundImage: NetworkImage(widget.sellerImage!),
              // child: ClipRRect(
              //   borderRadius: BorderRadius.circular(40),
              //   child: FadeInImage(
              //     fadeInDuration: Duration(milliseconds: 150),
              //     image: NetworkImage(widget.sellerImage!),
              //
              //     fit: BoxFit.cover,
              //     placeholder: placeHolder(100),
              //     imageErrorBuilder: (context, error, stackTrace) =>
              //         erroWidget(100),
              //   ),
              // )
            ),
          ),
          getHeading(widget.sellerStoreName!),
          SizedBox(
            height: 5,
          ),
          Text(
            widget.sellerName!,
            style: TextStyle(
                color: Theme.of(context).colorScheme.lightBlack2, fontSize: 16),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          color: colors.primary),
                      child: Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      widget.sellerRating!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.0),
                            color: colors.primary),
                        child: Icon(
                          Icons.description,
                          color: Theme.of(context).colorScheme.white,
                          size: 30,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          isDescriptionVisible = !isDescriptionVisible;
                        });
                      },
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      getTranslated(context, 'DESCRIPTION')!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              color: colors.primary),
                          child: Icon(
                            Icons.list_alt,
                            color: Theme.of(context).colorScheme.white,
                            size: 30,
                          ),
                        ),
                        onTap: () => _tabController
                            .animateTo((_tabController.index + 1) % 2)),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      getTranslated(context, 'PRODUCTS')!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Visibility(
              visible: isDescriptionVisible,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 8,
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: colors.primary)),
                child: SingleChildScrollView(
                    child: Text(
                  (widget.storeDesc != "" || widget.storeDesc != null)
                      ? "${widget.storeDesc}"
                      : getTranslated(context, "NO_DESC")!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                )),
              ))
        ],
      ),
    );
    // return FutureBuilder(
    //     future: fetchSellerDetails(),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         // If we got an error
    //         if (snapshot.hasError) {
    //           return Center(
    //             child: Text(
    //               '${snapshot.error} Occured',
    //               style: TextStyle(fontSize: 18),
    //             ),
    //           );
    //
    //           // if we got our data
    //         } else if (snapshot.hasData) {
    //           // Extracting data from snapshot object
    //           var data = snapshot.data;
    //           print("data is $data");
    //
    //           return Center(
    //             child: Text(
    //               'Hello',
    //               style: TextStyle(fontSize: 18),
    //             ),
    //           );
    //         }
    //       }
    //       return shimmer();
    //     });
  }

  Widget getHeading(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headline6!.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.fontColor,
          ),
    );
  }

  Widget getRatingBarIndicator(var ratingStar, var totalStars) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: RatingBarIndicator(
        rating: ratingStar,
        itemBuilder: (context, index) => const Icon(
          Icons.star_outlined,
          color: colors.yellow,
        ),
        itemCount: totalStars,
        itemSize: 20.0,
        direction: Axis.horizontal,
        unratedColor: Colors.transparent,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
