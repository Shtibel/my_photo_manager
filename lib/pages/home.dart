import 'package:flutter/material.dart';
import 'image_selector.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo manager'),
      ),
      bottomNavigationBar: Container(
        child: ButtonTheme(
          height: 50.0,
          child: RaisedButton(
            child: Text(
              'START',
              style: TextStyle(color: Colors.white),
            ),
            color: Theme.of(context).accentColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageSelector()),
              );
            },
          ),
        ),
      ),
    );
  }
}
