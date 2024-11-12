import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Requests extends StatefulWidget {
  const Requests({super.key});

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  String? _selectedRequest; // Variable to hold the selected dropdown value
  List<Map<String, dynamic>> _adjustmentData = []; // To store response data
  bool _isLoading = false;

  final List<String> _requestTypes = [
    'My Request',
    'Accepted Request',
    'Pending Request',
    'Rejected Request'
  ];

  final Map<String, String> _flags = {
    'My Request': 'MYREQUESTSVIEW',
    'Accepted Request': 'PENDINGREQUESTS',
    'Pending Request': 'APPROVEDREQUESTS',
    'Rejected Request': 'REJECTEDREQUESTS',
  };

  @override
  void initState() {
    super.initState();
    _fetchAdjustmentData(""); // Fetch data when the screen opens
  }

  Future<void> _fetchAdjustmentData(String flag) async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');
    final finYearId = prefs.getInt('finYearId');
    final acYearId = prefs.getInt('acYearId');
    final adminUserId = prefs.getString('adminUserId');
    final acYear = prefs.getString('acYear');
    final finYear = prefs.getString('finYear');
    final employeeId = prefs.getInt('employeeId');
    final collegeId = prefs.getString('collegeId');
    final colCode = prefs.getString('colCode');
    setState(() {
      _isLoading = true;
    });

    const String apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/ClassAdjustmentDataVIEW';

    final Map<String, dynamic> requestBody = {
      "GrpCode": "BEESdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "EmployeeId": employeeId,
      "ApplicationId": "0",
      "AdjustmentId": "0",
      "UserId": adminUserId,
      "Flag": flag
    };
    print(requestBody);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          _adjustmentData = List<Map<String, dynamic>>.from(data['multiList']);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Requests',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Request Type:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              value: _selectedRequest,
              items: _requestTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedRequest = newValue;
                });
                _fetchAdjustmentData(_flags[
                    newValue!]!); // Fetch data based on dropdown selection
              },
              hint: Text('Please select a request type'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _adjustmentData.isEmpty
                    ? Center(
                        child: Text('No data available',
                            style: TextStyle(fontSize: 16)))
                    :
            Expanded(
                        child: ListView.builder(
                            itemCount: _adjustmentData.length,
                            itemBuilder: (context, index) {
                              final adjustment = _adjustmentData[index];
                              return Card(
                                color: Colors.white,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                elevation: 7,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Application ID: ${adjustment['applicationId']?.toString() ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      _buildDataRow(
                                          'Requested Name',
                                          adjustment['requestedByName']
                                                  ?.toString() ??
                                              'N/A'),
                                      _buildDataRow(
                                          'Application Date',
                                          adjustment['applicationDate']
                                                  ?.toString() ??
                                              'N/A'),
                                      _buildDataRow(
                                          'No of Days',
                                          adjustment['noOfDays']?.toString() ??
                                              'N/A'),
                                      _buildDataRow(
                                          'Request Date',
                                          adjustment['requestDate']
                                                  ?.toString() ??
                                              'N/A'),
                                      _buildDataRow(
                                          'classAdjustmentDetails',
                                          adjustment['classAdjustmentDetails']
                                                  ?.toString() ??
                                              'N/A'),
                                      _buildDataRow(
                                          'classAdjustmentStatusName',
                                          adjustment['classAdjustmentStatusName']
                                                  ?.toString() ??
                                              'N/A'),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: TextStyle(
                  fontSize: 16,

                  color: Colors.black),
              overflow: TextOverflow
                  .ellipsis, // Prevents overflow by truncating the text
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.right,
              overflow: TextOverflow
                  .ellipsis, // Prevents overflow by truncating the text
            ),
          ),
        ],
      ),
    );
  }
}
