import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Widgets/local_photos.dart';
import '../Widgets/facebook_photos.dart';

class ImageSelector extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImageSelector();
  }
}

class _ImageSelector extends State<ImageSelector> {
  String _galleryType = 'local';
  Widget _bodyWidget = LocalPhotos();

  _changeGalleryType(String type) async {

    _galleryType = type;
    if (type == 'local') {
      _bodyWidget = LocalPhotos();
    } else if (type == 'facebook') {
      _bodyWidget = FacebookPhotos();
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
    return Scaffold(
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
    );
  }

  
}
