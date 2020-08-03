import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth.dart';

class DrawerUtil extends StatefulWidget {
  @override
  _DrawerUtilState createState() => _DrawerUtilState();
}

class _DrawerUtilState extends State<DrawerUtil> {
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
    BaseAuth auth = AuthFireBase();
    auth.currentUser.then((FirebaseUser user) {
      print("A");
      setState(() {
        currentUser = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("${currentUser?.displayName}"),
            accountEmail: Text("${currentUser?.email}"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                  ? Colors.deepPurple
                  : Colors.white,
              child: Text(
                  "${currentUser?.displayName?.substring(0, 1)?.toUpperCase()}"),
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
          ListTile(
            title: Text('Update Inventory list'),
          ),
          ListTile(
            title: Text('Sales Chart'),
          ),
          SizedBox(
            height: 35.0,
          ),
          ListTile(
            title: Text("Log Out"),
            onTap: () {
              Navigator.pop(context);
              BaseAuth auth = AuthFireBase();
              auth.signOut();
            },
          )
        ],
      ),
    );
  }
}
