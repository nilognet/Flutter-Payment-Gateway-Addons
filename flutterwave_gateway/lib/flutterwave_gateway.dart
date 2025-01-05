library flutterwave_gateway;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payment_base/payment_base.dart';

import 'widgets/flutterwave_native_screen.dart';

class FlutterwaveGateway implements PaymentBase {
  final String encryptionKey;

  FlutterwaveGateway({
    required this.encryptionKey,
  });

  /// Payment method key
  ///
  static const key = "rave";

  @override
  String get libraryName => "flutterwave_gateway";

  @override
  String get logoPath => "assets/images/rave.png";

  @override
  Future<void> initialized({
    required BuildContext context,
    required RouteTransitionsBuilder slideTransition,
    required Future<dynamic> Function(List<dynamic>) checkout,
    required Function(dynamic data) callback,
    required String amount,
    required String currency,
    required Map<String, dynamic> billing,
    required Map<String, dynamic> settings,
    required Future<dynamic> Function({String? cartKey, required Map<String, dynamic> data}) progressServer,
    required String cartId,
    required Widget Function(String url, BuildContext context, {String Function(String url)? customHandle})
    webViewGateway,
  }) async {
    try {
      final checkoutData = await checkout([]);
      int orderId = checkoutData["order_id"];
      dynamic result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, _, __) => FlutterwaveNativeScreen(
            amount: amount,
            currency: currency,
            encryptionKey: encryptionKey,
            billing: billing,
            settings: settings,
            orderId: orderId,
            cartId: cartId,
            callback: callback,
            progressServer: progressServer,
          ),
          transitionsBuilder: slideTransition,
        ),
      );
      if (result != null) {
          callback({
            'redirect': result['redirect'],
            'order_received_url': result['order_received_url'],
          });
      }
    } catch (e) {
      callback(e);
    }
  }

  @override
  String getErrorMessage(Map<String, dynamic>? error) {
    if (error == null) {
      return 'Something wrong in checkout!';
    }

    if (error['message'] != null) {
      return error['message'];
    }

    return 'Error!';
  }
}
