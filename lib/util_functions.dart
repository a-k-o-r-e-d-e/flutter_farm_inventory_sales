import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';

submitForm(BuildContext context, GlobalKey<FormState> formKey,
    Function performAction) async {
  final form = formKey.currentState;

  FocusManager.instance.primaryFocus.unfocus();

  if (form.validate()) {
    // form.save();

    await checkInternetConnection(context, performAction);
  }
}

Future checkInternetConnection(
    BuildContext context, Function performAction) async {
  if (await ConnectivityWrapper.instance.isConnected) {
    performAction();
  } else {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("You are not connected to the Internet!!"),
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

showMyDialog(BuildContext context, String message, String btnText,
    GlobalKey<FormState> formKey) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [
            RaisedButton(
                child: Text("HomePage"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }),
            RaisedButton(
                child: Text(btnText),
                onPressed: () {
                  Navigator.pop(context);
                  formKey.currentState.reset();
                })
          ],
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
        );
      });
}
