import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_photo_manager/services/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/model.dart';

class AppAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Map<String, dynamic>> actions;
  final List<Widget> actionList = [];

  AppAlertDialog({this.title, this.content, this.actions});

  @override
  Widget build(BuildContext context) {
    actions.forEach((action) {
      print(action);
      if (action['buttonAction'] == 'close') {
        actionList.add(
          FlatButton(
              child: Text(action['buttonText'], style: TextStyle(color: Theme.of(context).accentColor),),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        );
      }
      if (action['buttonAction'] == 'addAnyway') {
        var item = action['buttonItem'];
        actionList.add(
            ScopedModelDescendant<AppModel>(builder: (context, child, model) {
          return FlatButton(
              child: Text(action['buttonText']),
              onPressed: () {
                model.addItem(item, addAnyway: true);
                Provider.of(context).value += 1;
                Navigator.of(context).pop();
              });
        }));
      }
    });

    return Theme.of(context).platform == TargetPlatform.iOS
        ? CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: actionList,
        )
        : AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: actionList,
          );
  }
}
