import 'package:flutter/material.dart';
import 'package:my_photo_manager/Widgets/spinner.dart';

import 'dart:async';
import 'dart:io';
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
  final List<Filter> filters = presetFiltersList;

  bool loading = true;
  Filter _filter;
  
  
  String fileName;
  File imageFile;


  @override
  void initState() {
    super.initState();

    _setImage();
  }

  Future _setImage() async {
    try {
      // Saved with this method.
      var imageId = await ImageDownloader.downloadImage(widget._imageData.image, );
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
  }

  Future getImage(context) async {
    

    if (imageFile != null) {
      var image = imageLib.decodeImage(imageFile.readAsBytesSync());
      print('--- 1. image ---');
      print(image);

      image = imageLib.copyResize(image, width: 600);

      print('--- 3. image ---');
      print(image);

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: loading 
        ? WidgetSpinner() 
        : Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: EdgeInsets.all(12.0),
                      child: Container(),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filters.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            child: Container(
                              padding: EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    filters[index].name,
                                  )
                                ],
                              ),
                            ),
                            onTap: () => setState(() {
                                  _filter = filters[index];
                                }),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ), 
        
      ),
    );
  }
}