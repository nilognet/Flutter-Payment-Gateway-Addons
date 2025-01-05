import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payment_base/payment_base.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:razorpay_native_gateway/widgets/divider.dart';

class RazorPayNativeScreen extends StatefulWidget {
  const RazorPayNativeScreen({
    Key? key,
    required this.amount,
    this.email,
    this.currency,
    required this.orderId,
    required this.apiKeyId,
    required this.orderIdCheckout,
    required this.progressServer,
    required this.callback,
    required this.cartId,
    required this.name,
    this.phone,
    required this.orderKey,
  }) : super(key: key);
  final String orderKey;
  final String? phone;
  final String? email;
  final String amount;
  final String? currency;
  final String orderId;
  final String apiKeyId;
  final String orderIdCheckout;
  final Future<dynamic> Function({String? cartKey, required Map<String, dynamic> data}) progressServer;
  final Function(dynamic data) callback;
  final String cartId;
  final String name;
  @override
  State<RazorPayNativeScreen> createState() => _RazorPayNativeScreenState();
}

class _RazorPayNativeScreenState extends State<RazorPayNativeScreen> {
  late Razorpay _razorpay;
  late Map<String, dynamic> _options;
  bool _loadingPay = false;
  @override
  void initState() {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _createOption();

    super.initState();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _createOption() {
    _options = {
      'key': widget.apiKeyId,
      'amount': double.parse(widget.amount).round(),
      'name': widget.name,
      'currency': widget.currency,
      'order_id': widget.orderId,
      'description': ' ',
      'prefill': {'contact': widget.phone ?? ' ', 'email': widget.email ?? ' '}
    };
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Do something when payment succeeds
    Map<String, dynamic> data = {
      "razorpay_payment_id": response.paymentId ?? '',
      "razorpay_order_id": response.orderId ?? '',
      "razorpay_signature": response.signature ?? '',
      "gateway": "razorpay",
      "order_id": widget.orderIdCheckout,
      "order_key": widget.orderKey,
    };
    setState(() {
      _loadingPay = true;
    });
    try {
      dynamic confirmServer = await widget.progressServer(
        cartKey: widget.cartId,
        data: data,
      );
      setState(() {
        _loadingPay = true;
      });
      Navigator.of(context).pop(confirmServer);
    } catch (e) {
      setState(() {
        _loadingPay = true;
      });
      Navigator.of(context).pop();
      widget.callback(e);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    widget.callback(PaymentException(error: response.message ?? 'Payment error'));
    debugPrint(response.message);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    widget.callback(PaymentException(error: 'Please chose another method'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Center(
                        child: Image.asset(
                          "assets/images/razorpay.png",
                          package: "razorpay_native_gateway",
                          width: 150,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(widget.email ?? "",
                        style: const TextStyle(color: Colors.grey), maxLines: 1, textAlign: TextAlign.center),
                    RichText(
                      text: TextSpan(text: "Pay ", style: const TextStyle(color: Colors.grey), children: [
                        TextSpan(
                          text: "${double.parse(widget.amount).round()} ${widget.currency}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ]),
                    ),
                    const SizedBox(height: 30),
                    const DividerRazorPay(text: "Pay for order"),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        _razorpay.open(_options);
                      },
                      child: const Text("Pay Now"),
                    )
                  ],
                ),
              ),
            ),
            if (_loadingPay)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CupertinoActivityIndicator(),
                ),
              )
          ],
        ),
      ),
    );
  }
}
