import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_farm_inventory/services/auth.dart';
import 'package:flutter_farm_inventory/views/welcome_page.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // initializeDateFormatting();
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
