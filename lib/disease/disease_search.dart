import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:MedWiki/disease/disease_display.dart';

class DiseaseFinderPage extends StatefulWidget {
  @override
  _DiseaseFinderPageState createState() => _DiseaseFinderPageState();
}

class _DiseaseFinderPageState extends State<DiseaseFinderPage> {
  final TextEditingController _queryController = TextEditingController();
  List<Map<String, dynamic>> _responses = [];
  Future<List<Map<String, dynamic>>>? _futureResponse;

  Future<List<Map<String, dynamic>>> _loadDiseaseData() async {
    // Load the disease data from the JSON file
    String jsonData = await DefaultAssetBundle.of(context)
        .loadString('assets/disease_data.json');
    List<dynamic> diseaseList = jsonDecode(jsonData);
    return List<Map<String, dynamic>>.from(diseaseList);
  }

  Future<List<Map<String, dynamic>>> _fetchResponses(String query) async {
    final url =
        Uri.parse('https://medbot-api-endpoint.onrender.com/get_responses');
    final body = jsonEncode({"user_query": query});

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['responses'] != null) {
        // Load disease data
        List<Map<String, dynamic>> diseaseData = await _loadDiseaseData();

        List<Map<String, dynamic>> responses =
            List<Map<String, dynamic>>.from(data['responses']);
        // Map disease ID to each response
        responses.forEach((response) {
          String diseaseName = response['disease'];
          for (var disease in diseaseData) {
            if (disease['disease'] == diseaseName) {
              response['disease_id'] = disease['id'];
              break;
            }
          }
        });
        return responses;
      }
    } else {
      throw Exception('Failed to fetch responses');
    }
    return [];
  }

  void _onResponseTap(int diseaseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiseaseDataPage(diseaseId: diseaseId),
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
            'Disease Finder',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
          ),
          backgroundColor: Colors.red, // Changed app bar color
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
                    setState(() {
                      _futureResponse = _fetchResponses(query);
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a query.'),
                      ),
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white,fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _futureResponse == null
                    ? const Center(child: Text(''))
                    : FutureBuilder<List<Map<String, dynamic>>>(
                        future: _futureResponse,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.hasData &&
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No responses found.'));
                          } else {
                            _responses = snapshot.data!;
                            return ListView.builder(
                              itemCount: _responses.length,
                              itemBuilder: (context, index) {
                                final disease = _responses[index]['disease'];
                                final diseaseId =
                                    _responses[index]['disease_id'];
                                final similarityScore =
                                    _responses[index]['similarity_score'];

                                return GestureDetector(
                                  onTap: () {
                                    _onResponseTap(diseaseId);
                                  },
                                  child: Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    child: ListTile(
                                      title: Text(
                                        '$disease',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Similarity Score: $similarityScore',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
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
