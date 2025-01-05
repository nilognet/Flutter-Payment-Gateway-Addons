import 'package:flutter/material.dart';

class XenditWebViewScreen extends StatefulWidget {
  final dynamic data;
  final Widget Function(String url, BuildContext context, {String Function(String url)? customHandle}) webViewGateway;

  const XenditWebViewScreen({Key? key, required this.data, required this.webViewGateway}) : super(key: key);

  @override
  State<XenditWebViewScreen> createState() => _XenditWebViewScreenState();
}

class _XenditWebViewScreenState extends State<XenditWebViewScreen> {
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
        child: widget.webViewGateway(url, context),
      ),
    );
  }
}
