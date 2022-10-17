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

class LoginHeaderCustomClipPath extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    Path path0 = Path();
    path0.moveTo(0,0);
    path0.lineTo(0,size.height*0.8814286);
    path0.quadraticBezierTo(size.width*0.2841667,size.height*-0.0146429,size.width*0.4983333,size.height*0.4828571);
    path0.quadraticBezierTo(size.width*0.7050000,size.height*0.9542857,size.width,size.height*0.4371429);
    path0.lineTo(size.width,0);
    path0.close();
    return path0;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}