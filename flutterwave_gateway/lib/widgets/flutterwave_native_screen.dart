import 'package:flutter/material.dart';
import 'package:flutterwave/core/flutterwave_error.dart';
import 'package:flutterwave/flutterwave.dart';
import 'package:flutterwave/models/responses/charge_card_response/charge_card_response_data.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:payment_base/payment_base.dart';

import '../helper.dart';

class FlutterwaveNativeScreen extends StatefulWidget {
  const FlutterwaveNativeScreen({
    Key? key,
    required this.amount,
    required this.currency,
    required this.encryptionKey,
    required this.orderId,
    required this.cartId,
    required this.billing,
    required this.settings,
    required this.callback,
    required this.progressServer,
  }) : super(key: key);
  final String amount;
  final String currency;
  final String encryptionKey;
  final int orderId;
  final String cartId;
  final Map<String, dynamic> billing;
  final Map<String, dynamic> settings;
  final Function(dynamic data) callback;
  final Future<dynamic> Function({String? cartKey, required Map<String, dynamic> data}) progressServer;

  @override
  FlutterwaveNativeScreenState createState() => FlutterwaveNativeScreenState();
}

class FlutterwaveNativeScreenState extends State<FlutterwaveNativeScreen> {
  late bool testMode;
  late String testPublicKey;
  late String livePublicKey;
  late String email;
  late String fullName;
  late String phoneNumber;
  late String dateTime;
  bool loading = false;
  @override
  void initState() {
    testMode = get(widget.settings, ['go_live', 'value'], '') == "yes";

    ///Rave Test Key
    testPublicKey = get(widget.settings, ['test_public_key', 'value'], '');

    ///Rave lave Key
    livePublicKey = get(widget.settings, ['live_public_key', 'value'], '');

    email = get(widget.billing, ["email"], '');

    fullName = "${get(widget.billing, ["first_name"], '')} ${get(widget.billing, ["last_name"], '')}";

    phoneNumber = get(widget.billing, ["phone"], '');

    dateTime = "${double.parse((DateTime.now().millisecondsSinceEpoch / 1000).toString()).round()}";
    super.initState();
  }

  void openFlutterwave() async {
    try {
      Flutterwave flutterwave = Flutterwave.forUIPayment(
        amount: widget.amount,
        context: context,
        currency: widget.currency,
        publicKey: !testMode ? testPublicKey : livePublicKey,
        encryptionKey: widget.encryptionKey,
        email: email,
        phoneNumber: phoneNumber,
        fullName: fullName,
        isDebugMode: !testMode,
        txRef: "WOOC_${widget.orderId}_$dateTime",
        acceptCardPayment: true,
        acceptAccountPayment: true,
        acceptBankTransfer: true,
        acceptUSSDPayment: true,
      );
      try {
        ChargeResponse chargeResponse = await flutterwave.initializeForUiPayments();
        if (chargeResponse.data!.status != null) {
          ChargeResponseData? result = chargeResponse.data;
          try {
            setState(() {
              loading = true;
            });
          dynamic confirmServer = await widget.progressServer(
              data: {
                "gateway": "rave",
                "txRef": "${result?.txRef}",
                "cart_key": widget.cartId,
              },
              cartKey: widget.cartId,
            );
            setState(() {
              loading = false;
            });
            Navigator.of(context).pop(confirmServer);
          } catch (e) {
            debugPrint('$e');
          }
        }
      } catch (e) {
        debugPrint('Error:$e');
      }
    } catch (e) {
      if (e is FlutterWaveError) {
        widget.callback(PaymentException(error: e.message));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Info'),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.chevron_left, size: 26),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Table(
                border: TableBorder.all(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.black26,
                ),
                columnWidths: const <int, TableColumnWidth>{
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: <TableRow>[
                  buildItem('full name', fullName),
                  buildItem('email', email),
                  buildItem('phone number', phoneNumber),
                  buildItem('amount', widget.amount),
                  buildItem('currency', widget.currency),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(150, 48)),
              onPressed: loading ? null : () => openFlutterwave(),
              child: const Text('Continue'),
            ),
            if (loading) ...[
              AlertDialog(
                content: Row(
                  children: const [
                    CircularProgressIndicator(
                      backgroundColor: Colors.orangeAccent,
                    ),
                    SizedBox(width: 20),
                    Text(
                      'Loading...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  TableRow buildItem(String title, String subTitle) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(title),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(subTitle),
      ),
    ]);
  }
}
