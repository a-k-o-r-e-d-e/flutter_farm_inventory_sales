import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_farm_inventory/auth.dart';
import 'package:flutter_farm_inventory/update_products_page.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'util_functions.dart';

var dropDownValue;
StreamController<String> controller = StreamController<String>.broadcast();

AuthFireBase auth = AuthFireBase();

class AddStockPage extends StatefulWidget {
  @override
  _AddStockPageState createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  TextEditingController _quantityTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Map<String, DocumentSnapshot> documents = HashMap();

  bool _loading = false;

  @override
  void dispose() {
    _quantityTextController.dispose();
    super.dispose();
  }

  toggleLoading() {
    setState(() {
      _loading = !_loading;
    });
  }

  // Internet Connectivity test and Form Validation should have been done already before calling this method
  void _handleAddStock() async {
    toggleLoading();

    var quantity = int.parse(_quantityTextController.text);

    var farmRecordsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser.uid)
        .collection('farm_records');

    Map<String, dynamic> farmRecordsMap = Map();
    farmRecordsMap.putIfAbsent('action', () => "addStock");
    farmRecordsMap.putIfAbsent('productName', () => dropDownValue);
    farmRecordsMap.putIfAbsent('quantity', () => quantity);
    farmRecordsMap.putIfAbsent('dateTime', () => DateTime.now().toUtc());

    var documentSnapshot = documents[dropDownValue];
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap =
          await transaction.get(documentSnapshot.reference);
      transaction.update(freshSnap.reference,
          {'quantity': documentSnapshot.data()['quantity'] + quantity});
      farmRecordsCollection.add(farmRecordsMap);
    }).then((_) {
      var message =
          "${_quantityTextController.text} $dropDownValue Successfully added to Inventory!";
      var btnText = "Add more Stock";

      showMyDialog(context, message, btnText, formKey);
    }).catchError((onError) {
      var message = "Addition to Inventory failed!!";
      var btnText = "Try Again";

      showMyDialog(context, message, btnText, formKey);
    }).whenComplete(() => toggleLoading());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Stock")),
      body: ConnectivityWidgetWrapper(
        decoration: BoxDecoration(color: Colors.purple,
            gradient: LinearGradient(colors: [Colors.red, Colors.cyan])),
        child: ModalProgressHUD(
          inAsyncCall: _loading,
          opacity: 0.9,
          color: Colors.transparent,
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme
                .of(context)
                .primaryColor),
          ),
          child: Column(
            children: <Widget>[
              Expanded(flex: 1, child: _buildAvailableStockCard(context)),
              SizedBox(
                height: 50,
              ),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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
                          onBtnPressed: () {
                            submitForm(context, formKey, _handleAddStock);
                          }),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  TextEditingController _qtyTxtController = TextEditingController();
  TextEditingController _priceTxtController = TextEditingController();
  var netPriceTxt;
  bool _loading = false;

  Map<String, DocumentSnapshot> products = HashMap();

  Stream stream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _qtyTxtController.addListener(() {
      // This makes the net Price to recalculate each time quantity changes
      // Make sure dropDownValue is not null
      if (dropDownValue != null) {
        controller.add(dropDownValue);
      }
    });
    stream = controller.stream.asBroadcastStream();
  }

  toggleLoading() {
    setState(() {
      _loading = !_loading;
    });
  }

  // Internet Connectivity test and Form Validation should have been done already before calling this method
  void _handleSellStock() async {
    toggleLoading();

    var quantity = int.parse(_qtyTxtController.text);
    var stockDocumentSnapshot = products[dropDownValue];
    var salesCollection = FirebaseFirestore.instance.collection('users')
        .doc(auth.currentUser.uid).collection('farm_records');
    Map<String, dynamic> salesMap = Map();
    salesMap.putIfAbsent('action', () => 'sale');
    salesMap.putIfAbsent('productName', () => dropDownValue);
    salesMap.putIfAbsent('price', () => netPriceTxt);
    salesMap.putIfAbsent('quantity', () => quantity);
    salesMap.putIfAbsent('dateTime', () => DateTime.now().toUtc());
    print(stockDocumentSnapshot.data()['productName']);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap =
      await transaction.get(stockDocumentSnapshot.reference);
      transaction.update(freshSnap.reference, {
        'quantity': stockDocumentSnapshot.data()['quantity'] - quantity
      });
      salesCollection.add(salesMap);
    }).then((_) {
      var message = "${_qtyTxtController
          .text} $dropDownValue Successfully sold for $netPriceTxt Naira";
      var btnText = "Make another sale";

      showMyDialog(context, message, btnText, formKey);
    }
    ).catchError((error, stackTrace) {
      var message = "Transaction failed!!";
      var btnText = "Try Again";

      showMyDialog(context, message, btnText, formKey);
    }).whenComplete(() => toggleLoading());
  }


  bool isQuantityAvailable(val) {
    if (int.parse(val) <= products[dropDownValue].data()['quantity']) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _qtyTxtController.dispose();
    _priceTxtController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sell Stock")),
      body: ConnectivityWidgetWrapper(
        decoration: BoxDecoration(color: Colors.purple,
            gradient: LinearGradient(colors: [Colors.red, Colors.cyan])),
        child: ModalProgressHUD(
          inAsyncCall: _loading,
          opacity: 0.9,
          color: Colors.transparent,
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme
                .of(context)
                .primaryColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(flex: 1, child: _buildAvailableStockCard(context)),
              SizedBox(
                height: 30,
              ),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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
                                            const EdgeInsets.only(
                                                right: 15, top: 15),
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
                                                    builder: (context,
                                                        snapshot) {
                                                      if (snapshot.hasData) {
                                                        return Text(
                                                          products[snapshot
                                                              .data]
                                                              .data()['currentPrice']
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
                                      textController: _qtyTxtController),
                                  Card(
                                    margin: EdgeInsets.all(8.0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, left: 8.0, right: 8.0),
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                right: 15, top: 15),
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
                                                      if (_qtyTxtController
                                                          .text.isNotEmpty) {
                                                        // products[snapshot.data]['currentPrice'] should be a number on Database else an error occurs
                                                        netPriceTxt = products[
                                                        snapshot.data].data()
                                                        ['currentPrice'] *
                                                            int.parse(
                                                                _qtyTxtController
                                                                    .text);
                                                        text = netPriceTxt
                                                            .toString();
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
                          onBtnPressed: () {
                            submitForm(context, formKey, _handleSellStock);
                          }),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
              documentSnapshot.data()['productName'],
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
            padding: EdgeInsets.only(right: 5),
            child: Text(
              documentSnapshot.data()['quantity'].toString().padLeft(5),
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
      color: Theme
          .of(context)
          .accentColor,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: StreamBuilder(
                    stream: controller.stream,
                    builder: (context, snapshot) {
                      Stream stream;
                      if (snapshot.hasData) {
                        stream = FirebaseFirestore.instance
                            .collection('users')
                            .doc(auth.currentUser.uid)
                            .collection("inventory")
                            .where('productName', isEqualTo: snapshot.data)
                            .snapshots();
                      } else {
                        stream = FirebaseFirestore.instance
                            .collection('users')
                            .doc(auth.currentUser.uid)
                            .collection("inventory")
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

                            return snapshot.data.docs.isEmpty
                                ? Container(
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(
                                    text:
                                    "No Farm Products Found In Database. Please you have to ",
                                    style: DefaultTextStyle
                                        .of(context)
                                        .style,
                                    children: <TextSpan>[
                                      TextSpan(text: "create a product",
                                          style: TextStyle(
                                              decoration: TextDecoration
                                                  .underline, color: Theme
                                              .of(context)
                                              .primaryColor),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          UpdateProductsPage()));
                                            }),
                                      TextSpan(
                                          text: " first before you can continue")
                                    ]),

                              ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: snapshot.data.docs.length,
                                    itemBuilder: (context, index) =>
                                        _buildListItem(context,
                                            snapshot.data.docs[index]));
                          });
                    },
                  ),
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
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users')
                    .doc(auth.currentUser.uid)
                    .collection("inventory")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text("Loading....");
                  }

                  widget.products.clear();

                  snapshot.data.docs.forEach((element) {
                    widget.products.putIfAbsent(
                        element.data()['productName'], () => element);
                  });
                  print("Keys: ${widget.products.keys}");

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
                      hint: widget.products.isEmpty
                          ? Text("No Products found ")
                          : Text(
                        "Select Item",
                      ),
                      value: widget.selectedItem,
                      elevation: 5,
                      items: widget.products.keys.map((String value) {
                        // print(itemLists);
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
