import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemap/models/alerts.dart';
import 'package:googlemap/services/location_service.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _currentLocation;
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    final locationData = locationService.currentLocation;
    setState(() {
      _currentLocation = locationData != null ? LatLng(locationData.latitude, locationData.longitude) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Page'),
      ),
      body: Consumer<Alerts>( // Use Consumer to listen to changes in Alerts
        builder: (context, alertsProvider, child) {
          return GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
            initialCameraPosition: CameraPosition(target: _currentLocation!, zoom: 12),
            markers: _createAlertMarkers(alertsProvider.alerts),
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
          );
        },
      ),
    );
  }

  Set<Marker> _createAlertMarkers(List<Alert> alerts) {
    return alerts.map((alert) {
      return Marker(
        markerId: MarkerId(alert.id), // Assuming `id` is a unique field in your Alert model
        position: LatLng(alert.latitude, alert.longitude),
        infoWindow: InfoWindow(
          title: alert.title,
          snippet: alert.description,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(alert.type)),
      );
    }).toSet();
  }

  double _getMarkerHue(String type) {
    switch (type) {
      case 'accidents':
        return BitmapDescriptor.hueRed;
      case 'traffic':
        return BitmapDescriptor.hueYellow;
      case 'construction':
        return BitmapDescriptor.hueOrange;
      case 'roadblock':
        return BitmapDescriptor.hueViolet;
      case 'naturalDisaster':
        return BitmapDescriptor.hueCyan;
      case 'wildanimals':
        return BitmapDescriptor.hueGreen;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }
}
