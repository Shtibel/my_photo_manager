import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_photo_manager/pages/edit_image.dart';
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
  ScrollController _scrollController;
  int _scrollAmount = 0;


  @override
  void initState() {
    super.initState();

    _scrollController = new ScrollController();

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

    if(_scrollAmount>0){
      _scrollController.animateTo(100, duration: new Duration(seconds: 2), curve: Curves.ease);
    }
    
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
            if (model.imageItems.length == 0) {
              return Container(
                width: 0,
                height: 0,
              );
            } else {
              return Container(
                height: 150.0,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          textColor: Colors.blueGrey,
                          color: Colors.white,
                          child: new Text('Scroll start'),
                          onPressed: _scrollToStart,
                        ),
                        FlatButton(
                          textColor: Colors.blueGrey,
                          color: Colors.white,
                          child: new Text('Scroll end'),
                          onPressed: _scrollToEnd,
                        ),
                      ],
                    ),
                    Container(
                      height: 100.0,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8.0),
                          itemCount: model.imageItems.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                                onLongPress: () {
                                  model.deleteItem(model.imageItems[index]);
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => EditImage(model.imageItems[index])),
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
                    ),
                  ],
                ),
              );
            }
          })),
    );
  }

  void _scrollToStart() {
    setState(() {
      //_scrollAmount = 0;
    });
  }
  void _scrollToEnd() {
    setState(() {
      //_scrollAmount = 100;
    });
  }
}
