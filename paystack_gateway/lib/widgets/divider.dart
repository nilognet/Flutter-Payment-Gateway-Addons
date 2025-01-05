import 'package:flutter/material.dart';

class DividerPayStack extends StatelessWidget {
  const DividerPayStack({Key? key,required this.text}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    double width = (text.length * 7) + 5;
    if(width > (maxWidth * 0.8)){
      width = maxWidth * 0.8;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
      ),
      child: Row(
        children: [
          Expanded(child: Container(height: 1,color: Colors.grey)),
          Container(
            width: width,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Text(
                text,
                maxLines: 1,
              ),
            ),
          ),
          Expanded(child: Container(height: 1,color: Colors.grey)),
        ],
      ),
    );
  }
}