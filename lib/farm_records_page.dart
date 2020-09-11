import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_farm_inventory/auth.dart';
import 'package:intl/intl.dart';

import 'home_page.dart';

AuthFireBase auth = AuthFireBase();

class RecordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        title: Text('Records Page'),
      ),
      body: ConnectivityWidgetWrapper(
        decoration: BoxDecoration(
            color: Colors.purple,
            gradient: LinearGradient(colors: [Colors.red, Colors.cyan])),
        child: Column(
          children: <Widget>[
            Card(
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: RichText(
                    text: TextSpan(
                        text: "For a consolidated Sales record, Please ",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        children: <TextSpan>[
                      TextSpan(
                          text: "Click Here",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 15,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      ConsolidatedSalesPage()));
                            }),
                    ])),
              ),
            ),
            Text(
              "Stock List",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.left,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text("S/N"),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text("Product"),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text("Quantity Available"),
                  )
                ],
              ),
            ),
            StreamBuilder(
                stream: Firestore.instance.collection('users')
                    .document(auth.currentUser.uid)
                    .collection("inventory")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: Column(
                        children: <Widget>[
                          CircularProgressIndicator(),
                          Padding(padding: const EdgeInsets.only(top: 10.0)),
                          Text("Loading...")
                        ],
//                              ),
                      ),
                    );
                  }

                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext buildContext, int index) {
                        DocumentSnapshot documentSnapshot =
                            snapshot.data.documents[index];
                        return Card(
                          // color: Theme.of(context).accentColor,
                          elevation: 1,
                          margin: EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 8),
                          child: InkWell(
                            onTap: () {
                              print(
                                  "Tapped: ${documentSnapshot['productName']}");
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      ProductHistory(
                                        productName:
                                        documentSnapshot['productName'],
                                      )));
                            },
                            splashColor: Colors.brown,
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Text("${index + 1}"),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                        documentSnapshot['productName']),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      documentSnapshot['quantity']
                                          .toString()
                                          .padLeft(5),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                })
          ],
        ),
      ),
    );
  }
}

class ProductHistory extends StatelessWidget {
  final String productName;

  ProductHistory({this.productName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        title: Text("$productName History"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.home,
            ),
            onPressed: () {
//              This will basically push a home and remove all the routes behind the new one
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => HomePage()));
            },
          )
        ],
      ),
      body: ConnectivityWidgetWrapper(
        decoration: BoxDecoration(
            color: Colors.purple, gradient: LinearGradient(colors: [
          Colors.red,
          Colors.cyan
        ])),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text("  "),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Date"),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Action"),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Quantity"),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Price",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('users')
                      .document(auth.currentUser.uid)
                      .collection("farm_records")
                      .where("productName", isEqualTo: productName)
                      .orderBy("dateTime", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Column(
                          children: <Widget>[
                            CircularProgressIndicator(),
                            Padding(padding: const EdgeInsets.only(top: 10.0)),
                            Text("Loading...")
                          ],
//                              ),
                        ),
                      );
                    }

                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext buildContext, int index) {
                          DocumentSnapshot documentSnapshot =
                          snapshot.data.documents[index];
                          Timestamp dateStamp = documentSnapshot['dateTime'];
                          DateTime date = dateStamp.toDate();
                          String formattedDate =
                          DateFormat('dd-MMM-yy').format(date);

                          String price = documentSnapshot['price'] != null
                              ? documentSnapshot['price'].toString()
                              : "-";

                          String quantity = documentSnapshot['quantity'] != null
                              ? documentSnapshot['quantity'].toString()
                              : "-";

                          Color quantityColor =
                          documentSnapshot['action'] == 'sale' &&
                              documentSnapshot['quantity'] != null
                              ? Colors.red
                              : Colors.green;

                          return Card(
                            elevation: 1,
                            margin: EdgeInsets.symmetric(vertical: 6.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      formattedDate,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(documentSnapshot['action']),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      quantity,
                                      style: TextStyle(color: quantityColor),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                        child: Text(
                                          price,
                                          textAlign: TextAlign.center,
                                        )),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  }),
            )
          ],
        ),
      ),
    );
  }
}

class ConsolidatedSalesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .accentColor,
      appBar: AppBar(
        title: Text("Sales History"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.home,
            ),
            onPressed: () {
//              This will basically push a home and remove all the routes behind the new one
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => HomePage()));
            },
          )
        ],
      ),
      body: ConnectivityWidgetWrapper(
        decoration: BoxDecoration(
            color: Colors.purple, gradient: LinearGradient(colors: [
          Colors.red,
          Colors.cyan
        ])),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text("  "),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text("Date"),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text("Action"),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text("Quantity"),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Price",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('users')
                      .document(auth.currentUser.uid)
                      .collection("farm_records")
                      .where("action", isEqualTo: "sale")
                      .orderBy("dateTime", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Column(
                          children: <Widget>[
                            CircularProgressIndicator(),
                            Padding(padding: const EdgeInsets.only(top: 10.0)),
                            Text("Loading...")
                          ],
//                              ),
                        ),
                      );
                    }

                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext buildContext, int index) {
                          DocumentSnapshot documentSnapshot =
                          snapshot.data.documents[index];
                          Timestamp dateStamp = documentSnapshot['dateTime'];
                          DateTime date = dateStamp.toDate();
                          String formattedDate =
                          DateFormat('dd-MMM-yy').format(date);

                          String price = documentSnapshot['price'] != null
                              ? documentSnapshot['price'].toString()
                              : "-";

                          Color quantityColor =
                          documentSnapshot['action'] == 'sale'
                              ? Colors.red
                              : Colors.green;

                          return Card(
                            elevation: 1,
                            margin: EdgeInsets.symmetric(vertical: 4.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      formattedDate,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                        documentSnapshot['productName']),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      documentSnapshot['quantity'].toString(),
                                      style: TextStyle(color: quantityColor),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                        child: Text(
                                          price,
                                          textAlign: TextAlign.center,
                                        )),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
