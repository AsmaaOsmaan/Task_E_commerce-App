import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerc/models/product.dart';
import 'package:e_commerc/screens/user/CartScreen.dart';
import 'package:e_commerc/screens/user/product_info.dart';
import 'package:e_commerc/services/auth.dart';
import 'package:e_commerc/widgets/product_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:e_commerc/constans.dart';
import 'package:e_commerc/services/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login_screen.dart';

class Home extends StatefulWidget {
  static String id = 'Home';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _auth = Auth();
  Store _store = Store();
  int bottomBarIndex = 0;
 List<Product> _products;
  FirebaseUser _loggedUser;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        DefaultTabController(
          length: 4,
          child: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: bottomBarIndex,
                onTap: (value)async {
                  if(value==2){
                    SharedPreferences pref= await SharedPreferences.getInstance();
                    pref.clear();
                    await _auth.SignOut();
                    Navigator.pushNamed(context,  LoginScreen.id);

                  }
                  setState(() {
                    bottomBarIndex = value;
                  });
                },
                fixedColor: KmainColor,
                items: [
                  BottomNavigationBarItem(
                      title: Text('test'), icon: Icon(Icons.person)),
                  BottomNavigationBarItem(
                      title: Text('test'), icon: Icon(Icons.person)),
                  BottomNavigationBarItem(
                      title: Text('Sign out'), icon: Icon(Icons.close)),

                ]),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,

            ),
           body:  ProductsView()

          ),
        ),
            Material(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'discover'.toUpperCase(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, CartScreen.id);
                    },
                    child: Icon(Icons.shopping_cart),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget ProductsView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _store.LoadProduct(), // function where you call your api
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text('Please wait its loading...'));
        } else {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else {
            List<Product> products = [];
            for (var doc in snapshot.data.documents) {
              var data = doc.data;
              products.add(Product(
                  pID: doc.documentID,
                  pPrice: data[KproductPrice],
                  pName: data[KproductName],
                  plocation: data[KproductLocation],
                  pDescription: data[KproductDescription],
                  pCategory: data[KproductCategory]));
            }
            _products = [...products];

            return ProductView2(_products); // snapshot.data  :
          }
        }
      },
    );
  }


  /*getCurrentUser()async{
    _loggedUser= await _auth.getUser();
  }*/
}
