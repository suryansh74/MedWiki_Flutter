import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MedicineDisplay extends StatelessWidget {
  final int medicineId;
  const MedicineDisplay({Key? key, required this.medicineId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medicine Data',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MedicineDataPage(medicineId: medicineId),
    );
  }
}

class MedicineDataPage extends StatelessWidget {
  final int medicineId;
  const MedicineDataPage({Key? key, required this.medicineId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medicine Data',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: MedicineData(medicineId: medicineId),
    );
  }
}

class MedicineData extends StatefulWidget {
  final int medicineId;
  const MedicineData({Key? key, required this.medicineId}) : super(key: key);

  @override
  _MedicineDataState createState() => _MedicineDataState();
}

class _MedicineDataState extends State<MedicineData> {
  late Future<Medicine> _medicineData;

  @override
  void initState() {
    super.initState();
    _medicineData = _fetchMedicineData();
  }

  Future<Medicine> _fetchMedicineData() async {
    final response = await http.get(
      Uri.parse('https://shieldless-fathoms.000webhostapp.com/medical_conditions_connect_api/medicine_api.php?id=${widget.medicineId}'),
    );

    if (response.statusCode == 200) {
      return Medicine.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load medicine data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Medicine>(
      future: _medicineData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final medicineData = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMedicineInfo('Medicine Name', medicineData.name),
                _buildMedicineInfo('Description', medicineData.description),
                _buildMedicineInfo('Generic Name', medicineData.genericName),
                _buildMedicineInfo('Dosage Form', medicineData.dosageForm),
                _buildMedicineInfo('Strength', medicineData.strength),
                _buildMedicineInfo('Indication Check', medicineData.indicationCheck),
                _buildMedicineInfo('Contraindications', medicineData.contraindications),
                _buildMedicineInfo('Side Effects', medicineData.sideEffects),
                _buildMedicineInfo('Warnings/Precautions', medicineData.warningsPrecautions),
                _buildMedicineInfo('Storage Conditions', medicineData.storageConditions),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildMedicineInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class Medicine {
  final String name;
  final String description;
  final String genericName;
  final String dosageForm;
  final String strength;
  final String indicationCheck;
  final String contraindications;
  final String sideEffects;
  final String warningsPrecautions;
  final String storageConditions;

  Medicine({
    required this.name,
    required this.description,
    required this.genericName,
    required this.dosageForm,
    required this.strength,
    required this.indicationCheck,
    required this.contraindications,
    required this.sideEffects,
    required this.warningsPrecautions,
    required this.storageConditions,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'],
      description: json['medicine_description'],
      genericName: json['medicine_generic_name'],
      dosageForm: json['dosage_form'],
      strength: json['strength'],
      indicationCheck: json['indication_check'],
      contraindications: json['contraindications'],
      sideEffects: json['side_effects'],
      warningsPrecautions: json['warnings_precautions'],
      storageConditions: json['storage_conditions'],
    );
  }
}
