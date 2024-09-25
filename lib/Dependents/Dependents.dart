import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class Dependents extends StatefulWidget {
  const Dependents({super.key});

  @override
  State<Dependents> createState() => _DependentsState();
}

class _DependentsState extends State<Dependents> {
  List dependentsList = [];
  List relationList = [];
  List genderList = [];
  int? selectedRelationship;
  int physicallyHandicapped=0;
  int associatedWithInstitution = 0;

  @override
  void initState() {
    super.initState();
    fetchDependents();
    fetchRelationList();
    fetchGenderList();
  }

  Future<void> fetchDependents() async {
    final url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeDependents';
    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "GrpCode": "Beesdev",
          "ColCode": "0001",
          "DependentId": 0,
          "CollegeId": 1,
          "EmployeeId": "13",
          "UserId": "1",
          "LoginIpAddress": "",
          "LoginSystemName": "",
          "Flag": "VIEW",
          "EmployeeDependentsVariable": []
        }));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      setState(() {
        dependentsList = data['employeeDependentsList'] ?? [];
      });
    }
  }

  Future<void> fetchRelationList() async {
    final url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/CommonLookUpsDropDown';
    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "GrpCode": "Beesdev",
          "ColCode": "0001",
          "Flag": 31,
        }));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        relationList = data['relationList'] ?? [];
      });
    }
  }
  //EMP20240001

  Future<void> fetchGenderList() async {
    final url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/CommonLookUpsDropDown';
    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "GrpCode": "Beesdev",
          "ColCode": "0001",
          "Flag": 16,
        }));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        genderList = data['genderList'] ?? [];
      });
    }
  }

  // Function to show a form for adding or editing dependent
  void showDependentForm({Map? dependent}) {
    // Initialize controllers with existing values or empty strings
    TextEditingController firstNameController =
        TextEditingController(text: dependent?['firstName'] ?? '');
    TextEditingController lastNameController =
        TextEditingController(text: dependent?['lastName'] ?? '');
    TextEditingController dateOfBirthController =
        TextEditingController(text: dependent?['dateOfBirth'] ?? '');
    TextEditingController aadhaarCardNumberController =
        TextEditingController(text: dependent?['aadhaarCardNumber'] ?? '');
    TextEditingController contactNumberController =
        TextEditingController(text: dependent?['contactNumber'] ?? '');
    TextEditingController associationDetailsController =
        TextEditingController(text: dependent?['associationDetails'] ?? '');
    TextEditingController endDateController =
        TextEditingController(text: dependent?['endDate'] ?? '');

    // Initialize state values
    int initialRelationship = dependent?['relationship'] ?? 0;
    int initialGender = dependent?['gender'] ?? 0;
    int initialPhysicallyHandicapped = dependent?['physicallyHandicapped'] ?? 0;
    int initialAssociatedWithInstitution =
        dependent?['associatedWithInstitution'] ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return
          AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            dependent == null ? 'Add Dependent' : 'Edit Dependent',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          content:
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: dateOfBirthController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: aadhaarCardNumberController,
                  decoration: InputDecoration(
                    labelText: 'Aadhaar Card Number',
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: contactNumberController,
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: relationList.isNotEmpty &&
                          relationList.any(
                              (item) => item['lookUpId'] == initialRelationship)
                      ? initialRelationship
                      : null,
                  dropdownColor: Colors.white,
                  items: relationList.map((item) {
                    return DropdownMenuItem<int>(
                      value: item['lookUpId'],
                      child: Text(item['meaning']),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      initialRelationship = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Relationship',
                    enabledBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: genderList.isNotEmpty &&
                          genderList
                              .any((item) => item['lookUpId'] == initialGender)
                      ? initialGender
                      : null,
                  dropdownColor: Colors.white,
                  items: genderList.map<DropdownMenuItem<int>>((item) {
                    return DropdownMenuItem<int>(
                      value: item['lookUpId'],
                      child: Text(item['meaning']),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      initialGender = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    enabledBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: physicallyHandicapped,
                  decoration:
                      InputDecoration(labelText: 'Physically Handicapped'),
                  items: [
                    DropdownMenuItem(value: 0, child: Text('No')),
                    DropdownMenuItem(value: 1, child: Text('Yes')),
                  ],
                  onChanged: (int? newValue) {
                    setState(() {
                      physicallyHandicapped = newValue!;
                    });
                  },
                ),
                SizedBox(height: 10),

                DropdownButtonFormField<int>(
                  value: associatedWithInstitution,
                  decoration:
                      InputDecoration(labelText: 'Associated With Institution'),
                  items: [
                    DropdownMenuItem(value: 0, child: Text('No')),
                    DropdownMenuItem(value: 1, child: Text('Yes')),
                  ],
                  onChanged: (int? newValue) {
                    setState(() {
                      associatedWithInstitution = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: const Text('Cancel',style: TextStyle(fontWeight: FontWeight.bold),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Save'),
              onPressed: () {
                if (dependent == null) {
                  addDependent(
                    firstNameController.text,
                    lastNameController.text,
                    dateOfBirthController.text,
                    aadhaarCardNumberController.text,
                    contactNumberController.text,
                    initialRelationship,
                    initialGender,
                    initialPhysicallyHandicapped,
                    initialAssociatedWithInstitution,
                    associationDetailsController.text,
                    endDateController.text,
                  );
                } else {
                  editDependent(
                    dependent['dependentId'],
                    firstNameController.text,
                    lastNameController.text,
                    dateOfBirthController.text,
                    aadhaarCardNumberController.text,
                    contactNumberController.text,
                    initialRelationship,
                    initialGender,
                    initialPhysicallyHandicapped,
                    initialAssociatedWithInstitution,
                    associationDetailsController.text,
                    endDateController.text,
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Add dependent function
  Future<void> addDependent(
    String firstName,
    String lastName,
    String dateOfBirth,
    String aadhaarCardNumber,
    String contactNumber,
    int relationship,
    int gender,
    int physicallyHandicapped,
    int associatedWithInstitution,
    String associationDetails,
    String endDate,
  ) async {
    final url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeDependents';

    // Prepare the request body
    final requestBody = jsonEncode({
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "DependentId": 0,
      "CollegeId": 1,
      "EmployeeId": "13",
      "UserId": "1",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "CREATE",
      "EmployeeDependentsVariable": [
        {
          "DependentId": 0,
          "FirstName": firstName,
          "LastName": lastName,
          "DateOfBirth": dateOfBirth,
          "AadhaarCardNumber": aadhaarCardNumber,
          "ContactNumber": contactNumber,
          "Relationship": relationship,
          "Gender": gender,
          "PhysicallyHandicapped": physicallyHandicapped,
          "AssociatedWithInstitution": associatedWithInstitution,
          "AssociationDetails": associationDetails,
          "EndDate": endDate,
        }
      ]
    });

    // Print the request body
    print('Request Body: $requestBody');

    // Send the POST request
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      // Check if the message key is present
      if (responseBody.containsKey('message')) {
        // Show Snackbar with the message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody['message']),
            duration: Duration(seconds: 4),
          ),
        );
      }
      print(response.body);
      fetchDependents(); // Reload data
    } else {
      print('Failed to add dependent: ${response.statusCode}');
    }
  }

  // Edit dependent function
  Future<void> editDependent(
    int dependentId,
    String firstName,
    String lastName,
    String dateOfBirth,
    String aadhaarCardNumber,
    String contactNumber,
    int relationship,
    int gender,
    int physicallyHandicapped,
    int associatedWithInstitution,
    String associationDetails,
    String endDate,
  ) async {
    final url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeDependents';

    // Prepare the request body
    final requestBody = jsonEncode({
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "DependentId": 0, // This may be redundant if using dependentId directly
      "CollegeId": 1,
      "EmployeeId": "13",
      "UserId": "1",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "OVERWRITE",
      "EmployeeDependentsVariable": [
        {
          "DependentId": dependentId,
          "FirstName": firstName,
          "LastName": lastName,
          "DateOfBirth": dateOfBirth,
          "AadhaarCardNumber": aadhaarCardNumber,
          "ContactNumber": contactNumber,
          "Relationship": relationship,
          "Gender": gender,
          "PhysicallyHandicapped": physicallyHandicapped,
          "AssociatedWithInstitution": associatedWithInstitution,
          "AssociationDetails": associationDetails,
          "EndDate": endDate,
        }
      ]
    });

    // Print the request body
    print('Request Body: $requestBody');

    // Send the POST request
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      // Check if the message key is present
      if (responseBody.containsKey('message')) {
        // Show Snackbar with the message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody['message']),
            duration: Duration(seconds: 4),
          ),
        );
      }
      print('Response: ${response.body}');
      fetchDependents(); // Reload data
    } else {
      print('Failed to edit dependent: ${response.statusCode}');
    }
  }

  // Delete dependent function
  Future<void> deleteDependent(int dependentId) async {
    final url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeDependents';

    // Prepare the request body
    final requestBody = jsonEncode({
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "DependentId": dependentId,
      "CollegeId": 1,
      "EmployeeId": "13",
      "UserId": "1",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "DELETE",
      "EmployeeDependentsVariable": []
    });

    // Print the request body
    print('Request Body: $requestBody');

    // Send the POST request
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      // Check if the message key is present
      if (responseBody.containsKey('message')) {
        // Show Snackbar with the message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody['message']),
            duration: Duration(seconds: 4),
          ),
        );
      }
      print('Response: ${response.body}');
      fetchDependents(); // Reload data
    } else {
      print('Failed to delete dependent: ${response.statusCode}');
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
        title: Text(
          'Employee Dependents',
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: dependentsList.length,
        itemBuilder: (context, index) {
          final dependent = dependentsList[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                '${dependent['firstName']} ${dependent['lastName']}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoText('Aadhaar:', dependent['aadhaarCardNumber']),
                  _buildInfoText('Gender:', dependent['genderName']),
                  _buildInfoText('Relation:', dependent['relationName']),
                  _buildInfoText('Contact:', dependent['contactNumber']),
                  _buildInfoText('Status:', dependent['status']),
                ],
              ),
              trailing: _buildActionIcons(context, dependent),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDependentForm(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$label $value',
    style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildActionIcons(
      BuildContext context, Map<String, dynamic> dependent) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit_document, color: Colors.blue),

          onPressed: () => showDependentForm(dependent: dependent),
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => deleteDependent(dependent['dependentId']),
        ),
      ],
    );
  }
}
