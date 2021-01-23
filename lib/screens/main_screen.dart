import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_rider_app/assistants/assistantMethods.dart';
import 'package:uber_rider_app/components/common_utils.dart';
import 'package:uber_rider_app/components/configMaps.dart';
import 'package:uber_rider_app/components/divider.dart';
import 'package:uber_rider_app/data_handler/dataHandler.dart';
import 'package:uber_rider_app/firebase_utils/firebase_progress_dialog.dart';
import 'package:uber_rider_app/models/direction_details.dart';
import 'package:uber_rider_app/screens/login_screen.dart';

import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = 'mainScreen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController _googleMapController;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  bool drawerOpen = true;
  Position currentPosition;
  double bottomPaddingOfMap = 300;

  DirectionDetails tripDirectionDetails;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  double rideDetailsContainer = 0;
  double requestRideContainerHeight = 0;
  double searchContainerHeight = 300;

  void displayRequestRideContainer() {
    setState(() {
      requestRideContainerHeight = 250;
      rideDetailsContainer = 0;
      bottomPaddingOfMap = 230;
      drawerOpen = true;
    });
  }

  void resetMapApp() {
    setState(() {
      searchContainerHeight = 300;
      rideDetailsContainer = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 230;
      drawerOpen = true;

      polylineSet.clear();
      markerSet.clear();
      circleSet.clear();
      pLineCoordinates.clear();
    });

    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainer = 240;
      bottomPaddingOfMap = 230;
      drawerOpen = false;
    });

    saveRideRequest();
  }

  void locatePosition() async {
    Position position = await CommonUtils.getCurrentPosition();
    currentPosition = position;
    LatLng latLng = LatLng(position.latitude, position.longitude);
    //Move camera to current position
    moveCameraToPosition(latLng: latLng);

    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("This is Your Address : $address");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  DatabaseReference rideRequestRef;

  void saveRideRequest() {
    rideRequestRef =
        FirebaseDatabase.instance.reference().child('Ride Requests').push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map dropOffLocMap = {
      'latitude': dropOff.latitude,
      'longitude': dropOff.longitude,
    };

    Map pickUpLocMap = {
      'latitude': pickUp.latitude,
      'longitude': pickUp.longitude,
    };

    Map rideInfoMap = {
      'driver_id': 'waiting',
      'payment': 'cash',
      'pickup': pickUpLocMap,
      'dropoff': dropOffLocMap,
      'created_at': DateTime.now().toLocal().toString(),
      'rider_name': userCurrentInfo.name,
      'rider_phone': userCurrentInfo.phone,
      'pickup_address': pickUp.placeName,
      'dropoff_address': dropOff.placeName,
    };

    rideRequestRef.set(rideInfoMap);
  }

  void cancelRideRequest() {
    rideRequestRef.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      drawer: Container(
        color: Colors.white,
        width: 225,
        child: ListView(
          children: [
            //Drawer Header
            Container(
              height: 165,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset('images/user_icon.png', width: 65, height: 65),
                    SizedBox(height: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Profile Name',
                          style:
                              TextStyle(fontSize: 16, fontFamily: 'Brand-Bold'),
                        ),
                        SizedBox(height: 6),
                        Text('View Profile')
                      ],
                    )
                  ],
                ),
              ),
            ),
            DividerWidget(),
            SizedBox(height: 12),
            //Drawer Contents
            ListTile(
              leading: Icon(Icons.history),
              title: Text('History', style: TextStyle(fontSize: 15)),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Visit Profile', style: TextStyle(fontSize: 15)),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About', style: TextStyle(fontSize: 15)),
            ),
            ListTile(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.idScreen, (route) => false);
              },
              leading: Icon(Icons.logout),
              title: Text('Sign Out', style: TextStyle(fontSize: 15)),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: GoogleMap(
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              polylines: polylineSet,
              markers: markerSet,
              circles: circleSet,
              initialCameraPosition: currentPosition != null
                  ? CameraPosition(
                      target: LatLng(
                          currentPosition.latitude, currentPosition.longitude),
                      zoom: 20)
                  : _kGooglePlex,
              onMapCreated: (GoogleMapController mapController) {
                _controllerGoogleMap.complete(mapController);
                _googleMapController = mapController;

                locatePosition();
              },
            ),
          ),

          //Hamburger Button for drawer
          Positioned(
            top: 38,
            left: 22,
            child: GestureDetector(
              onTap: () {
                if (drawerOpen) {
                  _globalKey.currentState.openDrawer();
                } else {
                  resetMapApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 6.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon((drawerOpen) ? Icons.menu : Icons.close,
                      color: Colors.black),
                  radius: 20.0,
                ),
              ),
            ),
          ),

          //bottom sheet
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: Duration(milliseconds: 160),
              vsync: this,
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.0),
                      Text('Hi There,', style: TextStyle(fontSize: 12.0)),
                      Text('Where to?,',
                          style: TextStyle(
                              fontSize: 12.0, fontFamily: 'Brand-Bold')),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      SearchScreen()));

                          if (result == 'obtainDirection') {
                            displayRideDetailsContainer();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7),
                                )
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(width: 10),
                                Text('Search Drop Off')
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(
                            Icons.home,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(Provider.of<AppData>(context, listen: true)
                                            .pickUpLocation !=
                                        null
                                    ? Provider.of<AppData>(context,
                                            listen: true)
                                        .pickUpLocation
                                        .placeName
                                    : 'Add Home'),
                                SizedBox(height: 4),
                                Text(
                                  'Your living home address',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10.0),
                      DividerWidget(),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Icon(
                            Icons.work,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Add Work'),
                                SizedBox(height: 4),
                                Text(
                                  'Your office address',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          //rate calculate
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: Duration(milliseconds: 160),
              vsync: this,
              child: Container(
                height: rideDetailsContainer,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.tealAccent[100],
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Image.asset(
                                "images/taxi.png",
                                height: 70,
                                width: 80,
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Car',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: "Brand-Bold"),
                                  ),
                                  Text(
                                    (tripDirectionDetails != null)
                                        ? tripDirectionDetails.distanceText
                                        : '',
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.grey),
                                  )
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                (tripDirectionDetails != null)
                                    ? '\$${AssistantMethods.CalculateFares(tripDirectionDetails)}'
                                    : '',
                                style: TextStyle(fontFamily: "Brand-Bold"),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.moneyCheckAlt,
                              size: 18,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 16),
                            Text('Cash'),
                            SizedBox(width: 6),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black54,
                              size: 16,
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Padding(
                            padding: EdgeInsets.all(17),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Requests',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Icon(
                                  FontAwesomeIcons.taxi,
                                  color: Colors.white,
                                  size: 26,
                                )
                              ],
                            ),
                          ),
                          onPressed: () {
                            //request button
                            displayRequestRideContainer();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    )
                  ]),
              height: requestRideContainerHeight,
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    SizedBox(height: 12),
                    SizedBox(
                      width: 250.0,
                      child: ColorizeAnimatedTextKit(
                        onTap: () {
                          print("Tap Event");
                        },
                        text: [
                          "Requesting a Ride...",
                          "Please Wait...",
                          "Finding a Driver...",
                        ],
                        textStyle:
                            TextStyle(fontSize: 55.0, fontFamily: "Signatra"),
                        colors: [
                          Colors.green,
                          Colors.purple,
                          Colors.pink,
                          Colors.blue,
                          Colors.yellow,
                          Colors.red,
                        ],
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 22),
                    GestureDetector(
                      onTap: () {
                        cancelRideRequest();
                        resetMapApp();
                      },
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(26),
                          ),
                          border: Border.all(
                            color: Colors.grey[300],
                            width: 2.0,
                          ),
                        ),
                        child: Icon(Icons.close, size: 26.0),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      child: Text(
                        'Cancel Ride',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void moveCameraToPosition({@required LatLng latLng}) {
    CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 16);
    _googleMapController
        .moveCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLag = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLag = LatLng(finalPos.latitude, finalPos.longitude);

    showDialog(
        context: context,
        builder: (context) {
          return ProgressDialog(message: 'Please Wait...');
        });

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLag, dropOffLatLag);

    setState(() {
      tripDirectionDetails = details;
    });

    print(details.encodedPoints);
    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPointResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();

    if (decodedPointResult != null && decodedPointResult.isNotEmpty) {
      decodedPointResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
          color: Colors.pink,
          polylineId: PolylineId('polylineID'),
          jointType: JointType.round,
          points: pLineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);

      polylineSet.add(polyline);
    });

    //todo - set bounds for polyline
    LatLngBounds latLngBounds;
    if (pickUpLatLag.latitude > dropOffLatLag.latitude &&
        pickUpLatLag.longitude > dropOffLatLag.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLag, northeast: pickUpLatLag);
    } else if (pickUpLatLag.longitude > dropOffLatLag.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLag.latitude, dropOffLatLag.longitude),
          northeast: LatLng(dropOffLatLag.latitude, pickUpLatLag.longitude));
    } else if (pickUpLatLag.latitude > dropOffLatLag.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLag.latitude, pickUpLatLag.longitude),
          northeast: LatLng(pickUpLatLag.latitude, dropOffLatLag.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLag, northeast: dropOffLatLag);
    }

    _googleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpMarker = Marker(
      markerId: MarkerId('pickUpId'),
      position: pickUpLatLag,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: 'My Location'),
    );

    Marker dropOffMaker = Marker(
      markerId: MarkerId('dropOffId'),
      position: dropOffLatLag,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: 'Drop Off Location'),
    );

    setState(() {
      markerSet.add(pickUpMarker);
      markerSet.add(dropOffMaker);
    });

    Circle pickUpCircle = Circle(
        circleId: CircleId('pickUpCircle'),
        fillColor: Colors.blueAccent,
        center: pickUpLatLag,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.blueAccent);

    Circle dropOffCircle = Circle(
        circleId: CircleId('dropOffCircle'),
        fillColor: Colors.deepPurple,
        center: pickUpLatLag,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.deepPurple);

    setState(() {
      circleSet.add(pickUpCircle);
      circleSet.add(dropOffCircle);
    });
  }
}
