import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:googlemap/components/button.dart';
import 'package:googlemap/models/alerts.dart';
import 'package:googlemap/pages/pick_location_page.dart';
import 'package:googlemap/services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddAlert extends StatefulWidget {
  @override
  _AddAlertState createState() => _AddAlertState();
}

class _AddAlertState extends State<AddAlert> {
  final CollectionReference alertCollection =
      FirebaseFirestore.instance.collection('alerts');
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  String imageUrl = 'https://example.com/default-image.png'; // Permanent image link
  LatLng? selectedLocation;
  String? locationDisplay;

  void addAlert(LocationService locationService) {
    // Use the selected location or fallback to the current location
    selectedLocation ??= locationService.currentLocation;
    locationDisplay ??= "${locationService.sublocality}, ${locationService.locality}";

    final double? longitude = selectedLocation?.longitude;
    final double? latitude = selectedLocation?.latitude;
    final Alert alert = Alert(
      title: titleController.text,
      description: descriptionController.text,
      location: locationDisplay ?? "",
      date: DateTime.now().toString(),
      time: TimeOfDay.now().format(context),
      imageUrl: imageUrl,
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
      status: "active",
      upvotes: 0.0,
      type: typeController.text,
    );
    Provider.of<Alerts>(context, listen: false).addAlertToDb(alert);
  }

  Future<void> _pickLocation(BuildContext context) async {
    // Get the current location from the LocationService
    LatLng? currentLocation = Provider.of<LocationService>(context, listen: false).currentLocation;

    LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(currentLocation),
      ),
    );

    if (result != null) {
      selectedLocation = result;
      // Use reverse geocoding to get sublocality and locality for the selected location
      List<Placemark> placemarks = await placemarkFromCoordinates(
        result.latitude, result.longitude,
      );

      if (placemarks.isNotEmpty) {
        String sublocality = placemarks.first.subLocality ?? "";
        String locality = placemarks.first.locality ?? "";
        setState(() {
          locationDisplay = "$sublocality, $locality";
        });
      } else {
        setState(() {
          locationDisplay = "${result.latitude}, ${result.longitude}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Alert"),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Title",
                hintText: "Enter the alert title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                hintText: "Enter the alert description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            GestureDetector(
              onTap: () => _pickLocation(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        locationDisplay ?? "Tap to pick location",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: typeController,
              decoration: InputDecoration(
                labelText: "Type",
                hintText: "Enter the type of alert (e.g., accident, traffic)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            const SizedBox(height: 40.0),
            Consumer<LocationService>(
              builder: (context, locationService, child) {
                return MyButton(
                  text: "Add Alert",
                  onTap: () {
                    addAlert(locationService);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
