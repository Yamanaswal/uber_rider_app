import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_rider_app/screens/main_screen.dart';

class FirebaseDatabaseUtils {
  //TODO - DATABASE ROOT REFERENCES
  final DatabaseReference databaseReferenceRoot =
      FirebaseDatabase.instance.reference();
  DatabaseReference databaseReference;

  //TODO ******************* METHODS *******************************************

  //TODO - SET - CHILD REFERENCES
  DatabaseReference setDatabaseReferences({@required String databaseRoute}) {
    try {
      return databaseReferenceRoot.child(databaseRoute);
    } catch (e) {
      print(e);
    }
    return null;
  }

  //TODO - SAVE A NEW USER
  void saveNewUserInDatabase({
    BuildContext context,
    @required DatabaseReference databaseReference,
    @required User user,
    String name,
    String email,
    String phone,
  }) {
    // databaseReference.child(user.uid);

    Map userDataMap = {'name': name, 'email': email, 'phone': phone};
    databaseReference.child(user.uid).set(userDataMap);
    //Send User to main screen
    Navigator.pushNamedAndRemoveUntil(
        context, MainScreen.idScreen, (route) => false);
    Fluttertoast.showToast(
        msg: 'Congratulations ! your account has been created !');
  }

  //TODO - CHECK USER IN DATABASE
  void checkUserInDatabase({
    @required BuildContext context,
    @required DatabaseReference databaseReference,
    @required User user,
    @required FirebaseAuth firebaseAuth,
  }) {
    databaseReference
        .child(user.uid)
        .once()
        .then((DataSnapshot snapshot) async {
      if (snapshot.value != null) {
        Navigator.pushNamedAndRemoveUntil(
            context, MainScreen.idScreen, (route) => false);
        Fluttertoast.showToast(msg: 'You are logged-in now.');
      } else {
        await firebaseAuth.signOut();
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: 'No record exists for this user. Please create new account',
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            gravity: ToastGravity.BOTTOM);
      }
    });
  }
}
