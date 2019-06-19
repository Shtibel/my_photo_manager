import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_downloader/image_downloader.dart';

import '../models/model.dart';

enum AppState {
  free,
  picked,
  cropped,
}

class EditImage extends StatefulWidget {
  final ImageItem _imageData;

  EditImage(this._imageData);

  @override
  State<StatefulWidget> createState() {
    return _EditImageState();
  }
}

class _EditImageState extends State<EditImage> {
  AppState state;
  File imageFile;

  @override
  void initState() {
    super.initState();

    state = AppState.free;
    _pickImage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit image'),
      ),
      body: Center(
        child: imageFile != null ? Image.file(imageFile) : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (state == AppState.free)
            _pickImage();
          else if (state == AppState.picked)
            _cropImage();
          else if (state == AppState.cropped) _clearImage();
        },
        child: _buildButtonIcon(),
      ),
    );
  }

  Widget _buildButtonIcon() {
    if (state == AppState.free)
      return Icon(Icons.add);
    else if (state == AppState.picked)
      return Icon(Icons.crop);
    else if (state == AppState.cropped)
      return Icon(Icons.clear);
    else
      return Container();
  }

  Future<Null> _pickImage() async {
    try {
      // Saved with this method.
      var imageId =
          await ImageDownloader.downloadImage(widget._imageData.image);
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
      setState(() {
        state = AppState.picked;
      });
    }
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      toolbarTitle: 'Cropper',
      toolbarColor: Colors.blue,
      toolbarWidgetColor: Colors.white,
    );
    print('croppedFile');
    print(croppedFile);
    if (croppedFile != null) {
      imageFile = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  void _clearImage() {
    imageFile = null;
    setState(() {
      state = AppState.free;
    });
  }
}
