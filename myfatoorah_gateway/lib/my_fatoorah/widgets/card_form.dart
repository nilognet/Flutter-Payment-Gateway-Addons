
import 'package:flutter/material.dart';
import 'package:myfatoorah_gateway/my_fatoorah/widgets/field.dart';

class CardFormFatoorah extends StatelessWidget {
  const CardFormFatoorah({
    Key? key,
    required this.cardNumberController,
    required this.cardMonthController,
    required this.cardYearController,
    required this.cardCvvController,
    required this.cardNameController,
    this.cardUrl,
  }) : super(key: key);
  final TextEditingController cardNumberController;
  final TextEditingController cardMonthController;
  final TextEditingController cardYearController;
  final TextEditingController cardCvvController;
  final TextEditingController cardNameController;
  final String? cardUrl;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        FieldFatoorah(
          controller: cardNumberController,
          suffixUrl: cardUrl,
          labelText: "Card number",
          textInputType: TextInputType.number,
        ),
        const SizedBox(height: 10,),
        Row(
          children: [
            FieldFatoorah(
              width: width * 0.3,
              controller: cardCvvController,
              textInputType: TextInputType.number,
              labelText: "CVV",
            ),
            const Spacer(),
            FieldFatoorah(
              width: 100,
              controller: cardMonthController,
              textInputType: TextInputType.number,
              labelText: "MM",
              maxLength: 2,
            ),
            const SizedBox(width: 10,),
            FieldFatoorah(
              width: 100,
              controller: cardYearController,
              textInputType: TextInputType.number,
              labelText: "YY",
              maxLength: 2,
            ),
          ],
        ),
        const SizedBox(height: 10,),
        FieldFatoorah(
          controller: cardNameController,
          labelText: "Name on card",
          textInputType: TextInputType.text,
        ),
      ],
    );
  }
}
