library paytabs_gateway;

import 'package:flutter/widgets.dart';
import 'package:payment_base/payment_base.dart';
import 'package:paytabs_gateway/helper.dart';
import 'package:paytabs_gateway/widgets/paytabs_screen.dart';

class PayTabsGateway implements PaymentBase {
  final String serverKeyForMobile;
  final String clientKeyForMobile;
  final String merchantCountryCode;
  PayTabsGateway({
    required this.serverKeyForMobile,
    required this.clientKeyForMobile,
    required this.merchantCountryCode,
  });

  /// Payment method key
  ///
  static const key = "paytabs_all";

  @override
  String get libraryName => "paytabs_gateway";

  @override
  String get logoPath => "assets/images/paytabs_logo.png";

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
    debugPrint(checkoutData.toString());
    debugPrint("CartId: $cartId");
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) => PayTabsScreen(
          amount: amount,
          email: checkoutData["billing_address"]["email"],
          currency: currency,
          checkout: checkout,
          checkoutData: checkoutData,
          serverKeyForMobile: serverKeyForMobile,
          clientKeyForMobile: clientKeyForMobile,
          profileId: get(settings, ["profile_id", "value"], ""),
          merchantCountryCode: merchantCountryCode,
          callback: callback,
          progressServer: progressServer,
          orderId: orderId.toString(),
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
