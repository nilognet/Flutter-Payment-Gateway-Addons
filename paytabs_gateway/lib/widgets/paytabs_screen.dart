import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paytabs_bridge/BaseBillingShippingInfo.dart';
import 'package:flutter_paytabs_bridge/IOSThemeConfiguration.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkApms.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkConfigurationDetails.dart';
import 'package:flutter_paytabs_bridge/flutter_paytabs_bridge.dart';
import 'package:payment_base/payment_base.dart';
import 'package:paytabs_gateway/helper.dart';

class PayTabsScreen extends StatefulWidget {
  const PayTabsScreen({
    Key? key,
    required this.amount,
    this.email,
    this.currency,
    required this.checkout,
    required this.checkoutData,
    required this.serverKeyForMobile,
    required this.clientKeyForMobile,
    required this.profileId,
    required this.merchantCountryCode,
    required this.callback,
    required this.progressServer,
    required this.orderId,
    required this.cartId,
  }) : super(key: key);
  final String? email;
  final String amount;
  final String? currency;
  final Map<String, dynamic> checkoutData;
  final Future<dynamic> Function(List<dynamic>) checkout;
  final String serverKeyForMobile;
  final String clientKeyForMobile;
  final String profileId;
  final String merchantCountryCode;
  final Function(dynamic data) callback;
  final Future<dynamic> Function({String? cartKey, required Map<String, dynamic> data}) progressServer;
  final String orderId;
  final String cartId;
  @override
  State<PayTabsScreen> createState() => _PayTabsScreenState();
}

class _PayTabsScreenState extends State<PayTabsScreen> {
  bool _isLoading = false;
  @override
  void initState() {
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
                          "assets/images/paytabs_logo.png",
                          package: "paytabs_gateway",
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
                          await _handlePayment();
                        },
                        child: const Text("Pay"))
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

  PaymentSdkConfigurationDetails _configData() {
    int orderId = get(widget.checkoutData, ["order_id"], "");
    var billingDetails = BillingDetails(
      "${get(widget.checkoutData, ["billing_address", "first_name"], "")} ${get(widget.checkoutData, [
            "billing_address",
            "last_name"
          ], "")}",
      get(widget.checkoutData, ["billing_address", "email"], ""),
      get(widget.checkoutData, ["billing_address", "phone"], ""),
      get(widget.checkoutData, ["billing_address", "address_1"], ""),
      get(widget.checkoutData, ["billing_address", "country"], ""),
      get(widget.checkoutData, ["billing_address", "city"], ""),
      get(widget.checkoutData, ["billing_address", "state"], ""),
      get(widget.checkoutData, ["billing_address", "postcode"], "12345"),
    );
    var shippingDetails = ShippingDetails(
      "${get(widget.checkoutData, ["billing_address", "first_name"], "")} ${get(widget.checkoutData, [
            "billing_address",
            "last_name"
          ], "")}",
      get(widget.checkoutData, ["billing_address", "email"], ""),
      get(widget.checkoutData, ["billing_address", "phone"], ""),
      get(widget.checkoutData, ["billing_address", "address_1"], ""),
      get(widget.checkoutData, ["billing_address", "country"], ""),
      get(widget.checkoutData, ["billing_address", "city"], ""),
      get(widget.checkoutData, ["billing_address", "state"], ""),
      get(widget.checkoutData, ["billing_address", "postcode"], "12345"),
    );
    List<PaymentSdkAPms> aPms = [];
    aPms.add(PaymentSdkAPms.AMAN);
    var configuration = PaymentSdkConfigurationDetails(
      profileId: widget.profileId,
      serverKey: widget.serverKeyForMobile,
      clientKey: widget.clientKeyForMobile,
      cartId: orderId.toString(),
      screentTitle: "Pay with Card",
      amount: double.tryParse(widget.amount),
      showBillingInfo: true,
      forceShippingInfo: false,
      currencyCode: widget.currency,
      merchantCountryCode: widget.merchantCountryCode,
      billingDetails: billingDetails,
      shippingDetails: shippingDetails,
      alternativePaymentMethods: aPms,
      linkBillingNameWithCardHolderName: true,
      cartDescription: orderId.toString(),
    );

    var theme = IOSThemeConfigurations();

    configuration.iOSThemeConfigurations = theme;

    return configuration;
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isLoading = true;
    });
    FlutterPaytabsBridge.startCardPayment(_configData(), (event) async {
      debugPrint(event.toString());
      if (event["status"] == "success") {
        var transactionDetails = event["data"];
        if (transactionDetails["isSuccess"]) {
          try {
            String query = "";
            Digest? digest;
            query = Uri(queryParameters: {
              "gateway": "paytabs_all",
              "isOnHold": ((get(event, ["data", "isOnHold"], false)) ? 1 : 0).toString(),
              "isPending": ((get(event, ["data", "isPending"], false)) ? 1 : 0).toString(),
              "isSuccess": ((get(event, ["data", "isSuccess"], false)) ? 1 : 0).toString(),
              "order_id": widget.orderId,
              "responseCode": get(event, ["data", "paymentResult", "responseCode"], ""),
              "responseMessage": get(event, ["data", "paymentResult", "responseMessage"], ""),
              "transactionReference": get(event, ["data", "transactionReference"], ""),
              "transactionType": get(event, ["data", "transactionType"], ""),
            }).query;
            List<int> messageBytes = utf8.encode(query);
            List<int> key = utf8.encode(widget.serverKeyForMobile);
            Hmac hMac = Hmac(sha256, key);
            digest = hMac.convert(messageBytes);
            dynamic confirmServer = await widget.progressServer(
              data: {
                "gateway": "paytabs_all",
                "isOnHold": (get(event, ["data", "isOnHold"], false)) ? 1 : 0,
                "isPending": (get(event, ["data", "isPending"], false)) ? 1 : 0,
                "isSuccess": (get(event, ["data", "isSuccess"], false)) ? 1 : 0,
                "order_id": widget.orderId,
                "responseCode": get(event, ["data", "paymentResult", "responseCode"], ""),
                "responseMessage": get(event, ["data", "paymentResult", "responseMessage"], ""),
                "transactionReference": get(event, ["data", "transactionReference"], ""),
                "transactionType": get(event, ["data", "transactionType"], ""),
                "signature": digest.toString(),
              },
              cartKey: widget.cartId,
            );
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop(confirmServer);
          } catch (e) {
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop();
            widget.callback(e);
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          widget.callback(PaymentException(error: "Failed transaction"));
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        widget.callback(PaymentException(error: get(event, ["message"], "")));
      }
    });
  }
}
