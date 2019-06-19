import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class AppModel extends Model {
  List<ImageItem> _imageItems = [];
  List<ImageItem> get imageItems => _imageItems;
  final counter = ValueNotifier(0);


  void addItem(ImageItem item) {
    //print(item.name);
    _imageItems.add(item);
    counter.addListener(_myCallback);
    counter.value += 1;
    notifyListeners();
  }

  void deleteItem(ImageItem item) {
    _imageItems.remove(item);
    notifyListeners();
  }

  String _myCallback(){
    return 'callback';
  }
}

class ImageItem {
  final String library;
  final String directory;
  final String thumb;
  final String image;
  final int width;
  final int height;

  ImageItem({
    this.library,
    this.directory,
    this.thumb,
    this.image,
    this.width,
    this.height,
  });
}
