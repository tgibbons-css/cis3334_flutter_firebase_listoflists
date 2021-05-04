import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';        // for Firebase
import 'package:firebase_auth/firebase_auth.dart';        // for Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart';    // for Firebase Firestore
import 'package:google_sign_in/google_sign_in.dart';

import 'authentication.dart';
import 'detail_display.dart';
import 'shopping_item.dart';

//void main() {
//  runApp(MyApp());
//}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FireStore Demo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirebaseDemo(),
    );
  }
}

class FirebaseDemo extends StatefulWidget {
  @override
  _FirebaseDemoState createState() => _FirebaseDemoState();
}

class _FirebaseDemoState extends State<FirebaseDemo> {
  final TextEditingController _newItemTextField = TextEditingController();
  CollectionReference itemCollectionDB = FirebaseFirestore.instance.collection('ITEMS');
  String userID;       //  Added for Firebase Authentication

  //List<String> itemList = [];
  authenticationStuff authStuff = new authenticationStuff();

  Widget nameTextFieldWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.7,
      child: TextField(
        controller: _newItemTextField,
        style: TextStyle(fontSize: 22, color: Colors.black),
        decoration: InputDecoration(
          hintText: "Item Name",
          hintStyle: TextStyle(fontSize: 22, color: Colors.black),
        ),
      ),
    );
  }

  Widget addButtonWidget() {
    return SizedBox(
      child: ElevatedButton(
          onPressed: () async {
            String listName = _newItemTextField.text;
            ShoppingList shoppingList = new ShoppingList(listName);
            await itemCollectionDB.add({'ShoppingList': shoppingList});
            _newItemTextField.clear();
          },
          child: Text(
            'Add Data',
            style: TextStyle(fontSize: 20),
          )),
    );
  }

  Widget itemInputWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        nameTextFieldWidget(),
        SizedBox(width: 10,),
        addButtonWidget(),
      ],
    );
  }

  Widget itemTileWidget(snapshot, position) {
    ShoppingList shoppingList = snapshot.data.docs[position]['ShoppingList'];
    return ListTile(
      leading: Icon(Icons.check_box),
      title: Text(shoppingList.listName),
      onTap: () {
        setState(() {
          print("You tapped at postion =  $position");
          String listId = snapshot.data.docs[position].id;
          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailDisplay(itemID: listId,)));
        });
      },
      onLongPress: () {
        print("You long pressed at postion =  $position");
        String listId = snapshot.data.docs[position].id;
        itemCollectionDB.doc(listId).delete();
      },
    );
  }

  Widget itemListWidget() {
    return Expanded(
        child:
        StreamBuilder(stream: itemCollectionDB.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int position) {
                    return Card(
                        child: itemTileWidget(snapshot,position)
                    );
                  }
              );
            })
    );
  }

  Widget logoutButton() {
    return ElevatedButton(
        onPressed: ()
        async {
          //setState(() async {
          await FirebaseAuth.instance.signOut();
          print ("Button Logout");
          // });
        },
        child: Text(
          'Logout',
          style: TextStyle(fontSize: 20),
        )
    );
  }

  Widget mainScreen() {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 50),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            itemInputWidget(),
            SizedBox(height: 40,),
            itemListWidget(),
            logoutButton(),
          ],
        ),
      ),
    );
  }

  Widget loginScreen() {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 50),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Text("Not Logged in"),
            ElevatedButton(
                onPressed: ()
                async {
                  //setState(() async {
                  // do authenication
                  await authStuff.signInWithGoogle();
                  userID = authStuff.getUserID();
                  print ("Button onPressed DONE");
                  // });
                },
                child: Text(
                  'Log in with Google',
                  style: TextStyle(fontSize: 20),
                )
            ),
            logoutButton(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if(snapshot.hasData) {
          print("Main builder -- User exists");
          userID = FirebaseAuth.instance.currentUser.uid;
          itemCollectionDB = FirebaseFirestore.instance.collection('USERS').doc(userID).collection('TEST_ITEMS');
          return mainScreen();
        }
        else {
          print("Main builder -- need to login");
          return loginScreen();
        }
      },
    );


  }

}

