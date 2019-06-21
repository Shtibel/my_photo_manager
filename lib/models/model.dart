import 'package:flutter/material.dart';
import 'package:my_photo_manager/Widgets/app_alert_dialog.dart';
import 'package:my_photo_manager/utils/db_helper.dart';
import 'package:scoped_model/scoped_model.dart';
import '../utils/globals.dart';

class AppModel extends Model {
  List<ImageItem> _imageItems = [];
  List<ImageItem> get imageItems => _imageItems;
  final counter = ValueNotifier(0);
  final Globals globals = Globals();
  AppAlertDialog myAlert = AppAlertDialog();
  DbHelper dbHelper = DbHelper();

  dynamic addItem(ImageItem item, {bool addAnyway = false}) {
    if (!addAnyway) {
      //check item before adding to list
      if (item.width <= globals.cantPrintWidth ||
          item.width <= globals.cantPrintHeight) {
        //show can't print alert
        notifyListeners();
        return _cantPrintAlert();
      } else if ((item.width > globals.cantPrintWidth &&
              item.width <= globals.lowQualityWidth) ||
          (item.height > globals.cantPrintWidth &&
              item.height <= globals.lowQualityHeight)) {
        //show low quality alert
        notifyListeners();
        return _lowQualityAlert(item);
      }
    }

    _imageItems.add(item);
    counter.addListener(_myCallback);
    counter.value += 1;

    //add to db
    dbHelper.insertList('selected_photos', {
        'library': item.library,
        'directory': item.directory,
        'thumb': item.thumb,
        'image': item.image,
        'width': item.width,
        'height': item.height
    });

    notifyListeners();
  }

  void deleteItem(ImageItem item) {
    _imageItems.remove(item);

    //delete from db
    dbHelper.deleteRowFromDb('selected_photos', {
        'library': item.library,
        'directory': item.directory,
        'thumb': item.thumb,
        'image': item.image,
        'width': item.width,
        'height': item.height
    });
    notifyListeners();
  }

  String _myCallback() {
    return 'callback';
  }

  AppAlertDialog _cantPrintAlert() {
    final List<Map<String, dynamic>> _actions = [];
    _actions.add({'buttonText': 'CLOSE', 'buttonAction': 'close'});
    myAlert = AppAlertDialog(
        title: 'Problem with image',
        content:
            'This image width or height are less than ${globals.cantPrintHeight}.',
        actions: _actions);
    return myAlert;
  }

  AppAlertDialog _lowQualityAlert(ImageItem item) {
    final List<Map<String, dynamic>> _actions = [];
    _actions.add({'buttonText': 'ADD ANYWAY', 'buttonAction': 'addAnyway', 'buttonItem': item});
    _actions.add({
      'buttonText': 'CLOSE', 
      'buttonAction': 'close',
    });
    myAlert = AppAlertDialog(
        title: 'Low quality image',
        content:
            'This image width or height are less than ${globals.lowQualityHeight}.\nThe print will not be good.',
        actions: _actions);
    return myAlert;
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
