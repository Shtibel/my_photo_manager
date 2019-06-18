import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

import '../Widgets/local_photos.dart';
import '../Widgets/facebook_photos.dart';
import '../Widgets/instagram_photos.dart';
import '../models/model.dart';

class ImageSelector extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImageSelector();
  }
}

class _ImageSelector extends State<ImageSelector> {
  String _galleryType = 'local';
  Widget _bodyWidget = LocalPhotos();
  bool bottomNavigationBar = false;

  _changeGalleryType(String type) async {
    _galleryType = type;
    if (type == 'local') {
      _bodyWidget = LocalPhotos();
    } else if (type == 'facebook') {
      _bodyWidget = FacebookPhotos();
    } else if (type == 'instagram') {
      _bodyWidget = InstagramPhotos();
    } else {
      _bodyWidget = Container(
        child: Text(type),
      );
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppModel>(
      model: AppModel(),
      child: Scaffold(
          appBar: AppBar(
            title: Text('Select'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.photo_library),
                tooltip: 'Local photos',
                color: _galleryType == 'local' ? Colors.white : Colors.grey,
                onPressed: () => _changeGalleryType('local'),
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.facebook),
                tooltip: 'Facebook photos',
                color: _galleryType == 'facebook' ? Colors.white : Colors.grey,
                onPressed: () => _changeGalleryType('facebook'),
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.instagram),
                tooltip: 'Instagram photos',
                color: _galleryType == 'instagram' ? Colors.white : Colors.grey,
                onPressed: () => _changeGalleryType('instagram'),
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.google),
                tooltip: 'Google photos',
                color: _galleryType == 'google' ? Colors.white : Colors.grey,
                onPressed: () => _changeGalleryType('google'),
              ),
            ],
          ),
          body: _bodyWidget,
          bottomNavigationBar: ScopedModelDescendant<AppModel>(
              builder: (BuildContext context, Widget child, AppModel model) {
            if (model.items.length == 0) {
              return Container(
                width: 0,
                height: 0,
              );
            } else {
              return Container(
                height: 100.0,
                //color: Colors.white,
                decoration: new BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.black,
                      blurRadius: 10.0,
                    )
                  ],
                ),
                child: new ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: model.items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                          onLongPress: () {
                            model.deleteItem(model.items[index]);
                          },
                          child: Container(
                            margin: EdgeInsets.all(5.0),
                            child: Stack(
                              children: <Widget>[
                                Image.network(
                                  model.items[index].name,
                                  fit: BoxFit.cover,
                                  width: 80.0,
                                  height: 80.0,
                                ),
                              ],
                            ),
                          )

                          // Container(
                          //   margin: EdgeInsets.all(5.0),
                          //   height: 50.0,
                          //   width: 50.0,
                          //   color: Colors.black,
                          //   child: Text(model.items[index].name, style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
                          // )
                          );
                    }),
              );
            }
          })),
    );
  }
}
