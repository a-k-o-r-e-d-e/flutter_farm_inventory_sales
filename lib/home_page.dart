import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_stock_sell_stock_pages.dart';
import 'auth.dart';
import 'drawer_util.dart';
import 'farm_records_page.dart';
import 'update_products_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int curtPage = 0;

  AuthFireBase auth = AuthFireBase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        drawer: DrawerUtil(),
        body: ConnectivityWidgetWrapper(
          decoration: BoxDecoration(
              color: Colors.purple,
              gradient: LinearGradient(colors: [Colors.red, Colors.cyan])),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Flexible(
                  flex: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 8,
                      child: Container(
                        height: 260,
                        child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(auth.currentUser.uid)
                                .collection("farm_records")
                                .where("action", isEqualTo: "sale")
                                .orderBy("dateTime", descending: true)
                                .limit(5)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator()),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0)),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Text("Loading...")),
                                  ],
                                );
                              }

                              List salesList =
                                  []; //List.generate(snapshot.data.documents.length,
                              //     (index) => snapshot.data.documents[index]['price']);
                              List dailySalesList = [];
                              List monthlySalesList = [];
                              List yearlySalesList = [];
                              DateTime currentDate = DateTime.now();
                              for (int i = 0;
                              i < snapshot.data.docs.length;
                              i++) {
                                DocumentSnapshot documentSnap =
                                snapshot.data.docs[i];
                                Timestamp dateStamp = documentSnap
                                    .data()['dateTime'];
//                                print(dateStamp);
                                DateTime date = dateStamp.toDate();

                                salesList
                                    .add(snapshot.data.docs[i].data()['price']);
                                if (date.year == currentDate.year) {
                                  yearlySalesList
                                      .add(
                                      snapshot.data.docs[i].data()['price']);

                                  if (date.month == currentDate.month) {
                                    monthlySalesList.add(
                                        snapshot.data.docs[i].data()['price']);

                                    if (date.day == currentDate.day) {
                                      dailySalesList.add(
                                          snapshot.data.docs[i]
                                              .data()['price']);
                                    }
                                  }
                                }
                              }

                              int totalSales = salesList.fold(
                                  0,
                                  (previousValue, current) =>
                                      previousValue + current);
                              int todaySales = dailySalesList.fold(
                                  0,
                                  (previousValue, current) =>
                                      previousValue + current);
                              int monthSales = monthlySalesList.fold(
                                  0,
                                  (previousValue, current) =>
                                      previousValue + current);
                              int yearSales = salesList.fold(
                                  0,
                                  (previousValue, current) =>
                                      previousValue + current);

                              PageController _pageController =
                                  PageController(initialPage: curtPage);

                              return Stack(
                                children: [
                                  PageView(
                                    controller: _pageController,
                                    onPageChanged: (index) {
                                      setState(() {
                                        curtPage = index;
                                      });
                                    },
                                    children: <Widget>[
                                      Container(
                                        color: Theme.of(context).accentColor,
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Center(
                                                child: Text(
                                                  "Recently Sold",
                                                  style: TextStyle(
                                                      color: Theme
                                                          .of(context)
                                                          .primaryColor,
                                                      fontSize: 20,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            Divider(),
                                            Padding(
                                              padding:
                                              const EdgeInsets.all(
                                                  4.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
//                                            flex: 2,
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets
                                                          .only(
                                                          left: 4),
                                                      child: Text("Date",
                                                          style: TextStyle(
                                                              color: Theme
                                                                  .of(
                                                                  context)
                                                                  .primaryColor,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold)),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets
                                                          .only(
                                                          left: 4.0),
                                                      child: Text("Time",
                                                          style: TextStyle(
                                                              color: Theme
                                                                  .of(
                                                                  context)
                                                                  .primaryColor,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold)),
                                                    ),
                                                  ),
                                                  Expanded(
//                                            flex: 2,
                                                    child: Text("Product",
                                                        style: TextStyle(
                                                            color: Theme
                                                                .of(
                                                                context)
                                                                .primaryColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold)),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                        margin:
                                                        const EdgeInsets
                                                            .only(
                                                            left: 4),
                                                        child: Text('Qty',
                                                            style: TextStyle(
                                                                color: Theme
                                                                    .of(
                                                                    context)
                                                                    .primaryColor,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                                  ),
                                                  Expanded(
                                                    child: Text('Price',
                                                        style: TextStyle(
                                                            color: Theme
                                                                .of(
                                                                context)
                                                                .primaryColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold)),
                                                  )
                                                ],
                                              ),
                                            ),
                                            snapshot.data.docs.length == 0
                                                ? Expanded(
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text(
                                                    "No Sales Records Found!!!"),
                                              ),
                                            )
                                                :
                                            ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: snapshot
                                                  .data.docs.length,
                                              itemBuilder: (context, index) {
                                                DocumentSnapshot documentSnap =
                                                snapshot
                                                    .data.docs[index];
                                                Timestamp dateStamp =
                                                documentSnap.data()['dateTime'];
//                                print(dateStamp);
                                                DateTime date =
                                                dateStamp.toDate();
                                                String formattedDate =
                                                DateFormat('dd-MMM-yy')
                                                    .format(date);
                                                String formattedTime =
                                                DateFormat('kk:mm')
                                                    .format(date);

                                                return Card(
                                                  elevation: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4.0,
                                                        vertical: 6),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Flexible(
                                                          // flex: 2,
                                                          child: Text(
                                                              formattedDate),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            margin:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 6.0),
                                                            child: Text(
                                                                formattedTime),
                                                          ),
                                                        ),
                                                        Expanded(
//                                            flex: 2,
                                                          child: Text(
                                                            documentSnap.data()[
                                                            'productName'],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            margin:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8.0),
                                                            child: Text(
                                                                documentSnap
                                                                    .data()[
                                                                'quantity']
                                                                    .toString()),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                              documentSnap
                                                                  .data()[
                                                              'price']
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
                                        color: Theme.of(context).accentColor,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Center(
                                                  child: Text("Total Sales",
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontSize: 25,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                            ),
                                            Divider(),
                                            Card(
                                              elevation: 1,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Center(
                                                    child: Text(
                                                        "Today: $todaySales",
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                              ),
                                            ),
                                            Card(
                                              elevation: 1,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Center(
                                                    child: Text(
                                                        "This Month: $monthSales",
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                              ),
                                            ),
                                            Card(
                                              elevation: 1,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Center(
                                                    child: Text(
                                                        "This Year: $yearSales",
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                              ),
                                            ),
                                            Expanded(
                                              child: Card(
                                                margin: EdgeInsets.only(
                                                    bottom: 8,
                                                    top: 4,
                                                    left: 4,
                                                    right: 4),
                                                elevation: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                      child: Text(
                                                          "All Time: $totalSales",
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        iconSize: 18,
                                        icon: Icon(Icons.arrow_back_ios),
                                        alignment: Alignment.centerRight,
                                        // button is grey and disabled if we on the first page
                                        onPressed: curtPage == 0
                                            ? null
                                            : () {
                                                _pageController.animateToPage(
                                                    --curtPage,
                                                    duration: Duration(
                                                        milliseconds: 500),
                                                    curve: Curves.bounceInOut);
                                              },
                                      ),
                                      IconButton(
                                          iconSize: 18,
                                          alignment: Alignment.centerLeft,
                                          icon: Icon(Icons.arrow_forward_ios),
                                          onPressed: curtPage == 1
                                              ? null
                                              : () {
                                                  _pageController.animateToPage(
                                                      ++curtPage,
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      curve:
                                                          Curves.bounceInOut);
                                                }
                                          // color: Colors.white,
                                          // button is grey and disabled if we on the last page
                                          // color: currentPage == (options.length-1) ? Colors.grey : Theme.of(context).primaryColor,
                                          // onPressed: currentPage == (options.length-1) ? null : () {
                                          //   print("Front Clicked");
                                          //   moveToPage(pageIndex: ++currentPage);
                                          // },
                                          ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                      ),
                    ),
                  ),
                ),
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15))),
                        color: Theme
                            .of(context)
                            .accentColor,
                        icon: Icon(Icons.book,
                            color: Theme
                                .of(context)
                                .primaryColor),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => RecordPage()));
                        },
                        label: Text("Records"),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15))),
                          color: Colors.teal[100],
                          icon: Icon(
                            Icons.business_center,
                            color: Theme
                                .of(context)
                                .primaryColor,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => UpdateProductsPage()));
                          },
                          label: Text("Update Products")),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                bottomRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15))),
                        color: Theme
                            .of(context)
                            .accentColor,
                        icon: Icon(
                          Icons.shopping_cart,
                          color: Theme
                              .of(context)
                              .primaryColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SellStockPage()));
                        },
                        label: Text("Sell"),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15.0),
                                  bottomRight: Radius.circular(15),
                                  bottomLeft: Radius.circular(15))),
                          color: Theme
                              .of(context)
                              .accentColor,
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
                        ),
                      ))
                ],
              ),
            ),
          ),
          ]),
        ));
  }
}

