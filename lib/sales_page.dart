import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_farm_inventory/main.dart';

class SalesPage extends StatelessWidget {
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
            ],
          ),
          StreamBuilder(
              stream: Firestore.instance.collection("farm_records").snapshots(),
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
                      return Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text("${index + 1}"),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(documentSnapshot['itemName']),
                          ),
                        ],
                      );
                    });
              })
        ],
      ),
    );
  }
}
