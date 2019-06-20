import 'package:flutter/material.dart';

import '../image_selector/image_selector.dart';

class HomeWidgetBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
          child: ButtonTheme(
            height: 70.0,
            child: RaisedButton(
              padding: EdgeInsets.only(bottom: 15.0, top: 10.0),
              child: Text(
                'START',
                style: TextStyle(color: Colors.white),
              ),
              color: Theme.of(context).accentColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScreenImageSelector()),
                );
              },
            ),
          ),
        );
  }
}