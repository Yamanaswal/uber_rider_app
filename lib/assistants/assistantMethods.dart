import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_rider_app/assistants/requestAssitants.dart';
import 'package:uber_rider_app/components/configMaps.dart';
import 'package:uber_rider_app/data_handler/dataHandler.dart';
import 'package:uber_rider_app/models/address.dart';
import 'package:uber_rider_app/models/all_users.dart';
import 'package:uber_rider_app/models/direction_details.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(
      Position position, BuildContext context) async {
    String st1, st2, st3, st4;
    String placeAddress;
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

    var response = await RequestAssistant.getRequest(url: url);

    if (response != 'failed') {
      // placeAddress = response['results'][0]['formatted_address'];
      st1 = response['results'][0]['address_components'][3]['long_name'];
      st2 = response['results'][0]['address_components'][4]['long_name'];
      st3 = response['results'][0]['address_components'][5]['long_name'];
      st4 = response['results'][0]['address_components'][6]['long_name'];
      placeAddress = '$st1 $st2 $st3 $st4';

      Address userPickAddress = Address(
          latitude: position.latitude,
          longitude: position.longitude,
          placeName: placeAddress);

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(pickUpAddress: userPickAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(
      LatLng initPos, LatLng endPos) async {
    String directionUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${initPos.latitude},${initPos.longitude}&destination=${endPos.latitude},${endPos.longitude}&key=$apiKey';

    print(directionUrl);
    var res = await RequestAssistant.getRequest(url: directionUrl);
    print("Direction Api Result:: ");
    print(res);
    if (res['status'] == 'OK') {
      DirectionDetails directionDetails = DirectionDetails(
        encodedPoints: res['routes'][0]['overview_polyline']['points'],
        distanceText: res['routes'][0]['legs'][0]['distance']['text'],
        distanceValue: res['routes'][0]['legs'][0]['distance']['value'],
        durationText: res['routes'][0]['legs'][0]['duration']['text'],
        durationValue: res['routes'][0]['legs'][0]['duration']['value'],
      );

      return directionDetails;
    } else {
      return null;
    }
  }

  static int CalculateFares(DirectionDetails directionDetails) {
    //in USD currency
    double timeTraveledValue = (directionDetails.durationValue / 60) * 0.20;
    double distanceTraveledFare =
        (directionDetails.distanceValue / 1000) * 0.20;
    double totalFare = timeTraveledValue + distanceTraveledFare;

    //local currency
    // 1 $ = 70 Rs
    // double totalLocalAmount = totalFare * 70;

    return totalFare.truncate();
  }

  static void getCurrentOnlineUserInfo() async {
    firebaseUser = FirebaseAuth.instance.currentUser;
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(firebaseUser.uid);

    databaseReference.once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        userCurrentInfo = Users.fromSnapshot(dataSnapshot);
      }
    });
  }
}
