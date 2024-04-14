import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:MedWiki/disease/disease_search.dart';
import 'package:MedWiki/medicine/medicine_search.dart';

class FinderSelectionPage extends StatefulWidget {
  const FinderSelectionPage({Key? key}) : super(key: key);

  @override
  _FinderSelectionPageState createState() => _FinderSelectionPageState();
}

class _FinderSelectionPageState extends State<FinderSelectionPage> {
  int _selectedIndex = 0;

  Widget _buildFinderWidget() {
    switch (_selectedIndex) {
      case 0:
        return MedicineFinderPage();
      case 1:
        return DiseaseFinderPage();
      default:
        return MedicineFinderPage(); // Default to MedicineFinderPage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finder Selection'),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RadioListTile(
                title: const Text('Medicine Finder'),
                value: 0,
                groupValue: _selectedIndex,
                onChanged: (value) {
                  setState(() {
                    _selectedIndex = value as int;
                  });
                },
              ),
              RadioListTile(
                title: const Text('Disease Finder'),
                value: 1,
                groupValue: _selectedIndex,
                onChanged: (value) {
                  setState(() {
                    _selectedIndex = value as int;
                  });
                },
              ),
              Expanded(
                child: _buildFinderWidget(),
              ),
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                Platform.isAndroid ? 'App running on Android' : 'App running on iOS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FinderSelectionPage(),
    ),
  );
}
