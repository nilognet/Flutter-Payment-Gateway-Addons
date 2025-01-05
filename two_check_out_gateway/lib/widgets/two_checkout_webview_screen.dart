import 'package:flutter/material.dart';

class TwoCheckoutWebViewScreen extends StatefulWidget {
  final dynamic data;
  final Widget Function(String url, BuildContext context, {String Function(String url)? customHandle}) webViewGateway;

  const TwoCheckoutWebViewScreen({Key? key, required this.data, required this.webViewGateway}) : super(key: key);

  @override
  State<TwoCheckoutWebViewScreen> createState() => _TwoCheckoutWebViewScreenState();
}

class _TwoCheckoutWebViewScreenState extends State<TwoCheckoutWebViewScreen> {
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
