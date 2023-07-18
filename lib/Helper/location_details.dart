/*
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Screen/Add_Address.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocode/geocode.dart';

import 'package:location/location.dart';

class GetLocation {
  LocationData? _currentPosition;

  late String _address = "";
  Location location1 = Location();
  String firstLocation = "", lat = "", lng = "";
  ValueChanged onResult;

  GetLocation(this.onResult);
  Future<void> getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location1.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location1.requestService();
      if (!_serviceEnabled) {
        print('ek');
        return;
      }
    }

    _permissionGranted = await location1.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location1.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print('no');
        return;
      }
    }

    location1.onLocationChanged.listen((LocationData currentLocation) {
      print("${currentLocation.latitude} : ${currentLocation.longitude}");
      _currentPosition = currentLocation;
      print(currentLocation.latitude);
      latitudeFirst = _currentPosition!.latitude!;
      longitudeFirst = _currentPosition!.longitude!;
      if (latitude == null) {
        getAddress(_currentPosition!.latitude, _currentPosition!.longitude)
            .then((value) {
          firstLocation = value.first.city.toString();
          print(firstLocation);
          print(value.first.streetAddress.toString());
          print(value.first.city.toString());
          if (latitude == null) {
            if (!value.first.streetAddress.toString().contains("pricing")) {
              onResult(value);
            }
          }
        });
      }
    });
  }
}

Future<List<Address>> getAddress(double? lat, double? lng) async {
  final coordinates = new Coordinates(latitude: lat, longitude: lng);
  Address add =
      await GeoCode().reverseGeocoding(latitude: lat!, longitude: lng!);
  return [add];
}
*/
