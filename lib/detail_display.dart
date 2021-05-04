import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';        // for Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart';    // for Firebase Firestore

import 'shopping_item.dart';

class DetailDisplay extends StatefulWidget {

  String itemID;
  // define a constructor that saves the position into the variable above
  @override
  DetailDisplay({Key key, @required this.itemID}) : super(key: key);

  @override
  _DetailDisplayState createState() => _DetailDisplayState();
}

class _DetailDisplayState extends State<DetailDisplay> {

  String userID;
  String itemID;
  ShoppingList shoppingList;
  CollectionReference itemCollectionDB;
  final TextEditingController _newItemNameTextField = TextEditingController();
  final TextEditingController _newItemQuantityTextField = TextEditingController();

  @override
  initState() {
    userID = FirebaseAuth.instance.currentUser.uid;
    itemID = widget.itemID;     // get item ID that was passed into this widget
    // Set the firebase collection to point to the detail items under the UserID and the itemID
    //        |--> userID -- ITEMS_WITH_DETAILS
    //        |                                 |--> itemID -- DETAILS
    //  USERS |--> userID -- ITEMS_WITH_DETAILS |--> itemID -- DETAILS
    //        |
    //        |--> userID -- ITEMS_WITH_DETAILS|--> itemID -- DETAILS
    //        |                                |--> itemID -- DETAILS
    //itemCollectionDB = FirebaseFirestore.instance.collection('USERS').doc(userID).collection('ITEMS_WITH_DETAILS').doc(itemID).collection('DETAILS');
    itemCollectionDB = FirebaseFirestore.instance.collection('USERS').doc(userID).collection('TEST_ITEMS');
    //shoppingList = snapshot.data.docs[position]
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
          hintText: "Quant",
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
            ShoppingItem item = new ShoppingItem(name, quanity );

            // TODO update shoppinglist in FireStore
            //await itemCollectionDB.add({'ShoppingItem': item});
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

  Widget detailTileWidget(snapshot, position) {
    return ListTile(
      leading: Icon(Icons.check_box),
      title: Text(snapshot.data.docs[position]['item_name']),
      subtitle: Text(snapshot.data.docs[position]['item_name']),
      onTap: () {
        setState(() {
          print("You tapped at postion =  $position");
        });
      },
      onLongPress: () {
        print("You long pressed at postion =  $position");
        String itemId = snapshot.data.docs[position].id;
        itemCollectionDB.doc(itemId).delete();
      },
    );
  }

  Widget detailListWidget() {
    //itemCollectionDB = FirebaseFirestore.instance.collection('USERS').doc(userID).collection('TEST_ITEMS');
    return Expanded(
        child:
        StreamBuilder(stream: itemCollectionDB.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int position) {
                    return Card(
                        child: detailTileWidget(snapshot,position)
                    );
                  }
              );
            })
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
        title: Text("Details for item ${widget.itemID}"),
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