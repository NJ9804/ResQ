import 'package:resq/models/alerts.dart';

class UserPreferences {
  Set<AlertType> selectedAlertTypes;
  double notificationRadius; // in kilometers

  UserPreferences({
    required this.selectedAlertTypes,
    required this.notificationRadius,
  });
}
