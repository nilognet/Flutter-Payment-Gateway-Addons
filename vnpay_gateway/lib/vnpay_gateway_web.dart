library vnpay_gateway;

import 'package:flutter/widgets.dart';
import 'package:payment_base/payment_base.dart';
import 'widgets/vnpay.dart';

class VnpayGatewayWeb implements PaymentBase {
  /// Payment method key
  ///
  static const key = "vnpay";

  @override
  String get libraryName => "vnpay_gateway";

  @override
  String get logoPath => "assets/images/vnpay.png";

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
      dynamic data = await checkout([]);

      dynamic result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, _, __) => VnpayGateway(
            data: data,
            webViewGateway: webViewGateway,
          ),
          transitionsBuilder: slideTransition,
        ),
      );

      Map<String, dynamic> backData = {};

      if (result == null) {
        backData = {'redirect': 'checkout'};
      }

      if (result is Map<String, dynamic> && result['order_received_url'] != null) {
        dynamic confirmServer = await progressServer(
          data: {
            'cart_key': cartId,
            'action': 'clean',
          },
          cartKey: cartId,
        );
        backData = {
          'redirect': confirmServer['redirect'],
          'order_received_url': result['order_received_url'],
        };
      }

      callback(backData);
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
