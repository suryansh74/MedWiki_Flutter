import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DiseaseDataPage extends StatelessWidget {
  final int diseaseId;

  DiseaseDataPage({required this.diseaseId});

  Future<Disease> _fetchDiseaseData(int id) async {
    id++;
    final response = await http.get(Uri.parse(
        'https://shieldless-fathoms.000webhostapp.com/medical_conditions_connect_api/index.php?id=$id'));

    if (response.statusCode == 200) {
      return Disease.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load disease data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Disease Data',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
        body: FutureBuilder<Disease>(
          future: _fetchDiseaseData(diseaseId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final diseaseData = snapshot.data!;
              return DiseaseDataContent(diseaseData: diseaseData);
            }
          },
        ),
      ),
    );
  }
}

class DiseaseDataContent extends StatelessWidget {
  final Disease diseaseData;

  DiseaseDataContent({required this.diseaseData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDiseaseInfo('Name', diseaseData.name),
          _buildDiseaseInfo('Description', diseaseData.description),
          _buildDiseaseInfo('Symptoms', diseaseData.symptoms),
          _buildDiseaseInfo('Treatment', diseaseData.treatment),
          _buildDiseaseInfo('Medicine', diseaseData.medicine),
          _buildDiseaseInfo('Prescription', diseaseData.prescription),
          _buildDiseaseInfo('Prevalence/Incidence', diseaseData.prevalenceIncidence),
          _buildDiseaseInfo('Causes/Risk Factors', diseaseData.causesRiskFactors),
          _buildDiseaseInfo('Diagnostic Tests', diseaseData.diagnosticTests),
          _buildDiseaseInfo('Age/Gender Distribution', diseaseData.ageGenderDistribution),
          _buildDiseaseInfo('Geographical Distribution', diseaseData.geographicalDistribution),
          _buildDiseaseInfo('Comorbidities', diseaseData.comorbidities),
          _buildDiseaseInfo('Genetic Factors', diseaseData.geneticFactors),
          _buildDiseaseInfo('Environmental Factors', diseaseData.environmentalFactors),
          _buildDiseaseInfo('Patient Reported Outcomes', diseaseData.patientReportedOutcomes),
          _buildDiseaseInfo('Research Studies/Clinical Trials', diseaseData.researchStudiesClinicalTrials),
        ],
      ),
    );
  }

  Widget _buildDiseaseInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class Disease {
  final String name;
  final String description;
  final String symptoms;
  final String treatment;
  final String medicine;
  final String prescription;
  final String prevalenceIncidence;
  final String causesRiskFactors;
  final String diagnosticTests;
  final String ageGenderDistribution;
  final String geographicalDistribution;
  final String comorbidities;
  final String geneticFactors;
  final String environmentalFactors;
  final String patientReportedOutcomes;
  final String researchStudiesClinicalTrials;

  Disease({
    required this.name,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.medicine,
    required this.prescription,
    required this.prevalenceIncidence,
    required this.causesRiskFactors,
    required this.diagnosticTests,
    required this.ageGenderDistribution,
    required this.geographicalDistribution,
    required this.comorbidities,
    required this.geneticFactors,
    required this.environmentalFactors,
    required this.patientReportedOutcomes,
    required this.researchStudiesClinicalTrials,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      name: json['name'],
      description: json['description'],
      symptoms: json['symptoms'],
      treatment: json['treatment'],
      medicine: json['medicine'],
      prescription: json['prescription'],
      prevalenceIncidence: json['prevalence_incidence'],
      causesRiskFactors: json['causes_risk_factors'],
      diagnosticTests: json['diagnostic_tests'],
      ageGenderDistribution: json['age_gender_distribution'],
      geographicalDistribution: json['geographical_distribution'],
      comorbidities: json['comorbidities'],
      geneticFactors: json['genetic_factors'],
      environmentalFactors: json['environmental_factors'],
      patientReportedOutcomes: json['patient_reported_outcomes'],
      researchStudiesClinicalTrials: json['research_studies_clinical_trials'],
    );
  }
}
