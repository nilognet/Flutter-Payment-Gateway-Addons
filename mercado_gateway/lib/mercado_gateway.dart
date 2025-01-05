library mercado_gateway;

import 'package:flutter/widgets.dart';
import 'package:mercado_gateway/widgets/mercado_native_screen.dart';
import 'package:payment_base/payment_base.dart';
class MercadoGateway implements PaymentBase {
  MercadoGateway({required this.publicKey,required this.accessToken});

  final String publicKey;
  final String accessToken;
  /// Payment method key
  ///
  static const key = "woo-mercado-pago-basic";

  @override
  String get libraryName => "mercado_gateway";

  @override
  String get logoPath => "assets/images/mercado_logo.png";

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
    try{
      checkoutData = await checkout([]);
    }catch(e){
      callback(e);
      return;
    }
    int orderId = checkoutData["order_id"];
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) => MercadoNativeScreen(
          amount: amount,
          email: billing["email"],
          currency: currency,
          publicKey: publicKey,
          checkout: checkout,
          accessToken: accessToken,
          callback: callback,
          orderId: orderId.toString(),
          progressServer: progressServer,
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
