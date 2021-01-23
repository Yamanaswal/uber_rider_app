import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_rider_app/firebase_utils/firebase_auth_utils.dart';

import 'login_screen.dart';
import 'main_screen.dart';

class RegisterScreen extends StatelessWidget {
  static const String idScreen = 'registerScreen';

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
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
              'SignUp as a Rider',
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
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelStyle:
                            TextStyle(color: Colors.black, fontSize: 15.0),
                        hintText: 'Name',
                        hintStyle:
                            TextStyle(fontSize: 14.0, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: emailTextEditingController,
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
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelStyle:
                            TextStyle(color: Colors.black, fontSize: 15.0),
                        hintText: 'Phone',
                        hintStyle:
                            TextStyle(fontSize: 14.0, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
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
                        if (nameTextEditingController.text == null ||
                            nameTextEditingController.text.isEmpty) {
                          showToastMessage(
                              message: 'Name field must not be empty !!');
                          return;
                        }
                        if (emailTextEditingController.text == null ||
                            emailTextEditingController.text.isEmpty) {
                          showToastMessage(
                              message: 'Email field must not be empty !!');
                          return;
                        }
                        if (phoneTextEditingController.text == null ||
                            phoneTextEditingController.text.isEmpty) {
                          showToastMessage(
                              message:
                                  'Phone Number field must not be empty !!');
                          return;
                        }
                        if (passwordTextEditingController.text == null ||
                            passwordTextEditingController.text.isEmpty) {
                          showToastMessage(
                              message: 'Password field must not be empty !!');
                          return;
                        }
                        FirebaseAuthUtils().registerNewUser(context,
                            email: emailTextEditingController.text,
                            password: passwordTextEditingController.text,
                            name: nameTextEditingController.text,
                            phone: phoneTextEditingController.text);
                      },
                      color: Colors.yellow,
                      textColor: Colors.white,
                      child: Container(
                        child: Center(
                          child: Text(
                            'Create Account',
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
                        Navigator.pushNamedAndRemoveUntil(
                            context, LoginScreen.idScreen, (route) => false);
                      },
                      child: Text('Already have an Account? Login here.'),
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
