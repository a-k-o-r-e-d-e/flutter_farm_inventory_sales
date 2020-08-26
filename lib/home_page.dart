import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_stock_sell_stock_pages.dart';
import 'auth.dart';
import 'drawer_util.dart';
import 'farm_records_page.dart';
import 'login_signup_pages.dart';
import 'update_products_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        drawer: DrawerUtil(),
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <
                Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 8,
              child: Container(
                height: 260,
                child: StreamBuilder(
                    stream: Firestore.instance
                        .collection("farm_records")
                        .where("action", isEqualTo: "sale")
                        .orderBy("dateTime", descending: true)
                        .limit(5)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: ListView(
                            children: <Widget>[
                              CircularProgressIndicator(),
                              Padding(
                                  padding: const EdgeInsets.only(top: 10.0)),
                              Text("Loading...")
                            ],
                          ),
                        );
                      }
                      List sales = List.generate(snapshot.data.documents.length,
                          (index) => snapshot.data.documents[index]['price']);
                      int totalSales = sales.fold(0,
                          (previousValue, current) => previousValue + current);
                      print(snapshot.data.documents[0]['dateTime']);
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          Container(
                            color: Colors.teal[100],
                            width: 340,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(3.5),
                                  child: Center(
                                    child: Text(
                                      "Recently Sold",
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Divider(),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.documents.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
//                                            flex: 2,
                                              child: Text("Date",
                                                  style: TextStyle(
                                                      color: Colors.teal,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text("Time",
                                                    style: TextStyle(
                                                        color: Colors.teal,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            ),
                                            Expanded(
//                                            flex: 2,
                                              child: Text("Product",
                                                  style: TextStyle(
                                                      color: Colors.teal,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            Expanded(
                                              child: Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 8),
                                                  child: Text('Qty',
                                                      style: TextStyle(
                                                          color: Colors.teal,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                            ),
                                            Expanded(
                                              child: Text('Price',
                                                  style: TextStyle(
                                                      color: Colors.teal,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                    index -= 1;

                                    DocumentSnapshot documentSnap =
                                        snapshot.data.documents[index];
                                    Timestamp dateStamp =
                                        documentSnap['dateTime'];
//                                print(dateStamp);
                                    DateTime date = dateStamp.toDate();
                                    String formattedDate =
                                        DateFormat('dd-MMM-yy').format(date);
                                    String formattedTime =
                                        DateFormat('kk:mm').format(date);

                                    return Card(
                                      elevation: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
//                                            flex: 2,
                                              child: Text(formattedDate),
                                            ),
                                            Expanded(
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(formattedTime),
                                              ),
                                            ),
                                            Expanded(
//                                            flex: 2,
                                              child: Text(
                                                documentSnap['product'],
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(
                                                    documentSnap['quantity']
                                                        .toString()),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(documentSnap['price']
                                                  .toString()),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            color: Colors.blue,
                            width: 350,
                            child:
                                Center(child: Text("Total Sales: $totalSales")),
                          )
                        ],
                      );
                    }),
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                shrinkWrap: true,
                children: [
                  RaisedButton.icon(
                    color: Colors.teal[100],
                    icon:
                        Icon(Icons.book, color: Theme.of(context).primaryColor),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => RecordPage()));
                    },
                    label: Text("Records"),
                  ),
                  RaisedButton.icon(
                      color: Colors.teal[100],
                      icon: Icon(
                        Icons.business_center,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => UpdateProductsPage()));
                      },
                      label: Text("Update Products")),
                  RaisedButton.icon(
                    color: Colors.teal[100],
                    icon: Icon(
                      Icons.shopping_cart,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SellStockPage()));
                    },
                    label: Text("Sell"),
                  ),
                  RaisedButton.icon(
                    color: Colors.teal[100],
                    icon: Icon(
                      Icons.add_shopping_cart,
                      color: Theme
                          .of(context)
                          .primaryColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AddStockPage()));
                    },
                    label: Text("Add Stock"),
                  )
                    ],
                  ),
                ),
              ),
//          Expanded(
//            child: Container(
//              color: Colors.blue,
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                children: <Widget>[
//                  Expanded(
//                    child: RaisedButton.icon(
//                      icon: Icon(Icons.book,
//                          color: Theme.of(context).primaryColor),
//                      onPressed: () {
//                        Navigator.of(context).push(MaterialPageRoute(
//                            builder: (context) => RecordPage()));
//                      },
//                      label: Text("Records"),
//                    ),
//                  ),
//                  Expanded(
//                    child: RaisedButton(
//                        onPressed: () {
////                    Navigator.of(context).push(
////                        MaterialPageRoute(builder: (context) => SalesPage()));
//                        },
//                        child: Text("Update Products")),
//                  )
//                ],
//              ),
//            ),
//          ),
//          Expanded(
//            child: Container(
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                children: <Widget>[
//                  Expanded(
//                    child: RaisedButton.icon(
//                      icon: Icon(
//                        Icons.shopping_cart,
//                        color: Theme.of(context).primaryColor,
//                      ),
//                      onPressed: () {
//                        Navigator.of(context).push(MaterialPageRoute(
//                            builder: (context) => SellStockPage()));
//                      },
//                      label: Text("Sell"),
//                    ),
//                  ),
//                  RaisedButton.icon(
//                    icon: Icon(
//                      Icons.add_shopping_cart,
//                      color: Theme.of(context).primaryColor,
//                    ),
//                    onPressed: () {
//                      Navigator.of(context).push(MaterialPageRoute(
//                          builder: (context) => AddStockPage()));
//                    },
//                    label: Text("Add Stock"),
//                  )
//                ],
//              ),
//            ),
//          ),
            ]));
  }
}

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
        stream: AuthFireBase().onAuthStateChanged,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final bool isLoggedIn = snapshot.hasData;
//            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            print("isLoggedIn: $isLoggedIn");

            return isLoggedIn ? HomePage() : LoginPage();
          }
          return Scaffold(
              appBar: AppBar(),
              body: Center(child: CircularProgressIndicator()));
        });
  }
}
