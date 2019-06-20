import 'package:simple_auth/simple_auth.dart' as simpleAuth;

class AppFacebookLogin {
  final simpleAuth.FacebookApi facebookApi = new simpleAuth.FacebookApi(
    "facebook",
    "372060790329125",
    "cfb6a174aa2daa35aef2860e44fd6c15",
    "https://my-photo-manager.firebaseapp.com/__/auth/handler",
    scopes: ['email', 'user_photos'], 
  );

  Future<Map<String, dynamic>> login() async {
    final simpleAuth.FacebookApi api = facebookApi;
    Map<String, dynamic> returnData;

    try {
      var success = await api.authenticate();
      returnData = {
          'status': true,
          'facebook_token': null
        };
      print("Logged in success: $success");
    } catch (e) {
      returnData = {
        'status': false,
        'facebook_token': null
      };
      print('ERROR: '+e.toString());
    }    

    return returnData;
  }


}
