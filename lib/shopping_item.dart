
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
}


class ShoppingItem {
  String _itemName;
  int _quantity;
  ShoppingItem(this._itemName, this._quantity);
}