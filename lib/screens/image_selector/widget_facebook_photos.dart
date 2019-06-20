import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';

import '../../services/facebook_login.dart';
import '../../Widgets/spinner.dart';
import '../../utils/db_helper.dart';
import '../../utils/triangle_sticker.dart';
import '../../models/model.dart';

class WidgetFacebookPhotos extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WidgetFacebookPhotos();
  }
}

class _WidgetFacebookPhotos extends State<WidgetFacebookPhotos> {
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
          return _buildFacebookItem(
              context, index, photos, albums[i]['directory'],
              fromDB: true);
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
              return _buildFacebookItem(context, index, allImages, 'ALL',
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

    if (facebookToken == null) {
      return;
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
        List<Map<String, dynamic>> albumDbImages = [];
        for (int i = 0; i < photos.length; i++) {
          dynamic photo = photos[i];

          albumDbImages.add({
            'library': 'facebook',
            'directory': album['name'],
            'thumb': photo['images'][photo['images'].length - 1]['source'],
            'image': photo['images'][0]['source'],
            'width': photo['images'][0]['width'],
            'height': photo['images'][0]['width']
          });
        }
        dbHelper.insertToDb('facebook', album['name'], albumDbImages);
      }

      //set tab labels
      facebookTabBarLabels.add(Tab(text: album['name']));

      facebookTabBarContents.add(GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _buildFacebookItem(context, index, photos, album['name'],
              fromDB: false);
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
              return _buildFacebookItem(context, index, allImages, 'ALL',
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

  Widget _buildFacebookItem(
      BuildContext context, int index, currentImageList, String directory,
      {bool fromDB = false}) {
    final photo = currentImageList[index]; // image entity

    String _thumb;
    String _image;
    int _width;
    int _height;

    if (fromDB) {
      _thumb = photo['thumb'];
      _image = photo['image'];
      _width = photo['width'];
      _height = photo['height'];
    } else {
      _thumb = photo['images'][photo['images'].length - 1]['source'];
      _image = photo['images'][0]['source'];
      _width = photo['images'][0]['width'];
      _height = photo['images'][0]['height'];
    }

    //print('thumb: ' + thumb);
    //print('big: ' + big);
    //print('size: ' + width.toString() + 'X' + height.toString());
    //print('===============================');

    final int size = MediaQuery.of(context).size.width ~/
        3; // gets the width of the display and divides it by the number of images per row
    return ScopedModelDescendant<AppModel>(
        builder: (BuildContext context, Widget child, AppModel model) {
      return InkWell(
        onTap: () {
          ImageItem item = ImageItem(
              library: 'facebook',
              directory: directory,
              thumb: _thumb,
              image: _image,
              width: _width,
              height: _height);
          model.addItem(item);
          setState(() {});
        },
        child: Stack(
          alignment: const Alignment(1.0, -1.0),
          overflow: Overflow.clip,
          children: <Widget>[
            Image.network(
              _thumb,
              fit: BoxFit.cover,
              width: size.toDouble(),
              height: size.toDouble(),
            ),
            TriangleSticker(_width, _height),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return facebookTabControllerLength == null
        ? Center(
            child: WidgetSpinner(),
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
