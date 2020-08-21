import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth.dart';

class DrawerUtil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BaseAuth auth = AuthFireBase();
    return Drawer(
      child: Column(
        children: <Widget>[
          StreamBuilder<FirebaseUser>(
              stream: auth.onAuthStateChanged,
              builder: (context, snapshot) {
                return UserAccountsDrawerHeader(
                  accountName: Text("${snapshot.data?.displayName}"),
                  accountEmail: Text("${snapshot.data?.email}"),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).platform == TargetPlatform.iOS
                            ? Colors.deepPurple
                            : Colors.white,
                    child: Text(
                        "${snapshot.data?.displayName?.substring(0, 1)?.toUpperCase()}"),
                  ),
                );
              }),
          Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
          ListTile(
            title: Text('Update Inventory list'),
            trailing: Icon(
              Icons.system_update_alt,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Divider(height: 3),
          ListTile(
            title: Text('Sales Chart'),
            trailing: Icon(Icons.show_chart, color: Theme
                .of(context)
                .primaryColor,),
          ),
          Divider(height: 3),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Divider(height: 3),
                  ListTile(
                    title: Text("Log Out"),
                    trailing: Icon(Icons.hdr_strong, color: Theme
                        .of(context)
                        .primaryColor,),
                    onTap: () {
                      Navigator.pop(context);
                      BaseAuth auth = AuthFireBase();
                      auth.signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 3),
          SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }
}
