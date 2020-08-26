import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

var dropDownValue;
StreamController<String> controller = StreamController<String>.broadcast();

class AddStockPage extends StatefulWidget {
  @override
  _AddStockPageState createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  TextEditingController _quantityTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Map<String, DocumentSnapshot> documents = HashMap();

  @override
  void dispose() {
    _quantityTextController.dispose();
    super.dispose();
  }

  void _handleAddStock() {
    if (formKey.currentState.validate()) {
      var quantity = int.parse(_quantityTextController.text);

      var farmRecordsCollection = Firestore.instance.collection('farm_records');
      Map<String, dynamic> farmRecordsMap = Map();
      farmRecordsMap.putIfAbsent('action', () => "addStock");
      farmRecordsMap.putIfAbsent('product', () => dropDownValue);
      farmRecordsMap.putIfAbsent('quantity', () => quantity);
      farmRecordsMap.putIfAbsent('dateTime', () => DateTime.now().toUtc());

      var documentSnapshot = documents[dropDownValue];
      Firestore.instance
          .runTransaction((transaction) async {
            DocumentSnapshot freshSnap =
                await transaction.get(documentSnapshot.reference);
            await transaction.update(freshSnap.reference,
                {'quantity': documentSnapshot['quantity'] + quantity});
            farmRecordsCollection.add(farmRecordsMap);
          })
          .whenComplete(() => showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                            "${_quantityTextController.text} $dropDownValue Successfully added to Inventory!"),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                              child: Text("Ok!"),
                              onPressed: () {
                                Navigator.pop(context);
                                formKey.currentState.reset();
                              }),
                        )
                      ],
                    ),
                  ),
                );
              }))
          .catchError((onError) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("Addition to Inventory failed!!"),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                                child: Text("Ok!"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  formKey.currentState.reset();
                                }),
                          )
                        ],
                      ),
                    ),
                  );
                });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Stock")),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildAvailableStockCard(context),
            SizedBox(
              height: 50,
            ),
            Card(
              margin: EdgeInsets.all(6.0),
              child: Container(
                color: Colors.teal[100],
                child: Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      ProductsDropdown(
                        products: documents,
                      ),
                      buildTextFormField(context,
                          hintText: "Enter Quantity",
                          textInputType: TextInputType.number,
                          labelText: "Quantity",
                          validator: (String val) =>
                          isInvalidNum(val)
                              ? "Please enter valid quantity"
                              : null,
                          textController: _quantityTextController),
                    ],
                  ),
                ),
              ),
            ),
            buildButton(
                context: context,
                btnText: "Add Items",
                btnIcon: Icons.add_shopping_cart,
                onBtnPressed: _handleAddStock),
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
  var netPriceText;

  Map<String, DocumentSnapshot> products = HashMap();

  Stream stream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _quanTextController.addListener(() {
      // This makes the net Price to recalculate each time quantity changes
      // Make sure dropDownValue is not null
      if (dropDownValue != null) {
        controller.add(dropDownValue);
      }
    });
    stream = controller.stream.asBroadcastStream();
  }

  void _handleSellStock() {
    final form = formKey.currentState;
    print(dropDownValue != null);
    if (form.validate()) {
      var quantity = int.parse(_quanTextController.text);
      var stockDocumentSnapshot = products[dropDownValue];
      var salesCollection = Firestore.instance.collection('farm_records');
      Map<String, dynamic> salesMap = Map();
      salesMap.putIfAbsent('action', () => 'sale');
      salesMap.putIfAbsent('product', () => dropDownValue);
      salesMap.putIfAbsent('price', () => netPriceText);
      salesMap.putIfAbsent('quantity', () => quantity);
      salesMap.putIfAbsent('dateTime', () => DateTime.now().toUtc());
      print(stockDocumentSnapshot['itemName']);
      Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap =
        await transaction.get(stockDocumentSnapshot.reference);
        await transaction.update(freshSnap.reference,
            {'quantity': stockDocumentSnapshot['quantity'] - quantity});
        salesCollection.add(salesMap);
      }).whenComplete(() =>
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("${_quanTextController
                            .text} $dropDownValue Successfully sold for $netPriceText Naira"),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                              child: Text("Ok!"),
                              onPressed: () {
                                Navigator.pop(context);
                                form.reset();
                              }),
                        )
                      ],
                    ),
                  ),
                );
              })).catchError((error, stackTrace) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("Transaction failed!!"),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                            child: Text("Ok!"),
                            onPressed: () {
                              Navigator.pop(context);
                              form.reset();
                            }),
                      )
                    ],
                  ),
                ),
              );
            });
      });
    }
  }

  bool isQuantityAvailable(val) {
    if (int.parse(val) <= products[dropDownValue]['quantity']) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _quanTextController.dispose();
    _priceTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sell Stock")),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildAvailableStockCard(context),
            Card(
              margin: EdgeInsets.all(6.0),
              child: Container(
                color: Theme
                    .of(context)
                    .accentColor,
                child: Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        ProductsDropdown(
                          products: products,
                        ),
                        Card(
                          margin: EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 8.0, left: 8.0, right: 8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding:
                                  const EdgeInsets.only(right: 15, top: 15),
                                  child: Text("Current Price: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                          Theme
                                              .of(context)
                                              .primaryColor)),
                                ),
                                Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 15, top: 15),
                                      child: StreamBuilder<String>(
                                          stream: controller.stream,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Text(
                                                products[snapshot.data]
                                                ['currentPrice']
                                                    .toString(),
                                              );
                                            }
                                            return Text(
                                              'Please Select an Item first',
                                            );
                                          })),
                                ),
                              ],
                            ),
                          ),
                        ),
                        buildTextFormField(context,
                            hintText: "Enter Quantity sold",
                            textInputType: TextInputType.number,
                            validator: (String val) {
                              if (isInvalidNum(val)) {
                                return "Please enter valid quantity";
                              } else if (!isQuantityAvailable(val)) {
                                return "Quantity sold is more than Quantity available";
                              }
                              return null;
                            },
                            labelText: "Quantity",
                            textController: _quanTextController),
                        Card(
                          margin: EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 8.0, left: 8.0, right: 8.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding:
                                  const EdgeInsets.only(right: 15, top: 15),
                                  child: Text("Net Price: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                          Theme
                                              .of(context)
                                              .primaryColor)),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 15),
                                    child: StreamBuilder<String>(
                                        stream: controller.stream,
                                        builder: (context, snapshot) {
                                          var text;
                                          if (snapshot.hasData) {
                                            if (_quanTextController
                                                .text.isNotEmpty) {
                                              netPriceText = products[snapshot
                                                  .data]['currentPrice'] *
                                                  int.parse(
                                                      _quanTextController.text);
                                              text = netPriceText.toString();
                                            } else {
                                              // No Quantity entered
                                              text =
                                              "Please enter a valid Amount";
                                            }
                                          } else {
                                            // No Item selected in dropdown
                                            text =
                                            'Please Select an Item first';
                                          }

                                          return Text(
                                            text,
                                          );
                                        }),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
            buildButton(
                context: context,
                btnText: "Sell Product",
                btnIcon: Icons.shopping_cart,
                onBtnPressed: _handleSellStock),
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
              style: Theme
                  .of(context)
                  .textTheme
                  .headline5
                  .copyWith(color: Theme
                  .of(context)
                  .primaryColor),
            ),
          ),
          Container(
            color: Colors.teal[150],
//            decoration: const BoxDecoration(
//              color: Colors.teal[100],
//            ),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              documentSnapshot['quantity'].toString().padLeft(5),
              style: Theme
                  .of(context)
                  .textTheme
                  .headline4
                  .copyWith(color: Theme
                  .of(context)
                  .primaryColor),
            ),
          )
        ],
      ),
    ),
  );
}

Widget _buildAvailableStockCard(BuildContext context) {
  return Card(
    margin: const EdgeInsets.all(8.0),
    child: Container(
      color: Colors.teal[100],
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              "Available Stock",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme
                      .of(context)
                      .primaryColor),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: StreamBuilder(
                  stream: controller.stream,
                  builder: (context, snapshot) {
                    Stream stream;
                    if (snapshot.hasData) {
                      stream = Firestore.instance
                          .collection("inventory")
                          .where('itemName', isEqualTo: snapshot.data)
                          .snapshots();
                    } else {
                      stream = Firestore.instance
                          .collection("inventory")
                          .limit(3)
                          .snapshots();
                    }
                    return StreamBuilder(
                        stream: stream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: ListView(
                                shrinkWrap: true,
                                children: <Widget>[
                                  CircularProgressIndicator(),
                                  Padding(
                                      padding:
                                      const EdgeInsets.only(top: 10.0)),
                                  Text("Loading...")
                                ],
//                              ),
                              ),
                            );
                          }

                          return ListView.builder(
//                            itemExtent: ,
                              shrinkWrap: true,
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (context, index) =>
                                  _buildListItem(
                                      context, snapshot.data.documents[index]));
                        });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildTextFormField(BuildContext context,
    {String hintText,
    String labelText,
    TextEditingController textController,
    TextInputType textInputType,
    Function validator}) {
  return Card(
    margin: EdgeInsets.all(8.0),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
      child: Row(
        children: <Widget>[
//        Text("$labelText: ", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
          Expanded(
            child: TextFormField(
              controller: textController,
              validator: validator,
              keyboardType: textInputType,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: Padding(
                    padding: EdgeInsets.only(right: 15, top: 15),
                    child: Text(
                      "$labelText:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme
                              .of(context)
                              .primaryColor),
                    )),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildButton({BuildContext context,
  String btnText,
  IconData btnIcon,
  Function onBtnPressed}) {
  return RaisedButton.icon(
    icon: Icon(
      btnIcon,
      color: Theme
          .of(context)
          .primaryColor,
    ),
    onPressed: onBtnPressed,
    label: Text(
      btnText,
      style: TextStyle(color: Theme
          .of(context)
          .primaryColor),
    ),
  );
}

class ProductsDropdown extends StatefulWidget {
  Map<String, DocumentSnapshot> products;
  String selectedItem;

  ProductsDropdown({this.products});

  @override
  _ProductsDropdownState createState() => _ProductsDropdownState();
}

class _ProductsDropdownState extends State<ProductsDropdown> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            StreamBuilder(
                stream: Firestore.instance.collection("inventory").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text("Loading....");
                  }

                  widget.products.clear();
                  var itemLists = List<String>.generate(
                      snapshot.data.documents.length, (int index) {
                    print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx");
                    widget.products.putIfAbsent(
                        snapshot.data.documents[index]['itemName'],
                            () => snapshot.data.documents[index]);
                    return snapshot.data.documents[index]['itemName'];
                  });
                  print("Keys: ${widget.products.keys}");
//                  controller.add("Test");
                  return Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(right: 15, top: 15),
                              child: Text(
                                "Select Item:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme
                                        .of(context)
                                        .primaryColor),
                              ))),
                      hint: Text(
                        "Select Item",
                      ),
                      value: widget.selectedItem,
                      elevation: 5,
                      items: widget.products.keys.map((String value) {
                        print(itemLists);
                        return DropdownMenuItem(
                            value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String newValue) {
                        controller.add(newValue);
                        setState(() {
                          dropDownValue = newValue;
                          print(dropDownValue);
                          widget.selectedItem = newValue;
                        });
                      },
                      validator: (value) =>
                      value == null
                          ? "Field required: Please select item from dropdown"
                          : null,
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

isInvalidNum(String val) {
  RegExp _numericPattern = RegExp(r'^[0-9]+$');
  // Pattern Checks if string is made up of only zeros
  RegExp _zeroPattern = RegExp(r'^0+$');
  if (val.isEmpty ||
      _zeroPattern.hasMatch(val) ||
      !_numericPattern.hasMatch(val) ||
      val == null) {
    return true;
  }
  return false;
}
