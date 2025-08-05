import 'package:flutter/material.dart';

class BlindAssistOverviewScreen extends StatelessWidget {
  const BlindAssistOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blind Assist Overview'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Blind Assist!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Our assistant is designed to help you navigate the world with more independence. It combines powerful AI models to give you real-time information about your surroundings.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Key Features:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.visibility_outlined),
              title: Text('Object Recognition'),
              subtitle: Text('Get a description of objects in your camera\'s view.'),
            ),
            ListTile(
              leading: Icon(Icons.textsms_outlined),
              title: Text('Text Recognition'),
              subtitle: Text('Read text from signs, labels, and documents.'),
            ),
            // Add more features as needed
          ],
        ),
      ),
    );
  }
}