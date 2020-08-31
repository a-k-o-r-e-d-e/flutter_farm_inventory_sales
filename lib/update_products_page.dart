import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_farm_inventory/add_stock_sell_stock_pages.dart';

class UpdateProductsPage extends StatefulWidget {
  @override
  _UpdateProductsPageState createState() => _UpdateProductsPageState();
}

class _UpdateProductsPageState extends State<UpdateProductsPage> {
  var dropDownVal;
  List<String> options = ["Add New Product", "Update Product Price"];
  TextEditingController _quanTextController = TextEditingController();
  TextEditingController _priceTextController = TextEditingController();
  TextEditingController _productNameTextController = TextEditingController();

  int currentPage = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    dropDownVal = options[0];
    _pageController = PageController(initialPage: currentPage);
  }

  @override
  void dispose() {
    _quanTextController.dispose();
    _priceTextController.dispose();
    _productNameTextController.dispose();

    super.dispose();
  }

  _addNewProductCard(BuildContext context) {
    var formKey = GlobalKey<FormState>();

    return SingleChildScrollView(
      child: Card(
        color: Theme.of(context).accentColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Add New Product',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                buildTextFormField(context,
                    hintText: "Enter Product Name",
                    labelText: "Product Name",
                    textInputType: TextInputType.text,
                    textController: _productNameTextController,
                    validator: (String val) =>
                        val.isEmpty ? "Product Name is required" : null),
                buildTextFormField(context,
                    hintText: "Enter Available Quantity",
                    textController: _quanTextController,
                    textInputType: TextInputType.number,
                    labelText: "Quantity",
                    validator: (String val) =>
                        isInvalidNum(val) ? "Enter a valid number" : null),
                buildTextFormField(context,
                    hintText: "Enter Current Price",
                    textInputType: TextInputType.number,
                    labelText: "Price",
                    textController: _priceTextController,
                    validator: (String val) =>
                        isInvalidNum(val) ? "Enter a valid number" : null),
                SizedBox(
                  height: 15,
                ),
                Divider(),
                buildButton(
                    context: context,
                    btnText: "Add New Product",
                    btnIcon: Icons.add_shopping_cart,
                    onBtnPressed: () {
                      _handleAddProduct(formKey);
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _updateProductPrice(
      BuildContext context, Map<String, DocumentSnapshot> documents) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    ProductsDropdown productsDropdown = ProductsDropdown(
      products: documents,
    );

    return SingleChildScrollView(
      child: Card(
        color: Theme
            .of(context)
            .accentColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Update Product Price',
                  style: TextStyle(
                      color: Theme
                          .of(context)
                          .primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
//              ProductsDropdown(documents: documents,),
                productsDropdown,
                Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding:
                    const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 15, top: 15),
                          child: Text("Current Price: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme
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
                                      return Text(productsDropdown
                                          .products[snapshot.data]
                                      ['currentPrice']
                                          .toString()
//                                      products[snapshot.data]
//                                      ['currentPrice']
//                                          .toString(),
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
                    hintText: "Enter New Price",
                    labelText: "Price",
                    textInputType: TextInputType.number,
                    textController: _priceTextController,
                    validator: (String val) =>
                    isInvalidNum(val) ? "Enter a valid number" : null),
                SizedBox(
                  height: 15,
                ),
                Divider(),
                buildButton(
                    context: context,
                    btnText: "Add Product Price",
                    btnIcon: Icons.update,
                    onBtnPressed: () {
                      _handleProductPriceUpdate(
                        productsDropdown,
                        formKey,
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddProduct(GlobalKey<FormState> formKey) async {
    if (formKey.currentState.validate()) {
      var productName = _productNameTextController.text;
      // price & quantity columns should be numeric values
      var productPrice = int.parse(_priceTextController.text);
      var productQuantity = int.parse(_quanTextController.text);

      await Firestore.instance
          .collection('inventory')
          .where('itemName', isEqualTo: productName)
          .getDocuments()
          .then((value) {
        if (value.documents.isNotEmpty) {
          // that is product already exist in Inventory
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("Product Already Exist in Inventory"),
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
        } else {
          // if product doesn't exist
          var prodCollection = Firestore.instance.collection('inventory');
          var recordCollection = Firestore.instance.collection('farm_records');
          Map<String, dynamic> productMap = Map();
          productMap.putIfAbsent('itemName', () => productName);
          productMap.putIfAbsent('currentPrice', () => productPrice);
          productMap.putIfAbsent('quantity', () => productQuantity);

          Firestore.instance
              .runTransaction((transaction) async {
            prodCollection.add(productMap);
            recordCollection.add({
              'action': 'Product Created',
              'product': productName,
              'quantity': productQuantity,
              'currentPrice': productPrice,
              'dateTime': DateTime.now().toUtc(),
            });
          })
              .then((value) =>
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                                "The Product '$productName' has been created & added to inventory."),
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
              .catchError((error, stackTrace) {
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
      });
    }
  }

  void _handleProductPriceUpdate(
      ProductsDropdown productsDropdown, GlobalKey<FormState> formKey) {
    if (formKey.currentState.validate()) {
      // price column should be a numeric value
      var productPrice = int.parse(_priceTextController.text);
      var productName = _productNameTextController.text;

      var prodCollection = Firestore.instance.collection('farm_records');
//      Map<String, dynamic> productMap = Map();
//      productMap.putIfAbsent('currentPrice', () => productPrice);

      var documentSnapshot =
      productsDropdown.products[productsDropdown.selectedItem];
      var oldPrice = documentSnapshot['currentPrice'];
      Firestore.instance
          .runTransaction((transaction) async {
            DocumentSnapshot freshSnap =
                await transaction.get(documentSnapshot.reference);
            await transaction
                .update(freshSnap.reference, {'currentPrice': productPrice});
            prodCollection.add({
              'action': 'Price Change',
              'product': productName,
              'dateTime': DateTime.now().toUtc(),
              'oldPrice': oldPrice,
              'newPrice': productPrice
            });
      })
          .then((value) =>
          showDialog(
              context: context,
              builder: (BuildContext context) {
                // The line below ensures that the dropdown resets
                controller.add(productsDropdown.selectedItem);
                return AlertDialog(
                  content: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                            "The current Price of $productName has been updated to $productPrice in inventory."),
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
          .catchError((error, stackTrace) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("Price change unsuccessful !!"),
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

  moveToPage({int pageIndex}) {
    if (pageIndex < options.length) {
      setState(() {
        dropDownVal = options.elementAt(pageIndex);
      });
    }
    _pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.bounceInOut);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, DocumentSnapshot> documents = HashMap();

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Products'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
//              color: Theme.of(context).accentColor,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    prefixIcon: Padding(
                        padding: EdgeInsets.only(right: 15, left: 15, top: 15),
                        child: Text(
                          "Select Action:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                        ))),
                hint: Text(
                  "Select Action",
                ),
                value: dropDownVal,
                elevation: 5,
                items: options.map((String value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (String newValue) {
                  controller.add(newValue);
                  setState(() {
                    int newPageIndex = options.indexOf(newValue);
                    _pageController.animateToPage(newPageIndex,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.bounceInOut);
                    this.dropDownVal = newValue;
                  });
                },
                validator: (value) =>
                value == null
                    ? "Field required: Please select item from dropdown"
                    : null,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  print("Back Clicked");
                  moveToPage(pageIndex: --currentPage);
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  print("Front Clicked");
                  moveToPage(pageIndex: ++currentPage);
                },
              ),
            ],
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Padding(
              padding: EdgeInsets.all(8.0),
//              child: _updateProductPrice(context, documents),
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;

                    if (index < options.length) {
                      dropDownVal = options.elementAt(index);
                    }
                  });
                },
                children: [
                  _addNewProductCard(context),
                  _updateProductPrice(context, documents),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
