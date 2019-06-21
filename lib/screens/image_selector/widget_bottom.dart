import 'package:flutter/material.dart';
import 'package:my_photo_manager/services/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../models/model.dart';
//import '../edit_image/edit_image.dart';
import '../filter_image/filter_image.dart';

class ImageSelectorBottom extends StatefulWidget {
  @override
  _ImageSelectorBottomState createState() => _ImageSelectorBottomState();
}

class _ImageSelectorBottomState extends State<ImageSelectorBottom> {
  ScrollController controller;
  final double itemSize = 90.0;
  var providerCounter;
  var myCounter = 0;

  @override
  void initState() {
    controller = ScrollController();
    super.initState();
  }

  void _moveEnd() {
    if (controller.hasClients) {
      if (providerCounter > 4) {
        controller.animateTo(controller.offset + itemSize,
            curve: Curves.linear, duration: Duration(milliseconds: 250));
      }

      myCounter = providerCounter;
    }
  }

  @override
  Widget build(BuildContext context) {
    providerCounter = Provider.of(context).value;
    if (myCounter != providerCounter) {
      _moveEnd();
    }
    print('<--- _counter');
    print(providerCounter);
    return ScopedModelDescendant<AppModel>(
        builder: (BuildContext context, Widget child, AppModel model) {
      if (model.imageItems.length == 0) {
        return Container(
          width: 0,
          height: 0,
        );
      } else {
        return Container(
          height: 170.0,
          //color: Colors.white,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10.0,
              )
            ],
          ),
          child: Column(
            children: <Widget>[
              Container(
                height: 100.0,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: controller,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: model.imageItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onLongPress: () {
                          model.deleteItem(model.imageItems[index]);
                          Provider.of(context).value -= 1;
                          myCounter -= 1;
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ScreenFilterImage(model.imageItems[index])),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: Stack(
                            children: <Widget>[
                              Image.network(
                                model.imageItems[index].thumb,
                                fit: BoxFit.cover,
                                width: 80.0,
                                height: 80.0,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
              SizedBox(
                width: double.infinity,
                child: ButtonTheme(
                  height: 70.0,
                  child: RaisedButton(
                    child: Text('DONE'),
                    color: Theme.of(context).accentColor,
                    onPressed: () {},
                    textColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }
}
