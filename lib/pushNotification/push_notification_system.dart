import 'package:abblehelptech/models/contract_details.dart';
import 'package:abblehelptech/widgets/dialog_widget.dart';
import 'package:abblehelptech/widgets/notification_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem
{
  FirebaseMessaging firebaseCloudMessaging = FirebaseMessaging.instance;

  Future<String?> generateDeviceRegistrationToken() async
  {
    String? deviceRecognitionToken =  await firebaseCloudMessaging.getToken();

    DatabaseReference referenceOnlineContractor = FirebaseDatabase.instance.ref()
        .child("contractors")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("deviceToken");

    referenceOnlineContractor.set(deviceRecognitionToken);

    firebaseCloudMessaging.subscribeToTopic("contractors");
    firebaseCloudMessaging.subscribeToTopic("users");
  }


  startListeningForNewNotification(BuildContext context) async
  {

    ////1. Terminated
    //When the app is completely closed
FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? messageRemote)
{
  if(messageRemote != null)
    {
      String contractID =  messageRemote!.data["contractID"];

      retrieveContractRequestInfo(contractID, context);
    }

});
    ////2. Foreground
    //When the app is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? messageRemote)
    {
      if(messageRemote != null)
      {
        String contractID =  messageRemote!.data["contractID"];

        retrieveContractRequestInfo(contractID, context);
      }
    });

    ///3. Background
    /// When the app is in the background and it receives a push notification
    ///
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? messageRemote)
    {
      if(messageRemote != null)
      {
        String contractID =  messageRemote!.data["contractID"];

        retrieveContractRequestInfo(contractID, context);
      }
    });
  }
  retrieveContractRequestInfo(String contractID, context)
  {
showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => const DialogWidget(message: "getting details..."),
    );

DatabaseReference contractRequestsRef = FirebaseDatabase.instance.ref().child("contractRequests").child(contractID);

contractRequestsRef.once().then((dataSnapshot)
{
  Navigator.pop(context);

  //play notification sound
  ContractDetails contractorDetailsInfo = ContractDetails();
  double contractorResidenceLat = double.parse((dataSnapshot.snapshot.value! as Map) ["contractorResidenceLatLng"]["latitude"]);
  double contractorResidenceLng =double.parse((dataSnapshot.snapshot.value! as Map) ["contractorResidenceLatLng"]["longitude"]);
  contractorDetailsInfo.contractorResidenceLatLng = LatLng(contractorResidenceLat, contractorResidenceLng);

   contractorDetailsInfo.contractorAddress =  (dataSnapshot.snapshot.value! as Map)["contractorAddress"];

  double clientResidenceLat= double.parse((dataSnapshot.snapshot.value! as Map) ["clientResidenceLatLng"]["latitude"]);
  double clientResidenceLng = double.parse((dataSnapshot.snapshot.value! as Map) ["clientResidenceLatLng"]["longitude"]);
  contractorDetailsInfo.clientResidenceLatLng = LatLng(clientResidenceLat, clientResidenceLng);

  contractorDetailsInfo.clientAddress = (dataSnapshot.snapshot.value! as Map)["clientAddress"];

  contractorDetailsInfo.userName = (dataSnapshot.snapshot.value! as Map) ["userName"];
  contractorDetailsInfo.userPhone =  (dataSnapshot.snapshot.value! as Map) ["userPhone"];
  contractorDetailsInfo.contractID = contractID;

showDialog(
    context: context,
    builder: (BuildContext context) => NotificationDialog(contractDetailsInfo: contractorDetailsInfo,)
);


});
  }
}