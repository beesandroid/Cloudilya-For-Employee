import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailsScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final employeeDetails = data['employeeDetailsForApprovalList']?.first ?? {};
    final papers = data['employeePapersTabDisplayList'] ?? [];
    final conferences = data['employeePapersConferencesTabTempDisplayList'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Employee Details
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employee Details',

                  ),
                  SizedBox(height: 10),
                  _buildDetailRow('Employee Name:', employeeDetails['employeeName']),
                  _buildDetailRow('Employee ID:', employeeDetails['employeeNumber']),
                  _buildDetailRow('Designation:', employeeDetails['designationName']),
                  _buildDetailRow('Department:', employeeDetails['departmentName']),
                  _buildDetailRow('Email:', employeeDetails['emailAddress']),
                  _buildDetailRow('Phone Number:', employeeDetails['phoneNumber']),
                ],
              ),
            ),
          ),

          // Employee Papers
          if (papers.isNotEmpty) ...[
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Employee Papers',

                    ),
                    SizedBox(height: 10),
                    for (var paper in papers) ...[
                      _buildDetailRow('Title:', paper['title']),
                      _buildDetailRow('Language:', paper['languageName']),
                      _buildDetailRow('Author Role:', paper['authorRoleName']),
                      SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          ],

          // Employee Conferences
          if (conferences.isNotEmpty) ...[
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Employee Conferences',

                    ),
                    SizedBox(height: 10),
                    for (var conference in conferences) ...[
                      _buildDetailRow('Conference Name:', conference['nameOftheConference']),
                      _buildDetailRow('Title:', conference['titleName']),
                      _buildDetailRow('Date:', conference['date']),
                      _buildDetailRow('Place:', conference['placeOfTheConference']),
                      _buildDetailRow('Type:', conference['interNationalOrNationalName']),
                      SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
