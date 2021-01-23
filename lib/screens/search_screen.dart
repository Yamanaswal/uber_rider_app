import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_rider_app/assistants/requestAssitants.dart';
import 'package:uber_rider_app/components/configMaps.dart';
import 'package:uber_rider_app/components/divider.dart';
import 'package:uber_rider_app/components/prediction_tile.dart';
import 'package:uber_rider_app/data_handler/dataHandler.dart';
import 'package:uber_rider_app/models/address.dart';
import 'package:uber_rider_app/models/place_predictions.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpController = TextEditingController();
  TextEditingController dropOffController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation.placeName ?? '';
    pickUpController.text = placeAddress;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 6,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  )
                ]),
            child: Padding(
              padding:
                  EdgeInsets.only(left: 25, top: 20, right: 25, bottom: 20),
              child: Column(
                children: [
                  SizedBox(height: 5),
                  Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            child: Icon(Icons.arrow_back),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          Text(
                            'Set Drop Off',
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: 'Brand-Bold'),
                          ),
                          SizedBox(width: 50),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Image.asset(
                            'images/pickicon.png',
                            height: 16,
                            width: 16,
                          ),
                          SizedBox(width: 18),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(3),
                                child: TextField(
                                  onChanged: (val) {},
                                  controller: pickUpController,
                                  decoration: InputDecoration(
                                      hintText: 'PickUp Location',
                                      fillColor: Colors.grey[400],
                                      filled: true,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                          left: 11, top: 8, bottom: 8)),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Image.asset(
                            'images/desticon.png',
                            height: 16,
                            width: 16,
                          ),
                          SizedBox(width: 18),
                          Expanded(
                              child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3),
                              child: TextField(
                                onChanged: (String text) {
                                  findPlace(placeName: text);
                                },
                                controller: dropOffController,
                                decoration: InputDecoration(
                                    hintText: 'Where to?',
                                    fillColor: Colors.grey[400],
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 11, top: 8, bottom: 8)),
                              ),
                            ),
                          ))
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          //places list
          (placePredictionList.length > 0)
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          return PredictionTile(
                              placePredictions: placePredictionList[index]);
                        },
                        separatorBuilder: (context, index) {
                          return DividerWidget();
                        },
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: placePredictionList.length),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  void findPlace({String placeName}) async {
    if (placeName.length > 1) {
      String autocompleteURl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$apiKey&sessiontoken=1234567890';

      var response = await RequestAssistant.getRequest(url: autocompleteURl);
      if (response != 'failed') {
        print('Place Api Response :: ');
        if (response['status'] == 'OK') {
          var predictions = response['predictions'];
          var placesList = (predictions as List)
              .map((e) => PlacePredictions.fromJson(e))
              .toList();

          setState(() {
            placePredictionList = placesList;
          });
        }
      } else {
        return;
      }
    }
  }
}
