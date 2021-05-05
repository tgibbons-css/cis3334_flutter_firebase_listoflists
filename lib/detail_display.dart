import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';        // for Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart';    // for Firebase Firestore

//import 'shopping_item.dart';
import 'shopping_list.dart';

class DetailDisplay extends StatefulWidget {

  String listID;
  // define a constructor that saves the position into the variable above
  @override
  DetailDisplay({Key key, @required this.listID}) : super(key: key);

  @override
  _DetailDisplayState createState() => _DetailDisplayState();
}

class _DetailDisplayState extends State<DetailDisplay> {

  String userID;
  String listID;
  ShoppingList shoppingList;
  List<ListItem> itemList = [];
  DocumentSnapshot documentSnapshot;
  DocumentReference listFireStoreDoc;
  final TextEditingController _newItemNameTextField = TextEditingController();
  final TextEditingController _newItemQuantityTextField = TextEditingController();

  @override
  initState() {
    userID = FirebaseAuth.instance.currentUser.uid;
    listID = widget.listID;     // get item ID that was passed into this widget
    listFireStoreDoc = FirebaseFirestore.instance.collection('USERS').doc(userID).collection('SHOPPING_LISTS_2').doc(listID);
    listFireStoreDoc.get()
        .then((documentSnapshot) {
            if (documentSnapshot.exists) {
              setState(() {
                Map<String, dynamic> shoppingListMap = documentSnapshot
                    .data()['ShoppingList'];
                shoppingList = ShoppingList.fromJson(shoppingListMap);
                itemList = shoppingList.listItems;
              });
            }
        });
  }

  Widget nameTextFieldWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.7,
      child: TextField(
        controller: _newItemNameTextField,
        style: TextStyle(fontSize: 22, color: Colors.black),
        decoration: InputDecoration(
          hintText: "Name",
          hintStyle: TextStyle(fontSize: 22, color: Colors.black),
        ),
      ),
    );
  }
  Widget quantityTextFieldWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.7,
      child: TextField(
        controller: _newItemQuantityTextField,
        style: TextStyle(fontSize: 22, color: Colors.black),
        decoration: InputDecoration(
          hintText: "Quantity",
          hintStyle: TextStyle(fontSize: 22, color: Colors.black),
        ),
      ),
    );
  }

  Widget addButtonWidget() {
    return SizedBox(
      child: ElevatedButton(
          onPressed: () async {
            String name = _newItemNameTextField.text.toString();
            int quanity = int.parse(_newItemQuantityTextField.text.toString());
            ListItem item = new ListItem(itemName: name, quantity: quanity );
            setState(() {
              itemList.add(item);              // add new item to local copy of the itemList
            });
            await listFireStoreDoc.set({'ShoppingList': shoppingList.toJson()});         // Update the shopping list in Firestore with the new itemList included
            _newItemNameTextField.clear();
            _newItemQuantityTextField.clear();
          },
          child: Text(
            'Add Data',
            style: TextStyle(fontSize: 20),
          )),
    );
  }

  Widget detailInputWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        nameTextFieldWidget(),
        quantityTextFieldWidget(),
        addButtonWidget(),
      ],
    );
  }

  Widget detailTileWidget(position) {
    return ListTile(
      leading: Icon(Icons.check_box),
      title: Text(itemList[position].itemName),
      subtitle: Text('Quantity = ${itemList[position].quantity}'),
      onLongPress: () async {
        print("You long pressed at postion =  $position");
        setState(() {
          itemList.removeAt(position);              // remove item from local copy of the itemList
        });
        await listFireStoreDoc.set({'ShoppingList': shoppingList.toJson()});        // Update the shopping list in Firestore with the new itemList included
      },
    );
  }

  Widget detailListWidget() {
    return Expanded(
        child:
        ListView.builder(
          itemCount: itemList.length,
          itemBuilder: (BuildContext context, int position) {
            return Card(
                child: detailTileWidget(position)
            );
          },
        ),
    );
  }

  Widget backButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text('Go back!'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details ${widget.listID}"),
      ),
      body: Container(
        color: Colors.lime,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 50),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Text("Details"),
            detailInputWidget(),
            SizedBox(height: 40,),
            detailListWidget(),
            backButton(),
          ],
        ),
      ),
    );
  }
}