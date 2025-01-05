import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class MercadoService {
  static Future<String> getPreferenceId(
      int quantity, String currency, String price, String accessToken, String email,
      String orderId) async {
    dynamic body = {
      "items": [
        {
          "quantity": 1,
          "currency_id": currency,
          "unit_price": double.tryParse(price) ?? 0.0,
        }
      ],
      "payer": {"email": email},
      "external_reference": orderId
    };
    try {
      final response = await http.post(
        Uri.parse("https://api.mercadopago.com/checkout/preferences?access_token=$accessToken"),
        body: jsonEncode(body),
      );
      debugPrint("pre res: ${jsonDecode(response.body)}");
      return jsonDecode(response.body)['id'];
    } catch (e) {
      rethrow;
    }
  }
}
