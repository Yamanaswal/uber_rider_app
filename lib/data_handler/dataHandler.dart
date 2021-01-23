import 'package:flutter/foundation.dart';
import 'package:uber_rider_app/models/address.dart';

class AppData extends ChangeNotifier {
  Address pickUpLocation, dropOffLocation;

  void updatePickUpLocationAddress({Address pickUpAddress}) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress({Address dropOffAddress}) {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }
}
