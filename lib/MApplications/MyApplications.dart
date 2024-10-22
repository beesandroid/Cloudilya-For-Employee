import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Myapplications extends StatefulWidget {
  const Myapplications({super.key});

  @override
  State<Myapplications> createState() => _MyapplicationsState();
}

class _MyapplicationsState extends State<Myapplications> {
  List<dynamic> applications = [];

  @override
  void initState() {
    super.initState();
    _fetchApplicationData();
  }

  Future<void> _fetchApplicationData() async {
    const apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/ClassAdjustmentDataVIEW';
    const requestBody = {
      "GrpCode": "BEESdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "3",
      "ApplicationId": "0",
      "AdjustmentId": "0",
      "UserId": "759",
      "Flag": "MYAPPLICATION"
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode(requestBody),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          applications = data['multiList'] ?? [];
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _viewDetails(int applicationId) async {
    const apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/ClassAdjustmentDataVIEW';

    // List of flags to call sequentially
    final flags = ["LEVELVIEW", "ABSENCEVIEW", "APPLICATIONVIEW"];
    Map<String, List<dynamic>> allDetails = {};

    try {
      for (String flag in flags) {
        final requestBody = {
          "GrpCode": "BEESdev",
          "ColCode": "0001",
          "CollegeId": "1",
          "EmployeeId": "3",
          "AdjustmentId": "0",
          "applicationId": applicationId,
          "UserId": "759",
          "Flag": flag
        };

        final response = await http.post(
          Uri.parse(apiUrl),
          body: jsonEncode(requestBody),
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final details = data['multiList'] ?? [];

          // Assign heading based on the flag
          switch (flag) {
            case "LEVELVIEW":
              allDetails['Level Details'] = details;
              break;
            case "ABSENCEVIEW":
              allDetails['Absence Details'] = details;
              break;
            case "APPLICATIONVIEW":
              allDetails['Application Details'] = details;
              break;
          }
        } else {
          throw Exception('Failed to load details for flag: $flag');
        }
      }

      // Show the combined details in the dialog
      _showDetailsDialog(allDetails);
    } catch (e) {
      print(e);
    }
  }


  void _showDetailsDialog(Map<String, List<dynamic>> detailsMap) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Center(
            child: Text(
              'Application Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.blue,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: detailsMap.entries.map((entry) {
                final heading = entry.key;
                final details = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heading,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),
                      const Divider(thickness: 2, color: Colors.black),
                      ...details.map((detail) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black87,
                                  blurRadius: 4.0,
                                  spreadRadius: 1.0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Employee Name: ${detail['employeeName'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Approval ID: ${detail['approvalId'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Level Status: ${detail['levelStatus'] ?? 'Pending'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        backgroundColor: Colors.white,
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
          title: const Text(
            "My Applications",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.black,
        ),
        body: applications.isEmpty
            ? const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "No applications available",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        )
            : ListView.builder(
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final application = applications[index];
            return _buildApplicationCard(application);
          },
        ),
      );

  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    return Card(
      color: Colors.white,
      elevation: 10,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey,
            width: 2,
          ),

        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFuturisticText(
              'Leave Date: ${application['leaveFromDate'] ?? 'N/A'}',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            const SizedBox(height: 10),
            _buildFuturisticText(
              'Application Date: ${application['applicationDate'] ?? 'N/A'}',
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 10),
            _buildFuturisticText(
              'Application Status: ${application['applicationStatusName'] ?? 'Pending'}',
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
            const SizedBox(height: 10),
            _buildFuturisticText(
              'No of Days: ${application['noOfDays'] ?? 0}',
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 10),
            _buildFuturisticText(
              'Levels: ${application['levels'] ?? 0}',
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                onPressed: () => _viewDetails(application['applicationId']),
                child: const Text(
                  "View Details",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFuturisticText(String text,
      {double fontSize = 16,
        FontWeight fontWeight = FontWeight.normal,
        Color color = Colors.black}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        fontFamily: 'RobotoMono',
      ),
    );
  }
}
