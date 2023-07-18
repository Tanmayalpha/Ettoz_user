import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/User.dart';

class SectionModel {
  var id,
      title,
      varientId,
      qty,
      productId,
      perItemTotal,
      perItemPrice,
      style,
      shortDesc,
      add_on_id,
      add_on_qty,
      cartID;
  List<Product>? productList;
  List<Promo>? promoList;
  List<Filter>? filterList;
  List<AddOnsModel>? addOns;
  List<String>? selectedId = [];
  int? offset, totalItem;

  SectionModel(
      {this.id,
      this.title,
      this.shortDesc,
      this.productList,
      this.varientId,
        this.cartID,
      this.qty,
      this.add_on_id,
      this.addOns,
      this.productId,
      this.perItemTotal,
      this.perItemPrice,
      this.style,
      this.totalItem,
      this.offset,
      this.selectedId,
      this.filterList,
      this.promoList,
      this.add_on_qty});

  factory SectionModel.fromJson(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => new Product.fromJson(data))
        .toList();

    var flist = (parsedJson[FILTERS] as List?);
    List<Filter> filterList = [];
    if (flist == null || flist.isEmpty)
      filterList = [];
    else
      filterList = flist.map((data) => new Filter.fromJson(data)).toList();
    var aList = (parsedJson['add_on'] as List?);
    List<AddOnsModel> addsList = [];
    if (aList == null || aList.isEmpty)
      addsList = [];
    else
      addsList = aList.map((data) => new AddOnsModel.fromJson(data)).toList();
    List<String> selected = [];
    return SectionModel(
        id: parsedJson[ID],
        title: parsedJson[TITLE],
        shortDesc: parsedJson[SHORT_DESC],
        style: parsedJson[STYLE],
        productList: productList,
        offset: 0,
        totalItem: 0,
        addOns: addsList,
        filterList: filterList,
        add_on_id: parsedJson['add_on_id'],
        add_on_qty: parsedJson['add_on_qty'],
        selectedId: selected);
  }

  factory SectionModel.fromCart(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => new Product.fromJson(data))
        .toList();
    var aList = (parsedJson['add_on'] as List?);
    List<AddOnsModel> addsList = [];
    if (aList == null || aList.isEmpty)
      addsList = [];
    else
      addsList = aList.map((data) => new AddOnsModel.fromJson(data)).toList();
    return SectionModel(
      id: parsedJson[ID],
      varientId: parsedJson[PRODUCT_VARIENT_ID],
      cartID: parsedJson[CART_ID],
      qty: parsedJson[QTY],
      perItemTotal: "0",
      perItemPrice: "0",
      addOns: addsList,
      add_on_id: parsedJson['add_on_id'],
      add_on_qty: parsedJson['add_on_qty'],
      productList: productList,
    );
  }

  factory SectionModel.fromFav(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => new Product.fromJson(data))
        .toList();

    return SectionModel(
        id: parsedJson[ID],
        productId: parsedJson[PRODUCT_ID],
        productList: productList);
  }
}

class AddOnsModel {
  String? id;
  String? image;
  String? price;
  String? totalAmount;
  String? quantity;

  AddOnsModel({this.id, this.price, this.totalAmount, this.quantity});

  AddOnsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    price = json['price'];
    totalAmount = json['total_amount'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['price'] = this.price;
    data['total_amount'] = this.totalAmount;
    data['quantity'] = this.quantity;
    return data;
  }
}

class Product {
  String? id,
      name,
      desc,
      image,
      catName,
      type,
      rating,
      noOfRating,
      attrIds,
      tax,
      categoryId,
      shortDescription,
      qtyStepSize;
  List<String>? itemsCounter;
  List<String>? otherImage;
  List<Product_Varient>? prVarientList;
  List<Attribute>? attributeList;
  List<String>? selectedId = [];
  List<String>? tagList = [];
  List<AddOnModel>? addOnList = [];
  int? minOrderQuntity;
  String? isFav,
      isReturnable,
      isCancelable,
      isPurchased,
      availability,
      madein,
      indicator,
      stockType,
      cancleTill,
      total,
      banner,
      totalAllow,
      video,
      videType,
      warranty,
      gurantee;
  String? minPrice, maxPrice;
  String? totalImg;
  List<ReviewImg>? reviewList;

  bool? isFavLoading = false, isFromProd = false;
  int? offset, totalItem, selVarient;

  List<Product>? subList;
  List<Filter>? filterList;
  bool? history = false;
  String? store_description,
      seller_rating,
      seller_profile,
      seller_name,
      seller_id,
      store_name,
      estimated_time,
      food_person,
      open_close_status,
      storeIndicator,
      online,
      address;

  // String historyList;

  Product(
      {this.id,
      this.name,
      this.desc,
      this.image,
      this.catName,
      this.type,
      this.otherImage,
      this.prVarientList,
      this.attributeList,
      this.isFav,
      this.isCancelable,
      this.isReturnable,
      this.isPurchased,
      this.availability,
      this.noOfRating,
      this.attrIds,
      this.selectedId,
      this.rating,
      this.isFavLoading,
      this.indicator,
      this.madein,
      this.tax,
      this.shortDescription,
      this.total,
      this.categoryId,
      this.subList,
      this.filterList,
      this.stockType,
      this.isFromProd,
      this.cancleTill,
      this.totalItem,
      this.offset,
      this.totalAllow,
      this.banner,
      this.selVarient,
      this.video,
      this.videType,
      this.tagList,
      this.warranty,
      this.qtyStepSize,
      this.minOrderQuntity,
      this.itemsCounter,
      this.reviewList,
      this.history,
      this.minPrice,
      this.maxPrice,
      //  this.historyList,
      this.gurantee,
      this.store_description,
      this.addOnList,
      this.seller_rating,
      this.seller_profile,
      this.seller_name,
      this.seller_id,
      this.store_name,
      this.estimated_time,
      this.food_person,
      this.storeIndicator,
      this.open_close_status,
      this.online,
      this.address});

  factory Product.fromJson(Map<String, dynamic> json) {
    List<Product_Varient> varientList = (json[PRODUCT_VARIENT] as List)
        .map((data) => new Product_Varient.fromJson(data))
        .toList();
    List<AddOnModel> addList = [];
    if (json['add_on'] != null) {
      addList = (json['add_on'] as List)
          .map((data) => new AddOnModel.fromJson(data))
          .toList();
    }
    List<Attribute> attList = (json[ATTRIBUTES] as List)
        .map((data) => new Attribute.fromJson(data))
        .toList();

    var flist = (json[FILTERS] as List?);
    List<Filter> filterList = [];
    if (flist == null || flist.isEmpty)
      filterList = [];
    else
      filterList = flist.map((data) => new Filter.fromJson(data)).toList();

    List<String> other_image = List<String>.from(json[OTHER_IMAGE]);
    List<String> selected = [];

    List<String> tags = List<String>.from(json[TAG]);

    List<String> items = new List<String>.generate(
        json[TOTALALOOW] != null ? int.parse(json[TOTALALOOW]) : 10, (i) {
      return ((i + 1) * int.parse(json[QTYSTEP])).toString();
    });

    var reviewImg = (json[REV_IMG] as List?);
    List<ReviewImg> reviewList = [];
    if (reviewImg == null || reviewImg.isEmpty)
      reviewList = [];
    else
      reviewList =
          reviewImg.map((data) => new ReviewImg.fromJson(data)).toList();

    return new Product(
      id: json[ID],
      name: json[NAME],
      desc: json[DESC],
      image: json[IMAGE],
      catName: json[CAT_NAME],
      rating: json[RATING],
      noOfRating: json[NO_OF_RATE],
      type: json[TYPE],
      isFav: json[FAV].toString(),
      isCancelable: json[ISCANCLEABLE],
      availability: json[AVAILABILITY].toString(),
      isPurchased: json[ISPURCHASED].toString(),
      isReturnable: json[ISRETURNABLE],
      otherImage: other_image,
      prVarientList: varientList,
      attributeList: attList,
      filterList: filterList,
      addOnList: addList.toList(),
      isFavLoading: false,
      selVarient: 0,
      attrIds: json[ATTR_VALUE],
      madein: json[MADEIN],
      shortDescription: json[SHORT],
      indicator: json[INDICATOR].toString(),
      stockType: json[STOCKTYPE].toString(),
      tax: json[TAX_PER],
      total: json[TOTAL],
      categoryId: json[CATID],
      selectedId: selected,
      totalAllow: json[TOTALALOOW],
      cancleTill: json[CANCLE_TILL],
      video: json[VIDEO],
      videType: json[VIDEO_TYPE],
      tagList: tags,
      itemsCounter: items,
      warranty: json[WARRANTY],
      minOrderQuntity: int.parse(json[MINORDERQTY]),
      qtyStepSize: json[QTYSTEP],
      gurantee: json[GAURANTEE],
      reviewList: reviewList,
      history: false,
      minPrice: json[MINPRICE],
      maxPrice: json[MAXPRICE],
      seller_name: json[SELLER_NAME],
      seller_profile: json[SELLER_PROFILE],
      seller_rating: json[SELLER_RATING],
      store_description: json[STORE_DESC],
      store_name: json[STORE_NAME],
      seller_id: json[SELLER_ID],
      estimated_time: json["estimated_time"],
      food_person: json["food_person"],
      storeIndicator: json['indicator'],
      address: json["address"],
      online: json["online"],
      open_close_status: json["open_close_status"],
      // totalImg: tImg,
      // totalReviewImg: json[REV_IMG][TOTALIMGREVIEW],
      // productRating: reviewList
    );
  }

  factory Product.all(String name, String img, cat) {
    return new Product(name: name, catName: cat, image: img, history: false);
  }

  factory Product.history(String history) {
    return new Product(name: history, history: true);
  }

  factory Product.fromSeller(Map<String, dynamic> json) {
    return new Product(
      seller_name: json[SELLER_NAME],
      seller_profile: json[SELLER_PROFILE],
      seller_rating: json[SELLER_RATING],
      store_description: json[STORE_DESC],
      store_name: json[STORE_NAME],
      seller_id: json[SELLER_ID],
      estimated_time: json["estimated_time"],
      food_person: json["food_person"],
      address: json["address"],
      online: json["online"],
      storeIndicator: json['indicator'],
      open_close_status: json["open_close_status"],
    );
  }

  factory Product.fromCat(Map<String, dynamic> parsedJson) {
    return new Product(
      id: parsedJson[ID],
      name: parsedJson[NAME],
      image: parsedJson[IMAGE],
      banner: parsedJson[BANNER],
      isFromProd: false,
      offset: 0,
      totalItem: 0,
      tax: parsedJson[TAX],
      subList: createSubList(parsedJson["children"]),
    );
  }

  factory Product.popular(String name, String image) {
    return new Product(name: name, image: image);
  }

  static List<Product>? createSubList(List? parsedJson) {
    if (parsedJson == null || parsedJson.isEmpty) return null;

    return parsedJson.map((data) => new Product.fromCat(data)).toList();
  }
}

class Product_Varient {
  String? id,
      productId,
      attribute_value_ids,
      price,
      disPrice,
      type,
      attr_name,
      varient_value,
      availability,
      cartCount;
  List<String>? images;

  Product_Varient(
      {this.id,
      this.productId,
      this.attr_name,
      this.varient_value,
      this.price,
      this.disPrice,
      this.attribute_value_ids,
      this.availability,
      this.cartCount,
      this.images});

  factory Product_Varient.fromJson(Map<String, dynamic> json) {
    List<String> images = List<String>.from(json[IMAGES]);

    return new Product_Varient(
        id: json[ID],
        attribute_value_ids: json[ATTRIBUTE_VALUE_ID],
        productId: json[PRODUCT_ID],
        attr_name: json[ATTR_NAME],
        varient_value: json[VARIENT_VALUE],
        disPrice: json[DIS_PRICE],
        price: json[PRICE],
        availability: json[AVAILABILITY].toString(),
        cartCount: json[CART_COUNT],
        images: images);
  }
}

class Attribute {
  String? id, value, name, sType, sValue;

  Attribute({this.id, this.value, this.name, this.sType, this.sValue});

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return new Attribute(
        id: json[IDS],
        name: json[NAME],
        value: json[VALUE],
        sType: json[STYPE],
        sValue: json[SVALUE]);
  }
}

class Filter {
  String? attributeValues, attributeValId, name, swatchType, swatchValue;

  Filter(
      {this.attributeValues,
      this.attributeValId,
      this.name,
      this.swatchType,
      this.swatchValue});

  factory Filter.fromJson(Map<String, dynamic> json) {
    return new Filter(
        attributeValId: json[ATT_VAL_ID],
        name: json[NAME],
        attributeValues: json[ATT_VAL],
        swatchType: json[STYPE],
        swatchValue: json[SVALUE]);
  }
}

class ReviewImg {
  String? totalImg;
  List<User>? productRating;

  ReviewImg({this.totalImg, this.productRating});

  factory ReviewImg.fromJson(Map<String, dynamic> json) {
    var reviewImg = (json[PRODUCTRATING] as List?);
    List<User> reviewList = [];
    if (reviewImg == null || reviewImg.isEmpty)
      reviewList = [];
    else
      reviewList = reviewImg.map((data) => new User.forReview(data)).toList();

    return new ReviewImg(totalImg: json[TOTALIMG], productRating: reviewList);
  }
}

class AddOnModel {
  String? id;
  String? productId;
  String? price;
  String? quantity;
  String? totalAmount;
  String? image;
  String? name;
  String? cartCount;

  AddOnModel(
      {this.id,
      this.productId,
      this.price,
      this.totalAmount,
      this.quantity,
      this.image,
      this.name,
      this.cartCount});

  AddOnModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    price = json['price'];
    quantity = json['quantity'];
    totalAmount = json['total_amount'];
    image = json['image'];
    name = json['name'];
    cartCount = json['cart_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['price'] = this.price;
    data['image'] = this.image;
    data['name'] = this.name;
    data['cart_count'] = this.cartCount;
    return data;
  }
}

class Promo {
  String? id, promoCode, msg, image, day;

  Promo({this.id, this.promoCode, this.msg, this.image, this.day});

  factory Promo.fromJson(Map<String, dynamic> json) {
    return new Promo(
        id: json[ID],
        promoCode: json[PROMO_CODE],
        msg: json[MESSAGE],
        image: json[IMAGE],
        day: json[REMAIN_DAY]);
  }
}

class AddQtyModel {
  String id, qty;

  AddQtyModel(this.id, this.qty);
}
