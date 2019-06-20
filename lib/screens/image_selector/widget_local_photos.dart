import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class WidgetLocalPhotos extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WidgetLocalPhotos();
  }
}

class _WidgetLocalPhotos extends State<WidgetLocalPhotos> {
  final int numberOfImagesPerRow = 3;

  int tabControllerLength;
  List<Widget> tabBarLabels = [];
  List<Widget> tabBarContents = [];

  @override
  void initState() {
    super.initState();

    _loadAllImages();
  }

  Future<void> _loadAllImages() async {
    // asks for permissions and returns a boolean
    final bool result = await PhotoManager.requestPermission();

    if (result) {
      // success - user gave us authorisation

      // we fetch the list of all the asset paths
      final List<AssetPathEntity> assetPathList =
          await PhotoManager.getAssetPathList(isCache: false, hasVideo: false);

      //print('assetPathList');
      //print(assetPathList);

      // this is an alternative way to look for assets paths
      // final List<AssetPathEntity> imageAsset =
      //     await PhotoManager.getImageAsset();
      // print('imageAsset');
      // print(imageAsset);

      // for each asset path we fetch the list of all the images and we add to the global list
      for (int i = 0; i < assetPathList.length; i++) {
        // gets the list of all the images for the asset path
        final List<AssetEntity> newImageList = await assetPathList[i].assetList;

        //print(assetPathList[i].name + ' - ' + newImageList.length.toString());

        // adds every image to the global list
        if (newImageList.length > 0 &&
            assetPathList[i].name.toLowerCase() != 'recent') {
          List<AssetEntity> imageList = <AssetEntity>[];
          for (int ii = 0; ii < newImageList.length; ii++) {
            imageList.add(newImageList[ii]);
          }

          tabBarLabels.add(Tab(text: assetPathList[i].name));
          tabBarContents.add(GridView.builder(
            // gridview
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: numberOfImagesPerRow,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              return _buildItem(context, index, imageList);
            },
            itemCount: imageList.length,
          ));
        }
      }
      // updates the state to update the screen
      //print('TOTAL: ${imageList.length}');

      tabControllerLength = tabBarLabels.length;

      //print('Len 1: $tabControllerLength');
      //print('Len 2: ${tabBarLabels.length}');
      //print('Len 3: ${tabBarContents.length}');

      if (this.mounted) {
        setState(() {});
      }
    } else {
      // fail - user didn'g gave us authorisation
      // we open settings to give it manually
      PhotoManager.openSetting();
    }
  }

  // creates the single tile with the image
  Widget _buildItem(BuildContext context, int index, currentImageList) {
    final AssetEntity entity = currentImageList[index]; // image entity

    final int size = MediaQuery.of(context).size.width ~/
        numberOfImagesPerRow; // gets the width of the display and divides it by the number of images per row

    return FutureBuilder<dynamic>(
      future: entity.thumbDataWithSize(size, size), // gets the image
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return InkWell(
            onTap: () => print(entity),
            child: Image.memory(
              snapshot.data,
              fit: BoxFit.cover,
              width: size.toDouble(),
              height: size.toDouble(),
            ),
          );
        }
        return Center(
          child: const Text('loading...'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return tabControllerLength == null
        ? Container()
        : DefaultTabController(
            length: tabControllerLength,
            initialIndex: 0,
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  color: Theme.of(context).accentColor,
                  child: TabBar(
                    indicatorColor: Colors.white,
                    isScrollable: true,
                    tabs: tabBarLabels,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: tabBarContents,
                  ),
                ),
              ],
            ),
          );

    // return GridView.builder(
    //       // gridview
    //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //         crossAxisCount: numberOfImagesPerRow,
    //         childAspectRatio: 1.0,
    //       ),
    //       itemBuilder: _buildItem,
    //       itemCount: imageList.length,
    //     );
  }
}
