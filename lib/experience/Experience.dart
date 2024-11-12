import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Experience extends StatefulWidget {
  const Experience({super.key});

  @override
  State<Experience> createState() => _ExperienceState();
}

class _ExperienceState extends State<Experience> {
  List<dynamic> experienceList = [];
  final _formKey = GlobalKey<FormState>(); // Global key for form

  final industryController = TextEditingController();
  final locationController = TextEditingController();
  final dateFromController = TextEditingController();
  final dateToController = TextEditingController();

  List<dynamic> organizationList = [];
  List<dynamic> designationList = [];
  List<dynamic> mediumList = [];
  List<dynamic> certificateList = [];

  int? selectedOrganizationId;
  int? selectedDesignationId;
  int? selectedMediumId;
  int? selectedCertificateId;

  bool isEditing = false;
  int? empExpId; // To store the ID of the experience being edited

  @override
  void initState() {
    super.initState();
    fetchExperienceData();
    fetchOrganizationData();
    fetchDesignationData();
    fetchMediumData();
    fetchCertificateData();
  }

  // Fetch organization data
  Future<void> fetchOrganizationData() async {
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreprod/CloudilyaMobileAPP/CommonLookUpsDropDown');
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "Flag": 25,
    };
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body));

    if (response.statusCode == 200) {
      setState(() {
        organizationList = json.decode(response.body)['organizationList'];
      });
    } else {
      print('Failed to load organizations');
    }
  }

  // Fetch designation data
  Future<void> fetchDesignationData() async {
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreprod/CloudilyaMobileAPP/DesignationDropDownForExperience');
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
    };
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body));

    if (response.statusCode == 200) {
      setState(() {
        designationList =
        json.decode(response.body)['designationDropDownPayrollList'];
      });
    } else {
      print('Failed to load designations');
    }
  }

  // Fetch medium data
  Future<void> fetchMediumData() async {
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreprod/CloudilyaMobileAPP/CommonLookUpsDropDown');
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "Flag": 13,
    };
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body));

    if (response.statusCode == 200) {
      setState(() {
        mediumList = json.decode(response.body)['mediumList'];
      });
    } else {
      print('Failed to load mediums');
    }
  }

  // Fetch certificate data
  Future<void> fetchCertificateData() async {
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreprod/CloudilyaMobileAPP/CommonLookUpsDropDown');
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "Flag": 15,
    };
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body));

    if (response.statusCode == 200) {
      setState(() {
        certificateList = json.decode(response.body)['certificatesList'];
      });
    } else {
      print('Failed to load certificates');
    }
  }

  // Fetch experience data
  Future<void> fetchExperienceData() async {
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
    final userName = prefs.getString('userName');
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeExperience');
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "EmpExpId": 0,
      "EmployeeId": employeeId,
      "StartDate": "",
      "EndDate": "",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "UserId": adminUserId,
      "Flag": "VIEW",
      "EmployeeNumber": userName,
      "DisplayandSaveEmployeeExperienceVariable": [
        {
          "EmpExpId": 0,
          "Organization": 0,
          "Industry": "",
          "Location": "",
          "DateFrom": "",
          "DateTo": "",
          "Designation": 0,
          "Medium": 0,
          "CertificateSubmitted": 0,
          "Certificate": 0,
          "ChooseFile": ""
        }
      ]
    };
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        experienceList =
        json.decode(response.body)['displayandSaveEmployeeExperienceList'];
      });
    } else {
      print('Failed to fetch experience data');
    }
  }

  Future<void> saveExperience(String flag, dynamic experienceData) async {
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
    final userName = prefs.getString('userName');
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeExperience');
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "EmpExpId": experienceData['empExpId'] ?? 0,
      "EmployeeId": employeeId,
      "StartDate": experienceData['dateFrom'],
      "EndDate": experienceData['dateTo'],
      "UserId": adminUserId,
      "Flag": flag,
      "EmployeeNumber": userName,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "DisplayandSaveEmployeeExperienceVariable": [
        {
          'Organization': experienceData['organization'],
          'Industry': experienceData['industry'],
          'Location': experienceData['location'],
          'DateFrom': experienceData['dateFrom'],
          'DateTo': experienceData['dateTo'],
          'Designation': experienceData['designation'],
          'Medium': experienceData['medium'],
          'CertificateSubmitted': 0,
          'Certificate': experienceData['certificate'],
          'ChooseFile': ''
        }
      ]
    };
    print('Request Body: $body');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['message'] == 'Record is Successfully Saved') {
        setState(() {
          isEditing = false;
          empExpId = null;
          selectedOrganizationId = null;
          selectedDesignationId = null;
          selectedMediumId = null;
          selectedCertificateId = null;
        });
        fetchExperienceData();

        // Show Toast with the message
        Fluttertoast.showToast(
          msg: responseBody['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        // Show Toast with the message
        Fluttertoast.showToast(
          msg: responseBody['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      // Show Toast with the message
      Fluttertoast.showToast(
        msg: 'Failed to save data. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _handleSaveExperience() {
    if (_formKey.currentState!.validate()) {
      final experienceData = {
        'empExpId': empExpId ?? 0,
        'organization': selectedOrganizationId ?? 0,
        'industry': industryController.text,
        'location': locationController.text,
        'dateFrom': dateFromController.text,
        'dateTo': dateToController.text,
        'designation': selectedDesignationId ?? 0,
        'medium': selectedMediumId ?? 0,
        'certificate': selectedCertificateId ?? 0,
      };
      String flag = isEditing ? 'UPDATE' : 'CREATE';
      saveExperience(flag, experienceData);

      // Clear the form and reset state
      industryController.clear();
      locationController.clear();
      dateFromController.clear();
      dateToController.clear();

      setState(() {
        selectedOrganizationId = null;
        selectedDesignationId = null;
        selectedMediumId = null;
        selectedCertificateId = null;
        empExpId = null;
        isEditing = false;
      });
    }
  }

  @override
  void dispose() {
    industryController.dispose();
    locationController.dispose();
    dateFromController.dispose();
    dateToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Experience',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Form for adding experience
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildDropdownField(
                        'Organization',
                        organizationList,
                        selectedOrganizationId,
                            (newValue) {
                          setState(() {
                            selectedOrganizationId = newValue;
                          });
                        },
                      ),
                      _buildDropdownField(
                        'Designation',
                        designationList,
                        selectedDesignationId,
                            (newValue) {
                          setState(() {
                            selectedDesignationId = newValue;
                          });
                        },
                      ),
                      _buildDropdownField(
                        'Medium',
                        mediumList,
                        selectedMediumId,
                            (newValue) {
                          setState(() {
                            selectedMediumId = newValue;
                          });
                        },
                      ),
                      _buildDropdownField(
                        'Certificate',
                        certificateList,
                        selectedCertificateId,
                            (newValue) {
                          setState(() {
                            selectedCertificateId = newValue;
                          });
                        },
                      ),
                      _buildTextField(industryController, 'Industry'),
                      _buildTextField(locationController, 'Location'),
                      _buildTextField(dateFromController, 'From Date'),
                      _buildTextField(dateToController, 'To Date'),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _handleSaveExperience,
                        child: Text(
                          isEditing ? 'Update Experience' : 'Save Experience',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              experienceList.isEmpty
                  ? Center(
                child: CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.blue),
                  strokeWidth: 3,
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: experienceList.length,
                itemBuilder: (context, index) {
                  final experience = experienceList[index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.blue[100]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          spreadRadius: 4,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Organization Name
                          Text(
                            'Organization: ${experience['organizationName'] ?? ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Details
                          _buildDetailRow(
                              'Industry:', experience['industry'] ?? ''),
                          _buildDetailRow(
                              'Location:', experience['location'] ?? ''),
                          _buildDetailRow(
                              'From:', experience['dateFrom'] ?? ''),
                          _buildDetailRow(
                              'To:', experience['dateTo'] ?? ''),
                          _buildDetailRow(
                              'Designation:',
                              experience['designationName'] ?? ''),
                          _buildDetailRow(
                              'Medium:', experience['mediumName'] ?? ''),
                          _buildDetailRow('Certificate:',
                              experience['certificateName'] ?? ''),
                          _buildDetailRow('Status:',
                              experience['status'] ?? ''),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blueAccent),
                                onPressed: () {
                                  // Check if the status is "pending" or "Pending"
                                  final String status = experience['status']?.toString() ?? '';

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
                                    setState(() {
                                      selectedOrganizationId = experience['organization'];
                                      selectedDesignationId = experience['designation'];
                                      selectedMediumId = experience['medium'];
                                      selectedCertificateId = experience['certificate'];
                                      industryController.text = experience['industry'] ?? '';
                                      locationController.text = experience['location'] ?? '';
                                      dateFromController.text = experience['dateFrom'] ?? '';
                                      dateToController.text = experience['dateTo'] ?? '';
                                      empExpId = experience['empExpId'];
                                      isEditing = true;
                                    });
                                  }
                                },
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      String label,
      List<dynamic> items,
      int? selectedValue,
      Function(int?) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: DropdownButtonFormField<int>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: items.map((item) {
          int itemId = item['lookUpId'] ??
              item['designationId'] ??
              item['certificateId'];
          String itemName = item['meaning'] ??
              item['designationName'] ??
              item['certificateName'] ??
              '';
          return DropdownMenuItem<int>(
            value: itemId,
            child: Text(itemName),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value == 0) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Text(
      '$label ${value ?? ''}',
      style: TextStyle(fontSize: 16, color: Colors.black54),
    );
  }
}
