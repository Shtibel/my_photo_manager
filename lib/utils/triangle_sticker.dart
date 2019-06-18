import 'package:flutter/material.dart';
import 'dart:math' as math;

class TriangleSticker extends StatelessWidget {

  dynamic photo;
  bool fromDB;

  int _width;
  int _height;
  bool _hasLabel = false;
  String _labelText;
  Color _labelColor;

  TriangleSticker(this.photo, this.fromDB);

  @override
  Widget build(BuildContext context) {

    if(fromDB){
      _width = photo['width'];
      _height = photo['height'];
    }else{
      _width = photo['images'][0]['width'];
      _height = photo['images'][0]['height'];
    }

    if(_width <= 300 || _height <= 300){
        _hasLabel = true;
        _labelText = "Can't\nPrint";
        _labelColor = Colors.red;
    }
    if((_width > 300 && _width <= 700) || (_height > 300 && _height <= 700)){
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