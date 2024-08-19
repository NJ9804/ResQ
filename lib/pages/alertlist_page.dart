import 'package:flutter/material.dart';
import 'package:googlemap/components/description_box.dart';
import 'package:googlemap/components/drawer.dart';
import 'package:googlemap/components/silver_appbar.dart';
import 'package:googlemap/components/tab_bar.dart';
import 'package:googlemap/models/alerts.dart'; // Ensure this path is correct
import 'package:googlemap/components/alert_tile.dart';
import 'package:googlemap/pages/alert_details.dart';
import 'package:provider/provider.dart'; // Ensure this path is correct
// import 'package:googlemap/pages/alert_detail_page.dart'; // Ensure this path is correct

class AlertlistPage extends StatefulWidget {
  const AlertlistPage({super.key});

  @override
  State<AlertlistPage> createState() => _AlertlistPageState();
}

class _AlertlistPageState extends State<AlertlistPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  void initState() {
    super.initState();
    _tabController = TabController(length: AlertType.values.length, vsync: this);
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Alert> _filterAlertByType(String type, List<Alert> alerts) {
    return alerts.where((alert) => alert.type == type).toList();
  }

 List<Widget> _buildAlertList(List<Alert> alerts) {
  return AlertType.values.map((type) {
    List<Alert> filteredAlerts = _filterAlertByType(type.toString().split('.').last, alerts);
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            type.toString().split('.').last.toUpperCase(), 
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),// Display the alert type as a heading
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredAlerts.length,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final alert = filteredAlerts[index];
              return AlertTile(
                alert: alert,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlertDetailPage(alertId: alert.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }).toList();
}

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      drawer: const MyDrawer(),
      body: NestedScrollView(headerSliverBuilder: (context,innerBoxIsScrolled) => [
        MySilverAppBar(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10,),
            const MyDescriptionBox(),
          ],
        ), 
        title: MyTabBar(tabController: _tabController),
        ),
      ],
      body: Consumer<Alerts>(
        builder: (context, alerts, child) {
          return TabBarView(
            controller: _tabController,
            children: _buildAlertList(alerts.alerts),
          );
        },
      
      
      ),
    ),
    );
  }
}
