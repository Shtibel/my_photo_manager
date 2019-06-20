import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:simple_auth_flutter/simple_auth_flutter.dart';

import 'models/model.dart';
import 'screens/home/home.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
    SimpleAuthFlutter.init(context);
  }

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
