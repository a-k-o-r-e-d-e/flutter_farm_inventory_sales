import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_farm_inventory/auth.dart';

import 'home_page.dart';

BaseAuth _baseAuth = AuthFireBase();

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  String _email;
  String _password;

  performLogin() {
    _baseAuth.signInWithEmailAndPassword(_email, _password).then((msg) {
      print(msg);
      if (msg == null) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("Please verify account first"),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                            child: Text("Ok!"),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      )
                    ],
                  ),
                ),
              );
            });
      }
    }).catchError((error) {
      switch (error.code) {
        case "ERROR_USER_NOT_FOUND":
          {
            var errorMsg = "User doesn\'t exists";
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(errorMsg),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                                child: Text("Ok!"),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          )
                        ],
                      ),
                    ),
                  );
                });
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildHeadingAndLogo(heading: "Login"),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            CustomTextField(
                                icon: Icon(Icons.email),
                                label: "Email",
                                validator: emailValidator,
                                onSaved: (val) => _email = val,
                                obscureText: false),
                            CustomTextField(
                                icon: Icon(Icons.lock),
                                label: "Password",
                                validator: (val) => val.length < 6
                                    ? "Password too short"
                                    : null,
                                onSaved: (val) => _password = val,
                                obscureText: true),
                            RaisedButton.icon(
                              icon: Icon(
                                Icons.person_pin,
                                color: Theme.of(context).primaryColor,
                              ),
                              color: Colors.tealAccent,
                              label: Text("Log in"),
                              onPressed: () {
                                _submit(formKey, performLogin);
                              },
                            ),
                            _googleSignInButton(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15.0),
                  child: RichText(
                    text: TextSpan(
                        text: "Don\'t have an account? \t",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                        children: <TextSpan>[
                          TextSpan(
                              text: "Sign Up",
                              style:
                                  TextStyle(color: Colors.teal, fontSize: 18.0),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return SignUpPage();
                                  }));
                                })
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();

  String _email;
  String _password;
  String _fullName;

  @override
  void dispose() {
    _passwordTextController.dispose();
    super.dispose();
  }

  performSignUp() {
    _baseAuth
        .signUpWithEmailAndPassword(_fullName, _email, _password)
        .then((msg) {
      print(msg);
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return HomePage();
      }));
    }).catchError((error) {
      switch (error.code) {
        case "ERROR_EMAIL_ALREADY_IN_USE":
          {
            var errorMsg = "This email is already in use.";
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Container(
                      child: Text(errorMsg),
                    ),
                  );
                });
          }
          break;
        case "ERROR_WEAK_PASSWORD":
          {
            var errorMsg = "The password must be 6 characters long or more.";
//              _loading = false;
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Container(
                      child: Text(errorMsg),
                    ),
                  );
                });
          }
          break;
        case "ERROR_INVALID_EMAIL":
          {
            var errorMsg = "Email is invalid";
//              _loading = false;
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Container(
                      child: Text(errorMsg),
                    ),
                  );
                });
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildHeadingAndLogo(heading: "Sign Up"),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Card(
                    elevation: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              CustomTextField(
                                  icon: Icon(Icons.person),
                                  label: "Full Name",
                                  validator: (val) =>
                                  val.isEmpty
                                      ? 'Name Cannot be Empty'
                                      : null,
                                  onSaved: (val) => _fullName = val,
                                  obscureText: false),
                              CustomTextField(
                                  icon: Icon(Icons.email),
                                  label: "Email",
                                  validator: emailValidator,
                                  onSaved: (val) => _email = val,
                                  obscureText: false),
                              CustomTextField(
                                  icon: Icon(Icons.lock),
                                  label: "Password",
                                  validator: (val) =>
                                  val.length < 6
                                      ? "Password too short"
                                      : null,
                                  onSaved: (val) => _password = val,
                                  obscureText: true,
                                  textController: _passwordTextController),
                              CustomTextField(
                                  icon: Icon(Icons.lock_outline),
                                  label: "Confirm Password",
                                  obscureText: true,
                                  validator: (val) =>
                                  val != _passwordTextController.text
                                      ? "Passwords do not match"
                                      : null),
                              RaisedButton.icon(
                                onPressed: () {
                                  _submit(formKey, performSignUp);
                                },
                                icon: Icon(Icons.person_add, color: Theme
                                    .of(context)
                                    .primaryColor,),
                                color: Colors.tealAccent,
                                label: Text("Create Account"),
                              )
                            ],
                          )),
                    ),
                  ),
                ),
                _googleSignInButton(context),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: RichText(
                    text: TextSpan(
                        text: "Already have an account? \t",
                        style: TextStyle(color: Colors.black, fontSize: 15),
                        children: <TextSpan>[
                          TextSpan(
                              text: "Sign In",
                              style:
                                  TextStyle(color: Colors.teal, fontSize: 15.0),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return LoginPage();
                                  }));
                                })
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String emailValidator(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value)) {
    return 'Email format is invalid';
  } else {
    return null;
  }
}

_submit(GlobalKey<FormState> formKey, Function performAction) {
  final form = formKey.currentState;

  if (form.validate()) {
    form.save();

    performAction();
  }
}

Widget _googleSignInButton(BuildContext context) {
  return OutlineButton(
    onPressed: () {
      _baseAuth.signInWithGoogle().whenComplete(() {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return HomePage();
        }));
      });
    },
    splashColor: Colors.grey,
    highlightElevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    borderSide: BorderSide(color: Colors.grey),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(
            image: AssetImage("assets/google_logo.png"),
            height: 20.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
    ),
  );
}

Widget _buildHeadingAndLogo({String heading}) {
  return Column(
    children: <Widget>[
      SizedBox(height: 20),
      Text(
        heading,
        style: TextStyle(
            color: Colors.teal,
            fontSize: 28.0,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 20),
      Image.asset(
        "assets/wolf.png",
        height: 85,
        width: 150,
      ),
      SizedBox(height: 10)
    ],
  );
}
//
//Widget _buildTextField(
//    {String label,
//    FormFieldValidator<String> validator,
//    FormFieldSetter<String> onSaved,
//    bool obscureText,
//    TextEditingController textController}) {
//  double fontSize = 20;
//
//  return Container(
//      padding: const EdgeInsets.symmetric(horizontal: 8.0),
//      child: Theme(
//        data: ThemeData(primarySwatch: Colors.teal),
//        child: TextFormField(
//          obscureText: obscureText,
//          controller: textController,
//          validator: validator,
//          //Todo autofocus: true
//          onSaved: onSaved,
//          style: TextStyle(fontSize: fontSize),
//          decoration: InputDecoration(
//              hintStyle:
//                  TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
//              labelText: label,
//              enabledBorder: OutlineInputBorder(
//                  borderRadius: BorderRadius.circular(30),
//                  borderSide: BorderSide(
////              color: Theme.of(context).primaryColor,
//                    width: 2,
//                  )),
//              border: OutlineInputBorder(
//                borderRadius: BorderRadius.circular(30),
//                borderSide: BorderSide(
////              color: Theme.of(context).primaryColor,
//                  width: 3,
//                ),
//              ),
//              prefixIcon: Padding(
//                padding: EdgeInsets.only(left: 30, right: 10),
//                child: IconTheme(
////      data: IconThemeData(color: Theme.of(context).primaryColor),
//                  child: icon,
//                ),
//              )),
//        ),
//      ));
//}

class CustomTextField extends StatelessWidget {
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSaved;
  final String label;
  final Icon icon;
  final bool obscureText;
  final TextEditingController textController;

  final double fontSize = 20;

  CustomTextField({this.icon,
    this.label,
    this.obscureText = false,
    this.validator,
    this.onSaved,
    this.textController});


  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(6.0),
        child: TextFormField(
          obscureText: obscureText,
          controller: textController,
          validator: validator,
          autofocus: true,
          onSaved: onSaved,
          style: TextStyle(fontSize: fontSize),
          decoration: InputDecoration(
              hintStyle:
              TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
              labelText: label,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Theme
                        .of(context)
                        .primaryColor,
                    width: 2,
                  )),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  width: 3,
                ),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 30, right: 10),
                child: IconTheme(
                  data: IconThemeData(color: Theme
                      .of(context)
                      .primaryColor),
                  child: icon,
                ),
              )),
        ));
  }
}
