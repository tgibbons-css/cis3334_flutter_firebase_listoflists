// To parse this JSON data, do
//
//     final shoppingList = shoppingListFromJson(jsonString);

import 'dart:convert';

ShoppingList shoppingListFromJson(String str) => ShoppingList.fromJson(json.decode(str));
String shoppingListToJson(ShoppingList data) => json.encode(data.toJson());

class ShoppingList {
  ShoppingList({
    this.listName,
    this.listItems,
  });

  String listName;
  List<ListItem> listItems;

  factory ShoppingList.fromJson(Map<String, dynamic> json) => ShoppingList(
    listName: json["listName"],
    listItems: (() {
      if (json["listItems"] != null) {
        print (" #### ShoppintList.fromJson NOT NULL ####");
        print (" #### json list Items = ${json["listItems"]}");
        List<ListItem> itemList = List<ListItem>.from(json["listItems"].map((x) => ListItem.fromJson(x)));
        print (" #### itemList size = ${itemList.length}");

        return itemList;
      } else {
        print (" ######### ShoppintList.fromJson NULL ########");
        return <ListItem>[];
      }
    }())
  );

  Map<String, dynamic> toJson() => {
    "listName": listName,
    "listItems": List<dynamic>.from(listItems.map((x) => x.toJson())),
  };
}

class ListItem {
  ListItem({
    this.itemName,
    this.quantity,
  });

  String itemName;
  int quantity;

  factory ListItem.fromJson(Map<String, dynamic> json) => ListItem(
    itemName: json["itemName"],
    quantity: json["quantity"],
  );

  Map<String, dynamic> toJson() => {
    "itemName": itemName,
    "quantity": quantity,
  };
}
