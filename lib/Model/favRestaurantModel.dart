/// error : false
/// message : "Get Data Successfully"
/// data : [{"id":"13","ip_address":"182.69.6.75","username":"Shivam","password":"$2y$10$tSP6tJfKRW.wp1pmocWjOeAskkEfxYxpZdZFObSbYQXY/cFIWUPHC","email":"shivam@gmail.com","mobile":"9644595849","vehicle_no":null,"image":null,"driving_license":null,"profile_pic":null,"balance":"0","activation_selector":"493b4c60257d49e19a31","activation_code":"$2y$10$n1IYQer03z/8iycxX6gHleQwHWxhNjPEBDFe9g/EEERjrQLqsvdhO","forgotten_password_selector":null,"forgotten_password_code":null,"forgotten_password_time":null,"remember_selector":null,"remember_code":null,"created_on":"1682572793","last_login":"1682761450","active":"1","company":null,"address":"Vijay Nagar, Indore, Madhya Pradesh 452010, India","second_address":null,"bonus":null,"cash_received":"0.00","dob":null,"country_code":null,"city":null,"country":null,"area":null,"street":null,"pincode":null,"serviceable_zipcodes":null,"apikey":null,"referral_code":null,"friends_code":null,"fcm_id":"dXg-n5PZQwSII57UlWLK7n:APA91bFMIGsNHcYAM-Jy0bKjE93T-JXVBH5p9lu1PJET53KFCH0q6JmIv2vq9bkTTqGT5auYml4zxAlKLevNMsRRzttwQTiZlq0ftKBN0mElgnOUZPAa3HvAROuboe_SxJ6l4AFWBK02","otp":null,"verify_otp":null,"latitude":"22.7532848","longitude":"75.8936962","created_at":"2023-04-27 10:49:53","online":"1","account_number":"","account_name":"9876543210","ifsc_code":"","bank_name":"","account_type":"saving","branch":"","wallet_amount":"0","first_user":"0","login_status":"0","user_id":"35","slug":"test-restaurant","category_ids":"5","store_name":"Test Restaurant","store_description":"du","logo":"uploads/seller/new_screenshot2.png","store_url":"testrestaurant.com","no_of_ratings":"0","rating":"0.00","bank_code":"","national_identity_card":"","address_proof":"uploads/seller/new_screenshot3.png","pan_number":"sdsfsffs","tax_name":"efs","adhar_no":"3535353","tax_number":"531544","permissions":"{\"require_products_approval\":\"0\",\"customer_privacy\":\"0\",\"view_order_otp\":\"0\",\"assign_delivery_boy\":\"0\",\"online\":\"1\"}","commission":"2.00","estimated_time":"15","food_person":"sffsf","open_close_status":"0","status":"1","date_added":"2023-04-27 10:49:53","sponsered_type":"0","fassai_number":"sfsfs","indicator":"1"},{"id":"19","ip_address":"1.22.26.77","username":"Devesh","password":"$2y$10$JdT8LVW9cyf869B0ILsJoeaeHYK.VwMps9fyeniABPnPovfjkAD5y","email":"devesh1@gmail.com","mobile":"2020202020","vehicle_no":null,"image":null,"driving_license":null,"profile_pic":null,"balance":"0","activation_selector":"8509c86f991472dc6a22","activation_code":"$2y$10$yffH3r4JPaqQKMXITfCCteHGTHVn7gziEaQtYrby2AQqrbk4NbpRW","forgotten_password_selector":null,"forgotten_password_code":null,"forgotten_password_time":null,"remember_selector":null,"remember_code":null,"created_on":"1682770721","last_login":null,"active":"1","company":null,"address":"Vijay Nagar, Indore, Madhya Pradesh 452010, India","second_address":null,"bonus":null,"cash_received":"0.00","dob":null,"country_code":null,"city":"","country":null,"area":null,"street":null,"pincode":null,"serviceable_zipcodes":null,"apikey":null,"referral_code":null,"friends_code":null,"fcm_id":null,"otp":null,"verify_otp":null,"latitude":"22.7532848","longitude":"75.8936962","created_at":"2023-04-29 17:48:41","online":"1","account_number":"sss","account_name":"sbi","ifsc_code":"sfsfs","bank_name":"sfsfs","account_type":"saving","branch":"sf","wallet_amount":"0","first_user":"0","login_status":"0","user_id":"71","slug":"devesiya-restaurant","category_ids":"1,5,8,10,12,14,16,18,20,22,24,26,28,29,31,33,35,37,39,41,43,45,46,48,50,230,2,3,4,6,7,9,11,13,15,17,19,21,23,25,27,30,32,34,36,38,40,42,44,47,49,231","store_name":"Devesiya Restaurant","store_description":"This is dummy description","logo":"uploads/seller/paid1.png","store_url":"http://deveshiya.com","no_of_ratings":"0","rating":"0.00","bank_code":"sdfs","national_identity_card":"uploads/seller/paid2.png","address_proof":"uploads/seller/Screenshot_2023-01-31_11143515.png","pan_number":"sfs","tax_name":"sfsf","adhar_no":"sfss","tax_number":"sfsf","permissions":"{\"require_products_approval\":\"0\",\"customer_privacy\":\"0\",\"view_order_otp\":\"1\",\"assign_delivery_boy\":\"1\",\"online\":\"1\"}","commission":"2.00","estimated_time":"20","food_person":"2","open_close_status":"0","status":"1","date_added":"2023-04-29 17:48:41","sponsered_type":"0","fassai_number":"sfsf","indicator":"1"}]

class FavRestaurantModel {
  FavRestaurantModel({
      bool? error, 
      String? message, 
      List<Data>? data,}){
    _error = error;
    _message = message;
    _data = data;
}

  FavRestaurantModel.fromJson(dynamic json) {
    _error = json['error'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _error;
  String? _message;
  List<Data>? _data;
FavRestaurantModel copyWith({  bool? error,
  String? message,
  List<Data>? data,
}) => FavRestaurantModel(  error: error ?? _error,
  message: message ?? _message,
  data: data ?? _data,
);
  bool? get error => _error;
  String? get message => _message;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : "13"
/// ip_address : "182.69.6.75"
/// username : "Shivam"
/// password : "$2y$10$tSP6tJfKRW.wp1pmocWjOeAskkEfxYxpZdZFObSbYQXY/cFIWUPHC"
/// email : "shivam@gmail.com"
/// mobile : "9644595849"
/// vehicle_no : null
/// image : null
/// driving_license : null
/// profile_pic : null
/// balance : "0"
/// activation_selector : "493b4c60257d49e19a31"
/// activation_code : "$2y$10$n1IYQer03z/8iycxX6gHleQwHWxhNjPEBDFe9g/EEERjrQLqsvdhO"
/// forgotten_password_selector : null
/// forgotten_password_code : null
/// forgotten_password_time : null
/// remember_selector : null
/// remember_code : null
/// created_on : "1682572793"
/// last_login : "1682761450"
/// active : "1"
/// company : null
/// address : "Vijay Nagar, Indore, Madhya Pradesh 452010, India"
/// second_address : null
/// bonus : null
/// cash_received : "0.00"
/// dob : null
/// country_code : null
/// city : null
/// country : null
/// area : null
/// street : null
/// pincode : null
/// serviceable_zipcodes : null
/// apikey : null
/// referral_code : null
/// friends_code : null
/// fcm_id : "dXg-n5PZQwSII57UlWLK7n:APA91bFMIGsNHcYAM-Jy0bKjE93T-JXVBH5p9lu1PJET53KFCH0q6JmIv2vq9bkTTqGT5auYml4zxAlKLevNMsRRzttwQTiZlq0ftKBN0mElgnOUZPAa3HvAROuboe_SxJ6l4AFWBK02"
/// otp : null
/// verify_otp : null
/// latitude : "22.7532848"
/// longitude : "75.8936962"
/// created_at : "2023-04-27 10:49:53"
/// online : "1"
/// account_number : ""
/// account_name : "9876543210"
/// ifsc_code : ""
/// bank_name : ""
/// account_type : "saving"
/// branch : ""
/// wallet_amount : "0"
/// first_user : "0"
/// login_status : "0"
/// user_id : "35"
/// slug : "test-restaurant"
/// category_ids : "5"
/// store_name : "Test Restaurant"
/// store_description : "du"
/// logo : "uploads/seller/new_screenshot2.png"
/// store_url : "testrestaurant.com"
/// no_of_ratings : "0"
/// rating : "0.00"
/// bank_code : ""
/// national_identity_card : ""
/// address_proof : "uploads/seller/new_screenshot3.png"
/// pan_number : "sdsfsffs"
/// tax_name : "efs"
/// adhar_no : "3535353"
/// tax_number : "531544"
/// permissions : "{\"require_products_approval\":\"0\",\"customer_privacy\":\"0\",\"view_order_otp\":\"0\",\"assign_delivery_boy\":\"0\",\"online\":\"1\"}"
/// commission : "2.00"
/// estimated_time : "15"
/// food_person : "sffsf"
/// open_close_status : "0"
/// status : "1"
/// date_added : "2023-04-27 10:49:53"
/// sponsered_type : "0"
/// fassai_number : "sfsfs"
/// indicator : "1"

class Data {
  Data({
      String? id, 
      String? ipAddress, 
      String? username, 
      String? password, 
      String? email, 
      String? mobile, 
      dynamic vehicleNo, 
      dynamic image, 
      dynamic drivingLicense, 
      dynamic profilePic, 
      String? balance, 
      String? activationSelector, 
      String? activationCode, 
      dynamic forgottenPasswordSelector, 
      dynamic forgottenPasswordCode, 
      dynamic forgottenPasswordTime, 
      dynamic rememberSelector, 
      dynamic rememberCode, 
      String? createdOn, 
      String? lastLogin, 
      String? active, 
      dynamic company, 
      String? address, 
      dynamic secondAddress, 
      dynamic bonus, 
      String? cashReceived, 
      dynamic dob, 
      dynamic countryCode, 
      dynamic city, 
      dynamic country, 
      dynamic area, 
      dynamic street, 
      dynamic pincode, 
      dynamic serviceableZipcodes, 
      dynamic apikey, 
      dynamic referralCode, 
      dynamic friendsCode, 
      String? fcmId, 
      dynamic otp, 
      dynamic verifyOtp, 
      String? latitude, 
      String? longitude, 
      String? createdAt, 
      String? online, 
      String? accountNumber, 
      String? accountName, 
      String? ifscCode, 
      String? bankName, 
      String? accountType, 
      String? branch, 
      String? walletAmount, 
      String? firstUser, 
      String? loginStatus, 
      String? userId, 
      String? slug, 
      String? categoryIds, 
      String? storeName, 
      String? storeDescription, 
      String? logo, 
      String? storeUrl, 
      String? noOfRatings, 
      String? rating, 
      String? bankCode, 
      String? nationalIdentityCard, 
      String? addressProof, 
      String? panNumber, 
      String? taxName, 
      String? adharNo, 
      String? taxNumber, 
      String? permissions, 
      String? commission, 
      String? estimatedTime, 
      String? foodPerson, 
      String? openCloseStatus, 
      String? status, 
      String? dateAdded, 
      String? sponseredType, 
      String? fassaiNumber, 
      String? indicator,}){
    _id = id;
    _ipAddress = ipAddress;
    _username = username;
    _password = password;
    _email = email;
    _mobile = mobile;
    _vehicleNo = vehicleNo;
    _image = image;
    _drivingLicense = drivingLicense;
    _profilePic = profilePic;
    _balance = balance;
    _activationSelector = activationSelector;
    _activationCode = activationCode;
    _forgottenPasswordSelector = forgottenPasswordSelector;
    _forgottenPasswordCode = forgottenPasswordCode;
    _forgottenPasswordTime = forgottenPasswordTime;
    _rememberSelector = rememberSelector;
    _rememberCode = rememberCode;
    _createdOn = createdOn;
    _lastLogin = lastLogin;
    _active = active;
    _company = company;
    _address = address;
    _secondAddress = secondAddress;
    _bonus = bonus;
    _cashReceived = cashReceived;
    _dob = dob;
    _countryCode = countryCode;
    _city = city;
    _country = country;
    _area = area;
    _street = street;
    _pincode = pincode;
    _serviceableZipcodes = serviceableZipcodes;
    _apikey = apikey;
    _referralCode = referralCode;
    _friendsCode = friendsCode;
    _fcmId = fcmId;
    _otp = otp;
    _verifyOtp = verifyOtp;
    _latitude = latitude;
    _longitude = longitude;
    _createdAt = createdAt;
    _online = online;
    _accountNumber = accountNumber;
    _accountName = accountName;
    _ifscCode = ifscCode;
    _bankName = bankName;
    _accountType = accountType;
    _branch = branch;
    _walletAmount = walletAmount;
    _firstUser = firstUser;
    _loginStatus = loginStatus;
    _userId = userId;
    _slug = slug;
    _categoryIds = categoryIds;
    _storeName = storeName;
    _storeDescription = storeDescription;
    _logo = logo;
    _storeUrl = storeUrl;
    _noOfRatings = noOfRatings;
    _rating = rating;
    _bankCode = bankCode;
    _nationalIdentityCard = nationalIdentityCard;
    _addressProof = addressProof;
    _panNumber = panNumber;
    _taxName = taxName;
    _adharNo = adharNo;
    _taxNumber = taxNumber;
    _permissions = permissions;
    _commission = commission;
    _estimatedTime = estimatedTime;
    _foodPerson = foodPerson;
    _openCloseStatus = openCloseStatus;
    _status = status;
    _dateAdded = dateAdded;
    _sponseredType = sponseredType;
    _fassaiNumber = fassaiNumber;
    _indicator = indicator;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _ipAddress = json['ip_address'];
    _username = json['username'];
    _password = json['password'];
    _email = json['email'];
    _mobile = json['mobile'];
    _vehicleNo = json['vehicle_no'];
    _image = json['image'];
    _drivingLicense = json['driving_license'];
    _profilePic = json['profile_pic'];
    _balance = json['balance'];
    _activationSelector = json['activation_selector'];
    _activationCode = json['activation_code'];
    _forgottenPasswordSelector = json['forgotten_password_selector'];
    _forgottenPasswordCode = json['forgotten_password_code'];
    _forgottenPasswordTime = json['forgotten_password_time'];
    _rememberSelector = json['remember_selector'];
    _rememberCode = json['remember_code'];
    _createdOn = json['created_on'];
    _lastLogin = json['last_login'];
    _active = json['active'];
    _company = json['company'];
    _address = json['address'];
    _secondAddress = json['second_address'];
    _bonus = json['bonus'];
    _cashReceived = json['cash_received'];
    _dob = json['dob'];
    _countryCode = json['country_code'];
    _city = json['city'];
    _country = json['country'];
    _area = json['area'];
    _street = json['street'];
    _pincode = json['pincode'];
    _serviceableZipcodes = json['serviceable_zipcodes'];
    _apikey = json['apikey'];
    _referralCode = json['referral_code'];
    _friendsCode = json['friends_code'];
    _fcmId = json['fcm_id'];
    _otp = json['otp'];
    _verifyOtp = json['verify_otp'];
    _latitude = json['latitude'];
    _longitude = json['longitude'];
    _createdAt = json['created_at'];
    _online = json['online'];
    _accountNumber = json['account_number'];
    _accountName = json['account_name'];
    _ifscCode = json['ifsc_code'];
    _bankName = json['bank_name'];
    _accountType = json['account_type'];
    _branch = json['branch'];
    _walletAmount = json['wallet_amount'];
    _firstUser = json['first_user'];
    _loginStatus = json['login_status'];
    _userId = json['user_id'];
    _slug = json['slug'];
    _categoryIds = json['category_ids'];
    _storeName = json['store_name'];
    _storeDescription = json['store_description'];
    _logo = json['logo'];
    _storeUrl = json['store_url'];
    _noOfRatings = json['no_of_ratings'];
    _rating = json['rating'];
    _bankCode = json['bank_code'];
    _nationalIdentityCard = json['national_identity_card'];
    _addressProof = json['address_proof'];
    _panNumber = json['pan_number'];
    _taxName = json['tax_name'];
    _adharNo = json['adhar_no'];
    _taxNumber = json['tax_number'];
    _permissions = json['permissions'];
    _commission = json['commission'];
    _estimatedTime = json['estimated_time'];
    _foodPerson = json['food_person'];
    _openCloseStatus = json['open_close_status'];
    _status = json['status'];
    _dateAdded = json['date_added'];
    _sponseredType = json['sponsered_type'];
    _fassaiNumber = json['fassai_number'];
    _indicator = json['indicator'];
  }
  String? _id;
  String? _ipAddress;
  String? _username;
  String? _password;
  String? _email;
  String? _mobile;
  dynamic _vehicleNo;
  dynamic _image;
  dynamic _drivingLicense;
  dynamic _profilePic;
  String? _balance;
  String? _activationSelector;
  String? _activationCode;
  dynamic _forgottenPasswordSelector;
  dynamic _forgottenPasswordCode;
  dynamic _forgottenPasswordTime;
  dynamic _rememberSelector;
  dynamic _rememberCode;
  String? _createdOn;
  String? _lastLogin;
  String? _active;
  dynamic _company;
  String? _address;
  dynamic _secondAddress;
  dynamic _bonus;
  String? _cashReceived;
  dynamic _dob;
  dynamic _countryCode;
  dynamic _city;
  dynamic _country;
  dynamic _area;
  dynamic _street;
  dynamic _pincode;
  dynamic _serviceableZipcodes;
  dynamic _apikey;
  dynamic _referralCode;
  dynamic _friendsCode;
  String? _fcmId;
  dynamic _otp;
  dynamic _verifyOtp;
  String? _latitude;
  String? _longitude;
  String? _createdAt;
  String? _online;
  String? _accountNumber;
  String? _accountName;
  String? _ifscCode;
  String? _bankName;
  String? _accountType;
  String? _branch;
  String? _walletAmount;
  String? _firstUser;
  String? _loginStatus;
  String? _userId;
  String? _slug;
  String? _categoryIds;
  String? _storeName;
  String? _storeDescription;
  String? _logo;
  String? _storeUrl;
  String? _noOfRatings;
  String? _rating;
  String? _bankCode;
  String? _nationalIdentityCard;
  String? _addressProof;
  String? _panNumber;
  String? _taxName;
  String? _adharNo;
  String? _taxNumber;
  String? _permissions;
  String? _commission;
  String? _estimatedTime;
  String? _foodPerson;
  String? _openCloseStatus;
  String? _status;
  String? _dateAdded;
  String? _sponseredType;
  String? _fassaiNumber;
  String? _indicator;
Data copyWith({  String? id,
  String? ipAddress,
  String? username,
  String? password,
  String? email,
  String? mobile,
  dynamic vehicleNo,
  dynamic image,
  dynamic drivingLicense,
  dynamic profilePic,
  String? balance,
  String? activationSelector,
  String? activationCode,
  dynamic forgottenPasswordSelector,
  dynamic forgottenPasswordCode,
  dynamic forgottenPasswordTime,
  dynamic rememberSelector,
  dynamic rememberCode,
  String? createdOn,
  String? lastLogin,
  String? active,
  dynamic company,
  String? address,
  dynamic secondAddress,
  dynamic bonus,
  String? cashReceived,
  dynamic dob,
  dynamic countryCode,
  dynamic city,
  dynamic country,
  dynamic area,
  dynamic street,
  dynamic pincode,
  dynamic serviceableZipcodes,
  dynamic apikey,
  dynamic referralCode,
  dynamic friendsCode,
  String? fcmId,
  dynamic otp,
  dynamic verifyOtp,
  String? latitude,
  String? longitude,
  String? createdAt,
  String? online,
  String? accountNumber,
  String? accountName,
  String? ifscCode,
  String? bankName,
  String? accountType,
  String? branch,
  String? walletAmount,
  String? firstUser,
  String? loginStatus,
  String? userId,
  String? slug,
  String? categoryIds,
  String? storeName,
  String? storeDescription,
  String? logo,
  String? storeUrl,
  String? noOfRatings,
  String? rating,
  String? bankCode,
  String? nationalIdentityCard,
  String? addressProof,
  String? panNumber,
  String? taxName,
  String? adharNo,
  String? taxNumber,
  String? permissions,
  String? commission,
  String? estimatedTime,
  String? foodPerson,
  String? openCloseStatus,
  String? status,
  String? dateAdded,
  String? sponseredType,
  String? fassaiNumber,
  String? indicator,
}) => Data(  id: id ?? _id,
  ipAddress: ipAddress ?? _ipAddress,
  username: username ?? _username,
  password: password ?? _password,
  email: email ?? _email,
  mobile: mobile ?? _mobile,
  vehicleNo: vehicleNo ?? _vehicleNo,
  image: image ?? _image,
  drivingLicense: drivingLicense ?? _drivingLicense,
  profilePic: profilePic ?? _profilePic,
  balance: balance ?? _balance,
  activationSelector: activationSelector ?? _activationSelector,
  activationCode: activationCode ?? _activationCode,
  forgottenPasswordSelector: forgottenPasswordSelector ?? _forgottenPasswordSelector,
  forgottenPasswordCode: forgottenPasswordCode ?? _forgottenPasswordCode,
  forgottenPasswordTime: forgottenPasswordTime ?? _forgottenPasswordTime,
  rememberSelector: rememberSelector ?? _rememberSelector,
  rememberCode: rememberCode ?? _rememberCode,
  createdOn: createdOn ?? _createdOn,
  lastLogin: lastLogin ?? _lastLogin,
  active: active ?? _active,
  company: company ?? _company,
  address: address ?? _address,
  secondAddress: secondAddress ?? _secondAddress,
  bonus: bonus ?? _bonus,
  cashReceived: cashReceived ?? _cashReceived,
  dob: dob ?? _dob,
  countryCode: countryCode ?? _countryCode,
  city: city ?? _city,
  country: country ?? _country,
  area: area ?? _area,
  street: street ?? _street,
  pincode: pincode ?? _pincode,
  serviceableZipcodes: serviceableZipcodes ?? _serviceableZipcodes,
  apikey: apikey ?? _apikey,
  referralCode: referralCode ?? _referralCode,
  friendsCode: friendsCode ?? _friendsCode,
  fcmId: fcmId ?? _fcmId,
  otp: otp ?? _otp,
  verifyOtp: verifyOtp ?? _verifyOtp,
  latitude: latitude ?? _latitude,
  longitude: longitude ?? _longitude,
  createdAt: createdAt ?? _createdAt,
  online: online ?? _online,
  accountNumber: accountNumber ?? _accountNumber,
  accountName: accountName ?? _accountName,
  ifscCode: ifscCode ?? _ifscCode,
  bankName: bankName ?? _bankName,
  accountType: accountType ?? _accountType,
  branch: branch ?? _branch,
  walletAmount: walletAmount ?? _walletAmount,
  firstUser: firstUser ?? _firstUser,
  loginStatus: loginStatus ?? _loginStatus,
  userId: userId ?? _userId,
  slug: slug ?? _slug,
  categoryIds: categoryIds ?? _categoryIds,
  storeName: storeName ?? _storeName,
  storeDescription: storeDescription ?? _storeDescription,
  logo: logo ?? _logo,
  storeUrl: storeUrl ?? _storeUrl,
  noOfRatings: noOfRatings ?? _noOfRatings,
  rating: rating ?? _rating,
  bankCode: bankCode ?? _bankCode,
  nationalIdentityCard: nationalIdentityCard ?? _nationalIdentityCard,
  addressProof: addressProof ?? _addressProof,
  panNumber: panNumber ?? _panNumber,
  taxName: taxName ?? _taxName,
  adharNo: adharNo ?? _adharNo,
  taxNumber: taxNumber ?? _taxNumber,
  permissions: permissions ?? _permissions,
  commission: commission ?? _commission,
  estimatedTime: estimatedTime ?? _estimatedTime,
  foodPerson: foodPerson ?? _foodPerson,
  openCloseStatus: openCloseStatus ?? _openCloseStatus,
  status: status ?? _status,
  dateAdded: dateAdded ?? _dateAdded,
  sponseredType: sponseredType ?? _sponseredType,
  fassaiNumber: fassaiNumber ?? _fassaiNumber,
  indicator: indicator ?? _indicator,
);
  String? get id => _id;
  String? get ipAddress => _ipAddress;
  String? get username => _username;
  String? get password => _password;
  String? get email => _email;
  String? get mobile => _mobile;
  dynamic get vehicleNo => _vehicleNo;
  dynamic get image => _image;
  dynamic get drivingLicense => _drivingLicense;
  dynamic get profilePic => _profilePic;
  String? get balance => _balance;
  String? get activationSelector => _activationSelector;
  String? get activationCode => _activationCode;
  dynamic get forgottenPasswordSelector => _forgottenPasswordSelector;
  dynamic get forgottenPasswordCode => _forgottenPasswordCode;
  dynamic get forgottenPasswordTime => _forgottenPasswordTime;
  dynamic get rememberSelector => _rememberSelector;
  dynamic get rememberCode => _rememberCode;
  String? get createdOn => _createdOn;
  String? get lastLogin => _lastLogin;
  String? get active => _active;
  dynamic get company => _company;
  String? get address => _address;
  dynamic get secondAddress => _secondAddress;
  dynamic get bonus => _bonus;
  String? get cashReceived => _cashReceived;
  dynamic get dob => _dob;
  dynamic get countryCode => _countryCode;
  dynamic get city => _city;
  dynamic get country => _country;
  dynamic get area => _area;
  dynamic get street => _street;
  dynamic get pincode => _pincode;
  dynamic get serviceableZipcodes => _serviceableZipcodes;
  dynamic get apikey => _apikey;
  dynamic get referralCode => _referralCode;
  dynamic get friendsCode => _friendsCode;
  String? get fcmId => _fcmId;
  dynamic get otp => _otp;
  dynamic get verifyOtp => _verifyOtp;
  String? get latitude => _latitude;
  String? get longitude => _longitude;
  String? get createdAt => _createdAt;
  String? get online => _online;
  String? get accountNumber => _accountNumber;
  String? get accountName => _accountName;
  String? get ifscCode => _ifscCode;
  String? get bankName => _bankName;
  String? get accountType => _accountType;
  String? get branch => _branch;
  String? get walletAmount => _walletAmount;
  String? get firstUser => _firstUser;
  String? get loginStatus => _loginStatus;
  String? get userId => _userId;
  String? get slug => _slug;
  String? get categoryIds => _categoryIds;
  String? get storeName => _storeName;
  String? get storeDescription => _storeDescription;
  String? get logo => _logo;
  String? get storeUrl => _storeUrl;
  String? get noOfRatings => _noOfRatings;
  String? get rating => _rating;
  String? get bankCode => _bankCode;
  String? get nationalIdentityCard => _nationalIdentityCard;
  String? get addressProof => _addressProof;
  String? get panNumber => _panNumber;
  String? get taxName => _taxName;
  String? get adharNo => _adharNo;
  String? get taxNumber => _taxNumber;
  String? get permissions => _permissions;
  String? get commission => _commission;
  String? get estimatedTime => _estimatedTime;
  String? get foodPerson => _foodPerson;
  String? get openCloseStatus => _openCloseStatus;
  String? get status => _status;
  String? get dateAdded => _dateAdded;
  String? get sponseredType => _sponseredType;
  String? get fassaiNumber => _fassaiNumber;
  String? get indicator => _indicator;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['ip_address'] = _ipAddress;
    map['username'] = _username;
    map['password'] = _password;
    map['email'] = _email;
    map['mobile'] = _mobile;
    map['vehicle_no'] = _vehicleNo;
    map['image'] = _image;
    map['driving_license'] = _drivingLicense;
    map['profile_pic'] = _profilePic;
    map['balance'] = _balance;
    map['activation_selector'] = _activationSelector;
    map['activation_code'] = _activationCode;
    map['forgotten_password_selector'] = _forgottenPasswordSelector;
    map['forgotten_password_code'] = _forgottenPasswordCode;
    map['forgotten_password_time'] = _forgottenPasswordTime;
    map['remember_selector'] = _rememberSelector;
    map['remember_code'] = _rememberCode;
    map['created_on'] = _createdOn;
    map['last_login'] = _lastLogin;
    map['active'] = _active;
    map['company'] = _company;
    map['address'] = _address;
    map['second_address'] = _secondAddress;
    map['bonus'] = _bonus;
    map['cash_received'] = _cashReceived;
    map['dob'] = _dob;
    map['country_code'] = _countryCode;
    map['city'] = _city;
    map['country'] = _country;
    map['area'] = _area;
    map['street'] = _street;
    map['pincode'] = _pincode;
    map['serviceable_zipcodes'] = _serviceableZipcodes;
    map['apikey'] = _apikey;
    map['referral_code'] = _referralCode;
    map['friends_code'] = _friendsCode;
    map['fcm_id'] = _fcmId;
    map['otp'] = _otp;
    map['verify_otp'] = _verifyOtp;
    map['latitude'] = _latitude;
    map['longitude'] = _longitude;
    map['created_at'] = _createdAt;
    map['online'] = _online;
    map['account_number'] = _accountNumber;
    map['account_name'] = _accountName;
    map['ifsc_code'] = _ifscCode;
    map['bank_name'] = _bankName;
    map['account_type'] = _accountType;
    map['branch'] = _branch;
    map['wallet_amount'] = _walletAmount;
    map['first_user'] = _firstUser;
    map['login_status'] = _loginStatus;
    map['user_id'] = _userId;
    map['slug'] = _slug;
    map['category_ids'] = _categoryIds;
    map['store_name'] = _storeName;
    map['store_description'] = _storeDescription;
    map['logo'] = _logo;
    map['store_url'] = _storeUrl;
    map['no_of_ratings'] = _noOfRatings;
    map['rating'] = _rating;
    map['bank_code'] = _bankCode;
    map['national_identity_card'] = _nationalIdentityCard;
    map['address_proof'] = _addressProof;
    map['pan_number'] = _panNumber;
    map['tax_name'] = _taxName;
    map['adhar_no'] = _adharNo;
    map['tax_number'] = _taxNumber;
    map['permissions'] = _permissions;
    map['commission'] = _commission;
    map['estimated_time'] = _estimatedTime;
    map['food_person'] = _foodPerson;
    map['open_close_status'] = _openCloseStatus;
    map['status'] = _status;
    map['date_added'] = _dateAdded;
    map['sponsered_type'] = _sponseredType;
    map['fassai_number'] = _fassaiNumber;
    map['indicator'] = _indicator;
    return map;
  }

}