import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';

submitForm(BuildContext context, GlobalKey<FormState> formKey,
    Function performAction) async {
  final form = formKey.currentState;

  if (form.validate()) {
    form.save();

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
                            formKey.currentState.reset();
                          }),
                    )
                  ],
                ),
              ),
            );
          });
    }
  }
}
