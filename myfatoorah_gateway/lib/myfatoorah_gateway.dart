library myfatoorah_gateway;

import 'package:flutter/material.dart';
import 'package:myfatoorah_gateway/my_fatoorah/helper.dart';
import 'package:myfatoorah_gateway/my_fatoorah/my_fatoorah.dart';
import 'package:payment_base/payment_base.dart';

class MyFatoorahGateway implements PaymentBase {
  /// Payment method key
  ///
  static const key = "myfatoorah_v2";

  @override
  String get libraryName => "myfatoorah_gateway";

  @override
  String get logoPath => "assets/images/myfatoorah_v2.png";

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
    dynamic checkoutData;
    try {
      checkoutData = await checkout([]);
    } catch (e) {
      callback(e);
      return;
    }
    int orderId = checkoutData["order_id"];
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) => MyFatoorahPage(
          orderId: orderId.toString(),
          amount: amount,
          currencyCode: currency,
          apiKey: get(settings, ["apiKey", "value"]),
          progressServer: progressServer,
          callback: callback,
          cartId: cartId,
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
