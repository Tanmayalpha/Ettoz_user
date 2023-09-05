import 'package:cc_avenue/cc_avenue.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CCAvenueScreen extends StatefulWidget {
  const CCAvenueScreen({Key? key}) : super(key: key);

  @override
  State<CCAvenueScreen> createState() => _CCAvenueScreenState();
}

class _CCAvenueScreenState extends State<CCAvenueScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('CC Avenue Payment')),
    body: Center(
      child: ElevatedButton(onPressed: (){
        initPlatformState();
      }, child: Text('Done'
          '') ),
    ),);
  }


  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await CcAvenue.cCAvenueInit(
          transUrl: 'https://test.ccavenue.com/transaction/transaction.do?command=initiateTransaction&encRequest=2834ab557e3769dd56cab9b834255ac5c320c2e91548117586fa112d0b477ff3ab6c2011ea7c4d33371a085aa41d7e39dd3639c080c1fb6c7f5cc2eec1ec99ee5bff60247ed36f1a6aa3f1aa3f54d73279eba19debebf6e7b75f4f2b0debd66467b55365c0082b1306d77335363970575da30051cce3175c3d8f8a81d76f0a89c0d1ba3417ccf3980ee77ae8408e150e1828b80b22f533aedc6574dbbfaa835a16f4890dfbbee9141a0f4c690160ea527e7ff666428473cd096945830db9587c61c5095f3f6f9364a5597d3bf633d713442eb85776c704bf54f22943940941a1&access_code=AVTF02KH17BW62FTWB',
          accessCode: 'AVTF02KH17BW62FTWB',
          amount: '10',
          cancelUrl: 'https://eatoz.in/app/v1/api/ccevenue_response1',
          currencyType: 'INR',
          merchantId: '2784704',
          orderId: '35',
          redirectUrl: 'https://eatoz.in/app/v1/api/ccevenue_response?order_id=35',
          rsaKeyUrl: 'https://secure.ccavenue.com/transaction/jsp/GetRSA.jsp'
      );

    } on PlatformException {
      print('PlatformException');
    }
  }
}


