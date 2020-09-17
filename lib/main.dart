import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_farm_inventory/auth.dart';
import 'package:flutter_farm_inventory/home_page.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:provider/provider.dart';

import 'login_signup_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthFireBase(),
      child: ConnectivityAppWrapper(
        app: WillPopScope(
          onWillPop: () async {
            MoveToBackground.moveTaskToBack();
            return false;
          },
          child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData().copyWith(
                primaryColor: Colors.teal, accentColor: Colors.teal[100]),
            home: WelcomePage(),
          ),
        ),
      ),
    );
  }
}

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
//            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            print("isLoggedIn: $isLoggedIn");

            return HomePage();
          } else {
            return LoginPage();
          }


          // return Scaffold(
          //     appBar: AppBar(),
          //     body: Center(child: CircularProgressIndicator()));
          // });
        });
  }
}
