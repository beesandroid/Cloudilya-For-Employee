import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  int physicallyHandicapped = 0;
  int associatedWithInstitution = 0;

  @override
  void initState() {
    super.initState();
    fetchDependents();
    fetchRelationList();
    fetchGenderList();
  }

  Future<void> fetchDependents() async {
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
    final url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeDependents';
    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "GrpCode": "Beesdev",
          "ColCode": colCode,
          "DependentId": 0,
          "CollegeId": collegeId,
          "EmployeeId": employeeId,
          "UserId": adminUserId,
          "LoginIpAddress": "",
          "LoginSystemName": "",
          "Flag": "VIEW",
          "EmployeeDependentsVariable": []
        }));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        dependentsList = data['employeeDependentsList'] ?? [];
      });
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to load dependents',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
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
        return Dialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dependent == null ? 'Add Dependent' : 'Edit Dependent',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: 16),
                // First Row: First Name & Last Name
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Date of Birth & Aadhaar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: dateOfBirthController,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          isDense: true,
                          suffixIcon: Icon(Icons.calendar_today, size: 20),
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: dependent == null
                                ? DateTime.now()
                                : DateTime.parse(dependent['dateOfBirth']),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            dateOfBirthController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: aadhaarCardNumberController,
                        decoration: InputDecoration(
                          labelText: 'Aadhaar Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Contact Number
                TextField(
                  controller: contactNumberController,
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                    prefixIcon: Icon(Icons.phone, size: 20),
                  ),
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: initialRelationship != 0
                      ? initialRelationship
                      : null,
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: initialGender != 0 ? initialGender : null,
                  items: genderList.map((item) {
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                  ),
                ),
                // Relationship & Gender

                SizedBox(height: 10),
                // Physically Handicapped & Associated With Institution
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: physicallyHandicapped,
                        decoration: InputDecoration(
                          labelText: 'Physically Handicapped',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          isDense: true,
                        ),
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
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: associatedWithInstitution,
                        decoration: InputDecoration(
                          labelText: 'Associated With Institution',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          isDense: true,
                        ),
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
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Association Details & End Date

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
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
                            physicallyHandicapped,
                            associatedWithInstitution,
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
                            physicallyHandicapped,
                            associatedWithInstitution,
                            associationDetailsController.text,
                            endDateController.text,
                          );
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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

    final url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeDependents';
    final requestBody = jsonEncode({
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "DependentId": 0,
      "CollegeId": collegeId,
      "EmployeeId": employeeId,
      "UserId": adminUserId,
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
    print("sssss"+requestBody);

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody.containsKey('message')) {
        Fluttertoast.showToast(
          msg: responseBody['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      fetchDependents(); // Reload data
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to add dependent',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

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
    final url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeDependents';
    final requestBody = jsonEncode({
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "DependentId": 0, // This may be redundant if using dependentId directly
      "CollegeId": collegeId,
      "EmployeeId": employeeId,
      "UserId": adminUserId,
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

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody.containsKey('message')) {
        Fluttertoast.showToast(
          msg: responseBody['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      fetchDependents(); // Reload data
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to edit dependent',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  Future<void> deleteDependent(int dependentId) async {
    final url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeDependents';
    final requestBody = jsonEncode({
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "DependentId": dependentId,
      "CollegeId": 1,
      "EmployeeId": "17051",
      "UserId": "1",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "DELETE",
      "EmployeeDependentsVariable": []
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody.containsKey('message')) {
        Fluttertoast.showToast(
          msg: responseBody['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      fetchDependents(); // Reload data
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to delete dependent',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
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
        title: Text(
          'Employee Dependents',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.blueAccent,
      ),
      body: dependentsList.isEmpty
          ? Center(
        child: Text(
          'No dependents found.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchDependents,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: dependentsList.length,
          itemBuilder: (context, index) {
            final dependent = dependentsList[index];
            return Dismissible(
              key: Key(dependent['dependentId'].toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirm Delete'),
                    content:
                    Text('Are you sure you want to delete this dependent?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      ElevatedButton(
                        child: Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) {
                deleteDependent(dependent['dependentId']);
              },
              child: Card(color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 16),
                  title: Text(
                    '${dependent['firstName']} ${dependent['lastName']}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.assignment_ind,
                              size: 16,                      color: Colors.blue.shade900,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Aadhaar: ${dependent['aadhaarCardNumber']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person, size: 16,                    color: Colors.blue.shade900,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Gender: ${dependent['genderName']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person, size: 16,                     color: Colors.blue.shade900,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Relation: ${dependent['relationName']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16,                     color: Colors.blue.shade900,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Contact: ${dependent['contactNumber']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.info, size: 16,                     color: Colors.blue.shade900,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Status: ${dependent['status']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () {
                      // Check if the status is "pending" or "Pending"
                      final String status = dependent['status']?.toString() ?? '';

                      if (status.toLowerCase() == 'pending') {
                        // Show a toast message if the status is pending
                        Fluttertoast.showToast(
                          msg: "Changes sent for approval cannot be edited now",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else {
                        // Allow editing if the status is not pending
                        showDependentForm(dependent: dependent);
                      }
                    },
                  ),

                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDependentForm(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        tooltip: 'Add Dependent',
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcons(
      BuildContext context, Map<String, dynamic> dependent) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blueAccent),
          onPressed: () => showDependentForm(dependent: dependent),
        ),
      ],
    );
  }
}
