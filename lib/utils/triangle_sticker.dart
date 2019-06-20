import 'package:flutter/material.dart';
import 'dart:math' as math;

class TriangleSticker extends StatelessWidget {

  int width;
  int height;
  bool _hasLabel = false;
  String _labelText;
  Color _labelColor;

  TriangleSticker(this.width, this.height);

  @override
  Widget build(BuildContext context) {

    if(width <= 300 || height <= 300){
        _hasLabel = true;
        _labelText = "Can't\nPrint";
        _labelColor = Colors.red;
    }
    if((width > 300 && width <= 700) || (height > 300 && height <= 700)){
      _hasLabel = true;
      _labelText = "Low\nQuality";
      _labelColor = Theme.of(context).primaryColor;
    }
    
    return !_hasLabel ? Container() : Positioned(
            top: -50.0,
            right: -50.0,
            child: Transform.rotate(
              angle: math.pi / 4.0,
              child: Container(
                alignment: Alignment.bottomCenter,
                width: 100,
                height: 100,
                padding: EdgeInsets.only(bottom: 5.0),
                color: _labelColor,
                child: Text(
                  _labelText,
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
  }
}