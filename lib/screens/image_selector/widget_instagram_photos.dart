import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';

import '../../services/instagram_login.dart';

class InstagramPhotos extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InstagramPhotosState();
  }
}

class _InstagramPhotosState extends State<InstagramPhotos> {
  @override
  void initState() {
    super.initState();

    _loadInstagramImages();
  }

  Future<void> _loadInstagramImages({bool refechFromInstagram = false}) async {

    //final SharedPreferences prefs = await SharedPreferences.getInstance();

    print('aaaaaaa');

    AppInstagramLogin _appInstagramLogin = AppInstagramLogin();

    _appInstagramLogin.getToken('17e501e7410b4d9eafb027d4932d34ca', '75f8341a45e949eeaaca7d59af41cfd8').then((Token token) {
      print('token: '+token.access);
      print(token.access);
    });


    // dynamic instagramResult = await _appInstagramLogin.getToken('17e501e7410b4d9eafb027d4932d34ca', '75f8341a45e949eeaaca7d59af41cfd8');
    // print(instagramResult);


  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}