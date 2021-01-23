import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_rider_app/firebase_utils/firebase_database_utils.dart';
import 'package:uber_rider_app/firebase_utils/firebase_progress_dialog.dart';

import 'firebase_exception_manager.dart';

class FirebaseAuthUtils {
  //TODO - VARS
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //TODO ***************** Authentication Methods ******************************

  void registerNewUser(BuildContext context,
      {@required String email,
      @required String password,
      String name,
      String phone,
      String age,
      String gender}) async {
    //Show Progress dialog
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: 'Authenticating, Please Wait... ',
          );
        });

    try {
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        if (userCredential.additionalUserInfo.isNewUser) {
          //get db references
          DatabaseReference databaseReference = FirebaseDatabaseUtils()
              .setDatabaseReferences(databaseRoute: 'users');
          //save to db
          FirebaseDatabaseUtils().saveNewUserInDatabase(
              context: context,
              databaseReference: databaseReference,
              user: userCredential.user,
              name: name,
              email: email,
              phone: phone);
        } else {
          Fluttertoast.showToast(
              msg: 'Already Registered. Go to Login Page !! ');
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'New User Account Cannot Created !!');
      }
    } catch (e) {
      Navigator.pop(context);
      FirebaseExceptionManager(exception: e).manageFirebaseExceptions();
    }
  }

  void loginAndAuthenticateUser(
    BuildContext context, {
    @required String email,
    @required String password,
  }) async {
    try {
      //Show Progress dialog
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ProgressDialog(
              message: 'Authenticating, Please Wait... ',
            );
          });

      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      print("USER" + userCredential.user.toString());
      if (userCredential.user != null) {
        //get db reference
        DatabaseReference databaseReference = FirebaseDatabaseUtils()
            .setDatabaseReferences(databaseRoute: 'users');
        //check user
        FirebaseDatabaseUtils().checkUserInDatabase(
            context: context,
            firebaseAuth: firebaseAuth,
            databaseReference: databaseReference,
            user: userCredential.user);
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'Something went wrong  !!');
      }
    } catch (e) {
      Navigator.pop(context);
      FirebaseExceptionManager(exception: e).manageFirebaseExceptions();
    }
  }

  //TODO - ******************** END OF CLASS ********************************
}
