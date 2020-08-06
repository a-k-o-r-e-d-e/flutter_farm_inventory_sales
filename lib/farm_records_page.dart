import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'home_page.dart';

class RecordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stocks'),
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
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: Text(
                "List of Stocks",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
                textAlign: TextAlign.left,
              )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
          ),
          Row(
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
          StreamBuilder(
              stream: Firestore.instance.collection("inventory").snapshots(),
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
                        elevation: 1,
                        margin: EdgeInsets.symmetric(vertical: 12.0),
                        child: InkWell(
                          onTap: () {
                            print("Tapped: ${documentSnapshot['itemName']}");
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ProductHistory(
                                      productName: documentSnapshot['itemName'],
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
                                  child: Text(documentSnapshot['itemName']),
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
    );
  }
}

class ProductHistory extends StatelessWidget {
  final String productName;

  ProductHistory({this.productName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$productName History"),
      ),
      body: Column(
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
                    .collection("farm_records")
                    .where("product", isEqualTo: productName)
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

                        print(documentSnapshot['price'] == null);

                        return Card(
                          elevation: 1,
                          margin: EdgeInsets.symmetric(vertical: 6.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "${index + 1}",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(formattedDate),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(documentSnapshot['action']),
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
          )
        ],
      ),
    );
  }
}
