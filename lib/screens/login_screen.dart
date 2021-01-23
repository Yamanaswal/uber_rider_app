import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_rider_app/components/validation.dart';
import 'package:uber_rider_app/firebase_utils/firebase_auth_utils.dart';

import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String idScreen = 'loginScreen';

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 45,
            ),
            Image.asset(
              'images/logo.png',
              width: 390,
              height: 250,
              alignment: Alignment.center,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Login as a Rider',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Brand Bold', fontSize: 24.0),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    TextField(
                      controller: emailTextEditingController,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelStyle:
                            TextStyle(color: Colors.black, fontSize: 15.0),
                        hintText: 'Email',
                        hintStyle:
                            TextStyle(fontSize: 14.0, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelStyle:
                            TextStyle(color: Colors.black, fontSize: 15.0),
                        hintText: 'Password',
                        hintStyle:
                            TextStyle(fontSize: 14.0, color: Colors.grey),
                      ),
                    ),
                    RaisedButton(
                      onPressed: () {
                        bool validEmail = Validations.validateEmail(
                            emailAddress: emailTextEditingController.text);
                        bool validPassword = Validations.validatePassword(
                            password: passwordTextEditingController.text);

                        if (validEmail && validPassword) {
                          FirebaseAuthUtils().loginAndAuthenticateUser(context,
                              email: emailTextEditingController.text,
                              password: passwordTextEditingController.text);
                        }
                      },
                      color: Colors.yellow,
                      textColor: Colors.white,
                      child: Container(
                        child: Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontFamily: 'Brand Bold',
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(24.0))),
                    ),
                    FlatButton(
                      onPressed: () {
                        print('register here pressed');
                        Navigator.pushNamedAndRemoveUntil(
                            context, RegisterScreen.idScreen, (route) => false);
                      },
                      child: Text('Do not have an Account? Register here.'),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void showToastMessage({String message}) {
    Fluttertoast.showToast(
        msg: message,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        backgroundColor: Colors.black54,
        toastLength: Toast.LENGTH_SHORT);
  }
}
