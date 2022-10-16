import 'package:flutter/material.dart';

class HomeHeaderCustomClipPath extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height*0.1); //vertical line
    path.cubicTo(size.width/4, size.height, 2*size.width/3, size.height*0.5, size.width, size.height*0.25); //cubic curve
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}