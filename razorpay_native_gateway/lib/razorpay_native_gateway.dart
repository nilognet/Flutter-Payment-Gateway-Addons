library razorpay_native_gateway;

import 'package:flutter/widgets.dart';
import 'package:payment_base/payment_base.dart';
import 'package:razorpay_native_gateway/helper.dart';
import 'package:razorpay_native_gateway/widgets/razorpay_native_screen.dart';

class RazorPayNativeGateway implements PaymentBase {
  /// Payment method key
  ///
  static const key = "razorpay";

  @override
  String get libraryName => "razorpay_native_gateway";

  @override
  String get logoPath => "assets/images/razorpay.png";

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
    required Widget Function(String url, BuildContext context) webViewGateway,
  }) async {
    dynamic checkoutData;
    try {
      checkoutData = await checkout([]);
    } catch (e) {
      callback(e);
      return;
    }
    List<dynamic> paymentData = getData(checkoutData, ['payment_result', 'payment_details'], []);
    String orderId = paymentData.firstWhere((element) => getData(element, ['key'], '') == 'razorpayOrderId')['value'];
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) => RazorPayNativeScreen(
          amount: amount,
          phone: getData(checkoutData, ["billing_address","phone"], ''),
          email: getData(checkoutData, ["billing_address","email"], ''),
          currency: currency,
          orderId: orderId,
          orderIdCheckout: (checkoutData["order_id"] ?? '').toString(),
          apiKeyId: getData(settings, ['key_id', 'value'], ''),
          progressServer: progressServer,
          callback: callback,
          cartId: cartId,
          orderKey: checkoutData["order_key"] ?? '',
          name: '${getData(checkoutData, ['billing_address', 'first_name'], '')} ${getData(checkoutData, [
                'billing_address',
                'last_name'
              ], '')}',
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
