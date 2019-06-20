import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppGoogleLogin {

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'profile',
      'email',
      'https://www.googleapis.com/auth/photoslibrary',
    ],
  );

  Future<dynamic> login() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      // GoogleSignInAccount:{
      //   displayName: Dan Dushinsky, 
      //   email: dushy@shtibel.com, 
      //   id: 117635153059882796190, 
      //   photoUrl: https://lh4.googleusercontent.com/-5i4ZLKKPzr8/AAAAAAAAAAI/AAAAAAAAL4g/nc9Kce49O70/s1337/photo.jpg
      // }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      await googleUser.authHeaders;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('google_token', googleAuth.accessToken);

      // print('<-- google login');
      // print(googleUser);
      // print('<-- google googleAuth');
      // print(googleAuth);
      return({
          'status': true,
          'google_token': googleAuth.accessToken,
          'error': null
        });
    } on PlatformException catch (error) {
      // print('<-- google login error');
      // print(error);
      return({
          'status': false,
          'google_token': null,
          'error': error
        });
    }
  }

}
