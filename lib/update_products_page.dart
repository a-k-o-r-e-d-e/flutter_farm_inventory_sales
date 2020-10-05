import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_farm_inventory/add_stock_sell_stock_pages.dart';
import 'package:flutter_farm_inventory/util_functions.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class UpdateProductsPage extends StatefulWidget {
  @override
  _UpdateProductsPageState createState() => _UpdateProductsPageState();
}

class _UpdateProductsPageState extends State<UpdateProductsPage> {
  var dropDownVal;
  List<String> options = ["Add New Product", "Update Product Price"];
  TextEditingController _quantityTextController = TextEditingController();
  TextEditingController _priceTextController = TextEditingController();
  TextEditingController _productNameTextController = TextEditingController();

  GlobalKey<FormState> updatePriceFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> addProductFormKey = GlobalKey<FormState>();

  Map<String, DocumentSnapshot> documents = HashMap();
  ProductsDropdown productsDropdown;

  bool _loading = false;
  int currentPage = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    dropDownVal = options[0];
    _pageController = PageController(initialPage: currentPage);
    productsDropdown = ProductsDropdown(
      products: documents,
    );
  }

  @override
  void dispose() {
    _quantityTextController.dispose();
    _priceTextController.dispose();
    _productNameTextController.dispose();

    super.dispose();
  }

  _addNewProductCard(BuildContext context) {

    return SingleChildScrollView(
      child: Card(
        color: Theme.of(context).accentColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: addProductFormKey,
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
                    textController: _quantityTextController,
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
                      submitForm(context, addProductFormKey, _handleAddProduct);
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
    return SingleChildScrollView(
      child: Card(
        color: Theme
            .of(context)
            .accentColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: updatePriceFormKey,
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
                                          .data()['currentPrice']
                                          .toString()
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
                    btnText: "Update Product Price",
                    btnIcon: Icons.update,
                    onBtnPressed: () {
                      submitForm(context, updatePriceFormKey,
                          _handleProductPriceUpdate);
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Internet Connectivity test and Form Validation should have been done already before calling this method
  void _handleAddProduct() async {
    _loading = true;

    var productName = _productNameTextController.text;
    // price & quantity columns should be numeric values
    var productPrice = int.parse(_priceTextController.text);
    var productQuantity = int.parse(_quantityTextController.text);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser.uid)
        .collection('inventory')
        .where('productName', isEqualTo: productName)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        // that is product already exist in Inventory
        String message = "Product Already Exist in Inventory";
        String btnText = "Add another Product";

        showMyDialog(context, message, btnText, addProductFormKey);
      } else {
        // if product doesn't exist
        var prodCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser.uid)
            .collection('inventory');
        var recordCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser.uid)
            .collection('farm_records');
        Map<String, dynamic> productMap = Map();
        productMap.putIfAbsent('productName', () => productName);
        productMap.putIfAbsent('currentPrice', () => productPrice);
        productMap.putIfAbsent('quantity', () => productQuantity);

        FirebaseFirestore.instance
            .runTransaction((transaction) async {
          prodCollection.add(productMap);
          recordCollection.add({
            'action': 'Product Created',
            'productName': productName,
            'quantity': productQuantity,
            'currentPrice': productPrice,
            'dateTime': DateTime.now().toUtc(),
          });
        })
            .then((value) {
          String message = "The Product '$productName' has been created & added to inventory.";
          String btnText = "Add another Product";

          showMyDialog(context, message, btnText, addProductFormKey);
        })
            .catchError((error, stackTrace) {
          String message = "Operation failed!!";
          String btnText = "Try Again";


          showMyDialog(context, message, btnText, addProductFormKey);
        });
      }
    }).whenComplete(() => _loading = false);
  }


  // Internet Connectivity test and Form Validation should have been done already before calling this method
  void _handleProductPriceUpdate() {
    _loading = true;

    // price column should be a numeric value
    var productPrice = int.parse(_priceTextController.text);
    var productName = productsDropdown.selectedItem;

    var prodCollection = FirebaseFirestore.instance.collection('users')
        .doc(auth.currentUser.uid).collection('farm_records');

    var documentSnapshot =
    productsDropdown.products[productsDropdown.selectedItem];
    var oldPrice = documentSnapshot.data()['currentPrice'];
    FirebaseFirestore.instance
        .runTransaction((transaction) async {
      DocumentSnapshot freshSnap =
      await transaction.get(documentSnapshot.reference);
      transaction
          .update(freshSnap.reference, {'currentPrice': productPrice});
      prodCollection.add({
        'action': 'Price Change',
        'productName': productName,
        'dateTime': DateTime.now().toUtc(),
        'oldPrice': oldPrice,
        'newPrice': productPrice
      });
    })
        .then((value) {
      String message = "The current Price of $productName has been updated to $productPrice in inventory.";
      String btnText = "Update another Product";

      showMyDialog(context, message, btnText, updatePriceFormKey);
    }
    )
        .catchError((error, stackTrace) {
      String message = "Price change unsuccessful !!";
      String btnText = "Try Again";
      showMyDialog(context, message, btnText, updatePriceFormKey);
    }).whenComplete(() => _loading = false);
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Products'),
      ),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        prefixIcon: Padding(
                            padding: EdgeInsets.only(
                                right: 15, left: 15, top: 15),
                            child: Text(
                              "Select Action:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme
                                      .of(context)
                                      .primaryColor),
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
                    // button is grey and disabled if we on the first page
                    color: currentPage == 0 ? Colors.grey : Theme
                        .of(context)
                        .primaryColor,
                    onPressed: currentPage == 0 ? null : () {
                      print("Back Clicked");
                      moveToPage(pageIndex: --currentPage);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    // button is grey and disabled if we on the last page
                    color: currentPage == (options.length - 1)
                        ? Colors.grey
                        : Theme
                        .of(context)
                        .primaryColor,
                    onPressed: currentPage == (options.length - 1) ? null : () {
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
        ),
      ),
    );
  }
}
