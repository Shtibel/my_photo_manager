import 'package:flutter/material.dart';
import 'dart:math' as math;

class TriangleSticker extends StatelessWidget {
  int width;
  int height;
  bool _hasLabel = false;
  bool _cantPrint = false;
  String _labelText;
  Color _labelColor;

  TriangleSticker(this.width, this.height);

  @override
  Widget build(BuildContext context) {
    if (width <= 300 || height <= 300) {
      _hasLabel = true;
      _cantPrint = true;
      _labelText = "Can't\nPrint";
      _labelColor = Colors.red;
    }
    if ((width > 300 && width <= 700) || (height > 300 && height <= 700)) {
      _hasLabel = true;
      _labelText = "Low\nQuality";
      _labelColor = Theme.of(context).primaryColor;
    }

    final int size = MediaQuery.of(context).size.width ~/
        3; // gets the width of the display and divides it by the number of images per row

    return !_hasLabel
        ? Container()
        : Stack(
            children: <Widget>[
              !_cantPrint ? Container() : Container(
                width: size.toDouble(),
                height: size.toDouble(),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.7),
                ),
              ),
              Positioned(
                top: -50.0,
                right: -50.0,
                child: Transform.rotate(
                  angle: math.pi / 4.0,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    width: 100,
                    height: 100,
                    padding: EdgeInsets.only(bottom: 6.0),
                    color: _labelColor,
                    child: Text(
                      _labelText,
                      style: TextStyle(color: Colors.white, height: 0.8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            ],
          );
  }
}
