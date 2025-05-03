import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googlemap/models/alerts.dart';
import 'package:googlemap/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Set<AlertType> _selectedAlertTypes = {};
  double _notificationRadius = 5.0; // Default to 5 km

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final alertTypes = prefs.getStringList('selectedAlertTypes') ?? [];
    _selectedAlertTypes = alertTypes
        .map((type) => AlertType.values.firstWhere((e) => e.toString() == type))
        .toSet();
    _notificationRadius = prefs.getDouble('notificationRadius') ?? 5.0;
    setState(() {});
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final alertTypes =
        _selectedAlertTypes.map((type) => type.toString()).toList();
    await prefs.setStringList('selectedAlertTypes', alertTypes);
    await prefs.setDouble('notificationRadius', _notificationRadius);
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Preferences saved!'),
      duration: Duration(seconds: 2),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Dark Mode Toggle
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(left: 25, top: 10, right: 25),
            padding: const EdgeInsets.all(25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Dark Mode",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CupertinoSwitch(
                  value: Provider.of<ThemeProvider>(context).isDarkMode,
                  onChanged: (value) {
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleTheme();
                  },
                ),
              ],
            ),
          ),
          // Container for Alert Type Selector, Radius Slider, and Save Button
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.surface,
                  blurRadius: 10,
                ),
              ],
            ),
            margin: const EdgeInsets.all(25),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select your notification preferences",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: AlertType.values.map((alertType) {
                    return ListTile(
                      title: Text(getAlertTypeLabel(alertType)),
                      leading: Icon(alertType.icon),
                      trailing: Checkbox(
                        value: _selectedAlertTypes.contains(alertType),
                        onChanged: (isChecked) {
                          setState(() {
                            if (isChecked ?? false) {
                              _selectedAlertTypes.add(alertType);
                            } else {
                              _selectedAlertTypes.remove(alertType);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  "Notification Radius",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: _notificationRadius,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  label: 'Radius: ${_notificationRadius.toStringAsFixed(1)} km',
                  onChanged: (value) {
                    setState(() {
                      _notificationRadius = value;
                    });
                  },
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: _savePreferences,
                    child: Text('Save Preferences',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
