import 'dart:async';

import 'package:abblehelptech/global/global_var.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  final Completer<GoogleMapController> googleMapCompleteController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? getCurrentPositionOfTech;
  Color colorToShow = Colors.green;
  String titleToShow ="Go ONLINE NOW";
  bool isDriverAvailable = false;

  getCurrentTechLocation() async{
    Position positionOfTech = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    getCurrentPositionOfTech = positionOfTech;
    LatLng positionOfTechLatLng = LatLng(getCurrentPositionOfTech!.latitude,getCurrentPositionOfTech!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: positionOfTechLatLng, zoom: 15);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController){
              controllerGoogleMap = mapController;
              googleMapCompleteController.complete(controllerGoogleMap);

              getCurrentTechLocation();

            },
          ),
          //Go Online offline Button 
          Positioned(
            top:61,
            left:0,
            right:0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () {},
                 style: ElevatedButton.styleFrom(
                  backgroundColor: colorToShow,
                 ),
                 child: Text(
                  titleToShow,
                 ),
                  )
              ]
            )
          )
        ],
      ),
    );
  }
}