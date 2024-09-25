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
        return AlertDialog(backgroundColor: Colors.white,
          title: const Text('Application Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: detailsMap.entries.map((entry) {
                final heading = entry.key;
                final details = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heading,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Divider(),
                      ...details.map((detail) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Employee Name: ${detail['employeeName'] ?? 'N/A'}'),
                              Text('Approval ID: ${detail['approvalId'] ?? 'N/A'}'),
                              Text('Level Status: ${detail['levelStatus'] ?? 'Pending'}'),
                              const Divider(),
                            ],
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
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: applications.isEmpty
          ? const Center(child: CircularProgressIndicator())
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
    return Card(color: Colors.white,
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue[300],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.blue,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFuturisticText(
              'Leave Date: ${application['leaveFromDate'] ?? 'N/A'}',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            _buildFuturisticText(
              'Application Date: ${application['applicationDate'] ?? 'N/A'}',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 10),
            _buildFuturisticText(
              'Application Status: ${application['applicationStatusName'] ?? 'Pending'}',
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 10),
            _buildFuturisticText(
              'No of Days: ${application['noOfDays'] ?? 0}',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 10),
            _buildFuturisticText(
              'Levels: ${application['levels'] ?? 0}',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () => _viewDetails(application['applicationId']),
                child: const Text(
                  "View Details",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
