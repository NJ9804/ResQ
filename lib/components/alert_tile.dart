import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:googlemap/models/alerts.dart';
import 'package:googlemap/services/location_service.dart';

class AlertTile extends StatelessWidget {
  final Alert alert;
  
  final void Function()? onTap;

  const AlertTile({
    super.key,
    required this.alert,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Consumer<LocationService>(
      builder: (context, locationService, child) {
        return InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            alert.description,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.location_pin,
                                color: Theme.of(context).colorScheme.primary,
                                size: 15,
                              ),
                              Text(
                                locationService.latitude != null && locationService.longitude != null
                                    ? "${alert.location} (${locationService.calculateDistance(alert.latitude, alert.longitude).toStringAsFixed(2)} km)"
                                    : "Location not available",
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${alert.date} at ${alert.time}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Status: ${alert.status}",
                            style: TextStyle(
                              color: alert.status == 'Resolved'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Text(
                          //   "Type: ${alert.type}",
                          //   style: TextStyle(
                          //     color: Theme.of(context).colorScheme.tertiary,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(10),
                    //   child: Image.network(alert.imageUrl, height: 100, width: 100, fit: BoxFit.cover),
                    // ),
                  ],
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.tertiary,
                endIndent: 25,
                indent: 25,
              ),
            ],
          ),
        );
      },
    );
  }
}
