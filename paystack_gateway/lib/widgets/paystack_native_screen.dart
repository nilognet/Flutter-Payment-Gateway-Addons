import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:payment_base/payment_base.dart';
import 'package:paystack_gateway/widgets/divider.dart';
import 'package:paystack_gateway/widgets/method_label.dart';

class PayStackNativeScreen extends StatefulWidget {
  const PayStackNativeScreen({
    Key? key,
    required this.amount,
    this.email,
    this.currency,
    required this.orderId,
    required this.publicKey,
    required this.checkout,
    required this.orderKey,
    required this.progressServer,
    required this.callback,
    required this.cartId,
  }) : super(key: key);
  final String? email;
  final String amount;
  final String? currency;
  final String orderId;
  final String publicKey;
  final String orderKey;
  final Function(CheckoutResponse response) checkout;
  final Future<dynamic> Function({String? cartKey, required Map<String, dynamic> data}) progressServer;
  final Function(dynamic data) callback;
  final String cartId;
  @override
  State<PayStackNativeScreen> createState() => _PayStackNativeScreenState();
}

class _PayStackNativeScreenState extends State<PayStackNativeScreen> {
  bool _isLoading = false;
  final plugin = PaystackPlugin();
  String _ref = "";
  @override
  void initState() {
    plugin.initialize(publicKey: widget.publicKey);
    super.initState();
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
                          "assets/images/pay_stack_logo.png",
                          package: "paystack_gateway",
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
                    const DividerPayStack(text: "Pay with"),
                    const SizedBox(height: 30),
                    MethodLabelPayStack(
                      text: "Card",
                      icon: Icons.credit_card,
                      onTap: () {
                        _handleCheckout(context, CheckoutMethod.card);
                      },
                    ),
                    const SizedBox(height: 30),
                    MethodLabelPayStack(
                      text: "Bank",
                      icon: Icons.account_balance,
                      onTap: () {
                        _handleCheckout(context, CheckoutMethod.bank);
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
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

  _handleCheckout(BuildContext context, CheckoutMethod method) async {
    setState(() => _isLoading = true);
    try {
      Charge charge = Charge()
        ..amount = double.parse(widget.amount).round() * 100 // In base currency
        ..email = widget.email
        ..card = PaymentCard(
          number: "",
          cvc: "",
          expiryMonth: 0,
          expiryYear: 0,
        )
        ..currency = widget.currency;
      if (method == CheckoutMethod.bank) {
        charge.accessCode = _getReference();
        _ref = charge.accessCode ?? "";
      } else {
        charge.reference = _getReference();
        _ref = charge.reference ?? "";
      }
      CheckoutResponse response = await plugin.checkout(
        context,
        method: method,
        charge: charge,
        fullscreen: false,
        logo: const Icon(Icons.payment),
      );
      debugPrint('Response = $response');
      if (response.status) {
        try {
          dynamic confirmServer = await widget.progressServer(
            data: {
              "order_id": widget.orderId,
              "gateway": "paystack",
              "paystack_txnref": _ref,
              'cart_key': widget.cartId,
            },
            cartKey: widget.cartId,
          );
          setState(() => _isLoading = false);
          Navigator.of(context).pop(confirmServer);
        } catch (e) {
          setState(() => _isLoading = false);
          Navigator.of(context).pop();
          widget.callback(e);
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          widget.callback(PaymentException(error: response.message));
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      widget.callback(PaymentException(error: e.toString()));
    }
  }

  String _getReference() {
    return '${widget.orderId}_${double.parse((DateTime.now().millisecondsSinceEpoch / 1000).toString()).round()}';
  }
}
