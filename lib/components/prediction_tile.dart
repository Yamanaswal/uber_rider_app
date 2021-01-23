import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_rider_app/assistants/requestAssitants.dart';
import 'package:uber_rider_app/data_handler/dataHandler.dart';
import 'package:uber_rider_app/firebase_utils/firebase_progress_dialog.dart';
import 'package:uber_rider_app/models/address.dart';
import 'package:uber_rider_app/models/place_predictions.dart';

import 'configMaps.dart';

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePredictions;

  PredictionTile({@required this.placePredictions});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        getPlaceAddressDetails(placePredictions.place_id, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        placePredictions.main_text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        placePredictions.secondary_text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetails(String placeId, BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProgressDialog(message: 'Setting DropOff, Please Wait...');
        });

    String placeUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    var res = await RequestAssistant.getRequest(url: placeUrl);

    Navigator.pop(context);

    if (res['status'] == 'OK') {
      Address address = Address(
        placeName: res['result']['name'],
        placeId: placeId,
        latitude: res['result']['geometry']['location']['lat'],
        longitude: res['result']['geometry']['location']['lng'],
      );

      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationAddress(dropOffAddress: address);
      print('This is Drop off location');
      print(address.placeName);

      Navigator.pop(context, 'obtainDirection');
    }
  }
}
