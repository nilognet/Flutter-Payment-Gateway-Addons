import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mercado_gateway/mercado_service.dart';

import 'package:mercado_pago_mobile_checkout/mercado_pago_mobile_checkout.dart';
import 'package:payment_base/payment_base.dart';

class MercadoNativeScreen extends StatefulWidget {
  const MercadoNativeScreen({
    Key? key,
    this.email,
    required this.amount,
    this.currency,
    required this.publicKey,
    required this.accessToken,
    required this.checkout,
    required this.callback,
    required this.orderId,
    required this.progressServer,
    required this.cartId,
  }) : super(key: key);
  final String? email;
  final String amount;
  final String? currency;
  final String publicKey;
  final String accessToken;
  final Future<dynamic> Function(List<dynamic>) checkout;
  final Function(dynamic data) callback;
  final String orderId;
  final Future<dynamic> Function({String? cartKey, required Map<String, dynamic> data}) progressServer;
  final String cartId;

  @override
  State<MercadoNativeScreen> createState() => _MercadoNativeScreenState();
}

class _MercadoNativeScreenState extends State<MercadoNativeScreen> {
  bool _isLoading = false;

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
                          "assets/images/mercado_logo.png",
                          package: "mercado_gateway",
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
                          text: "${widget.amount} ${widget.currency}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ]),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                        onPressed: () async {
                          String preferenceId = await _getPreferenceId();
                          try {
                            if (preferenceId.isNotEmpty) {
                              await _handleCheckout(preferenceId);
                            }
                          } catch (e) {
                            if (mounted) {
                              widget.callback(PaymentException(error: e.toString()));
                            }
                          }
                        },
                        child: const Text("Pay Now"))
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CupertinoActivityIndicator(
                    color: Colors.white,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckout(String preferenceId) async {
    PaymentResult result = await MercadoPagoMobileCheckout.startCheckout(
      widget.publicKey,
      preferenceId,
    );
    debugPrint(result.toString());
    if (result.status != null) {
      if (result.status == 'approved') {
        try {
          setState(() => _isLoading = true);
          dynamic confirmServer = await widget.progressServer(
            cartKey: widget.cartId,
            data: {
              'cart_key': widget.cartId,
              'order_id': widget.orderId,
              "paymentId": result.id.toString(),
              "gateway": "woo-mercado-pago-basic",
            }
          );
          setState(() => _isLoading = false);
          Navigator.of(context).pop(confirmServer);
        } catch (e) {
          Navigator.of(context).pop();
          widget.callback(e);
        }
      } else {
        widget.callback(PaymentException(error: result.errorMessage ?? result.status!));
      }
    } else {
      widget.callback(PaymentException(error: result.errorMessage ?? "Payment error"));
    }
  }

  Future<String> _getPreferenceId() async {
    setState(() => _isLoading = true);
    String preferenceId = "";
    try {
      preferenceId = await MercadoService.getPreferenceId(
          1, widget.currency ?? "ARS", widget.amount, widget.accessToken, widget.email ?? "", widget.orderId);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      widget.callback(PaymentException(error: "Error from Mercado server"));
    }
    return preferenceId;
  }
}
