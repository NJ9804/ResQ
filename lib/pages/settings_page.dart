import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googlemap/models/alerts.dart';
import 'package:googlemap/models/user_preference.dart';
import 'package:googlemap/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
    _selectedAlertTypes = alertTypes.map((type) => AlertType.values.firstWhere((e) => e.toString() == type)).toSet();
    _notificationRadius = prefs.getDouble('notificationRadius') ?? 5.0;
    setState(() {});
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final alertTypes = _selectedAlertTypes.map((type) => type.toString()).toList();
    await prefs.setStringList('selectedAlertTypes', alertTypes);
    await prefs.setDouble('notificationRadius', _notificationRadius);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
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
                  value: Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
                  onChanged: (value) {
                    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                  },
                ),
              ],
            ),
          ),
          // Alert Type Selector
          Expanded(
            child: ListView(
              children: AlertType.values.map((alertType) {
                return ListTile(
                  title: Text(alertType.toString()),
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
          ),
          // Radius Slider
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
          ElevatedButton(
            onPressed: () {
              _savePreferences();
            },
            child: Text('Save Preferences'),
          ),
        ],
      ),
    );
  }
}
