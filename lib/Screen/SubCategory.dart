import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Model/response_recomndet_products.dart';
import 'package:eshop_multivendor/Provider/FavoriteProvider.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:eshop_multivendor/Screen/Product_Detail.dart';
import 'package:eshop_multivendor/Screen/Seller_Details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../Model/favRestaurantModel.dart';

class SubCategory extends StatefulWidget {
  final String title;
  final sellerId;
  final catId;
  final sellerData;
  final bool? fromSearch;

  SubCategory(
      {Key? key,
      required this.title,
      this.sellerId,
      this.sellerData,
      this.fromSearch,
      this.catId})
      : super(key: key);

  @override
  State<SubCategory> createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  dynamic subCatData = [];
  var recommendedProductsData = [];
  bool mount = false;
  late ResponseRecomndetProducts responseProducts;
  var newData;
  StreamController<dynamic> productStream = StreamController();
  var imageBase = "";
  List<TextEditingController> _controller = [];
  bool _isLoading = true, _isProgress = false;
  bool _isNetworkAvail = true;

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
    print("checking status code here now ${response.statusCode}");
    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();
      final jsonResponse =
          FavRestaurantModel.fromJson(json.decode(finalResult));
      setState(() {
        favRestaurantModel = jsonResponse;
      });
      print("sdsfs ${favRestaurantModel!.data!.length}");
      for (var i = 0; i < favRestaurantModel!.data!.length; i++) {
        print("ok now data here ${favRestaurantModel!.data![i].id}");
        favList.add(favRestaurantModel!.data![i].id.toString());
      }

      print(" checking fav here ${favList}");
    } else {
      print(response.reasonPhrase);
    }
  }

  List<String> favList = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.catId);
    print(widget.sellerId);
    getSubCategory(widget.sellerId, widget.catId);
    getFavorite();
    // Future.delayed(Duration(milliseconds: 200),(){
    //   return
    // });
    getRecommended(widget.sellerId);
  }

  @override
  void dispose() {
    super.dispose();
    productStream.close();
  }

  Future<Null> callApi() async {
    getSubCategory(widget.sellerId, widget.catId);
    // Future.delayed(Duration(milliseconds: 200),(){
    //   return
    // });
    getFavorite();
    getRecommended(widget.sellerId);
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
      var finalResult = await response.stream.bytesToString();
      final jsonResponse = json.decode(finalResult);

      setState(() {
        _refresh();
        // setSnackbar("${jsonResponse['message']}", context);
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
    print("checking params here now ${request.fields}");
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

  Future<Null> _refresh() {
    return callApi();
  }

  @override
  Widget build(BuildContext context) {
    print("ggggggggggg ${widget.sellerData}");
    print(imageBase);
    return Scaffold(
      appBar: getAppBar(widget.title, context),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StreamBuilder<dynamic>(
                  stream: productStream.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Container(
                        child: Text(snapshot.error.toString()),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator());
                    }
                    return Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 90),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 60,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width / 40,
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Recommended Products',
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 150,
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemCount: snapshot.data["data"].length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 1.0,
                              childAspectRatio: 1.0,
                              mainAxisSpacing: 4.5,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              dynamic model = snapshot.data["data"][index];
                              return InkWell(
                                onTap: () => onTapGoDetails(
                                    index: index, response: snapshot.data!),
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width /
                                              50),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                    child: new Card(
                                        child: new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                          child: FadeInImage(
                                            image: CachedNetworkImageProvider(
                                              snapshot.data["data"][index]
                                                      ["image"]
                                                  .toString(),
                                            ),
                                            fadeInDuration:
                                                Duration(milliseconds: 120),
                                            fit: BoxFit.cover,
                                            height: 120,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            // width: 120,
                                            imageErrorBuilder:
                                                (context, error, stackTrace) =>
                                                    erroWidget(120),
                                            placeholder: placeHolder(120),
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          padding:
                                              EdgeInsets.only(top: 5, left: 5),
                                          child: Text(
                                            snapshot.data["data"][index]["name"]
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .lightBlack),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(MONEY_TYPE),
                                            Text(
                                                "${snapshot.data["data"][index]["min_max_price"]["max_special_price"]}"),
                                            Text(
                                              " ${snapshot.data["data"][index]["min_max_price"]["max_price"]}",
                                              style: TextStyle(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );

                    // new
                  }),
              // InkWell(
              //   onTap: () {
              //     Product model = Product.fromJson(newData["data"][0]);
              //     Navigator.of(context).push(MaterialPageRoute(
              //         builder: (context) => ProductDetail(
              //               index: 0,
              //               model: model,
              //               secPos: 0,
              //               list: false,
              //             )));
              //   },
              //   child: Container(
              //     height: 60.0,
              //     width: 60.0,
              //     color: Colors.orange,
              //     child: Text("dsddd"),
              //   ),
              // ),
              mount
                  ? subCatData.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.fromSearch == true
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 170,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      "${imageUrl}${widget.sellerData['logo']}"),
                                                  fit: BoxFit.fill,
                                                )),
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.35,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.35,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                              ),
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    // leading: CircleAvatar(
                                                    //   backgroundImage: NetworkImage(widget.sellerData!.seller_profile),
                                                    // ),
                                                    title: Text(
                                                      "${widget.sellerData['store_name'].toString()}"
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          color:
                                                              colors.whiteTemp),
                                                    ),
                                                    subtitle: Text(
                                                      "${widget.sellerData['store_description'].toString()}",
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color:
                                                              colors.whiteTemp),
                                                    ),
                                                  ),
                                                  // ListTile(title: Text("Address"), subtitle: Text("${widget.sellerData.address}"),),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        // Column(
                                                        //   children: [
                                                        //     Icon(
                                                        //       Icons.star_rounded,
                                                        //       color: colors.primary,
                                                        //     ),
                                                        //     Text("${widget.sellerData.seller_rating}",
                                                        //       style: TextStyle(
                                                        //           color: colors.whiteTemp,
                                                        //         fontWeight: FontWeight.w600
                                                        //       ),
                                                        //     )
                                                        //   ],
                                                        // ),
                                                        //  widget.sellerData.estimated_time !=""?
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            widget.sellerData[
                                                                            'seller_rating'] ==
                                                                        "" ||
                                                                    widget.sellerData[
                                                                            'seller_rating'] ==
                                                                        null
                                                                ? SizedBox
                                                                    .shrink()
                                                                : Icon(
                                                                    Icons
                                                                        .star_rounded,
                                                                    color: colors
                                                                        .primary,
                                                                  ),
                                                            widget.sellerData[
                                                                            'seller_rating'] ==
                                                                        "" ||
                                                                    widget.sellerData[
                                                                            'seller_rating'] ==
                                                                        null
                                                                ? SizedBox
                                                                    .shrink()
                                                                : Text(
                                                                    "${widget.sellerData['seller_rating']}",
                                                                    style: TextStyle(
                                                                        color: colors
                                                                            .whiteTemp,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                            widget.sellerData[
                                                                        'estimated_time'] ==
                                                                    ""
                                                                ? SizedBox
                                                                    .shrink()
                                                                : Text(
                                                                    "Delivery Time",
                                                                    style: TextStyle(
                                                                        color: colors
                                                                            .whiteTemp,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                            widget.sellerData[
                                                                        'estimated_time'] ==
                                                                    ""
                                                                ? SizedBox
                                                                    .shrink()
                                                                : Text(
                                                                    "${widget.sellerData['estimated_time']} minutes",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                            widget.sellerData[
                                                                        'indicator'] ==
                                                                    "1"
                                                                ? Image.asset(
                                                                    "assets/images/vegImage.png",
                                                                    height: 15,
                                                                    width: 15,
                                                                  )
                                                                : widget.sellerData[
                                                                            'indicator'] ==
                                                                        "2"
                                                                    ? Image
                                                                        .asset(
                                                                        "assets/images/non-vegImage.png",
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      )
                                                                    : Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Image
                                                                              .asset(
                                                                            "assets/images/vegImage.png",
                                                                            height:
                                                                                15,
                                                                            width:
                                                                                15,
                                                                          ),
                                                                          Image
                                                                              .asset(
                                                                            "assets/images/non-vegImage.png",
                                                                            height:
                                                                                15,
                                                                            width:
                                                                                15,
                                                                          )
                                                                        ],
                                                                      ),
                                                            /*widget.sellerData[
                                                            'address'] == '' ? SizedBox() :  Text(
                                                              "address",
                                                              style: TextStyle(
                                                                  color: colors
                                                                      .whiteTemp,
                                                                  fontWeight:
                                                                  FontWeight.w600),
                                                            ),*/
                                                          ],
                                                        )
                                                        //:Container(),
                                                        //    widget.sellerData.food_person !=""?
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
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 1,
                                            right: 1,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, bottom: 10),
                                              child: InkWell(
                                                onTap: () {
                                                  print(
                                                      "checking data here now ${widget.sellerData['user_id']}");
                                                  if (favList.contains(widget
                                                      .sellerData['user_id']
                                                      .toString())) {
                                                    removeRestaurant(widget
                                                        .sellerData['user_id']
                                                        .toString());
                                                    favList.remove(widget
                                                        .sellerData['user_id']
                                                        .toString());
                                                    setState(() {});
                                                  } else {
                                                    print("yes here now");
                                                    addFavRestaurant(widget
                                                        .sellerData['user_id']
                                                        .toString());
                                                  }
                                                },
                                                child: InkWell(
                                                  child: Card(
                                                    elevation: 1,
                                                    color: Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: favList.contains(
                                                              widget.sellerData[
                                                                      'user_id']
                                                                  .toString())
                                                          ? Icon(
                                                              Icons.favorite,
                                                              color: Colors.red,
                                                              size: 25,
                                                            )
                                                          : Icon(
                                                              Icons
                                                                  .favorite_border,
                                                              color: Colors.red,
                                                              size: 25,
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 1,
                                            left: 1,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 12, bottom: 18),
                                              child: widget.sellerData[
                                                              'address'] ==
                                                          "" ||
                                                      widget.sellerData[
                                                              'address'] ==
                                                          null
                                                  ? Container()
                                                  : Text(
                                                      "${widget.sellerData['address']}",
                                                      style: TextStyle(
                                                          color:
                                                              colors.whiteTemp),
                                                    ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 215,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: NetworkImage(widget.sellerData.seller_profile ?? ''),
                                                  fit: BoxFit.fill,
                                                )),
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.35,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.35,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                              ),
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    // leading: CircleAvatar(
                                                    //   backgroundImage: NetworkImage(widget.sellerData!.seller_profile),
                                                    // ),
                                                    title: Text(
                                                      "${widget.sellerData.store_name.toString()}"
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          color:
                                                              colors.whiteTemp),
                                                    ),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${widget.sellerData.store_description}",
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                              color: colors
                                                                  .whiteTemp),
                                                        ),
                                                        // Text(
                                                        //   "${widget.sellerData.address}",
                                                        //   style: TextStyle(
                                                        //       color: colors
                                                        //           .whiteTemp),
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                  // ListTile(title: Text("Address"), subtitle: Text("${widget.sellerData.address}"),),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        // Container(
                                                        //   child:  Text("${widget.sellerData.address}"),
                                                        // ),
                                                        // Column(
                                                        //   children: [
                                                        //     Icon(
                                                        //       Icons.star_rounded,
                                                        //       color: colors.primary,
                                                        //     ),
                                                        //     Text("${widget.sellerData.seller_rating}",
                                                        //       style: TextStyle(
                                                        //           color: colors.whiteTemp,
                                                        //         fontWeight: FontWeight.w600
                                                        //       ),
                                                        //     )
                                                        //   ],
                                                        // ),
                                                        //  widget.sellerData.estimated_time !=""?
                                                        Container(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              widget.sellerData
                                                                              .seller_rating ==
                                                                          "" ||
                                                                      widget.sellerData
                                                                              .seller_rating ==
                                                                          null
                                                                  ? SizedBox
                                                                      .shrink()
                                                                  : Icon(
                                                                      Icons
                                                                          .star_rounded,
                                                                      color: colors
                                                                          .primary,
                                                                    ),
                                                              widget.sellerData
                                                                              .seller_rating ==
                                                                          "" ||
                                                                      widget.sellerData
                                                                              .seller_rating ==
                                                                          null
                                                                  ? SizedBox
                                                                      .shrink()
                                                                  : Text(
                                                                      "${widget.sellerData.seller_rating}",
                                                                      style: TextStyle(
                                                                          color: colors
                                                                              .whiteTemp,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                              widget.sellerData
                                                                          .estimated_time ==
                                                                      ""
                                                                  ? SizedBox
                                                                      .shrink()
                                                                  : Text(
                                                                      "Delivery Time",
                                                                      style: TextStyle(
                                                                          color: colors
                                                                              .whiteTemp,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                              widget.sellerData
                                                                          .estimated_time ==
                                                                      ""
                                                                  ? SizedBox
                                                                      .shrink()
                                                                  : Text(
                                                                      "${widget.sellerData.estimated_time} Minutes",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                              widget.sellerData
                                                                          .storeIndicator ==
                                                                      "1"
                                                                  ? Image.asset(
                                                                      "assets/images/vegImage.png",
                                                                      height:
                                                                          15,
                                                                      width: 15,
                                                                    )
                                                                  : widget.sellerData
                                                                              .storeIndicator ==
                                                                          "2"
                                                                      ? Image
                                                                          .asset(
                                                                          "assets/images/non-vegImage.png",
                                                                          height:
                                                                              15,
                                                                          width:
                                                                              15,
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
                                                        )
                                                        //:Container(),
                                                        //    widget.sellerData.food_person !=""?
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
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 1,
                                            right: 1,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, bottom: 10),
                                              child: InkWell(
                                                onTap: () {
                                                  print(
                                                      "llllllllllllllll ${widget.sellerId.toString()}");
                                                  // if (favList.contains(widget
                                                  //     .sellerId
                                                  //     .toString())) {
                                                  //   removeRestaurant(widget
                                                  //       .sellerId
                                                  //       .toString());
                                                  //   setState(() {});
                                                  // } else {
                                                  //   addFavRestaurant(widget
                                                  //       .sellerId
                                                  //       .toString());
                                                  // }
                                                  if (favList.contains(widget
                                                      .sellerId
                                                      .toString())) {
                                                    print("kosfsf");
                                                    removeRestaurant(widget
                                                        .sellerId
                                                        .toString());
                                                    favList.remove(widget
                                                        .sellerId
                                                        .toString());

                                                    setState(() {});
                                                  } else {
                                                    print("yes here now");
                                                    favList.remove(widget
                                                        .sellerId
                                                        .toString());
                                                    addFavRestaurant(widget
                                                        .sellerId
                                                        .toString());
                                                    setState(() {});
                                                  }
                                                },
                                                child: Card(
                                                  elevation: 1,
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: favList.contains(
                                                            widget.sellerId
                                                                .toString())
                                                        ? Icon(
                                                            Icons.favorite,
                                                            color: Colors.red,
                                                            size: 25,
                                                          )
                                                        : Icon(
                                                            Icons
                                                                .favorite_border,
                                                            color: Colors.red,
                                                            size: 25,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 1,
                                            left: 1,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 12, bottom: 18),
                                              child: Text(
                                                "${widget.sellerData.address}",
                                                style: TextStyle(
                                                    color: colors.whiteTemp),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Subcategories",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  physics: ClampingScrollPhysics(),
                                  itemCount: subCatData.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SellerProfile(
                                                      search: false,
                                                      fromSearch:
                                                          widget.fromSearch ==
                                                                  true
                                                              ? true
                                                              : false,
                                                      catId: widget.catId,
                                                      sellerID: widget.sellerId,
                                                      sellerStoreName:
                                                          widget.title,
                                                      subCatId:
                                                          subCatData[index]
                                                              ["id"],
                                                      sellerData:
                                                          widget.sellerData,
                                                    )));
                                      },
                                      child: Container(
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Container(
                                                //   height:60,
                                                //   width: 100,
                                                //   child: ClipRRect(
                                                //       borderRadius: BorderRadius.only(
                                                //         topRight: Radius.circular(10),
                                                //         topLeft: Radius.circular(10),
                                                //       ),
                                                //       child: Image.network("$imageBase${subCatData[index]["image"] ?? ""}",fit: BoxFit.fill,)),
                                                // ),
                                                // SizedBox(height: 2,),
                                                Text(
                                                  subCatData[index]["name"] ??
                                                      "",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 15,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                    //   Card(
                                    //   child: ListTile(
                                    //     onTap: () {
                                    //       Navigator.push(
                                    //           context,
                                    //           MaterialPageRoute(
                                    //               builder: (context) => SellerProfile(
                                    //                 search: false,
                                    //                     sellerID: widget.sellerId,
                                    //                     subCatId: subCatData[index]["id"],
                                    //                     sellerData: widget.sellerData,
                                    //                   )));
                                    //     },
                                    //     leading: CircleAvatar(
                                    //       backgroundImage: NetworkImage(
                                    //           "$imageBase${subCatData[index]["image"] ?? ""}"),
                                    //     ),
                                    //     title: Text(subCatData[index]["name"] ?? "",
                                    //       style: Theme.of(
                                    //           context)
                                    //           .textTheme
                                    //           .caption!
                                    //           .copyWith(
                                    //         color: Theme.of(
                                    //             context)
                                    //             .colorScheme
                                    //             .fontColor,
                                    //         fontWeight:
                                    //         FontWeight
                                    //             .w600,
                                    //       ),
                                    //     ),
                                    //     trailing: Icon(Icons.arrow_forward_ios_rounded),
                                    //   ),
                                    // );
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(child: Text("No Sub Category"))
                  : Text(""),
            ],
          ),
        ),
      ),
    );
  }

  getSubCategory(sellerId, catId) async {
    print("ffff ${sellerId} sdsfsfs ${widget.sellerId}");
    var parm = {};
    if (catId != null) {
      parm = {"seller_id": "${widget.sellerId}", "cat_id": "$catId"};
    } else {
      parm = {"seller_id": "${widget.sellerId}"};
    }
    print("nnnnnnnn ${getSubCatBySellerId} nnnnnn ${parm}");
    apiBaseHelper.postAPICall(getSubCatBySellerId, parm).then((value) {
      setState(() {
        subCatData = value["recommend_products"];
        imageBase = value["image_path"];
        mount = true;
      });
    });
  }

  getRecommended(sellerId) async {
    // var parm = {"seller_id": "$sellerId"};
    // try {
    var parm = {"seller_id": sellerId};
    print('___________${sellerId}__________');
    print(parm);
    var data = await apiBaseHelper.postAPINew(recommendedProductapi, parm);
    newData = data;
    setState(() {});
    // responseProducts = ResponseRecomndetProducts.fromJson(newData);
    if (newData["data"].isNotEmpty) {
      productStream.sink.add(newData);
    } else {
      productStream.sink.addError("");
    }
    // } catch (e) {
    //   productStream.sink.addError('ddd');
    // }
  }

  onTapGoDetails({response, index}) {
    Product model = Product.fromJson(response["data"][0]);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProductDetail(
              index: index,
              model: model,
              secPos: 0,
              list: false,
            )));
  }
}
