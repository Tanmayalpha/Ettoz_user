import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Screen/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../Provider/UserProvider.dart';

class NewLocationPage extends StatefulWidget {
  const NewLocationPage({Key? key}) : super(key: key);

  @override
  State<NewLocationPage> createState() => _NewLocationPageState();
}

class _NewLocationPageState extends State<NewLocationPage> {
  var latitude;
  var longitude;

  var pinController = TextEditingController();
  var currentAddress = TextEditingController();

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

      if (currentAddress.text == "" || currentAddress.text == null) {
      } else {
        setState(() {
          navigateToPage();
        });
      }
    }
  }

  navigateToPage() async {
    Future.delayed(Duration(milliseconds: 800), () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
          (route) => false);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLoc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 150,
              width: 150,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    "assets/images/locationLogo.png",
                    fit: BoxFit.cover,
                  )),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "DELIVERING TO",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            currentAddress.text == "" || currentAddress.text == null
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Locating...",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  )
                : Text(
                    "${currentAddress.text}",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  )
          ],
        ),
      ),
    );
  }
}
