
import 'package:flutter/material.dart';

class CacheImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;

  final BoxFit fit;

  final Color color;

  const CacheImage(
      this.url, {
        Key? key,
        this.width,
        this.height,
        this.fit = BoxFit.cover,
        this.color = Colors.transparent,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Image.network(
      url != null && url!.isNotEmpty ? url! : "",
      width: width,
      height: height,
      errorBuilder: (context, url, error) => const Text("Loading error"),
    );
  }
}
