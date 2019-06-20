import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;

import 'package:image_downloader/image_downloader.dart';


import '../../models/model.dart';

class ScreenFilterImage extends StatefulWidget {
  final ImageItem _imageData;

  ScreenFilterImage(this._imageData);

  @override
  _ScreenFilterImageState createState() => _ScreenFilterImageState();
}

class _ScreenFilterImageState extends State<ScreenFilterImage> {
  String fileName;
  List<Filter> filters = presetFiltersList;
  File imageFile;

  Future getImage(context) async {
    try {
      // Saved with this method.
      var imageId = await ImageDownloader.downloadImage(widget._imageData.image);
      print('imageId: '+imageId);
      if (imageId == null) {
        return;
      }

      var path = await ImageDownloader.findPath(imageId);
      imageFile = File(path);

      print('imageFile: '+path);
    } catch (error) {
      print('!!!error!!!');
      print(error);
    }

    if (imageFile != null) {
      var image = imageLib.decodeImage(imageFile.readAsBytesSync());
      image = imageLib.copyResize(image, width: 600);

      Map imagefile = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new PhotoFilterSelector(
                title: Text("Photo Filter Example"),
                image: image,
                filters: presetFiltersList,
                filename: fileName,
                loader: Center(child: CircularProgressIndicator()),
                fit: BoxFit.contain,
              ),
        ),
      );
      
      if (imagefile != null && imagefile.containsKey('image_filtered')) {
        setState(() {
          imageFile = imagefile['image_filtered'];
        });
        print(imageFile.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Photo Filter Example'),
      ),
      body: Center(
        child: new Container(
          child: imageFile == null
              ? Center(
                  child: new Text('No image selected.'),
                )
              : Image.file(imageFile),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => getImage(context),
        tooltip: 'Pick Image',
        child: new Icon(Icons.add_a_photo),
      ),
    );
  }
}