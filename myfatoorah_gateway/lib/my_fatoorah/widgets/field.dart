
import 'package:flutter/material.dart';
import 'package:myfatoorah_gateway/my_fatoorah/widgets/cache_image.dart';

class FieldFatoorah extends StatelessWidget {
  const FieldFatoorah({
    Key? key,
    this.width,
    required this.controller,
    this.labelText,
    this.suffixUrl,
    this.validator,
    this.textInputType,
    this.maxLength,
  }) : super(key: key);
  final double? width;
  final TextEditingController controller;
  final String? labelText;
  final String? suffixUrl;
  final Function(String? value)? validator;
  final TextInputType? textInputType;
  final int? maxLength;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Center(
        child: TextFormField(
          validator: (value) {
            if (validator != null) {
              return validator!(value);
            }
            return null;
          },
          maxLength: maxLength,
          keyboardType: textInputType,

          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.withOpacity(0.2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            counterText: "",
            labelText: labelText ?? "",
            labelStyle: const TextStyle(
              color: Colors.grey,
            ),
            suffixIcon: (suffixUrl != null)
                ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: CacheImage(
                      suffixUrl,
                      width: 40,
                      fit: BoxFit.fill,
                    ),
                )
                : const SizedBox.shrink(),
          ),
          controller: controller,
        ),
      ),
    );
  }
}
