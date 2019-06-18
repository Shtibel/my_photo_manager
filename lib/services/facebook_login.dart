import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppFacebookLogin {

  Future<Map<String, dynamic>> login() async {
    final facebookLogin = FacebookLogin();
    final FacebookLoginResult result = await facebookLogin.logInWithReadPermissions(['email', 'user_photos']);
    var returnData;
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('facebook_token', result.accessToken.token);
        returnData = {
          'status': true,
          'facebook_token': result.accessToken.token
        };

        break;
      case FacebookLoginStatus.cancelledByUser:
        returnData = {
          'status': true,
          'facebook_token': null
        };
        
        break;
      case FacebookLoginStatus.error:
        returnData = {
          'status': true,
          'facebook_token': null
        };

        break;
    }
    return returnData;
  }
}

      