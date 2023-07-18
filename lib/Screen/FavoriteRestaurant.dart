import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/favRestaurantModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Helper/Session.dart';
import '../Model/Section_Model.dart';
import 'SubCategory.dart';

class FavoriteRestaurant extends StatefulWidget {
  const FavoriteRestaurant({Key? key}) : super(key: key);

  @override
  State<FavoriteRestaurant> createState() => _FavoriteRestaurantState();
}

class _FavoriteRestaurantState extends State<FavoriteRestaurant> {
  FavRestaurantModel favRestaurantModel = FavRestaurantModel();

  List<Product> restList = [];

  getFavorite() async {
    print("working this ap[i here]");
    var headers = {
      'Cookie': 'ci_session=c7c206a79f404e9650f05602a43825258241a0ec'
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('${baseUrl}get_favourite_restaurant'));
    request.fields.addAll({
      'user_id': CUR_USERID.toString(),
    });
    request.headers.addAll(headers);
    print(
        "ccccccccccc ${baseUrl}get_favourite_restaurant    and ${request.fields}");
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();
      final jsonResponse = json.decode(finalResult);

      if (jsonResponse['error'] == false) {
        List<Product> data = jsonResponse["data"];
        print("datta here ${data}");

        // setState(() {
        //   restList = (data as List)
        //       .map((data) => new Product.fromSeller(data))
        //       .toList();
        //   restList.sort((a, b) => b.online!.compareTo(a.online!));
        // });

        setState(() {
          //restList = data.map((val) => Product.fromSeller(val)).toList();
          restList = data;
        });
        print("reslist here now ${restList[0].id}");

        for (var i = 0; i < restList.length; i++) {
          print(
              "jkjkjkjkjkjkj ${restList[i].id} nnnn ${restList[i].seller_id} ${restList[i].noOfRating} and ${restList[i].rating}");
        }
      }
      // final jsonResponse =
      //     FavRestaurantModel.fromJson(json.decode(finalResult));
      // setState(() {
      //   favRestaurantModel = jsonResponse;
      // });

    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 200), () {
      return getFavorite();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar("Restaurant", context),
      body: Container(
        child: favRestaurantModel == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : favRestaurantModel.data?.length == 0
                ? Center(
                    child: Text("No Restaurant to  see"),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: restList.length,
                    itemBuilder: (c, index) {
                      print("uuuuuuuuu ${restList[index].id}");
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 1),
                        child: GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => SellerProfile(
                            //               sellerStoreName: sellerList[index]
                            //                       .store_name ??
                            //                   "",
                            //               sellerRating: sellerList[index]
                            //                       .seller_rating ??
                            //                   "",
                            //               sellerImage: sellerList[index]
                            //                       .seller_profile ??
                            //                   "",
                            //               sellerName: sellerList[index]
                            //                       .seller_name ??
                            //                   "",
                            //               sellerID:
                            //                   sellerList[index].seller_id,
                            //               storeDesc: sellerList[index]
                            //                   .store_description,
                            //             )));
                            if (restList[index].online == "1") {
                              print(
                                  "seller id now here ${restList[index].id} and ${restList[index].seller_id} ${restList[index].online} ");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SubCategory(
                                            fromSearch: false,
                                            title: restList[index]
                                                .store_name
                                                .toString(),
                                            sellerId:
                                                restList[index].id.toString(),
                                            sellerData: restList[index],
                                          )));
                            } else {
                              setSnackbar("Restaurant is Close!!", context);
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Container(
                                  // decoration: BoxDecoration(
                                  //     borderRadius:
                                  //         BorderRadius.circular(10),
                                  //     image: DecorationImage(
                                  //         fit: BoxFit.cover,
                                  //         // opacity: .05,
                                  //         image: NetworkImage(
                                  //             sellerList[index]
                                  //                 .seller_profile!))),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 120,
                                        width: 110,
                                        padding: EdgeInsets.only(
                                            left: 10, top: 5, bottom: 5),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: FadeInImage(
                                            fadeInDuration:
                                                Duration(milliseconds: 150),
                                            image: CachedNetworkImageProvider(
                                              "${imageUrl}${restList[index].image}",
                                            ),
                                            fit: BoxFit.cover,
                                            imageErrorBuilder:
                                                (context, error, stackTrace) =>
                                                    erroWidget(50),
                                            placeholder: placeHolder(50),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            ListTile(
                                              dense: true,
                                              title: Text(
                                                "${restList[index].store_name}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .fontColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              subtitle: Text(
                                                "${restList[index].store_description}",
                                                maxLines: 2,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .fontColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              trailing: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  restList[index].online == "1"
                                                      ? Text(
                                                          "Open",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green),
                                                        )
                                                      : Text(
                                                          "Close",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                  InkWell(
                                                    onTap: () {
                                                      removeRestaurant(
                                                          restList[index]
                                                              .id
                                                              .toString());
                                                    },
                                                    child: Card(
                                                      color: Colors.white,
                                                      elevation: 1,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100)),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(1),
                                                        child: Icon(
                                                          Icons.favorite,
                                                          color: Colors.red,
                                                          size: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  // favRestaurantModel!.data![index].sto == "1" ? Image.asset("assets/images/vegImage.png",height: 15,width: 15,): sellerList[index].storeIndicator == "2" ? Image.asset("assets/images/non-vegImage.png",height: 15,width: 15,) : Row(
                                                  //   crossAxisAlignment: CrossAxisAlignment.start,
                                                  //   children: [
                                                  //     Image.asset("assets/images/vegImage.png",height: 15,width: 15,),
                                                  //     Image.asset("assets/images/non-vegImage.png",height: 15,width: 15,)
                                                  //   ],
                                                  // )
                                                ],
                                              ),
                                            ),
                                            Divider(
                                              height: 0,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  FittedBox(
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star_rounded,
                                                          color: Colors.amber,
                                                          size: 15,
                                                        ),
                                                        Text(
                                                          "${restList[index].noOfRating}",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .caption!
                                                              .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .fontColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  restList[index]
                                                              .estimated_time !=
                                                          ""
                                                      ? FittedBox(
                                                          child: Container(
                                                              child: Center(
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 5,
                                                                  vertical: 2),
                                                              child: Text(
                                                                "${restList[index].estimated_time}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ),
                                                          )),
                                                        )
                                                      : Container(),
                                                  // sellerList[index]
                                                  //             .food_person !=
                                                  //         ""
                                                  //     ? FittedBox(
                                                  //         child: Container(
                                                  //             child:
                                                  //                 Padding(
                                                  //           padding: const EdgeInsets
                                                  //                   .symmetric(
                                                  //               horizontal:
                                                  //                   5,
                                                  //               vertical:
                                                  //                   1),
                                                  //           child: Text(
                                                  //             "${sellerList[index].food_person}",
                                                  //             style: TextStyle(
                                                  //                 fontSize:
                                                  //                     14),
                                                  //           ),
                                                  //         )),
                                                  //       )
                                                  //     : Container(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
      ),
    );
  }
}
