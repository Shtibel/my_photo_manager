import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

import 'widget_local_photos.dart';
import 'widget_facebook_photos.dart';
import 'widget_instagram_photos.dart';
import 'widget_bottom.dart';

import '../../models/model.dart';

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
  


  @override
  void initState() {
    super.initState();
  }

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
          bottomNavigationBar: ImageSelectorBottom(),
      )
    );
  }

  
}