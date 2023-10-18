// To parse this JSON data, do
//
//     final favoriteRestaurant = favoriteRestaurantFromJson(jsonString);

import 'dart:convert';

FavoriteRestaurant favoriteRestaurantFromJson(String str) => FavoriteRestaurant.fromJson(json.decode(str));

String favoriteRestaurantToJson(FavoriteRestaurant data) => json.encode(data.toJson());

class FavoriteRestaurant {
  bool error;
  String message;
  List<RetaurantData> data;

  FavoriteRestaurant({
    required this.error,
    required this.message,
    required this.data,
  });

  factory FavoriteRestaurant.fromJson(Map<String, dynamic> json) => FavoriteRestaurant(
    error: json["error"],
    message: json["message"],
    data: json["data"] == null ? [] : List<RetaurantData>.from(json["data"]!.map((x) => RetaurantData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class RetaurantData {
  String? id;
  String? ipAddress;
  String? username;
  String? password;
  String? email;
  String? mobile;
  dynamic vehicleNo;
  String? image;
  dynamic drivingLicense;
  dynamic profilePic;
  String? balance;
  String? activationSelector;
  String? activationCode;
  dynamic forgottenPasswordSelector;
  dynamic forgottenPasswordCode;
  dynamic forgottenPasswordTime;
  dynamic rememberSelector;
  dynamic rememberCode;
  String? createdOn;
  String? lastLogin;
  String? active;
  dynamic company;
  String? address;
  dynamic secondAddress;
  dynamic bonus;
  String? cashReceived;
  dynamic dob;
  dynamic countryCode;
  String? city;
  dynamic country;
  dynamic area;
  dynamic street;
  dynamic pincode;
  dynamic serviceableZipcodes;
  dynamic apikey;
  dynamic referralCode;
  dynamic friendsCode;
  String? fcmId;
  dynamic otp;
  dynamic verifyOtp;
  String? latitude;
  String? longitude;
  DateTime? createdAt;
  String? online;
  String? accountNumber;
  String? accountName;
  String? ifscCode;
  String? bankName;
  String? accountType;
  String? branch;
  String? walletAmount;
  String? firstUser;
  String? loginStatus;
  String? currentAddress;
  String? lat2;
  String? lang2;
  String? heading;
  String? datumNew;
  String? userId;
  String? slug;
  String? categoryIds;
  String? storeName;
  String? storeDescription;
  String? logo;
  String? storeUrl;
  String? noOfRatings;
  String? rating;
  String? bankCode;
  String? nationalIdentityCard;
  String? addressProof;
  String? panNumber;
  String? taxName;
  String? adharNo;
  String? taxNumber;
  String? permissions;
  String? commission;
  String? estimatedTime;
  String? foodPerson;
  String? openCloseStatus;
  String? status;
  DateTime? dateAdded;
  String? sponseredType;
  String? fassaiNumber;
  String? indicator;

  RetaurantData({
    this.id,
    this.ipAddress,
    this.username,
    this.password,
    this.email,
    this.mobile,
    this.vehicleNo,
    this.image,
    this.drivingLicense,
    this.profilePic,
    this.balance,
    this.activationSelector,
    this.activationCode,
    this.forgottenPasswordSelector,
    this.forgottenPasswordCode,
    this.forgottenPasswordTime,
    this.rememberSelector,
    this.rememberCode,
    this.createdOn,
    this.lastLogin,
    this.active,
    this.company,
    this.address,
    this.secondAddress,
    this.bonus,
    this.cashReceived,
    this.dob,
    this.countryCode,
    this.city,
    this.country,
    this.area,
    this.street,
    this.pincode,
    this.serviceableZipcodes,
    this.apikey,
    this.referralCode,
    this.friendsCode,
    this.fcmId,
    this.otp,
    this.verifyOtp,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.online,
    this.accountNumber,
    this.accountName,
    this.ifscCode,
    this.bankName,
    this.accountType,
    this.branch,
    this.walletAmount,
    this.firstUser,
    this.loginStatus,
    this.currentAddress,
    this.lat2,
    this.lang2,
    this.heading,
    this.datumNew,
    this.userId,
    this.slug,
    this.categoryIds,
    this.storeName,
    this.storeDescription,
    this.logo,
    this.storeUrl,
    this.noOfRatings,
    this.rating,
    this.bankCode,
    this.nationalIdentityCard,
    this.addressProof,
    this.panNumber,
    this.taxName,
    this.adharNo,
    this.taxNumber,
    this.permissions,
    this.commission,
    this.estimatedTime,
    this.foodPerson,
    this.openCloseStatus,
    this.status,
    this.dateAdded,
    this.sponseredType,
    this.fassaiNumber,
    this.indicator,
  });

  factory RetaurantData.fromJson(Map<String, dynamic> json) => RetaurantData(
    id: json["id"],
    ipAddress: json["ip_address"],
    username: json["username"],
    password: json["password"],
    email: json["email"],
    mobile: json["mobile"],
    vehicleNo: json["vehicle_no"],
    image: json["image"],
    drivingLicense: json["driving_license"],
    profilePic: json["profile_pic"],
    balance: json["balance"],
    activationSelector: json["activation_selector"],
    activationCode: json["activation_code"],
    forgottenPasswordSelector: json["forgotten_password_selector"],
    forgottenPasswordCode: json["forgotten_password_code"],
    forgottenPasswordTime: json["forgotten_password_time"],
    rememberSelector: json["remember_selector"],
    rememberCode: json["remember_code"],
    createdOn: json["created_on"],
    lastLogin: json["last_login"],
    active: json["active"],
    company: json["company"],
    address: json["address"],
    secondAddress: json["second_address"],
    bonus: json["bonus"],
    cashReceived: json["cash_received"],
    dob: json["dob"],
    countryCode: json["country_code"],
    city: json["city"],
    country: json["country"],
    area: json["area"],
    street: json["street"],
    pincode: json["pincode"],
    serviceableZipcodes: json["serviceable_zipcodes"],
    apikey: json["apikey"],
    referralCode: json["referral_code"],
    friendsCode: json["friends_code"],
    fcmId: json["fcm_id"],
    otp: json["otp"],
    verifyOtp: json["verify_otp"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    online: json["online"],
    accountNumber: json["account_number"],
    accountName: json["account_name"],
    ifscCode: json["ifsc_code"],
    bankName: json["bank_name"],
    accountType: json["account_type"],
    branch: json["branch"],
    walletAmount: json["wallet_amount"],
    firstUser: json["first_user"],
    loginStatus: json["login_status"],
    currentAddress: json["current_address"],
    lat2: json["lat2"],
    lang2: json["lang2"],
    heading: json["heading"],
    datumNew: json["new"],
    userId: json["user_id"],
    slug: json["slug"],
    categoryIds: json["category_ids"],
    storeName: json["store_name"],
    storeDescription: json["store_description"],
    logo: json["logo"],
    storeUrl: json["store_url"],
    noOfRatings: json["no_of_ratings"],
    rating: json["rating"],
    bankCode: json["bank_code"],
    nationalIdentityCard: json["national_identity_card"],
    addressProof: json["address_proof"],
    panNumber: json["pan_number"],
    taxName: json["tax_name"],
    adharNo: json["adhar_no"],
    taxNumber: json["tax_number"],
    permissions: json["permissions"],
    commission: json["commission"],
    estimatedTime: json["estimated_time"],
    foodPerson: json["food_person"],
    openCloseStatus: json["open_close_status"],
    status: json["status"],
    dateAdded: json["date_added"] == null ? null : DateTime.parse(json["date_added"]),
    sponseredType: json["sponsered_type"],
    fassaiNumber: json["fassai_number"],
    indicator: json["indicator"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ip_address": ipAddress,
    "username": username,
    "password": password,
    "email": email,
    "mobile": mobile,
    "vehicle_no": vehicleNo,
    "image": image,
    "driving_license": drivingLicense,
    "profile_pic": profilePic,
    "balance": balance,
    "activation_selector": activationSelector,
    "activation_code": activationCode,
    "forgotten_password_selector": forgottenPasswordSelector,
    "forgotten_password_code": forgottenPasswordCode,
    "forgotten_password_time": forgottenPasswordTime,
    "remember_selector": rememberSelector,
    "remember_code": rememberCode,
    "created_on": createdOn,
    "last_login": lastLogin,
    "active": active,
    "company": company,
    "address": address,
    "second_address": secondAddress,
    "bonus": bonus,
    "cash_received": cashReceived,
    "dob": dob,
    "country_code": countryCode,
    "city": city,
    "country": country,
    "area": area,
    "street": street,
    "pincode": pincode,
    "serviceable_zipcodes": serviceableZipcodes,
    "apikey": apikey,
    "referral_code": referralCode,
    "friends_code": friendsCode,
    "fcm_id": fcmId,
    "otp": otp,
    "verify_otp": verifyOtp,
    "latitude": latitude,
    "longitude": longitude,
    "created_at": createdAt?.toIso8601String(),
    "online": online,
    "account_number": accountNumber,
    "account_name": accountName,
    "ifsc_code": ifscCode,
    "bank_name": bankName,
    "account_type": accountType,
    "branch": branch,
    "wallet_amount": walletAmount,
    "first_user": firstUser,
    "login_status": loginStatus,
    "current_address": currentAddress,
    "lat2": lat2,
    "lang2": lang2,
    "heading": heading,
    "new": datumNew,
    "user_id": userId,
    "slug": slug,
    "category_ids": categoryIds,
    "store_name": storeName,
    "store_description": storeDescription,
    "logo": logo,
    "store_url": storeUrl,
    "no_of_ratings": noOfRatings,
    "rating": rating,
    "bank_code": bankCode,
    "national_identity_card": nationalIdentityCard,
    "address_proof": addressProof,
    "pan_number": panNumber,
    "tax_name": taxName,
    "adhar_no": adharNo,
    "tax_number": taxNumber,
    "permissions": permissions,
    "commission": commission,
    "estimated_time": estimatedTime,
    "food_person": foodPerson,
    "open_close_status": openCloseStatus,
    "status": status,
    "date_added": dateAdded?.toIso8601String(),
    "sponsered_type": sponseredType,
    "fassai_number": fassaiNumber,
    "indicator": indicator,
  };
}
