import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  Alerts() {
    _setupAlertListener();
  }

  List<Alert> get alerts => _alerts;

  void _setupAlertListener() {
    alertsCollection.snapshots().listen((snapshot) {
      _alerts.clear();
      snapshot.docs.forEach((doc) {
        final data = doc.data() as Map<String, dynamic>;
        _alerts.add(Alert(
          id: doc.id,
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
        ));
      });
      notifyListeners();
    });
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
