import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationService with ChangeNotifier {
  final loc.Location _locationController = loc.Location();
  LatLng? _currentLocation;
  String? _locality;
  String? _sublocality;
  StreamSubscription<loc.LocationData>? _locationSubscription;
  GoogleMapController? _mapController;

  LatLng? get currentLocation => _currentLocation;
  String? get locality => _locality;
  String? get sublocality => _sublocality;
  double? get latitude => _currentLocation?.latitude;
  double? get longitude => _currentLocation?.longitude;

  LocationService() {
    _initialize();
  }

  void _initialize() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription =
        _locationController.onLocationChanged.listen((loc.LocationData locationData) async {
      if (locationData.latitude != null && locationData.longitude != null) {
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);

        // Update locality using reverse geocoding
        List<Placemark> placemarks = await placemarkFromCoordinates(
          locationData.latitude!, locationData.longitude!,
        );
        if (placemarks.isNotEmpty) {
          _locality = placemarks.first.locality;
          _sublocality = placemarks.first.subLocality;
        }

        notifyListeners(); // Notifies listeners of the location change

        // Move the camera to the new location if the map is initialized
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _currentLocation!, zoom: 14.4746),
            ),
          );
        }
      }
    });
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLocation!, zoom: 14.4746),
        ),
      );
    }
  }

  double calculateDistance(double latitude, double longitude) {
  if (_currentLocation == null) {
    return double.infinity; // Return infinity if location is not available
  }

  double distance = Geolocator.distanceBetween(
    _currentLocation!.latitude,
    _currentLocation!.longitude,
    latitude,
    longitude,
  );

  return distance / 1000; // Convert meters to kilometers
}

  void stopLocationUpdates() {
    _locationSubscription?.cancel();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
