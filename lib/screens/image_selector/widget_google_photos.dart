import 'package:flutter/material.dart';
import 'package:my_photo_manager/Widgets/spinner.dart';
import 'package:my_photo_manager/Widgets/triangle_sticker.dart';
import 'package:my_photo_manager/models/model.dart';
import 'package:my_photo_manager/services/photos_library_api/album.dart';
import 'package:my_photo_manager/services/photos_library_api/list_albums_response.dart';
import 'package:my_photo_manager/services/photos_library_api/media_item.dart';
import 'package:my_photo_manager/services/photos_library_api/media_items_response.dart';
import 'package:my_photo_manager/services/photos_library_api/photos_library_api_client.dart';
import 'package:my_photo_manager/services/photos_library_api/search_media_items_request.dart';
import 'package:my_photo_manager/services/photos_library_api/search_media_items_response.dart';
import 'package:my_photo_manager/services/google_login.dart';
import 'package:my_photo_manager/services/provider.dart';
import 'package:my_photo_manager/utils/db_helper.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetGooglePhotos extends StatefulWidget {
  @override
  _WidgetGooglePhotosState createState() => _WidgetGooglePhotosState();
}

class _WidgetGooglePhotosState extends State<WidgetGooglePhotos> {
  DbHelper dbHelper = DbHelper();

  int googleTabControllerLength;
  List<Widget> googleTabBarLabels = [];
  List<Widget> googleTabBarContents = [];
  List allImages = [];
  String googleToken;

  bool _isTableEmpty = true;

  @override
  void initState() {
    super.initState();

    _loadGoogleImages();
  }

  Future<void> _loadGoogleImages({bool refechFromGoogle = false}) async {
    if (refechFromGoogle == true) {
      print('delete all');
      //delete all the images
      await dbHelper
          .deleteSql('delete from photos where library=?', params: ['google']);
    }

    var dbImages = await dbHelper.readList('google');
    if (dbImages.length == 0) {
      _isTableEmpty = true;
      await _loadFromGoogle();
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
        'select distinct directory from photos where library=?', ['google']);

    //set tab length
    googleTabControllerLength = albums.length;

    for (int i = 0; i < albums.length; i++) {
      //set tab labels
      googleTabBarLabels.add(Tab(text: albums[i]['directory']));

      var photos = await dbHelper.selectFromDb(
          'select * from photos where library=? and directory=?',
          ['google', albums[i]['directory']]);

      // set tab body
      googleTabBarContents.add(GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _buildGoogleItem(
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
    googleTabControllerLength++;
    googleTabBarLabels.insert(0, Tab(text: 'ALL'));
    googleTabBarContents.insert(
        0,
        RefreshIndicator(
          onRefresh: _refreshGoogleImages,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              return _buildGoogleItem(context, index, allImages, 'ALL',
                  fromDB: true);
            },
            itemCount: allImages.length,
          ),
        ));
  }

  Future<Map<String, String>> getAuthHeaders() async {
    return <String, String>{
      "Authorization": "Bearer $googleToken",
      "X-Goog-AuthUser": "0",
    };
  }

  Future<void> _loadFromGoogle() async {
    print('_loadFromGoogle');

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    //get google token
    //googleToken = prefs.getString('google_token');

    //check if there is no token > show login
    dynamic googleResult = '';
    if (googleToken == null) {
      AppGoogleLogin _appGoogleLogin = AppGoogleLogin();
      googleResult = await _appGoogleLogin.login();

      googleToken = googleResult['google_token'];
    }

    if (googleToken == null) {
      return;
    }

    //get images
    Future<Map<String, String>> authHeaders = getAuthHeaders();
    PhotosLibraryApiClient client = PhotosLibraryApiClient(authHeaders);

    //get all images
    googleTabBarLabels.add(Tab(text: 'ALL'));

    MediaItemsResponse allImagesResponse =
        await client.allMediaItems(googleToken);
    for (int i = 0; i < allImagesResponse.mediaItems.length; i++) {
      MediaItem photo = allImagesResponse.mediaItems[i];
      if (photo.mimeType.indexOf('image') != -1) {
        allImages.add(photo);
      }
    }
    googleTabBarContents.add(RefreshIndicator(
      onRefresh: _refreshGoogleImages,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _buildGoogleItem(context, index, allImages, 'ALL',
              fromDB: false);
        },
        itemCount: allImages.length,
      ),
    ));

    //get albums
    ListAlbumsResponse albumsResponse = await client.listAlbums();
    List<Album> albums = albumsResponse.albums;
    for (int i = 0; i < albums.length; i++) {
      Album album = albums[i];

      googleTabBarLabels.add(Tab(text: album.title));

      //get album images
      SearchMediaItemsResponse albumsResponse = await client
          .searchMediaItems(SearchMediaItemsRequest.albumId(album.id));
      List albumImages = [];
      List<Map<String, dynamic>> albumDbImages = [];
      for (int i = 0; i < albumsResponse.mediaItems.length; i++) {
        MediaItem photo = albumsResponse.mediaItems[i];
        if (photo.mimeType.indexOf('image') != -1) {
          albumImages.add(photo);
          albumDbImages.add({
            'library': 'google',
            'directory': album.title,
            'thumb': photo.baseUrl+'=w300-h300',
            'image': photo.baseUrl,
            'width': photo.width,
            'height': photo.height
          });
        }
      }

      dbHelper.insertToDb('google', album.title, albumDbImages);

      googleTabBarContents.add(RefreshIndicator(
        onRefresh: _refreshGoogleImages,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (BuildContext context, int index) {
            return _buildGoogleItem(context, index, albumImages, album.title,
                fromDB: false);
          },
          itemCount: albumImages.length,
        ),
      ));
    }

    googleTabControllerLength = googleTabBarLabels.length;
  }

  Widget _buildGoogleItem(
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
      _thumb = photo.baseUrl + '=w300-h300';
      _image = photo.baseUrl;
      _width = photo.width;
      _height = photo.height;
    }

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
          dynamic result = model.addItem(item);
          if(result!=null){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return result;
              }
            );
          }else{
            Provider.of(context).value += 1;
          }
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

  Future<Null> _refreshGoogleImages() async {
    googleTabControllerLength = null;
    googleTabBarLabels = [];
    googleTabBarContents = [];
    allImages = [];

    await _loadGoogleImages(refechFromGoogle: true);

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return googleTabControllerLength == null
        ? Center(
            child: WidgetSpinner(),
          )
        : DefaultTabController(
            length: googleTabControllerLength,
            initialIndex: 0,
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  color: Theme.of(context).accentColor,
                  child: TabBar(
                    indicatorColor: Colors.white,
                    isScrollable: true,
                    tabs: googleTabBarLabels,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: googleTabBarContents,
                  ),
                ),
              ],
            ),
          );
  }
}
