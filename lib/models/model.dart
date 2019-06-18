import 'package:scoped_model/scoped_model.dart';

class AppModel extends Model {
  List<Item> _items = [];
  List<Item> get items => _items;

  void addItem(Item item) {
    //print(item.name);
    _items.add(item);
    _items.forEach((aaa) {
      print(aaa.name);
    });
    notifyListeners();
  }

  void deleteItem(Item item) {
    _items.remove(item);
    notifyListeners();
  }
}

class Item {
  final String name;
  Item(this.name);
}
