import 'dart:async';
import 'dart:ui';

import 'package:abblehelptech/methodes/common_methods.dart';
import 'package:abblehelptech/methodes/map_theme_methods.dart';
import 'package:abblehelptech/models/contract_details.dart';
import 'package:abblehelptech/widgets/dialog_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../global/global_var.dart';



class NewContractPage extends StatefulWidget
{
  ContractDetails? newContractDetailsInfo;
  NewContractPage({super.key, this.newContractDetailsInfo});

  @override
  State<NewContractPage> createState() => _NewContractPageState();
}

class _NewContractPageState extends State<NewContractPage>
{
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  MapThemeMethods themeMethods = MapThemeMethods();
  double googleMapPaddingFromBottom = 0;
  List<LatLng> coordinatesPolylineLatLngList = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Set<Marker> markersSet = Set<Marker>();
  Set<Circle> circlesSet = Set<Circle>();
  Set<Polyline> polyLinesSet = Set<Polyline>();
  BitmapDescriptor? carMarkerIcon;
  bool taskRequested = false;
  String statusOfContract = "accepted";
  String durationText = "";
  String distanceText = "";
  String buttonTitleText = "ARRIVED";
  Color buttonColor = Colors.indigoAccent;



  makeMarker()
  {
    if(carMarkerIcon == null)
      {
        ImageConfiguration configuration = createLocalImageConfiguration(context, size: Size(2, 2));
        BitmapDescriptor.fromAssetImage(configuration, "assets/images/tracking.png")
            .then((valueIcon)
        {
          carMarkerIcon= valueIcon;
        });
      }
  }



  obtainDirectionAndDrawRoute(sourceLocationLatLng,destinationLocationLatLng) async
  {
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => DialogWidget(message: " Please wait",),
    );

    var contractDetailsInfo = await CommonMethod.getDirectionDetailsFromAPI(
        sourceLocationLatLng,
        destinationLocationLatLng
    );

    Navigator.pop(context);

    PolylinePoints pointsPolyline = PolylinePoints();
    List<PointLatLng> latLngPoints = pointsPolyline.decodePolyline(contractDetailsInfo!.encodedPoints!);

    coordinatesPolylineLatLngList.clear();

    if(latLngPoints.isNotEmpty)
      {
        latLngPoints.forEach((PointLatLng pointLatLng)
        {
          coordinatesPolylineLatLngList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        });
      }

    //draw polyline
    polyLinesSet.clear();

    setState(() {
      Polyline polyline = Polyline(
          polylineId: const PolylineId("routeID"),
          color:Colors.amber,
          points: coordinatesPolylineLatLngList,
          jointType : JointType.round,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true
      );

      polyLinesSet.add(polyline);
    });
//fit the polyline on google
LatLngBounds boundsLatLng;

if(sourceLocationLatLng.latitude > destinationLocationLatLng.latitude
&& sourceLocationLatLng.longitude > destinationLocationLatLng.longitude) {
  boundsLatLng = LatLngBounds(
      southwest: destinationLocationLatLng,
      northeast: sourceLocationLatLng
  );
}
else if (sourceLocationLatLng.longitude > destinationLocationLatLng.longitude)
  {
    boundsLatLng = LatLngBounds(
        southwest: LatLng(sourceLocationLatLng.latitude, destinationLocationLatLng.longitude),
        northeast: LatLng(destinationLocationLatLng.latitude, sourceLocationLatLng.longitude)
    );
  }

else if(sourceLocationLatLng.latitude > destinationLocationLatLng.latitude)
  {
    boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLocationLatLng.latitude, sourceLocationLatLng.longitude),
        northeast: LatLng(sourceLocationLatLng.latitude, destinationLocationLatLng.longitude),
    );
  }
else
{
  boundsLatLng = LatLngBounds(
      southwest: sourceLocationLatLng,
      northeast: destinationLocationLatLng,
  );
}

    controllerGoogleMap!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 72));

    // add marker
    Marker sourceMarker = Marker(
      markerId: const MarkerId('sourceID'),
      position: sourceLocationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('destinationID'),
      position: destinationLocationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );


    setState(() {
      markersSet.add(sourceMarker);
      markersSet.add(destinationMarker);
    });

    //add circle
    Circle sourceCircle = Circle(
      circleId: const CircleId('sourceCircleID'),
      strokeColor: Colors.orange,
      strokeWidth: 4,
      radius: 14,
      center: sourceLocationLatLng,
      fillColor: Colors.green,
    );

Circle destinationCircle = Circle(
  circleId: const CircleId('destinationCircleID'),
  strokeColor: Colors.green,
  strokeWidth: 4,
  radius: 14,
  center: destinationLocationLatLng,
  fillColor: Colors.orange,
);

setState(() {
  circlesSet.add(sourceCircle);
  circlesSet.add(destinationCircle);
});


  }

  getLiveLocationUpdatesOfContractor()
  {
    LatLng lastPositionLatLng = LatLng(0, 0);
    positionStreamNewContractPage = Geolocator.getPositionStream().listen((Position positionContractor)
    {
      contractorCurrentPosition = positionContractor;

      LatLng contractorCurrentPositionLatLng = LatLng(
          contractorCurrentPosition!.latitude,
          contractorCurrentPosition!.longitude);

      Marker carMarker = Marker(
          markerId: const MarkerId("carMarkerID"),
          position: contractorCurrentPositionLatLng,
          icon: carMarkerIcon!,
        infoWindow: const InfoWindow(title: "My Location"),
      );
      
      setState(() {
        CameraPosition cameraPosition = CameraPosition(target: contractorCurrentPositionLatLng, zoom: 16);
        controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        
        markersSet.removeWhere((element) => element.markerId.value == "carMarkerID");
        markersSet.add(carMarker);
      });
      
      lastPositionLatLng = contractorCurrentPositionLatLng;

      //update the contractor Trip Details Information
      updateTripDetailsInformation();

      //update contractor location to tripRequest Information

      Map updatedLocationOfContractor =
          {
            "latitude": contractorCurrentPosition!.latitude,
            "longitude": contractorCurrentPosition!.longitude,
          };
      FirebaseDatabase.instance.ref().child("contractRequests")
          .child(widget.newContractDetailsInfo!.contractID!).
          child("contractorLocation").set(updatedLocationOfContractor);



    });
  }

  updateTripDetailsInformation() async
  {
if(!taskRequested)
  {
    taskRequested = true;

    if(contractorCurrentPosition == null)
      {
        return;
      }
    var contractorLocationLatLng = LatLng(
        contractorCurrentPosition!.latitude,
        contractorCurrentPosition!.longitude);

    LatLng dropOffDestinationLocationLatLng;
    if(statusOfContract== "accepted") {
      dropOffDestinationLocationLatLng =
      widget.newContractDetailsInfo!.clientResidenceLatLng!;

      var directionDetailsInfo = await CommonMethod.getDirectionDetailsFromAPI(
          contractorLocationLatLng, dropOffDestinationLocationLatLng);

      if(directionDetailsInfo != null)
      {
        taskRequested = false;
        setState(() {
          durationText = directionDetailsInfo.durationTextString!;
          distanceText = directionDetailsInfo.distanceTextString!;
        });
        }
    }
  }
  }


  endContractNow() async
  {
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (BuildContext context ) => DialogWidget(message: "Please wait...")
    );


    Navigator.pop(context);

    String contractAmount = "250";
    // contract Amount need to be displayed here -

    await FirebaseDatabase.instance.ref().child("contractRequests")
        .child(widget.newContractDetailsInfo!.contractID!)
        .child("contractAmount").set(contractAmount);

    await FirebaseDatabase.instance.ref().child("contractRequests")
        .child(widget.newContractDetailsInfo!.contractID!)
        .child("status").set("ended");

    positionStreamNewContractPage!.cancel();

    //dialog for collecting contract amount


    //save contract amount to technician total earnings



  }

  @override
  Widget build(BuildContext context) {

    makeMarker();


    return Scaffold(
      body: Stack(
        children: [

          GoogleMap(
            padding:  EdgeInsets.only(bottom:googleMapPaddingFromBottom),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            markers: markersSet,
            circles: circlesSet,
            polylines: polyLinesSet,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController) async
            {
              controllerGoogleMap = mapController;
              themeMethods.updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);


              setState(() {
                googleMapPaddingFromBottom = 262;
              });

              var contractorCurrentLocationLatLng = LatLng(
                  contractorCurrentPosition!.latitude,
                  contractorCurrentPosition!.longitude
              );

              var userResidenceLocationLatLng = widget.newContractDetailsInfo!.clientResidenceLatLng;

              await obtainDirectionAndDrawRoute(contractorCurrentLocationLatLng,userResidenceLocationLatLng);


             getLiveLocationUpdatesOfContractor();

            },
          ),

          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(topRight: Radius.circular(17), topLeft: Radius.circular(17)),
                boxShadow:
                [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 17,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ]
            ),
                height: 256,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        //trip duration Text
                        Center(
                          child: Text(
                            durationText + " - " + distanceText,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 5,),
                      // user name  - call user icon btn
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            //user name
                            Text(
                              widget.newContractDetailsInfo!.userName!,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),


                            // Call user icon btn
                            GestureDetector(
                                onTap: ()
                                {
                                  launchUrl(
                                    Uri.parse(
                                      "tel://${widget.newContractDetailsInfo!.userPhone.toString()}"
                                    ),
                                  );
                                },

                              child: const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.phone_android_outlined,
                                  color: Colors.grey,
                                ),
                              ),

                            ),
                          ],
                        ),

                        const SizedBox(height: 15,),

                       //contract icon and location
                        Row(
                          children: [

                            Image.asset(
                              "assets/images/initial.png",
                              height: 16,
                              width: 16,
                            ),

                            Expanded(
                                child: Text(
                                  widget.newContractDetailsInfo!.contractorResidenceLatLng.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 25,),

                        Center(
                          child: ElevatedButton(
                            onPressed: () async
                            {
                              if(statusOfContract == "accepted"){

                                setState(() {
                                  buttonTitleText = "START CONTRACT";
                                  buttonColor = Colors.green;
                                });

                                statusOfContract = "arrived";

                                FirebaseDatabase.instance.ref()
                                    .child("contractRequests")
                                    .child(widget.newContractDetailsInfo!.contractID!)
                                    .child("status").set("arrive");

                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) => DialogWidget(message: "Now you can start the contract..."));

                                await obtainDirectionAndDrawRoute(
                                    widget.newContractDetailsInfo!.clientResidenceLatLng,
                                    widget.newContractDetailsInfo!.clientResidenceLatLng);

                                Navigator.pop(context);
                              }


                              else if (statusOfContract == "arrived")
                                {
                                    setState(() {
                                      buttonTitleText = "END CONTRACT";
                                      buttonColor = Colors.amber;
                                    });
                                  statusOfContract = "executingContract";
                                  FirebaseDatabase.instance.ref()
                                      .child("contractRequest")
                                      .child(widget.newContractDetailsInfo!.contractID!)
                                      .child("status").set("executingContract");
                                }

                              else if (statusOfContract == "executingContract")
                                {
                                  //end the Contract or the Task
                                  endContractNow();
                                }


                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                            ),
                            child: Text(
                              buttonTitleText,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ))
        ],
      ),
    );
  }
}
