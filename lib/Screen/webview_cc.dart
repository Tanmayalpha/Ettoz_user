import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'Dashboard.dart';


class WebviewPage extends StatefulWidget {
  const WebviewPage({Key? key, this.data}) : super(key: key);
  final data;

  @override
  _WebviewPageState createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  bool loading = true;
  late InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    // _loadHTML();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) =>  AlertDialog(
        //title: new Text('Are you sure?'),
        content: const Text('Do you want to cancel this transaction ?'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => Dashboard()));
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child:  Scaffold(
        // appBar: AppBar(
        //   title: Text('Payment'),
        // ),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: InAppWebView(
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        useShouldOverrideUrlLoading: true,
                        mediaPlaybackRequiresUserGesture: false,
                        javaScriptEnabled: true,
                        javaScriptCanOpenWindowsAutomatically: true,
                      ),
                      android: AndroidInAppWebViewOptions(
                        useWideViewPort: false,
                        useHybridComposition: true,
                        loadWithOverviewMode: true,
                        domStorageEnabled: true,
                      ),
                      ios: IOSInAppWebViewOptions(
                          allowsInlineMediaPlayback: true,
                          enableViewportScale: true,
                          ignoresViewportScaleLimits: true
                      )),
                  initialData: InAppWebViewInitialData(
                      data: _loadHTML()),
                  onWebViewCreated: (InAppWebViewController controller) {
                    _webViewController = controller;
                  },
                  onLoadError: (controller, url, code, message) {
                    print(message);
                    Navigator.pop(context);
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Dashboard()));
                  },
                  onLoadStop:
                      (InAppWebViewController controller, Uri? pageUri) async {
                    setState(() {
                      loading = false;
                    });
                    print(pageUri.toString());
                    final page = pageUri.toString();

                    // if (page == widget.data?.cancelUrl ||
                    //     page == widget.data?.redirectUrl) {
                      var html = await controller.evaluateJavascript(
                          source: "window.document.getElementsByTagName('html')[0].outerHTML;");

                      /*String html1 = html.toString();
                      print(html1);
                      if (html1.contains('<body>')) {
                        html1 = html1.split('<body>')[1].split('</body>')[0];

                        log(html1);

                        // Map<String, dynamic> map = jsonDecode(html1);
                        // String status = map['order_status'];
                        // Navigator.of(context).pushAndRemoveUntil(

                        //     MaterialPageRoute(
                        //         builder: (context) =>
                        //             PaymentStatus(resp: html1.toString())),
                        //     (Route<dynamic> route) => false);

                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (_) {
                          return PaymentStatus(resp: html1.toString());
                        }));
                      }*/
                    // }
                    // var html = await controller.evaluateJavascript(
                    //     source: "window.document.getElementsByTagName('html')[0].outerHTML;");
                    // String html1 = html.toString();
                    // Navigator.of(context)
                    //             .pushReplacement(MaterialPageRoute(builder: (_) {
                    //           return PaymentStatus(resp: html1.toString());
                    //         }));
                  },
                ),
              ),
              (loading)
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : Center(),
            ],
          ),
        ),
      ),
    );
  }

  String _loadHTML() {
    // final url = UrlList.ccAvenue_payment_url;
    // final command = "initiateTransaction";
    // final encRequest = widget.data?.encVal;
    // final accessCode = widget.data?.accessCode;
    final data = widget.data;

    var data1 = jsonDecode(data) ;

    String html = data1["message"];
        // "<html> <head><meta name='viewport' content='width=device-width, initial-scale=1.0'></head> "
        //     "<body onload='document.f.submit();'> <form id='f' name='f' method='post' action='$url'>" +
        //     "<input type='hidden' name='command' value='$command'/>" +
        //     "<input type='hidden' name='encRequest' value='$encRequest' />" +
        //     "<input  type='hidden' name='access_code' value='$accessCode' />";
    print(html);
    return html ;
    //+ "</form> </body> </html>";
  }
}
