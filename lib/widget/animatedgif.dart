import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';

class AnimatedGifWidget extends StatefulWidget {
  final double? width;
  final double? height;

  // Accept optional width and height as parameters
  const AnimatedGifWidget({Key? key,  required this.width, required this.height}) : super(key: key);

  @override
  _AnimatedGifWidgetState createState() => _AnimatedGifWidgetState();
}

class _AnimatedGifWidgetState extends State<AnimatedGifWidget> with SingleTickerProviderStateMixin {
  late FlutterGifController gifController;

  @override
  void initState() {
    super.initState();
    gifController = FlutterGifController(vsync: this);
    
    gifController.repeat(min: 0, max: 100, period: const Duration(seconds: 3)); // Adjust frames and duration
  }

  @override
  void dispose() {
    gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use widget.width and widget.height for dynamic sizing
    double dynamicWidth = widget.width ?? MediaQuery.of(context).size.width * 0.1;
    double dynamicHeight = widget.height ?? MediaQuery.of(context).size.width * 0.1;

    return GifImage(
      controller: gifController,
      image: const AssetImage('assets/images/coin.gif'),
      width: dynamicWidth,
      height: dynamicHeight,
    );
  }
}
