import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'MaterialUploading.dart';

class EmployeeMaterialScreen extends StatefulWidget {
  @override
  _EmployeeMaterialScreenState createState() => _EmployeeMaterialScreenState();
}

class _EmployeeMaterialScreenState extends State<EmployeeMaterialScreen> {
  List<dynamic> _employeeMaterialList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeMaterialData();
  }

  Future<void> _fetchEmployeeMaterialData() async {
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeMaterialUploading'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "GrpCode": "Beesdev",
        "ColCode": "0001",
        "CollegeId": 1,
        "UserId": 1,
        "Id": 1,
        "Batch": "",
        "TopicId": 159,
        "ChooseFile": "23148_Regular.pdf",
        "UpdatedDate": "2024-09-18",
        "EmployeeId": 3,
        "ProgramId": 51,
        "BranchId": 62,
        "SemId": 47,
        "SectionId": 0,
        "CourseId": 1556,
        "MaterialType": 0,
        "Unit": "5652",
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "VIEW"
      }),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(responseData);
      setState(() {
        _employeeMaterialList = responseData['employeeMaterialUploadingList'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEmployeeMaterial(
      int id, int topicId, String updatedDate, String ChooseFile) async {
    final requestBody = json.encode({
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": 1,
      "EmployeeId": 3,
      "UserId": 1,
      "UpdatedDate": updatedDate,
      "ChooseFile": ChooseFile,
      "TopicId": topicId,
      "Batch": "",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Id": id,
      "Flag": "DELETE",
    });
    print('Request Body: $requestBody');
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeMaterialUploading'),
      headers: {"Content-Type": "application/json"},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        _employeeMaterialList.removeWhere((item) => item['id'] == id);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete material')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Employee Material',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22, // Enhanced font size for richness
          ),
        ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProgramDropdownScreen(),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue.shade900,
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounder, more modern FAB
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _employeeMaterialList.length,
                    itemBuilder: (context, index) {
                      final item = _employeeMaterialList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        child: Material(
                          elevation: 8.0,
                          shadowColor: Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          child: ExpansionTile(
                            backgroundColor: Colors.white,
                            collapsedBackgroundColor: Colors.white,
                            tilePadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            leading: Icon(Icons.description,
                                color: Colors.blue.shade900),
                            title: Text(
                              item['topicName'] ?? 'No Topic Name',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            childrenPadding: EdgeInsets.all(16.0),
                            expandedAlignment: Alignment.centerLeft,
                            children: [
                              Container(
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoText(
                                        'Program', item['programName']),
                                    _buildInfoText(
                                        'Branch', item['branchName']),
                                    _buildInfoText(
                                        'Semester', item['semester']),
                                    _buildInfoText(
                                        'Course', item['courseName']),
                                    _buildInfoText('Material Type',
                                        item['materialTypeName']),
                                    _buildInfoText('Unit', item['unitName']),
                                    _buildInfoText(
                                        'Updated Date', item['updatedDate']),
                                    _buildInfoText(
                                        'File Names', item['chooseFileName']),
                                    SizedBox(height: 16.0),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade600,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 10.0),
                                        ),
                                        onPressed: () async {
                                          final confirm = await showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: Text(
                                                'Delete Material',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: Text(
                                                'Are you sure you want to delete this material?',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx)
                                                          .pop(false),
                                                  child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx)
                                                          .pop(true),
                                                  child: Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.red.shade700,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm) {
                                            _deleteEmployeeMaterial(
                                              item['id'],
                                              item['topicId'],
                                              item['updatedDate'],
                                              item['chooseFileName'],
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          'Delete',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

// Utility method to build rich info text fields
  Widget _buildInfoText(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
