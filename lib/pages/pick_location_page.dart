import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  const MapPickerScreen(this.initialLocation, {super.key});

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _pickedLocation;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation!,
              zoom: 14.0,
            ),
            onMapCreated: _onMapCreated,
            onTap: _onMapTap,
            markers: _pickedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('picked-location'),
                      position: _pickedLocation!,
                    ),
                  }
                : {},
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
          ),
          if (_pickedLocation != null) // Conditionally render the button
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 30.0),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.pop(context, _pickedLocation);
                  },
                  label: const Text(
                    "Select",
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  extendedPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
