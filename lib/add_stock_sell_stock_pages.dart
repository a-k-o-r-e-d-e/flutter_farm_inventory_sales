import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

var dropDownValue;

class AddStockPage extends StatefulWidget {
  @override
  _AddStockPageState createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  TextEditingController _quantityTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _quantityTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, DocumentSnapshot> documents = HashMap();
    return Scaffold(
      appBar: AppBar(title: Text("Add Stock")),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildAvailableStockCard(),
            SizedBox(
              height: 50,
            ),
            Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  _buildItemsDropdown(
                    documents: documents,
                  ),
                  _buildTextFormField(
                      hintText: "Enter Quantity",
                      labelText: "Quantity",
                      validator: (String val) => _isInvalidText(val)
                          ? "Please enter valid quantity"
                          : null,
                      textController: _quantityTextController),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () {
                if (formKey.currentState.validate()) {
                  var quantity = int.parse(_quantityTextController.text);

                  var farmRecordsCollection =
                      Firestore.instance.collection('farm_records');
                  Map<String, dynamic> farmRecordsMap = Map();
                  farmRecordsMap.putIfAbsent('action', () => "addStock");
                  farmRecordsMap.putIfAbsent('product', () => dropDownValue);
                  farmRecordsMap.putIfAbsent('quantity', () => quantity);
                  farmRecordsMap.putIfAbsent(
                      'dateTime', () => DateTime.now().toUtc());

                  var documentSnapshot = documents[dropDownValue];
//                print("XXX: ${documentSnapshot['itemName']}");
                  Firestore.instance.runTransaction((transaction) async {
                    DocumentSnapshot freshSnap =
                        await transaction.get(documentSnapshot.reference);
                    await transaction.update(freshSnap.reference,
                        {'quantity': documentSnapshot['quantity'] + quantity});
                    farmRecordsCollection.add(farmRecordsMap);
                  });
                }
              },
              child: Text("Add Items"),
            )
          ],
        ),
      ),
    );
  }
}

class SellStockPage extends StatefulWidget {
  @override
  _SellStockPageState createState() => _SellStockPageState();
}

class _SellStockPageState extends State<SellStockPage> {
  var formKey = GlobalKey<FormState>();

  TextEditingController _quanTextController = TextEditingController();
  TextEditingController _priceTextController = TextEditingController();

  @override
  void dispose() {
    _quanTextController.dispose();
    _priceTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, DocumentSnapshot> documents = HashMap();
    return Scaffold(
      appBar: AppBar(title: Text("Sell Stock")),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildAvailableStockCard(),
            Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    _buildItemsDropdown(
                      documents: documents,
                    ),
                    _buildTextFormField(
                        hintText: "Enter Quantity sold",
                        validator: (String val) => _isInvalidText(val)
                            ? "Please enter valid quantity"
                            : null,
                        labelText: "Quantity",
                        textController: _quanTextController),
                    _buildTextFormField(
                        hintText: "Enter price of items sold",
                        validator: (val) => _isInvalidText(val)
                            ? "Please enter valid quantity"
                            : null,
                        labelText: "Price",
                        textController: _priceTextController),
                  ],
                )),
            RaisedButton(
              onPressed: () {
                final form = formKey.currentState;
                print(dropDownValue != null);
                if (form.validate()) {
                  var quantity = int.parse(_quanTextController.text);
                  var stockDocumentSnapshot = documents[dropDownValue];
                  var salesCollection =
                      Firestore.instance.collection('farm_records');
                  Map<String, dynamic> salesMap = Map();
                  salesMap.putIfAbsent('action', () => 'sale');
                  salesMap.putIfAbsent('product', () => dropDownValue);
                  salesMap.putIfAbsent(
                      'price', () => int.parse(_priceTextController.text));
                  salesMap.putIfAbsent('quantity', () => quantity);
                  salesMap.putIfAbsent(
                      'dateTime', () => DateTime.now().toUtc());
                  print(stockDocumentSnapshot['itemName']);
                  Firestore.instance.runTransaction((transaction) async {
                    DocumentSnapshot freshSnap =
                        await transaction.get(stockDocumentSnapshot.reference);
                    await transaction.update(freshSnap.reference, {
                      'quantity': stockDocumentSnapshot['quantity'] - quantity
                    });
                    salesCollection.add(salesMap);
                  });
                }
              },
              child: Text("Sell Product"),
            )
          ],
        ),
      ),
    );
  }
}

Widget _buildListItem(BuildContext context, DocumentSnapshot documentSnapshot) {
  return Material(
    child: ListTile(
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              documentSnapshot['itemName'],
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xffddddff),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              documentSnapshot['quantity'].toString().padLeft(5),
              style: Theme.of(context).textTheme.display1,
            ),
          )
        ],
      ),
    ),
  );
}

Widget _buildAvailableStockCard() {
  return Column(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          "Available Stock",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 125,
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: StreamBuilder(
                  stream:
                      Firestore.instance.collection("inventory").snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: ListView(
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
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) => _buildListItem(
                            context, snapshot.data.documents[index]));
                  }),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildTextFormField(
    {String hintText,
    String labelText,
    TextEditingController textController,
    Function validator}) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: TextFormField(
      controller: textController,
      validator: validator,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Padding(
            padding: EdgeInsets.only(right: 15, top: 15),
            child: Text(
              "$labelText:",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
      ),
    ),
  );
}

class _buildItemsDropdown extends StatefulWidget {
  Map<String, DocumentSnapshot> documents;

  _buildItemsDropdown({this.documents});

  @override
  __buildItemsDropdownState createState() => __buildItemsDropdownState();
}

class __buildItemsDropdownState extends State<_buildItemsDropdown> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text("Select Item: "),
        StreamBuilder(
            stream: Firestore.instance.collection("inventory").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text("Loading....");
              }

              var itemLists = List<String>.generate(
                  snapshot.data.documents.length, (int index) {
                widget.documents.putIfAbsent(
                    snapshot.data.documents[index]['itemName'],
                    () => snapshot.data.documents[index]);
                return snapshot.data.documents[index]['itemName'];
              });
              print("Keys: ${widget.documents.keys}");

              return Expanded(
                child: DropdownButtonFormField<String>(
                  hint: Text("Select Item"),
                  value: dropDownValue,
                  elevation: 5,
                  items: widget.documents.keys.map((String value) {
                    print(itemLists);
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String newValue) {
                    setState(() {
                      dropDownValue = newValue;
                      print(dropDownValue);
                    });
                  },
                  validator: (value) => value == null
                      ? "Field required: Please select item from dropdown"
                      : null,
                ),
              );
            }),
      ],
    );
  }
}

_isInvalidText(String val) {
  RegExp _numericPattern = RegExp(r'^[0-9]+$');

  if (val.isEmpty || !_numericPattern.hasMatch(val) || val == null) {
    return true;
  }
  return false;
}
