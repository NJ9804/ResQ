import 'package:flutter/material.dart';
import 'package:googlemap/models/alerts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlertDetailPage extends StatefulWidget {
  final String alertId;

  const AlertDetailPage({required this.alertId, Key? key}) : super(key: key);

  @override
  State<AlertDetailPage> createState() => _AlertDetailPageState();
}

class _AlertDetailPageState extends State<AlertDetailPage> {
  Alert? _alert; // Allow _alert to be null initially
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
      final data = alertDoc.data()!;
      final alert = Alert(
        id: alertDoc.id,
        title: data['title'],
        description: data['description'],
        location: data['location'],
        date: data['date'],
        time: data['time'],
        imageUrl: data['imageUrl'],
        latitude: data['latitude'].toDouble(),
        longitude: data['longitude'].toDouble(),
        status: data['status'],
        upvotes: data['upvotes'].toDouble(),
        type: data['type'],
      );

      setState(() {
        _alert = alert;
        // Example condition to set the local flag
        _hasUpvoted = _alert!.upvotes > 0; // Adjust according to your logic
      });
    }
  }

  Future<void> _updateUpvotes() async {
    if (_alert == null || _hasUpvoted) return;

    final updatedUpvotes = _alert!.upvotes + 1;

    await FirebaseFirestore.instance
        .collection('alerts')
        .doc(widget.alertId)
        .update({
      'upvotes': updatedUpvotes,
    });

    setState(() {
      _hasUpvoted = true;
    });

    await _fetchAlertDetails();
  }

  Future<void> _removeUpvote() async {
    if (_alert == null || !_hasUpvoted) return;

    final updatedUpvotes = _alert!.upvotes - 1;

    await FirebaseFirestore.instance
        .collection('alerts')
        .doc(widget.alertId)
        .update({
      'upvotes': updatedUpvotes,
    });

    setState(() {
      _hasUpvoted = false;
    });

    await _fetchAlertDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.warning_amber_outlined),
            Text(' Alert Details'),
          ],
        ),
      ),
      body: _alert == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _alert!.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _alert!.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Image.asset('assets/gps.png'),
                            Text(
                          ' ${_alert!.location}',
                          style: const TextStyle(fontSize: 16),
                        ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Time: ${_alert!.time}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.thumb_up, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  '${_alert!.upvotes.toInt()} upvotes',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            if (!_hasUpvoted)
                              ElevatedButton(
                                onPressed: _updateUpvotes,
                                child: const Text('Upvote'),
                              )
                            else
                              ElevatedButton(
                                onPressed: _removeUpvote,
                                child: const Text('Remove Upvote'),
                              ),
                          ],
                        ),
                      ],
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
                                backgroundImage: AssetImage(getAlertIcon(AlertType.values.firstWhere((e) => e.toString() == 'AlertType.${_alert!.type}'))),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                getAlertTypeLabel(AlertType.values.firstWhere((e) => e.toString() == 'AlertType.${_alert!.type}')),
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => MapPage(alert: _alert),
                            //   ),
                            // );
                          },
                          child: Container(
                            height: 170,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
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
