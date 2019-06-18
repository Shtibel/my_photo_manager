import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/facebook_login.dart';
import '../Widgets/spinner.dart';
import '../utils/db_helper.dart';

class FacebookPhotos extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FacebookPhotos();
  }
}

class _FacebookPhotos extends State<FacebookPhotos> {
  DbHelper dbHelper = DbHelper();

  int facebookTabControllerLength;
  List<Widget> facebookTabBarLabels = [];
  List<Widget> facebookTabBarContents = [];
  List allImages = [];
  String facebookToken;
  bool _isTableEmpty = true;

  @override
  void initState() {
    super.initState();

    _loadFacebookImages();
  }

  Future<void> _insertToDb(
      String library, String directory, List<dynamic> photos) async {
    //try insert
    photos.forEach((photo) async {
      String thumb = photo['images'][photo['images'].length - 1]['source'];
      String image = photo['images'][0]['source'];
      num width = photo['images'][0]['width'];
      num height = photo['images'][0]['width'];

      await dbHelper.insertList({
        'library': library,
        'directory': directory,
        'thumb': thumb,
        'image': image,
        'width': width,
        'height': height
      });
    });
  }

  Future<void> _loadFacebookImages({bool refechFromFacebook = false}) async {
    if (refechFromFacebook == true) {
      print('delete all');
      //delete all the images
      await dbHelper.deleteSql('delete from photos where library=?',
          params: ['facebook']);
    }

    var dbImages = await dbHelper.readList('facebook');
    if (dbImages.length == 0) {
      _isTableEmpty = true;
      await _loadFromFacebook();
    } else {
      _isTableEmpty = false;
      await _loadFromDb();
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future _loadFromDb() async {
    print('loadFromDb');

    var albums = await dbHelper.selectFromDb(
        'select distinct directory from photos where library=?', ['facebook']);

    //set tab length
    facebookTabControllerLength = albums.length;

    for (int i = 0; i < albums.length; i++) {
      //set tab labels
      facebookTabBarLabels.add(Tab(text: albums[i]['directory']));

      var photos = await dbHelper.selectFromDb(
          'select * from photos where library=? and directory=?',
          ['facebook', albums[i]['directory']]);

      // set tab body
      facebookTabBarContents.add(GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _buildFacebookItem(context, index, photos, fromDB: true);
        },
        itemCount: photos.length,
      ));

      photos.forEach((photo) {
        allImages.add(photo);
      });
    }

    //add TAB ALL
    facebookTabControllerLength++;
    facebookTabBarLabels.insert(0, Tab(text: 'ALL'));
    facebookTabBarContents.insert(
        0,
        RefreshIndicator(
          onRefresh: _refreshFacebookImages,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              return _buildFacebookItem(context, index, allImages,
                  fromDB: true);
            },
            itemCount: allImages.length,
          ),
        ));
  }

  Future<void> _loadFromFacebook() async {
    print('_loadFromFacebook');

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    //get facebook token
    facebookToken = prefs.getString('facebook_token');

    //check if there is no token > show login
    if (facebookToken == null) {
      AppFacebookLogin _appFacebookLogin = AppFacebookLogin();
      dynamic facebookResult = await _appFacebookLogin.login();
      facebookToken = facebookResult['facebook_token'];
    }

    //get images
    var graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?&access_token=' +
            facebookToken +
            '&fields=albums.limit(100){name,count,cover_photo{picture},photos.limit(100){picture,images}}');
    var result = json.decode(graphResponse.body);

    //list of all albums
    List<dynamic> albums = result['albums']['data'];

    //set tab length
    facebookTabControllerLength = albums.length;

    //loop all albums
    albums.forEach((album) async {
      //get photos
      List<dynamic> photos = album['photos']['data'];

      //insert to db
      if (_isTableEmpty) {
        _insertToDb('facebook', album['name'], photos);
      }

      //set tab labels
      facebookTabBarLabels.add(Tab(text: album['name']));

      facebookTabBarContents.add(GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _buildFacebookItem(context, index, photos, fromDB: false);
        },
        itemCount: photos.length,
      ));

      //add all photos to TAB ALL
      photos.forEach((photo) {
        allImages.add(photo);
      });
    });

    //add TAB ALL
    facebookTabControllerLength++;
    facebookTabBarLabels.insert(0, Tab(text: 'ALL'));
    facebookTabBarContents.insert(
        0,
        RefreshIndicator(
          onRefresh: _refreshFacebookImages,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              return _buildFacebookItem(context, index, allImages,
                  fromDB: false);
            },
            itemCount: allImages.length,
          ),
        ));
  }

  Future<Null> _refreshFacebookImages() async {
    facebookTabControllerLength = null;
    facebookTabBarLabels = [];
    facebookTabBarContents = [];
    allImages = [];

    await _loadFacebookImages(refechFromFacebook: true);

    return null;
  }

  Widget _buildFacebookItem(BuildContext context, int index, currentImageList,
      {bool fromDB}) {
    final photo = currentImageList[index]; // image entity

    // num width = photo['images'][0]['width'];
    // num height = photo['images'][0]['width'];
    // String big = photo['images'][0]['source'];
    // String thumb = photo['images'][photo['images'].length - 1]['source'];

    //print('thumb: ' + thumb);
    //print('big: ' + big);
    //print('size: ' + width.toString() + 'X' + height.toString());
    //print('===============================');

    final int size = MediaQuery.of(context).size.width ~/
        3; // gets the width of the display and divides it by the number of images per row

    return InkWell(
        onTap: () => print(photo),
        child: Container(
          width: size.toDouble(),
          height: size.toDouble(),
          child: Stack(
            alignment: const Alignment(1.0, -1.0),
            overflow: Overflow.clip,
            children: <Widget>[
              Image.network(
                fromDB == false
                    ? photo['images'][photo['images'].length - 1]['source']
                    : photo['thumb'],
                fit: BoxFit.cover,
                width: size.toDouble(),
                height: size.toDouble(),
              ),
              Transform.rotate(
                angle: math.pi / 4.0,
                child: Container(
                  height: 20.0,
                  color: Colors.red,
                  child: Center(
                    child: Text(
                      'Low quality',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return facebookTabControllerLength == null
        ? Center(
            child: Spinner(),
          )
        : DefaultTabController(
            length: facebookTabControllerLength,
            initialIndex: 0,
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  color: Theme.of(context).accentColor,
                  child: TabBar(
                    indicatorColor: Colors.white,
                    isScrollable: true,
                    tabs: facebookTabBarLabels,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: facebookTabBarContents,
                  ),
                ),
              ],
            ),
          );
  }
}
