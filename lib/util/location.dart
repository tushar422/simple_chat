import 'package:latlong2/latlong.dart' as latlng;
import 'package:location/location.dart';

Future<latlng.LatLng> getCurrentLocation() async {
  const defaultLocation = latlng.LatLng(0, 0);
  Location location = Location();

  bool serviceEnabled;
  PermissionStatus permissionGranted;
  LocationData locationData;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return defaultLocation;
    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return defaultLocation;
    }
  }

  locationData = await location.getLocation();

  if (locationData.latitude == null || locationData.longitude == null) {
    return defaultLocation;
  } else {
    return latlng.LatLng(locationData.latitude!, locationData.longitude!);
  }
  
}
