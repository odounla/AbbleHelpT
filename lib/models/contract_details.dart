

import 'package:google_maps_flutter/google_maps_flutter.dart';

class ContractDetails
{
  String? contractID;

  LatLng? contractorResidenceLatLng;
  String? contractorAddress;

  LatLng? clientResidenceLatLng;
  String? clientAddress;

  String? userName;
  String? userPhone;


  ContractDetails(
  {
    this.contractID,
    this.contractorResidenceLatLng,
    this.contractorAddress,
    this.clientResidenceLatLng,
    this.clientAddress,
    this.userName,
    this.userPhone,
});
}