import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//todo - Const of exceptions
const EMPTY_FIELD = '[firebase_auth/unknown] Given String is empty or null';
const EMAIL_ALREADY_IN_USE =
    '[firebase_auth/email-already-in-use] The email address is already in use by another account.';
const USER_NOT_FOUND =
    '[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.';
const INVALID_EMAIL =
    '[firebase_auth/invalid-email] The email address is badly formatted.';
const WRONG_PASSWORD =
    '[firebase_auth/wrong-password] The password is invalid or the user does not have a password.';

//TODO - MAIN CLASS
class FirebaseExceptionManager {
  Exception exception;

  FirebaseExceptionManager({this.exception});

  void manageFirebaseExceptions() {
    print("EXCEPTIONS::-> " + exception.toString());
    switch (exception.toString()) {
      case USER_NOT_FOUND:
        showToastMessage(
            message: 'No record exists. Please create new account !');
        break;

      case EMPTY_FIELD:
        showToastMessage(message: 'All fields are required to be filled ');
        break;

      case INVALID_EMAIL:
        showToastMessage(
            message: 'Invalid email. The email address is badly formatted.');
        break;

      case WRONG_PASSWORD:
        showToastMessage(message: 'Enter Wrong Password !! ');
        break;

      case EMAIL_ALREADY_IN_USE:
        showToastMessage(
            message:
                'This email address is already in use by another account.');
        break;

      default:
        showToastMessage(message: 'Error Occurred !!');
        break;
    }
  }

  //Toast message
  void showToastMessage({String message}) {
    Fluttertoast.showToast(
        msg: message,
        timeInSecForIosWeb: 1,
        textColor: Colors.black,
        backgroundColor: Colors.black54,
        toastLength: Toast.LENGTH_SHORT);
  }
}
