import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'medicine_display.dart'; // Import MedicineDisplay page

class MedicineFinderPage extends StatefulWidget {
  @override
  _MedicineFinderPageState createState() => _MedicineFinderPageState();
}

class _MedicineFinderPageState extends State<MedicineFinderPage> {
  final TextEditingController _queryController = TextEditingController();
  List<Map<String, dynamic>> _responses = [];
  bool _isLoading = false;

  Future<List<Map<String, dynamic>>> _loadMedicineData() async {
    // Load the medicine data from the JSON file
    String jsonData =
        await DefaultAssetBundle.of(context).loadString('assets/medicine_data.json');
    List<dynamic> medicineList = jsonDecode(jsonData);
    return List<Map<String, dynamic>>.from(medicineList);
  }

  Future<void> _fetchResponses(String query) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final url = Uri.parse('https://medwiki.onrender.com/get_responses');
    final body = jsonEncode({"user_query": query});

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['responses'] != null) {
        // Load medicine data
        List<Map<String, dynamic>> medicineData = await _loadMedicineData();

        setState(() {
          _responses = List<Map<String, dynamic>>.from(data['responses']);
          // Map medicine ID to each response
          _responses.forEach((response) {
            String medicineName = response['medicine'];
            for (var medicine in medicineData) {
              if (medicine['medicine'] == medicineName) {
                response['medicine_id'] = medicine['id'];
                break;
              }
            }
          });
          _isLoading = false; // Stop loading
        });
      }
    } else {
      setState(() {
        _isLoading = false; // Stop loading in case of error
      });
      throw Exception('Failed to fetch responses');
    }
  }

  void _onResponseTap(int medicineId) {
    // Navigate to MedicineDisplay page and pass the medicine ID
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineDisplay(medicineId: medicineId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Medicine Finder',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
          ),
          backgroundColor: Colors.green, // Changed app bar color
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  labelText: 'Enter your query',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final query = _queryController.text.trim();
                  if (query.isNotEmpty) {
                    _fetchResponses(query);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a query.'),
                      ),
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator()) // Loader while loading
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _responses.length,
                        itemBuilder: (context, index) {
                          final medicine = _responses[index]['medicine'];
                          final similarityScore =
                              _responses[index]['similarity_score'];

                          return GestureDetector(
                            onTap: () {
                              _onResponseTap(_responses[index]['medicine_id']);
                            },
                            child: Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: ListTile(
                                title: Text(
                                  medicine,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Similarity Score: $similarityScore',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
