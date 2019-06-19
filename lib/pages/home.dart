import 'package:flutter/material.dart';
import 'package:my_photo_manager/models/model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'image_selector.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppModel>(
      model: AppModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Photo manager'),
        ),
        bottomNavigationBar: Container(
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
                  MaterialPageRoute(builder: (context) => ImageSelector()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
