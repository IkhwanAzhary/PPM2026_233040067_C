import 'package:flutter/material.dart';

class GaleryWidget extends StatelessWidget {
  const GaleryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {"name": "Display", "icon": Icons.tv},
      {"name": "Input", "icon": Icons.input},
      {"name": "Button", "icon": Icons.smart_button},
      {"name": "Feedback", "icon": Icons.feedback},
      {"name": "Layout", "icon": Icons.layers},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Widget Gallery")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return InkWell(
            onTap: () {
              // Navigation logic here
            },
            child: Card(
              color: Colors.blue.shade50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat["icon"], size: 48, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(cat["name"],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}