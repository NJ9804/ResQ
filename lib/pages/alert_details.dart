import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googlemap/models/alerts.dart';
import 'package:googlemap/pages/alert_map.dart';
import 'package:googlemap/pages/pick_location_page.dart';

class AlertDetailPage extends StatefulWidget {
  final String alertId;

  const AlertDetailPage({required this.alertId, super.key});

  @override
  _AlertDetailPageState createState() => _AlertDetailPageState();
}

class _AlertDetailPageState extends State<AlertDetailPage> {
  Map<String, dynamic>? _alertData;
  bool _hasUpvoted = false;

  @override
  void initState() {
    super.initState();
    _fetchAlertDetails();
  }

  Future<void> _fetchAlertDetails() async {
    final alertDoc = await FirebaseFirestore.instance
        .collection('alerts')
        .doc(widget.alertId)
        .get();

    if (alertDoc.exists) {
      setState(() {
        _alertData = alertDoc.data();
        _hasUpvoted = _alertData?['upvotes'] > 0;
      });
    }
  }

  Future<void> _updateUpvotes(bool increment) async {
    if (_alertData == null) return;

    final updatedUpvotes = _alertData!['upvotes'] + (increment ? 1 : -1);

    await FirebaseFirestore.instance
        .collection('alerts')
        .doc(widget.alertId)
        .update({'upvotes': updatedUpvotes});

    setState(() {
      _alertData!['upvotes'] = updatedUpvotes;
      _hasUpvoted = increment;
    });
  }

  Future<void> _resolveAlert() async {
    if (_alertData == null) return;

    await FirebaseFirestore.instance
        .collection('alerts')
        .doc(widget.alertId)
        .update({'status': 'resolved'});

    setState(() {
      _alertData!['status'] = 'resolved';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_outlined),
            Text(' Alert Details'),
          ],
        ),
      ),
      body: _alertData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _alertData!['title'],
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _alertData!['description'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Image.asset('assets/gps.png'),
                              Text(
                                ' ${_alertData!['location']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Time: ${_alertData!['time']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.thumb_up,
                                      color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_alertData!['upvotes'].toInt()} upvotes',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  if (!_hasUpvoted)
                                    ElevatedButton(
                                      onPressed: () => _updateUpvotes(true),
                                      child: const Text('Upvote'),
                                    )
                                  else
                                    ElevatedButton(
                                      onPressed: () => _updateUpvotes(false),
                                      child: const Text('Remove Upvote'),
                                    ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: _resolveAlert,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _alertData!['status'] == 'resolved'
                                          ? Colors.yellow
                                          : Colors.green,
                                    ),
                                    child: Text(
                                      _alertData!['status'] == 'resolved'
                                          ? 'Resolved'
                                          : 'Resolve',
                                      style:  TextStyle(
                                        color: Theme.of(context).colorScheme.onSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                                spreadRadius: 2,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(getAlertIcon(
                                    AlertType.values.firstWhere((e) =>
                                        e.toString() ==
                                        'AlertType.${_alertData!['type']}'))),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                getAlertTypeLabel(AlertType.values.firstWhere(
                                    (e) =>
                                        e.toString() ==
                                        'AlertType.${_alertData!['type']}')),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlertMapPage(alert: Alert(
          id: widget.alertId,
          title: _alertData!['title'],
          description: _alertData!['description'],
          latitude: _alertData!['latitude'],
          longitude: _alertData!['longitude'],
          type: _alertData!['type'],
          location: _alertData!['location'],
          time: _alertData!['time'],
          upvotes: _alertData!['upvotes'],
          status: _alertData!['status'],
          date: _alertData!['date'],
          imageUrl: _alertData!['imageUrl'],
        )),
      ),
    );
  },
  child: Container(
    height: 170,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          blurRadius: 10,
          spreadRadius: 5,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        'assets/maps.png',
        fit: BoxFit.cover,
      ),
    ),
  ),
),

                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
