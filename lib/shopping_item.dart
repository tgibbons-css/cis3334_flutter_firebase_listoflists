
class ShoppingList {
  String listName;

  ShoppingList(this.listName);

  List <ShoppingItem> listItems;

  ShoppingItem addItem(String itemName, int quantity) {
    ShoppingItem newItem = new ShoppingItem(itemName, quantity);
    return newItem;
  }

  removeItem(int position) {
    listItems.removeAt(position);
  }

  ShoppingList.fromJson(Map<String, dynamic> json)
      : listName = json['listName'],
        listItems = json['listItems'];
 // products: snap.get('products').map<Product>((p) => Product.fromJson(p)).toList(),
 //       listItems = map['listItems'].map((set) {return Set.fromJson(set);}).toList();

  Map<String, dynamic> toJson() => {
    'listName': listName,
    'listItems': listItems.map((i) => i.toJson()).toList()
  };

}


class ShoppingItem {
  String _itemName;
  int _quantity;
  ShoppingItem(this._itemName, this._quantity);

  // From https://flutter.dev/docs/development/data-and-backend/json
  ShoppingItem.fromJson(Map<String, dynamic> json)
      : _itemName = json['itemName'],
        _quantity = json['quantity'];

  Map<String, dynamic> toJson() => {
    'itemName': _itemName,
    'quantity': _quantity,
  };

}