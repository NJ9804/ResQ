import 'package:flutter/material.dart';
import 'package:googlemap/components/button.dart';
import 'package:googlemap/pages/add_alert_page.dart';

class MyDescriptionBox extends StatelessWidget {
  const MyDescriptionBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(left: 20, right:20, bottom: 20),
      child: Column(
        children: [
          Text(
            "Have An Alert?",
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            "Add it here and we will help you spread the word.",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          MyButton(
            text: "Add Alert",
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AddAlert()));
            },
          ),
        ],
      ),
    );
  }
}
