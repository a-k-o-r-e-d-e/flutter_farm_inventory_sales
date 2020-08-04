import 'package:flutter/material.dart';
import 'package:flutter_farm_inventory/auth.dart';
import 'package:flutter_farm_inventory/home_page.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthFireBase(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.light().copyWith(primaryColor: Colors.teal),
        home: WelcomePage(),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.teal;
    Color bgColor = Colors.white;
    Color btnColor = Colors.tealAccent;
    Color btnTextColor = Colors.black;

    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        body: Center(
            child: Column(

              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Wolf Farms",
                  style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
                Padding(padding: EdgeInsets.only(top: 10.0)),
                Image.asset(
                  "assets/wolf.png",
                  height: 100,
                  width: 150,
                ),
                Padding(padding: EdgeInsets.only(top: 10.0)),
                Text(
                  "Keeping Records....",
                  style: TextStyle(
                      color: textColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.only(top: 10.0)),
                RaisedButton(
                  color: btnColor,
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return RootPage();
                    }));
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    "Get Started",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: btnTextColor),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 10.0)),
              ],
            )),
      ),
    );
  }
}