import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../models/model.dart';
import 'widget_buttom.dart';

class ScreenHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppModel>(
      model: AppModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Photo manager'),
        ),
        bottomNavigationBar: HomeWidgetBottom(),
      ),
    );
  }
}
