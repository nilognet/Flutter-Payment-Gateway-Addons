import 'package:flutter/material.dart';

class MidtransWebViewScreen extends StatefulWidget {
  final dynamic data;
  final Widget Function(String url, BuildContext context, {String Function(String url)? customHandle}) webViewGateway;

  const MidtransWebViewScreen({Key? key, required this.data, required this.webViewGateway}) : super(key: key);

  @override
  State<MidtransWebViewScreen> createState() => _MidtransWebViewScreenState();
}

class _MidtransWebViewScreenState extends State<MidtransWebViewScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String url = widget.data['payment_result']['redirect_url'];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: widget.webViewGateway(url, context, customHandle: (url) {
          if (url.contains("/shop/")) {
            Navigator.of(context).pop({'order_received_url': ""});
            return "prevent";
          }
          return "";
        }),
      ),
    );
  }
}
