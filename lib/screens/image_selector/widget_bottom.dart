import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../models/model.dart';
//import '../edit_image/edit_image.dart';
import '../filter_image/filter_image.dart';

class ImageSelectorBottom extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final int _scrollAmount = 0;

  void _scrollToStart() {
    
  }
  void _scrollToEnd() {
    
  }
  @override
  Widget build(BuildContext context) {

    if(_scrollAmount>0){
      _scrollController.animateTo(100, duration: new Duration(seconds: 2), curve: Curves.ease);
    }

    return ScopedModelDescendant<AppModel>(
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
                                    MaterialPageRoute(builder: (context) => ScreenFilterImage(model.imageItems[index])),
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
          });
  }
}