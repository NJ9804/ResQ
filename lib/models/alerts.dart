import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:googlemap/services/local_notifications.dart';
import 'package:googlemap/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Alert {
  final String id;
  final String title;
  final String description;
  final String location;
  final String date;
  final String time;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String status;
  final double upvotes;
  final String type;

  Alert({
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.time,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.upvotes,
    required this.type,
    String? id,
  }) : id = id ?? '';
}

class Alerts extends ChangeNotifier {
  final CollectionReference alertsCollection =
      FirebaseFirestore.instance.collection('alerts');
  final List<Alert> _alerts = [];
  LocationService locationService = LocationService();
  String? _lastProcessedAlertId;

  Alerts() {
    _setupAlertListener();
  }

  List<Alert> get alerts => _alerts;

  void _setupAlertListener() {
    alertsCollection.snapshots().listen((snapshot) {
      for (var doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          final data = doc.doc.data() as Map<String, dynamic>;
          final newAlert = Alert(
            id: doc.doc.id,
            title: data['title'] as String,
            description: data['description'] as String,
            location: data['location'] as String,
            date: data['date'] as String,
            time: data['time'] as String,
            imageUrl: data['imageUrl'] as String,
            latitude: _convertToDouble(data['latitude']),
            longitude: _convertToDouble(data['longitude']),
            status: data['status'] as String,
            upvotes: _convertToDouble(data['upvotes']),
            type: data['type'] as String,
          );

          // Add the alert to the list
          _alerts.add(newAlert);

          // Check if this alert is new and should trigger a notification
          if (newAlert.id != _lastProcessedAlertId) {
            _applyLatestPreferencesAndCheckForNotification(newAlert);
            _lastProcessedAlertId = newAlert.id;
          }
        }
      }
      notifyListeners(); // Notify listeners about the new alerts
    });
  }

  Future<void> _applyLatestPreferencesAndCheckForNotification(
      Alert alert) async {
    final prefs = await SharedPreferences.getInstance();
    final alertTypes = prefs.getStringList('selectedAlertTypes') ?? [];
    final selectedAlertTypes = alertTypes
        .map((type) => AlertType.values.firstWhere((e) => e.toString() == type))
        .toSet();
    final notificationRadius = prefs.getDouble('notificationRadius') ?? 5.0;

    if (selectedAlertTypes.contains(AlertType.values
        .firstWhere((e) => e.toString() == 'AlertType.${alert.type}'))) {
      final double distance = await locationService.calculateDistance(
          alert.latitude, alert.longitude);
      if (distance <= notificationRadius) {
        LocalNotifications.showSimpleNotification(
          title: alert.title,
          body: alert.description,
          payload: alert.type,
        );
      }
    }
  }

  void addAlertToDb(Alert alert) {
    alertsCollection.add({
      'title': alert.title,
      'description': alert.description,
      'location': alert.location,
      'date': alert.date,
      'time': alert.time,
      'imageUrl': alert.imageUrl,
      'latitude': alert.latitude,
      'longitude': alert.longitude,
      'status': alert.status,
      'upvotes': alert.upvotes,
      'type': alert.type,
    });
  }

  Alert? getAlertById(String id) {
    try {
      return _alerts.firstWhere((alert) => alert.id == id);
    } catch (e) {
      return null;
    }
  }

  double _convertToDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else {
      throw ArgumentError(
          'Expected int or double, but got ${value.runtimeType}');
    }
  }
}

enum AlertType {
  accidents,
  traffic,
  construction,
  roadblock,
  naturalDisaster,
  wildanimals,
  others
}

String getAlertTypeLabel(AlertType type) {
  switch (type) {
    case AlertType.accidents:
      return 'Accidents';
    case AlertType.traffic:
      return 'Traffic';
    case AlertType.construction:
      return 'Construction';
    case AlertType.roadblock:
      return 'Roadblock';
    case AlertType.naturalDisaster:
      return 'Natural Disaster';
    case AlertType.wildanimals:
      return 'Wild Animals';
    case AlertType.others:
      return 'Others';
    default:
      return '';
  }
}

String getAlertIcon(AlertType type) {
  switch (type) {
    case AlertType.accidents:
      return 'assets/icons/accident.png';
    case AlertType.traffic:
      return 'assets/icons/traffic.png';
    case AlertType.construction:
      return 'assets/icons/construction.png';
    case AlertType.roadblock:
      return 'assets/icons/roadblock.png';
    case AlertType.naturalDisaster:
      return 'assets/icons/naturaldisaster.png';
    case AlertType.wildanimals:
      return 'assets/icons/wildanimals.png';
    case AlertType.others:
      return 'assets/icons/others.png';
    default:
      return '';
  }
}

extension AlertTypeExtension on AlertType {
  IconData get icon {
    switch (this) {
      case AlertType.accidents:
        return Icons.car_crash; // Use an appropriate icon
      case AlertType.traffic:
        return Icons.traffic;
      case AlertType.construction:
        return Icons.construction;
      case AlertType.roadblock:
        return Icons.block;
      case AlertType.naturalDisaster:
        return Icons
            .energy_savings_leaf_rounded; // Choose an icon that represents a natural disaster
      case AlertType.wildanimals:
        return Icons.pets; // Use an icon representing animals
      case AlertType.others:
        return Icons.warning; // General alert icon
      default:
        return Icons.help; // Fallback icon
    }
  }
}
