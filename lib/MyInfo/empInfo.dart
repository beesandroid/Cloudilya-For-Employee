import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmployeeInfo extends StatefulWidget {
  const EmployeeInfo({super.key});

  @override
  State<EmployeeInfo> createState() => _EmployeeInfoState();
}

class _EmployeeInfoState extends State<EmployeeInfo> {
  Map<String, dynamic> _employeeData = {};
  bool _isEditing = false;
  List<dynamic> casteCategoryList = [];
  List<dynamic> casteList = [];
  List<dynamic> religionList = [];
  List<dynamic> nationalityList = [];
  List<dynamic> maritalStatusList = [];
  List<dynamic> prefixList = [];

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _fetchEmployeeDetails();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers['firstName'] = TextEditingController();
    _controllers['lastName'] = TextEditingController();
    _controllers['preferredName'] = TextEditingController();
    _controllers['dateOfBirth'] = TextEditingController();
    _controllers['maritalStatus'] = TextEditingController();
    _controllers['nationality'] = TextEditingController();
    _controllers['religion'] = TextEditingController();
    _controllers['prefixList'] = TextEditingController();
    _controllers['casteCategory'] = TextEditingController();
    _controllers['caste'] = TextEditingController();
    _controllers['driversLicenseNumber'] = TextEditingController();
    _controllers['driversLicenseExpiryDate'] = TextEditingController();
    _controllers['passportNumber'] = TextEditingController();
    _controllers['passportExpiryDate'] = TextEditingController();
    _controllers['rationCardNumber'] = TextEditingController();
    _controllers['aicteId'] = TextEditingController();
    _controllers['universityId'] = TextEditingController();
    _controllers['biometricId'] = TextEditingController();
    _controllers['voterId'] = TextEditingController();
    _controllers['officePhoneNumber'] = TextEditingController();
    _controllers['personalPhoneNumber'] = TextEditingController();
    _controllers['officeEmailAddress'] = TextEditingController();
    _controllers['personalEmailAddress'] = TextEditingController();
    _controllers['fatherName'] = TextEditingController();
    _controllers['countryOfBirth'] = TextEditingController();
    _controllers['bloodGroup'] = TextEditingController();
    _controllers['panCardNumber'] = TextEditingController();
    _controllers['providentFundNumber'] = TextEditingController();
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _fetchEmployeeDetails() async {
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreprod/CloudilyaMobileAPP/SaveEmployeePersonalDetails'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {
            "GrpCode": "bees",
            "ColCode": "0001",
            "CollegeId": 1,
            "UserId": 1,
            "EmployeeId": "2",
            "FirstName": "",
            "LastName": "",
            "id": 0,
            "StartDate": "",
            "EndDate": "",
            "EffectiveDate": "",
            "PrefixId": 0,
            "PreferredName": "",
            "DateOfBirth": "",
            "MaritalStatus": 0,
            "ChangeReason":"",
            "Nationality": 0,
            "Religion": 0,
            "CasteCategory": 0,
            "Caste": 0,
            "DriversLicenseNumber": "",
            "DriversLicenseExpiryDate": "",
            "PassportNumber": "",
            "PassportExpiryDate": "",
            "RationCardNumber": "",
            "AICTEId": "",
            "UniversityId": "",
            "BiometricId": "",
            "VoterId": "",
            "OfficePhoneNumber": "",
            "PersonalPhoneNumber": "",
            "OfficeEmailAddress": "",
            "PersonalEmailAddress": "",
            "LoginIpAddress": "",
            "LoginSystemName": "",
            "FatherName": "",
            "Flag": "VIEW",
            "CountryOfBirth":0,
            "BloodGroup": 0,
            "PANCardNumber": "",
            "ProvidentFundNumber": ""

          }

      ),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        print('Parsed Data: $data');

        setState(() {
          _employeeData = data['employeePersonalList'] != null && data['employeePersonalList'].isNotEmpty
              ? data['employeePersonalList'][0]
              : {};

          casteCategoryList = List<Map<String, dynamic>>.from(data['employeePersonalList'][0]['casteCategoryList'] ?? []);
          casteList = List<Map<String, dynamic>>.from(data['employeePersonalList'][0]['castList'] ?? []);
          religionList = List<Map<String, dynamic>>.from(data['employeePersonalList'][0]['religionList'] ?? []);
          nationalityList = List<Map<String, dynamic>>.from(data['employeePersonalList'][0]['nationalityStatusList'] ?? []);
          maritalStatusList = List<Map<String, dynamic>>.from(data['employeePersonalList'][0]['maritalStatusList'] ?? []);
          prefixList = List<Map<String, dynamic>>.from(data['employeePersonalList'][0]['prefixList'] ?? []);

          print('Caste Category List: $casteCategoryList');
          print('Caste List: $casteList');
          print('Religion List: $religionList');
          print('Nationality List: $nationalityList');
          print('Marital Status List: $maritalStatusList');
          print('Prefix List: $prefixList');
        });

      } catch (e) {
        print('Error parsing JSON: $e');
      }
    } else {
      print('Failed to load data');
    }

  }

  Future<void> _updateEmployeeDetails() async {
    final requestBody = {
      "GrpCode": "bees",
      "ColCode": "0001",
      "CollegeId": _employeeData['collegeId'] ?? 0,
      "UserId": 1,
      "EmployeeId": _employeeData['employeeId'] ?? '',
      "FirstName": _controllers['firstName']?.text ?? '',
      "id":"0",
      "startDate":"",
      "endDate":"",
      "effectiveDate":"",
      "changeReason":"",
      "prefixId":int.tryParse(_controllers['prefixList']?.text ?? '0') ?? 0,
      "LastName": _controllers['lastName']?.text ?? '',
      "PreferredName": _controllers['preferredName']?.text ?? '',
      "DateOfBirth": _controllers['dateOfBirth']?.text ?? '',
      "MaritalStatus": int.tryParse(_controllers['maritalStatus']?.text ?? '0') ?? 0,
      "Nationality": int.tryParse(_controllers['nationality']?.text ?? '0') ?? 0,
      "Religion": int.tryParse(_controllers['religion']?.text ?? '0') ?? 0,
      "CasteCategory": int.tryParse(_controllers['casteCategory']?.text ?? '0') ?? 0,
      "Caste": int.tryParse(_controllers['caste']?.text ?? '0') ?? 0,
      "DriversLicenseNumber": _controllers['driversLicenseNumber']?.text ?? '',
      "DriversLicenseExpiryDate": _controllers['driversLicenseExpiryDate']?.text ?? '',
      "PassportNumber": _controllers['passportNumber']?.text ?? '',
      "PassportExpiryDate": _controllers['passportExpiryDate']?.text ?? '',
      "RationCardNumber": _controllers['rationCardNumber']?.text ?? '',
      "AICTEId": _controllers['aicteId']?.text ?? '',
      "UniversityId": _controllers['universityId']?.text ?? '',
      "BiometricId": _controllers['biometricId']?.text ?? '',
      "VoterId": _controllers['voterId']?.text ?? '',
      "OfficePhoneNumber": _controllers['officePhoneNumber']?.text ?? '',
      "PersonalPhoneNumber": _controllers['personalPhoneNumber']?.text ?? '',
      "OfficeEmailAddress": _controllers['officeEmailAddress']?.text ?? '',
      "PersonalEmailAddress": _controllers['personalEmailAddress']?.text ?? '',
      "FatherName": _controllers['fatherName']?.text ?? '',
      "CountryOfBirth": int.tryParse(_controllers['countryOfBirth']?.text ?? '0') ?? 0,
      "BloodGroup": int.tryParse(_controllers['bloodGroup']?.text ?? '0') ?? 0,
      "PANCardNumber": _controllers['panCardNumber']?.text ?? '',
      "ProvidentFundNumber": _controllers['providentFundNumber']?.text ?? '',
      "Flag": "OVERWRITE",
      "loginIpAddress":"",
      "loginSystemName":"",
      // Added lookUpId here
    };

    print('Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreprod/CloudilyaMobileAPP/SaveEmployeePersonalDetails'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        return; // Exit early if there's a message
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee details updated successfully')),
      );

      // Optionally, you can reload the entire screen or navigate to it to refresh
      Navigator.pushReplacementNamed(context, '/employeeDetailsScreen');
      // or
      //  Navigator.of(context).popUntil((route) => route.isFirst);
      if (data['maritalStatusList'] != null) {
        maritalStatusList = List<Map<String, dynamic>>.from(data['maritalStatusList']);
      } else {
        maritalStatusList = [];
      }
      if (data['nationalityStatusList'] != null) {
        nationalityList = List<Map<String, dynamic>>.from(data['nationalityStatusList']);
      } else {
        nationalityList = [];
      }
      if (data['religionList'] != null) {
        religionList = List<Map<String, dynamic>>.from(data['religionList']);
      } else {
        religionList = [];
      }
      if (data['casteCategoryList'] != null) {
        casteCategoryList = List<Map<String, dynamic>>.from(data['casteCategoryList']);
      } else {
        casteCategoryList = [];
      }
      if (data['castList'] != null) {
        casteList = List<Map<String, dynamic>>.from(data['castList']);
      } else {
        casteList = [];
      }  if (data['prefixList'] != null) {
        prefixList = List<Map<String, dynamic>>.from(data['prefixList']);
      } else {
        prefixList = [];
      }
      try {
        final data = jsonDecode(response.body);
        setState(() {
          _employeeData = data['employeePersonalList'] != null && data['employeePersonalList'].isNotEmpty
              ? data['employeePersonalList'][0]
              : {};

          casteCategoryList = List<dynamic>.from(data['casteCategoryList'] ?? []);
          casteList = List<dynamic>.from(data['castList'] ?? []);
          religionList = List<dynamic>.from(data['religionList'] ?? []);
          nationalityList = List<dynamic>.from(data['nationalityStatusList'] ?? []);
          maritalStatusList = List<dynamic>.from(data['maritalStatusList'] ?? []);
          prefixList = List<dynamic>.from(data['prefixList'] ?? []);

          print('Caste Category List: $casteCategoryList');
          print('Caste List: $casteList');
          print('Religion List: $religionList');
          print('Nationality List: $nationalityList');
          print('Marital Status List: $maritalStatusList');
          print('Prefix List: $prefixList');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee details updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse response')),
        );
        print('Error parsing JSON: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update employee details')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Personal Information'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateEmployeeDetails();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: _employeeData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDropdownField('prefixList', 'prefixId', prefixList, 'lookUpId', 'meaning'),


              _buildTextField('First Name', 'firstName'),
              _buildTextField('Last Name', 'lastName'),
              _buildTextField('Preferred Name', 'preferredName'),
              _buildTextField('Date of Birth', 'dateOfBirth'),
              _buildDropdownField('Marital Status', 'maritalStatus', maritalStatusList, 'lookUpId', 'meaning'),
              _buildDropdownField('Nationality', 'nationality', nationalityList, 'lookUpId', 'meaning'),
              _buildDropdownField('Religion', 'religion', religionList, 'lookUpId', 'meaning'),
              _buildDropdownField('Caste Category', 'casteCategory', casteCategoryList, 'lookUpId', 'meaning'),
              _buildDropdownField('Caste', 'caste', casteList, 'lookUpId', 'meaning'),
              _buildTextField('Driver\'s License Number', 'driversLicenseNumber'),
              _buildTextField('Driver\'s License Expiry Date', 'driversLicenseExpiryDate'),
              _buildTextField('Passport Number', 'passportNumber'),
              _buildTextField('Passport Expiry Date', 'passportExpiryDate'),
              _buildTextField('Ration Card Number', 'rationCardNumber'),
              _buildTextField('AICTE ID', 'aicteId'),
              _buildTextField('University ID', 'universityId'),
              _buildTextField('Biometric ID', 'biometricId'),
              _buildTextField('Voter ID', 'voterId'),
              _buildTextField('Office Phone Number', 'officePhoneNumber'),
              _buildTextField('Personal Phone Number', 'personalPhoneNumber'),
              _buildTextField('Office Email Address', 'officeEmailAddress'),
              _buildTextField('Personal Email Address', 'personalEmailAddress'),
              _buildTextField('Father\'s Name', 'fatherName'),
              _buildTextField('Country of Birth', 'countryOfBirth'),
              _buildTextField('Blood Group', 'bloodGroup'),
              _buildTextField('PAN Card Number', 'panCardNumber'),
              _buildTextField('Provident Fund Number', 'providentFundNumber'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        enabled: _isEditing,
        controller: _controllers[key]?..text = _employeeData[key]?.toString() ?? '',
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _employeeData[key] = value;
          });
        },
      ),
    );
  }

  Widget _buildDropdownField(
      String label,
      String key,
      List<dynamic> options,
      String optionKey,
      String optionValue,
      ) {
    String? selectedValue = _employeeData[key]?.toString();

    // Ensure that options list contains unique values for the dropdown
    final uniqueOptions = options.toSet().toList();

    // Check if the selected value is in the uniqueOptions list
    if (selectedValue != null &&
        !uniqueOptions.any((item) => item[optionKey].toString() == selectedValue)) {
      selectedValue = null; // reset selected value if it's not in options
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        items: uniqueOptions.map<DropdownMenuItem<String>>((dynamic item) {
          return DropdownMenuItem<String>(
            value: item[optionKey].toString(),
            child: Text(item[optionValue].toString()),
          );
        }).toList(),
        onChanged: _isEditing
            ? (value) {
          setState(() {
            _employeeData[key] = value;
            _controllers[key]?.text = value ?? '';
          });
        }
            : null,
      ),
    );
  }



}
