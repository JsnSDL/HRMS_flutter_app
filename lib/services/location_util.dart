import 'package:flutter/material.dart';
import 'package:location/location.dart';


class LocationUtil {
  static Future<Map<String, double?>?> getLocation(BuildContext context) async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location service is disabled.'),
          ),
        );
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permission denied.'),
          ),
        );
        return null;
      }
    }

    _locationData = await location.getLocation();
    final Map<String, double?> locationMap = {
      'latitude': _locationData.latitude,
      'longitude': _locationData.longitude,
    };

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content:
    //      Text(
    //       'Latitude: ${_locationData.latitude}, Longitude: ${_locationData.longitude}',
    //     ),
    //   ),
    // );
    return locationMap;
  }
}
