import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'models/model.dart';
import 'screens/home/home.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppModel>(
      model: AppModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ScreenHome())
    );
  }
}
