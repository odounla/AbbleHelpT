import 'dart:async';
import 'dart:convert';

import 'package:abblehelptech/global/global_var.dart';
import 'package:abblehelptech/methodes/map_theme_methods.dart';
import 'package:abblehelptech/pushNotification/push_notification_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
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
  Position? currentPositionOfContractor;
  Color colorToShow = Colors.green;
  String titleToShow ="Go ONLINE NOW";
  bool isTechnicianAvailable = false;
  DatabaseReference? newContractRequestReference;
  MapThemeMethods themeMethods = MapThemeMethods();

  getCurrentTechLocation() async{
    Position positionOfTech = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfContractor = positionOfTech;
    contractorCurrentPosition = currentPositionOfContractor;



    LatLng positionOfTechLatLng = LatLng(currentPositionOfContractor!.latitude,currentPositionOfContractor!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: positionOfTechLatLng, zoom: 15);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
  //Implement goOnline Now()
  goOnlineNow()
  {

    //All the contractors available for new contract request
    Geofire.initialize("onlineContractor");
    Geofire.setLocation(
    FirebaseAuth.instance.currentUser!.uid,
  currentPositionOfContractor!.latitude,
  currentPositionOfContractor!.longitude,
);
  newContractRequestReference = FirebaseDatabase.instance.ref()
      .child("contractors").child(FirebaseAuth.instance.currentUser!.uid)
      .child("newContractStatus");
  newContractRequestReference!.set("waiting");

  newContractRequestReference!.onValue.listen((event) {});
  }

  setAndGetLocationUpdates()
  {
    positionStreamHomePage = Geolocator.getPositionStream().listen((Position position)
    {
currentPositionOfContractor = position;
 if(isTechnicianAvailable == true)
   {
     Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
     currentPositionOfContractor!.latitude,
     currentPositionOfContractor!.longitude,
     );
   }
 LatLng positionLatLng = LatLng(position.latitude,position.longitude);
 controllerGoogleMap!.animateCamera(CameraUpdate.newLatLng(positionLatLng));
    });
  }

  goOfflineNow()
  {
    //stop sharing contractor live location updates
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    //stop listening to the newContractorStatus
    newContractRequestReference!.onDisconnect();
    newContractRequestReference!.remove();
    newContractRequestReference = null;
  }

  intitializePushNotificationSystem()
  {
    PushNotificationSystem notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.startListeningForNewNotification(context);
  }

  @override
 void initState(){
    //TODO : implement initState
    super.initState();
    intitializePushNotificationSystem();
  }



  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: const EdgeInsets.only(top:136),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController){
              controllerGoogleMap = mapController;
              themeMethods.updateMapTheme(controllerGoogleMap!);
              googleMapCompleteController.complete(controllerGoogleMap);

              getCurrentTechLocation();

            },
          ),

          Container(
            height: 136,
            width: double.infinity,
            color: Colors.black54,
          ),
          //Go Online offline Button 
          Positioned(
            top:61,
            left:0,
            right:0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () 
                {
                  showModalBottomSheet(
                      context: context,
                      isDismissible: false,
                      builder: (BuildContext context)
                  {
                  return Container(
                   decoration: const BoxDecoration(
                     color: Colors.black54,
                     boxShadow:
                       [
                         BoxShadow(
                           color: Colors.grey,
                           blurRadius: 5.0,
                           spreadRadius: 0.5,
                           offset: Offset(
                             0.7,
                             0.7
                           )
                         )
                       ]
                   ),
                    height: 221,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      child: Column (
                        children: [
                          const SizedBox(height: 11,),
                          Text(
                              (!isTechnicianAvailable ) ? "GO ONLINE NOW" : "GO OFFLINE NOW",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 21,),

                          Text(
                            (!isTechnicianAvailable ) ?
                            "You are about to go online, you will become available to received contracts requests from users."
                                : "You are about to go offline, you will stop receiving new contracts requests from users.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white30,

                            ),
                          ),

                          const SizedBox(height: 25,),

                          Row(
                            children: [
                              Expanded(
                                  child: ElevatedButton(
                                    onPressed: ()
                                    {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "BACK"
                                    ),
                                  ),
                              ),

                              const SizedBox(width: 16,),

                              Expanded(
                                child: ElevatedButton(
                                  onPressed: ()
                                  {
                                if(!isTechnicianAvailable ){
                                    //go online
                                  goOnlineNow();


                                  //get contractor location updates
                                    setAndGetLocationUpdates();

                                  Navigator.pop(context);
                                  setState(() {
                                    colorToShow : Colors.pink;
                                    titleToShow = "GO OFFLINE NOW";
                                    isTechnicianAvailable = true;
                                  });
                                   }
                                else{
                                  //go offline
                                  goOfflineNow();
                                  Navigator.pop(context);

                                  setState(() {
                                    colorToShow : Colors.green;
                                    titleToShow = "GO ONLINE NOW";
                                    isTechnicianAvailable = false;
                                  });

                                }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: (titleToShow =="GO ONLINE NOW")
                                        ? Colors.green
                                        : Colors.pink
                                     ),
                                  child: const Text(
                                      "CONFIRM"
                                  ),
                                ),
                              ),

                            ],
                          )
                        ],
                      ),
                    ),
                  );
                  });
                },
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