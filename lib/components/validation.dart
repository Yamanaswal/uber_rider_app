//TODO - Patterns
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

const String kMobilePattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
const String kEmailPattern =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
const String kPasswordPattern =
    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';

class Validations {
  //Todo - Email Address
  static bool validateEmail({String emailAddress}) {
    if (emailAddress == null || emailAddress.isEmpty) {
      showToastMessage(message: 'Email Address field must not be empty !!');
    } else if (!RegExp(kEmailPattern).hasMatch(emailAddress)) {
      showToastMessage(message: 'Email Address is not valid address !!');
    } else {
      return true;
    }
    return false;
  }

  //Todo - Phone Number
  static bool validatePhone({String phoneNumber}) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      showToastMessage(message: 'Phone Number field must not be empty !!');
    } else if (!RegExp(kMobilePattern).hasMatch(phoneNumber)) {
      showToastMessage(message: 'Phone Number is not valid number !!');
    } else {
      return true;
    }
    return false;
  }

  //Todo - Password
  static bool validatePassword({String password}) {
    if (password == null || password.isEmpty) {
      showToastMessage(message: 'Password field must not be empty !!');
    } else if (password.length <= 6) {
      showToastMessage(message: 'Password must be greater than 6 digits !!');
    } else if (!RegExp(kPasswordPattern).hasMatch(password)) {
      showToastMessage(
          message:
              'Password is not valid ! It contains at least one upper case, lower case, one digit & one special character');
    } else {
      return true;
    }
    return false;
  }

  //Todo - Phone Number
  static bool validateName({String name}) {
    if (name == null || name.isEmpty) {
      showToastMessage(message: 'Name field must not be empty !!');
    } else if (name.length > 4) {
      showToastMessage(
          message: 'Name is not valid number! It should be greater than 4');
    } else {
      return true;
    }
    return false;
  }

  //TODO  - TOAST MESSAGE
  static void showToastMessage({String message}) {
    Fluttertoast.showToast(
        msg: message,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        backgroundColor: Colors.black54,
        toastLength: Toast.LENGTH_SHORT);
  }
}

// String validateMobile(String input) {
//   RegExp regExp = ;
//   if (RegExp(kMobilePattern).hasMatch(input)) {
//     return '';
//   }
//   return null;
// }
