import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemap/models/alerts.dart';
import 'package:googlemap/pages/pick_location_page.dart';
import 'package:googlemap/services/location_service.dart';
import 'package:gradient_slide_to_act/gradient_slide_to_act.dart';
import 'package:provider/provider.dart';

class AddAlertNew extends StatefulWidget {
  const AddAlertNew({super.key});

  @override
  State<AddAlertNew> createState() => _AddAlertNewState();
}

class _AddAlertNewState extends State<AddAlertNew>
    with SingleTickerProviderStateMixin {
  final CollectionReference alertCollection =
      FirebaseFirestore.instance.collection('alerts');
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final String imageUrl =
      'https://example.com/default-image.png'; // Permanent image link
  LatLng? selectedLocation;
  String? locationDisplay;

  AlertType? selectedAlertType;
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 3), vsync: this);

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(_controller!)
      ..addListener(() {
        setState(() {});
      });

    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void addAlert(LocationService locationService) {
    // Use the selected location or fallback to the current location
    selectedLocation ??= locationService.currentLocation;

    final double? longitude = selectedLocation?.longitude;
    final double? latitude = selectedLocation?.latitude;
    final Alert alert = Alert(
      title: titleController.text,
      description: descriptionController.text,
      location: locationService.locality?? "",
      date: DateTime.now().toString(),
      time: TimeOfDay.now().format(context),
      imageUrl: imageUrl,
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
      status: "active",
      upvotes: 0.0,
      type: selectedAlertType?.toString().split('.').last ?? 'others',
    );

    Provider.of<Alerts>(context, listen: false).addAlertToDb(alert);
  }

  Future<void> _pickLocation(BuildContext context) async {
    // Get the current location from the LocationService
    LatLng? currentLocation =
        Provider.of<LocationService>(context, listen: false).currentLocation;

    LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(currentLocation),
      ),
    );

    if (result != null) {
      selectedLocation = result;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          result.latitude,
          result.longitude,
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
      } catch (e) {
        // Handle exception for placemarkFromCoordinates
        setState(() {
          locationDisplay = "${result.latitude}, ${result.longitude}";
        });
      }
    }
  }

  Widget buildAlertTypeTile(AlertType type) {
    bool isSelected = selectedAlertType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAlertType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? Colors.green
                : Theme.of(context).colorScheme.primary,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: Column(
          children: [
            Image.asset(
              getAlertIcon(type),
              height: 30,
              width: 30,
            ),
            const SizedBox(height: 10),
            Text(
              getAlertTypeLabel(type),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.yellow : Theme.of(context).colorScheme.inversePrimary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.warning_amber_outlined),
              Text(' Add Alert')
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(15.0),
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
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
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 5)
                        ]),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('assets/user.png'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Jane Cooper',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _pickLocation(context);
                    },
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                             BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 5)
                          ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Transform.scale(
                          scale: _animation!.value,
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/maps.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 5 // changes position of shadow
                    ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("  Alert Type",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  children: [
                    buildAlertTypeTile(AlertType.accidents),
                    buildAlertTypeTile(AlertType.traffic),
                    buildAlertTypeTile(AlertType.construction),
                    buildAlertTypeTile(AlertType.roadblock),
                    buildAlertTypeTile(AlertType.naturalDisaster),
                    buildAlertTypeTile(AlertType.wildanimals),
                    buildAlertTypeTile(AlertType.others),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 70),
          Consumer<LocationService>(
            builder: (context, locationService, child) {
              return GradientSlideToAct(
                onSubmit: () {
                  addAlert(locationService);
                  Navigator.pop(context);
                },
                width: 350,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                text: 'Submit Alert',
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                submittedIcon: Icons.check,
                sliderButtonIcon: Icons.lock_open,
                dragableIcon: Icons.arrow_forward_ios,
              );
            },
          ),
        ],
      ),
    );
  }
}
