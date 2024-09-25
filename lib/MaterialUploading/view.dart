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
        "Unit": 5652,
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
      // Handle error response
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEmployeeMaterial(
      int id, int topicId, String updatedDate, String ChooseFile) async {
    // Prepare the request body
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
      "Id": id, // Use the ID of the item to delete
      "Flag": "DELETE", // Set flag to "DELETE"
      // Add other relevant values in the request body if necessary
    });

    // Print the request body to the console
    print('Request Body: $requestBody');

    // Make the API call
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeMaterialUploading'),
      headers: {"Content-Type": "application/json"},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      print(response.body);
      // Remove the deleted item from the list
      setState(() {
        _employeeMaterialList.removeWhere((item) => item['id'] == id);
      });
    } else {
      // Handle error if delete request fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete material')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Material',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                builder: (context) =>
                    ProgramDropdownScreen()), // Navigate to ProgramDropdownScreen
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
        elevation: 8.0,
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
                      return Card(
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['topicName'] ?? 'No Topic Name',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      // Ask for confirmation before deleting
                                      final confirm = await showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text('Delete Material'),
                                          content: Text(
                                              'Are you sure you want to delete this material?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm) {
                                        _deleteEmployeeMaterial(
                                            item['id'],
                                            item['topicId'],
                                            item['updatedDate'],
                                            item[
                                                'chooseFileName']); // Call delete function
                                      }
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              Text('Program: ${item['programName'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 16)),
                              Text('Branch: ${item['branchName'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 16)),
                              Text('Semester: ${item['semester'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 16)),
                              Text('Course: ${item['courseName'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 16)),
                              Text(
                                  'Material Type: ${item['materialTypeName'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 16)),
                              Text('Unit: ${item['unitName'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 16)),
                              Text(
                                  'Updated Date: ${item['updatedDate'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 16)),
                              Text(
                                  'File Names: ${item['chooseFileName'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 16)),
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
}
