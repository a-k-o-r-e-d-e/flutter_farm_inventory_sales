import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_farm_inventory/services/auth.dart';
import 'package:flutter_farm_inventory/views/home_page.dart';
import 'package:flutter_farm_inventory/views/login_signup_pages.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Color textColor = Colors.teal;
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
                  color: Theme.of(context).primaryColor),
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
                  color: Theme.of(context).primaryColor,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            RaisedButton(
              color: btnColor,
              onPressed: () {
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return CheckAuth();
                }));
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Text(
                "Get Started",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: btnTextColor),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 10.0)),
          ],
        )),
      ),
    );
  }
}

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
        stream: AuthFireBase().onAuthStateChanged,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final bool isLoggedIn = snapshot.hasData;
            print("isLoggedIn: $isLoggedIn");

            return HomePage();
          } else {
            return LoginPage();
          }
        });
  }
}
