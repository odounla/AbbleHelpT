


import 'dart:async';

import 'package:abblehelptech/methodes/common_methods.dart';
import 'package:abblehelptech/models/contract_details.dart';
import 'package:abblehelptech/widgets/dialog_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../global/global_var.dart';
import '../pages/task/new_task_page.dart';

class NotificationDialog extends StatefulWidget
{
  ContractDetails? contractDetailsInfo;

  NotificationDialog({super.key, this.contractDetailsInfo});
  @override
  State<NotificationDialog> createState() => _NotificationDialogState();

}

class _NotificationDialogState  extends State<NotificationDialog>
{

  String contractRequestStatus = "";
  CommonMethod cMethods = CommonMethod();

  cancelNotificationDialogAfter20Sec()
  {
    const oneTickPerSecond = Duration(seconds: 1);
    var timerCountDown = Timer.periodic(oneTickPerSecond, (timer)
    {
      contractRequestTimeout = contractRequestTimeout -1;

      if(contractRequestStatus =="accepted")
      {
        timer.cancel();
        contractRequestTimeout = 20;
      }
      
      if(contractRequestTimeout == 0)
        {
          Navigator.pop(context);
          timer.cancel();
          contractRequestTimeout = 20;
        }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    cancelNotificationDialogAfter20Sec();
  }

  checkAvailabilityOfContractRequest(BuildContext context) async
  {
      showDialog(
        barrierDismissible: false,
          context: context,
           builder: (BuildContext context) => DialogWidget(message: 'please wait...',),
      );

      DatabaseReference techContractStatusRef = FirebaseDatabase.instance.ref()
          .child("contractor")
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("newContractStatus");
      await  techContractStatusRef.once().then((snap)
      {
        Navigator.pop(context);
        Navigator.pop(context);

        String newContractStatusValue = "";
        if(snap.snapshot.value != null)
          {
            newContractStatusValue = snap.snapshot.value.toString();
          }
        else
            {
              cMethods.displaySnackBar("Contract Request Not Found", context);
            }

        if(newContractStatusValue == widget.contractDetailsInfo!.contractID)
          {
            techContractStatusRef.set("accepted");

            //disable homepage location updates
            cMethods.turnOffLocationUpdatesForHomePage();
            Navigator.push(context, MaterialPageRoute(builder:  (c) => NewContractPage(newContractDetailsInfo: widget.contractDetailsInfo)));
          }
        else if(newContractStatusValue == "cancelled")
          {
            cMethods.displaySnackBar("Contract Request has been Cancelled by user..", context);
          }
        else if(newContractStatusValue == "timeout")
        {
          cMethods.displaySnackBar("Contract Request timeout.", context);
        }
        else
        {
          cMethods.displaySnackBar("Contract Request removed. Not Found.", context);
        }
      });
  }

  @override
  Widget build(BuildContext context){
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.black54,
      child: Container(
        margin: const EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 30.0,),

            Image.asset(
              "assets/images/uberexec.png",
              width:140,
            ),

            const SizedBox(height: 16.0,),

            const Text(
              "NEW CONTRACT REQUEST",
              style:TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color:Colors.grey,
              )
            ),

            const SizedBox(height:20.0,),

            const Divider(
              height: 1,
              color: Colors.white,
              thickness: 1,
            ),
            
            const SizedBox(height: 10.0,),

            //Contractor and client addresses
            Padding(
                padding: EdgeInsets.all(16.0),
                child:Column(
                children: [

                //From contractor Residency
                Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Image.asset(
                   "assets/images/initial.png",
                   height:16,
                   width:16,
                 ),

                 const SizedBox(width:18,),

                 Expanded(
                   child: Text(
                     widget.contractDetailsInfo!.contractorResidenceLatLng.toString(),
                     overflow: TextOverflow.ellipsis,
                     maxLines: 2,
                     style: const TextStyle(
                       color: Colors.grey,
                       fontSize: 18,
                     ),
                   ),
                 ),
               ],
                ),

                const SizedBox(height: 15,),
                //Client Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      "assets/images/initial.png",
                      height:16,
                      width:16,
                    ),

                    const SizedBox(width:18,),

                    Expanded(
                      child: Text(
                        widget.contractDetailsInfo!.clientAddress.toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),

            const SizedBox(height: 20,),

            const Divider(
              height: 1,
              color: Colors.white,
              thickness: 1,
            ),

            const SizedBox(height: 8,),

            //decline btn  - accept btn
            Padding(
                padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [

                Expanded(child: ElevatedButton(
                  onPressed: ()
                  {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                  ),
                  child: const Text(
                    "DECLINE",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                ),

                const SizedBox(width: 10,),


                Expanded(child: ElevatedButton(
                  onPressed: ()
                  {
                    setState(() {
                      contractRequestStatus = "accepted";
                    });

                    checkAvailabilityOfContractRequest(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "ACCEPT",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                ),
              ],
            ),

            ),
            const SizedBox(height: 10.0,),
          ],
        ),
      ),
    );
  }
}