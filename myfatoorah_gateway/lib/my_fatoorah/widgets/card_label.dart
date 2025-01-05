import 'package:flutter/material.dart';
import 'package:myfatoorah_gateway/my_fatoorah/color.dart';
import 'package:myfatoorah_gateway/my_fatoorah/widgets/cache_image.dart';

class CardLabelFatoorah extends StatelessWidget {
  const CardLabelFatoorah({
    Key? key,
    required this.labelUrl,
    required this.label,
    this.onTap,
    this.amount,
    this.unit,
  }) : super(key: key);
  final String? labelUrl;
  final String? label;
  final Function()? onTap;
  final double? amount;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 60,
          width: width,
          decoration: BoxDecoration(
            color: ColorBlock.gray1,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              )
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: CacheImage(
                  labelUrl,
                  width: 80,
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 120,
                child: Text(
                  label ?? "",
                  maxLines: 2,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              Expanded(
                  child: RichText(
                textAlign: TextAlign.end,
                maxLines: 2,
                text: TextSpan(
                    style: const TextStyle(
                        color: ColorBlock.black, fontWeight: FontWeight.bold),
                    text: (amount ?? 0.0).toStringAsFixed(2),
                    children: [TextSpan(text: "  $unit")]),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
