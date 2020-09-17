import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_farm_inventory/auth.dart';
import 'package:flutter_farm_inventory/main.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'home_page.dart';
import 'util_functions.dart';

BaseAuth _baseAuth = AuthFireBase();

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String _email;
  String _password;
  bool _loading = false;

// Internet Connectivity test and Form Validation should have been done already before calling this method
  performNormalLogin() async {
    setState(() {
      _loading = true;
    });

    await _baseAuth.signInWithEmailAndPassword(_email, _password).then((
        response) {
      // response.user.reload();

      if (!response.user.emailVerified) {
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
      String errorMsg;

      switch (error.code) {
      //TODO:: Handle Wrong Password case

        case "wrong-password":
          errorMsg = "Your password is wrong.";
          break;
        case "user-not-found":
          errorMsg = "User with this email doesn't exist.";
          break;
        case "user-disabled":
          errorMsg = "User with this email has been disabled.";
          break;
        case "too-many-requests":
          errorMsg = "Too many requests. Try again later.";
          break;
        case "invalid-email":
          errorMsg = "Email entered is Invalid";
          break;
        default:
          errorMsg = "An undefined Error happened.";
      }
      print("Error: ${error.code}");
      print("Error Type: ${error.runtimeType}");

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
    }).whenComplete(() {
      // Loading Dialog
      setState(() {
        _loading = false;
      });
    });
  }


  Widget _loginForm() {
    return Scaffold(
      body: ConnectivityWidgetWrapper(
        decoration: BoxDecoration(
            color: Colors.purple,
            gradient: LinearGradient(colors: [Colors.red, Colors.cyan])),
        child: ModalProgressHUD(
          opacity: 0.9,
          color: Colors.transparent,
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme
                .of(context)
                .primaryColor),
          ),
          inAsyncCall: _loading,
          child: Container(
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
                                    validator: (val) =>
                                    val.length < 6
                                        ? "Password too short"
                                        : null,
                                    onSaved: (val) => _password = val,
                                    obscureText: true),
                                RaisedButton.icon(
                                  icon: Icon(
                                    Icons.person_pin,
                                    color: Theme
                                        .of(context)
                                        .primaryColor,
                                  ),
                                  color: Colors.tealAccent,
                                  label: Text("Log in"),
                                  onPressed: () {
                                    submitForm(
                                        context, formKey, performNormalLogin);
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
                                  style: TextStyle(
                                      color: Colors.teal, fontSize: 18.0),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).pushReplacement(
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loginForm();
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  bool _loading = false;

  String _email;
  String _password;
  String _fullName;

  @override
  void dispose() {
    _passwordTextController.dispose();
    super.dispose();
  }

  // Internet Connectivity test and Form Validation should have been done already before calling this method
  performSignUp() async {
    setState(() {
      _loading = true;
    });


    await _baseAuth
        .signUpWithEmailAndPassword(_fullName, _email, _password)
        .then((value) {
      // print(value);

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("User Successfully Created"),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                          child: Text("Ok!"),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) {
                                  return CheckAuth();
                                }));
                          }),
                    )
                  ],
                ),
              ),
            );
          });
    }).catchError((error) {
      print("Error: ${error.code}");
      print("Error Type: ${error.runtimeType}");

      String dialogMsg;

      switch (error.code) {
        case "email-already-in-use":
          dialogMsg = "This email is already in use.";
          break;
        case "weak-password":
          dialogMsg = "The password must be 6 characters long or more.";
          break;
        case "invalid-email":
          dialogMsg = "Email is invalid";
          break;
        case "operation-not-allowed":
          dialogMsg = "User Creation by email and Password not enabled";
          break;
        default:
          dialogMsg = "An Undefined Error Occurred";
      }
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(dialogMsg),
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
    }).whenComplete(() {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConnectivityWidgetWrapper(
        decoration: BoxDecoration(
            color: Colors.purple,
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
          child: Container(
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
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
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
                                      submitForm(
                                          context, formKey, performSignUp);
                                    },
                                    icon: Icon(
                                      Icons.person_add,
                                      color: Theme
                                          .of(context)
                                          .primaryColor,
                                    ),
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
                                  style: TextStyle(
                                      color: Colors.teal, fontSize: 15.0),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(builder: (context) {
                                            return CheckAuth();
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

class CustomTextField extends StatefulWidget {
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSaved;
  final String label;
  final Icon icon;
  final bool obscureText;
  final TextEditingController textController;
  bool _hideTxt;


  CustomTextField({this.icon,
    this.label,
    this.obscureText = false,
    this.validator,
    this.onSaved,
    this.textController}) {
    this._hideTxt = this.obscureText;
  }

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final double fontSize = 13.5;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(5.0),
        child: TextFormField(
          obscureText: widget._hideTxt,
          controller: widget.textController,
          validator: widget.validator,
//          autofocus: true,
          onSaved: widget.onSaved,
          style: TextStyle(fontSize: fontSize),
          decoration: InputDecoration(
              hintStyle:
              TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
              labelText: widget.label,
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
              suffixIcon: widget.obscureText ? IconButton(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: widget._hideTxt ? Theme
                      .of(context)
                      .primaryColor : Colors.grey,
                ),
                onPressed: () {
                  setState(() => widget._hideTxt = !widget._hideTxt);
                },
              ) : null,
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 30, right: 10),
                child: IconTheme(
                  data: IconThemeData(color: Theme
                      .of(context)
                      .primaryColor),
                  child: widget.icon,
                ),
              )),
        ));
  }
}
