import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';
import 'package:myfatoorah_flutter/utils/MFEnvironment.dart';
import 'package:myfatoorah_gateway/my_fatoorah/fatoorah_function.dart';
import 'package:myfatoorah_gateway/my_fatoorah/helper.dart';
import 'package:myfatoorah_gateway/my_fatoorah/widgets/card_form.dart';
import 'package:myfatoorah_gateway/my_fatoorah/widgets/card_label.dart';
import 'package:myfatoorah_gateway/my_fatoorah/widgets/divider.dart';
import 'package:payment_base/payment_base.dart';

const int _visaPaymentId = 20;

class MyFatoorahPage extends StatefulWidget {
  final String orderId;
  final String amount;
  final String currencyCode;
  final String apiKey;
  final Future<dynamic> Function({String? cartKey, required Map<String, dynamic> data}) progressServer;
  final Function(dynamic data) callback;
  final String cartId;

  const MyFatoorahPage({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.currencyCode,
    required this.apiKey,
    required this.progressServer,
    required this.callback,
    required this.cartId,
  }) : super(key: key);

  @override
  State<MyFatoorahPage> createState() => _MyFatoorahPageState();
}

class _MyFatoorahPageState extends State<MyFatoorahPage> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardMonthController = TextEditingController();
  final TextEditingController _cardYearController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();

  final List<PaymentMethods> _paymentMethods = [];
  bool _loadingMethod = true;
  bool _loadingPay = false;

  @override
  void initState() {
    super.initState();
    MFSDK.init(widget.apiKey, FatoorahHelper.codeToCountry(widget.currencyCode), MFEnvironment.TEST);

    initiatePayment();
    initiateSession();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Payment"),
            centerTitle: true,
            automaticallyImplyLeading: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const DividerFatoorah(text: "Pay With"),
                    (_loadingMethod)
                        ? const CupertinoActivityIndicator()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _paymentMethods.length,
                            itemBuilder: (context, index) {
                              if (_paymentMethods[index].isDirectPayment != null) {
                                if (_paymentMethods[index].isDirectPayment!) {
                                  return const SizedBox.shrink();
                                }
                              }
                              return CardLabelFatoorah(
                                labelUrl: _paymentMethods[index].imageUrl,
                                label: _paymentMethods[index].paymentMethodEn,
                                amount: _paymentMethods[index].totalAmount,
                                unit: _paymentMethods[index].currencyIso,
                                onTap: () {
                                  pay(paymentMethodId: _paymentMethods[index].paymentMethodId, isDirectMethod: false);
                                },
                              );
                            },
                          ),
                    const DividerFatoorah(text: "Or Insert Card Details"),
                    CardFormFatoorah(
                      cardUrl: (_paymentMethods.isNotEmpty)
                          ? _paymentMethods.firstWhere((element) {
                              if (element.isDirectPayment != null) {
                                return (element.isDirectPayment!);
                              }
                              return false;
                            }).imageUrl
                          : null,
                      cardNumberController: _cardNumberController,
                      cardMonthController: _cardMonthController,
                      cardYearController: _cardYearController,
                      cardCvvController: _cardCvvController,
                      cardNameController: _cardNameController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                pay(paymentMethodId: _visaPaymentId, isDirectMethod: true);
              },
              child: const Text("Pay Now"),
            ),
          ),
        ),
        if (_loadingPay)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CupertinoActivityIndicator(),
            ),
          )
      ],
    );
  }

  void initiatePayment() {
    try {
      var request = MFInitiatePaymentRequest(double.parse(widget.amount), widget.currencyCode);
      MFSDK.initiatePayment(
          request,
          MFAPILanguage.EN,
          (MFResult<MFInitiatePaymentResponse> result) => {
                if (result.isSuccess())
                  {
                    setState(() {
                      if (result.response?.paymentMethods != null) {
                        _paymentMethods.addAll(result.response!.paymentMethods!.toList());
                      }
                      _loadingMethod = false;
                    })
                  }
                else
                  {
                    setState(() {
                      _loadingMethod = false;
                      widget.callback(PaymentException(error: result.error?.toJson().toString() ?? ""));
                    })
                  }
              });
    } catch (_) {
      setState(() {
        _loadingMethod = false;
      });
    }
  }

  void pay({required int? paymentMethodId, required bool isDirectMethod}) {
    if (paymentMethodId != null) {
      setState(() {
        _loadingPay = true;
      });
      if (isDirectMethod) {
        bool check = FatoorahFunction.formCardValidator(_cardNumberController.text, _cardCvvController.text,
            _cardMonthController.text, _cardYearController.text, _cardNameController.text);
        if (check) {
          executeDirectPayment(_visaPaymentId);
        } else {
          widget.callback(PaymentException(error: "You have not filled in the information completely"));
        }
      } else {
        executeRegularPayment(paymentMethodId);
      }
    }
  }

  /*
    Execute Regular Payment
   */
  void executeRegularPayment(int paymentMethodId) {
    var request = MFExecutePaymentRequest(paymentMethodId, double.parse(widget.amount));
    request.displayCurrencyIso = widget.currencyCode;
    request.customerReference = widget.orderId;
    MFSDK.executePayment(context, request, MFAPILanguage.EN,
        onPaymentResponse: (String invoiceId, MFResult<MFPaymentStatusResponse> result) async {
      if (result.isSuccess()) {
        try {
          List<dynamic> transaction = get(result.response?.toJson(), ["InvoiceTransactions"], []);
          dynamic confirmServer = await widget.progressServer(
            data: {
              "oid": widget.orderId,
              "paymentId": transaction.first["PaymentId"],
              "gateway": "myfatoorah_v2",
              'cart_key': widget.cartId,
              'order_id': widget.orderId,
            },
            cartKey: widget.cartId,
          );
          setState(() {
            _loadingPay = false;
          });
          Navigator.of(context).pop(confirmServer);
        } catch (e) {
          setState(() {
            _loadingPay = false;
          });
          Navigator.of(context).pop();
          widget.callback(e);
        }
      } else {
        setState(() {
          _loadingPay = false;
        });
        widget.callback(PaymentException(error: result.error?.message ?? ""));
      }
    });
  }

  /*
    Execute Direct Payment
   */
  void executeDirectPayment(int paymentMethodId) {
    var request = MFExecutePaymentRequest(paymentMethodId, double.parse(widget.amount));
    request.customerReference = widget.orderId;
    request.displayCurrencyIso = widget.currencyCode;
    var mfCardInfo = MFCardInfo(
        cardNumber: _cardNumberController.text,
        expiryMonth: _cardMonthController.text,
        expiryYear: _cardYearController.text,
        securityCode: _cardCvvController.text,
        cardHolderName: _cardNameController.text,
        bypass3DS: false,
        saveToken: true);

    MFSDK.executeDirectPayment(context, request, mfCardInfo, MFAPILanguage.EN,
        (String invoiceId, MFResult<MFDirectPaymentResponse> result) async {
      if (result.isSuccess()) {
        try {
          List<dynamic> transaction =
              get(result.response?.toJson(), ["mfPaymentStatusResponse", "InvoiceTransactions"]);
          dynamic confirmServer = await widget.progressServer(
            data: {
              "oid": widget.orderId,
              "paymentId": transaction.first["PaymentId"],
              "gateway": "myfatoorah_v2",
              "cart_key": widget.cartId,
              "order_id": widget.orderId,
            },
            cartKey: widget.cartId,
          );
          setState(() {
            _loadingPay = false;
          });
          Navigator.of(context).pop(confirmServer);
        } catch (e) {
          setState(() {
            _loadingPay = false;
          });
          Navigator.of(context).pop();
          widget.callback(e);
        }
      } else {
        setState(() {
          _loadingPay = false;
        });
        widget.callback(PaymentException(error: result.error?.message ?? ""));
      }
    });
  }

  void initiateSession() {
    MFSDK.initiateSession(null, (MFResult<MFInitiateSessionResponse> result) => {});
  }
}
