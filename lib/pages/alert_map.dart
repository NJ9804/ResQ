import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemap/models/alerts.dart';

class AlertMapPage extends StatefulWidget {
  final Alert alert;

  const AlertMapPage({required this.alert, super.key});

  @override
  _AlertMapPageState createState() => _AlertMapPageState();
}

class _AlertMapPageState extends State<AlertMapPage> {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Location'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.alert.latitude, widget.alert.longitude),
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: MarkerId(widget.alert.id),
            position: LatLng(widget.alert.latitude, widget.alert.longitude),
            infoWindow: InfoWindow(
              title: widget.alert.title,
              snippet: widget.alert.description,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(widget.alert.type)),
          ),
        },
        myLocationButtonEnabled: false,
      ),
    );
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
