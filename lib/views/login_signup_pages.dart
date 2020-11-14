import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_farm_inventory/services/auth.dart';
import 'package:flutter_farm_inventory/views/welcome_page.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../util_functions.dart';

AuthFireBase _baseAuth = AuthFireBase();

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();

  String _email;
  String _password;
  bool _loading = false;

// Internet Connectivity test and Form Validation should have been done already before calling this method
  performNormalLogin(BuildContext context) async {
    toggleLoading();

    _email = _emailTextController.text;
    _password = _passwordTextController.text;

    await _baseAuth
        .signInWithEmailAndPassword(_email, _password)
        .then((response) {
      checkUserVerification(response.user, context);
    }).catchError((error) {
      String errorMsg;
      print("Error: ${error.runtimeType}");
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
      toggleLoading();
    });
  }

  toggleLoading() {
    if (this.mounted) {
      setState(() {
        _loading = !_loading;
      });
    }
  }

  Widget _loginForm(BuildContext context) {
    return Scaffold(
      body: ConnectivityWidgetWrapper(
        decoration: BoxDecoration(
            color: Colors.purple,
            gradient: LinearGradient(colors: [Colors.red, Colors.cyan])),
        child: ModalProgressHUD(
          opacity: 0.9,
          color: Colors.transparent,
          progressIndicator: CircularProgressIndicator(
            valueColor:
            AlwaysStoppedAnimation<Color>(Theme
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
                                    textController: _emailTextController,
                                    onSaved: (val) => _email = val,
                                    obscureText: false),
                                CustomTextField(
                                    icon: Icon(Icons.lock),
                                    label: "Password",
                                    textController: _passwordTextController,
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
                                        context, formKey, () {
                                      performNormalLogin(context);
                                    });
                                  },
                                ),
                                _googleSignInButton(context, toggleLoading),
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
    return _loginForm(context);
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _nameTextController = TextEditingController();
  bool _loading = false;

  String _email;
  String _password;
  String _fullName;

  @override
  void dispose() {
    _passwordTextController.dispose();
    super.dispose();
  }

  toggleLoading() {
    setState(() {
      _loading = !_loading;
    });
  }

  // Internet Connectivity test and Form Validation should have been done already before calling this method
  performSignUp(BuildContext context) async {
    toggleLoading();

    _fullName = _nameTextController.text;
    _email = _emailTextController.text;
    _password = _passwordTextController.text;

    print("Email Entered: $_email");
    print("Password: $_password");

    await _baseAuth
        .signUpWithEmailAndPassword(_fullName, _email, _password)
        .then((userCred) {
      _baseAuth.signOut().then((value) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Success!"),
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                          "User Successfully Created. Please Check your email for verification mail"),
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
      });
    }).catchError((error) {
      print("Error: ${error.code}");
      print("Error Type: ${error.runtimeType}");
      print(error.message);
      print("Email Used : ${error.email}");


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
      toggleLoading();
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
            valueColor:
            AlwaysStoppedAnimation<Color>(Theme
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
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  CustomTextField(
                                      icon: Icon(Icons.person),
                                      label: "Full Name",
                                      textController: _nameTextController,
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
                                      textController: _emailTextController,
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
                                          context, formKey, () {
                                        performSignUp(context);
                                      });
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
                    _googleSignInButton(context, toggleLoading),
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

Widget _googleSignInButton(BuildContext context, Function toggleLoading) {
  return OutlineButton(
    onPressed: () {
      checkInternetConnection(context, () {
        _performGoogleSignIn(context, toggleLoading);
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

void checkUserVerification(User user, BuildContext context) async {
  if (!user.emailVerified) {
    print("XXX: Point C");

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(

            title: Text("Unverified Email"),
            actions: [
              RaisedButton(
                  child: Text("Log out"),
                  onPressed: () {
                    Navigator.pop(context);
                    _baseAuth.signOut();
                  }),
              // RaisedButton(
              //     child: Text("Verify Verification Status"),
              //     onPressed: () async {
              //       checkInternetConnection(context, () async {
              //         await user.reload();
              //         if (user.emailVerified) {
              //           print("Verified");
              //           Navigator.pop(context);
              //         }
              //       });
              //
              //     }),
            ],
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RichText(text: TextSpan(
                      text: "Please Check your Mail for verification mail. ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                            text: "Click here ",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                checkInternetConnection(context, () {
                                  user.sendEmailVerification();
                                });
                              },
                            style: TextStyle(color: Theme
                                .of(context)
                                .primaryColor)
                        ),
                        TextSpan(
                            text: "to resend verification mail "
                        )
                      ]
                  )),
                ],
              ),
            ),
          );
        });

  }
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
              suffixIcon: widget.obscureText
                  ? IconButton(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: widget._hideTxt
                      ? Theme
                      .of(context)
                      .primaryColor
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() => widget._hideTxt = !widget._hideTxt);
                },
              )
                  : null,
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

_performGoogleSignIn(BuildContext context, Function toggleLoading) {
  toggleLoading();

  _baseAuth.signInWithGoogle().then((response) {
    print("XXX : Point A");
    checkUserVerification(response.user, context);
  }).catchError((error) {
    print("Error: ${error.code}");
    print("Error Type: ${error.runtimeType}");

    String dialogMsg;

    switch (error.code) {
      case "account-exists-with-different-credential":
        dialogMsg = "An Account Already exists for this email.";
        break;
      case "invalid-credential":
        dialogMsg = "An Error Occurred, please try again later";
        break;
      case "operation-not-allowed":
        dialogMsg = "Operation not allowed. Please contact admin";
        break;
      case "user-disabled":
        dialogMsg = "User has been disabled. Please contact admin";
        break;
      case "user-not-found":
        dialogMsg = "User not found.";
        break;

      default:
        dialogMsg = "Please Contact admin";
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            actions: [],
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
    toggleLoading();
  });
}
