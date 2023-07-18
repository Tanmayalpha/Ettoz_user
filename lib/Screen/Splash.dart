import 'dart:async';
import 'package:eshop_multivendor/Helper/app_assets.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Screen/Intro_Slider.dart';
import 'package:eshop_multivendor/Screen/NewLocationPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Helper/Color.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import 'package:flutter_svg/flutter_svg.dart';

//splash screen of app
class Splash extends StatefulWidget {
  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.top]);
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   statusBarIconBrightness: Brightness.light,
    // ));

    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    //  SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // decoration: back(),
        child: Image.asset("assets/images/EatozBGGIF.gif",fit: BoxFit.fill,),
      ),
    );
  }

  startTime() async {
    var _duration = Duration(seconds: 4);
    return Timer(_duration, navigationPage);
  }

  Future<void> navigationPage() async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(this.context, listen: false);

    bool isFirstTime = await settingsProvider.getPrefrenceBool(ISFIRSTTIME);
    if (isFirstTime) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NewLocationPage()), (route) => false);
    //  Navigator.pushReplacementNamed(context, "/home");
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => IntroSlider(),
          ));
    }
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.black),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ));
  }

  @override
  void dispose() {
    //  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }
}
