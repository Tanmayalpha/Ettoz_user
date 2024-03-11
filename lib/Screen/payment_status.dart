
import 'package:flutter/material.dart';

import 'Cart.dart';
import 'Dashboard.dart';


class PaymentStatus extends StatefulWidget {
  final String resp;

  const PaymentStatus({required this.resp});

  @override
  _PaymentStatusState createState() => _PaymentStatusState();
}

class _PaymentStatusState extends State<PaymentStatus> {
  Future<bool> _onWillPop() async {
    Navigator.of(context).pushAndRemoveUntil<bool>(
        MaterialPageRoute(builder: (context) => Cart(fromBottom: false,)),
            (Route<dynamic> route) => false);
    return false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 3),(){
      Navigator.of(context).pushAndRemoveUntil<bool>(
          MaterialPageRoute(builder: (context) => Dashboard()),
              (Route<dynamic> route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child:  Scaffold(
          appBar: AppBar(
            title: Text("Payment Status"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Text("Payment status",
                    // widget.resp,
                    style:
                     TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
