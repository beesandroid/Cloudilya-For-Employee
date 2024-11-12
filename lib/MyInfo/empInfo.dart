import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  TextEditingController descriptionController = TextEditingController();

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
    _controllers['employeeNumber'] = TextEditingController();
    _controllers['genderName'] = TextEditingController();
    _controllers['aadhaarNumber'] = TextEditingController();
    _controllers['countryOfBirth'] = TextEditingController();
    _controllers['motherTongueName'] = TextEditingController();
    _controllers['bloodGroup'] = TextEditingController();
    _controllers['panCardNumber'] = TextEditingController();
    _controllers['providentFundNumber'] = TextEditingController();
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmployeeDetails() async {
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

    final requestBody = {
      "GrpCode": "beesDEV",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "UserId": adminUserId,
      "EmployeeId": employeeId,
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
      "ChangeReason": "",
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
      "CountryOfBirth": 0,
      "BloodGroup": 0,
      "PANCardNumber": "",
      "ProvidentFundNumber": ""
    };
    print(requestBody);

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreprod/CloudilyaMobileAPP/SaveEmployeePersonalDetails'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        print(data);
        final id = data['employeePersonalList'][0]['id'];

        setState(() {
          _employeeData = data['employeePersonalList'] != null &&
                  data['employeePersonalList'].isNotEmpty
              ? data['employeePersonalList'][0]
              : {};

          casteCategoryList = List<Map<String, dynamic>>.from(
              data['employeePersonalList'][0]['casteCategoryList'] ?? []);
          casteList = List<Map<String, dynamic>>.from(
              data['employeePersonalList'][0]['castList'] ?? []);
          religionList = List<Map<String, dynamic>>.from(
              data['employeePersonalList'][0]['religionList'] ?? []);
          nationalityList = List<Map<String, dynamic>>.from(
              data['employeePersonalList'][0]['nationalityStatusList'] ?? []);
          maritalStatusList = List<Map<String, dynamic>>.from(
              data['employeePersonalList'][0]['maritalStatusList'] ?? []);
          prefixList = List<Map<String, dynamic>>.from(
              data['employeePersonalList'][0]['prefixList'] ?? []);
        });
      } catch (e) {
        print('Error parsing JSON: $e');
      }
    } else {
      print('Failed to load data: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> _updateEmployeeDetails(id) async {
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
    String paymentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final requestBody = {
      "GrpCode": "beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "UserId": adminUserId,
      "EmployeeId": employeeId,
      "FirstName":
          _controllers['firstName']?.text ?? _employeeData['firstName'],
      "Id": id,
      "StartDate": "",
      "EndDate": "",
      "EffectiveDate": paymentDate,
      "PreferredName": _controllers['preferredName']?.text ?? '',
      "DateOfBirth": _controllers['dateOfBirth']?.text ?? '',
      "LastName": _controllers['lastName']?.text ?? '',
      "ChangeReason": descriptionController.text,
      "MaritalStatus":
          int.tryParse(_employeeData['maritalStatus']?.toString() ?? '0') ?? 0,
      "Nationality":
          int.tryParse(_employeeData['nationality']?.toString() ?? '0') ?? 0,
      "Religion":
          int.tryParse(_employeeData['religion']?.toString() ?? '0') ?? 0,
      "CasteCategory":
          int.tryParse(_employeeData['casteCategory']?.toString() ?? '0') ?? 0,
      "Caste": int.tryParse(_employeeData['caste']?.toString() ?? '0') ?? 0,
      "PrefixId":
            int.tryParse(_employeeData['prefixList']?.toString() ?? '0') ?? 0,
      "DriversLicenseNumber": _controllers['driversLicenseNumber']?.text ??
          _employeeData['driversLicenseNumber'],
      "DriversLicenseExpiryDate":
          _controllers['driversLicenseExpiryDate']?.text ??
              _employeeData['driversLicenseExpiryDate'],
      "PassportNumber": _controllers['passportNumber']?.text ??
          _employeeData['passportNumber'],
      "PassportExpiryDate": _controllers['passportExpiryDate']?.text ??
          _employeeData['passportExpiryDate'],
      "RationCardNumber": _controllers['rationCardNumber']?.text ??
          _employeeData['rationCardNumber'],
      "AICTEId": _controllers['aicteId']?.text ?? _employeeData['AICTEId'],
      "UniversityId":
          _controllers['universityId']?.text ?? _employeeData['UniversityId'],
      "BiometricId":
          _controllers['biometricId']?.text ?? _employeeData['BiometricId'],
      "VoterId": _controllers['voterId']?.text ?? _employeeData['VoterId'],
      "OfficePhoneNumber": _controllers['officePhoneNumber']?.text ??
          _employeeData['OfficePhoneNumber'],
      "PersonalPhoneNumber": _controllers['personalPhoneNumber']?.text ??
          _employeeData['PersonalPhoneNumber'],
      "OfficeEmailAddress": _controllers['officeEmailAddress']?.text ??
          _employeeData['OfficeEmailAddress'],
      "PersonalEmailAddress": _controllers['personalEmailAddress']?.text ??
          _employeeData['PersonalEmailAddress'],
      "FatherName":
          _controllers['fatherName']?.text ?? _employeeData['FatherName'],
      "GenderName":
          _controllers['genderName']?.text ?? _employeeData['genderName'],
      "AadhaarNumber":
          _controllers['aadhaarNumber']?.text ?? _employeeData['aadhaarNumber'],
      "EmployeeNumber": _controllers['employeeNumber']?.text ??
          _employeeData['employeeNumber'],
      "CountryOfBirth":
          int.tryParse(_employeeData['CountryOfBirth']?.toString() ?? '0') ?? 0,
      "BloodGroup":
          int.tryParse(_employeeData['BloodGroup']?.toString() ?? '0') ?? 0,
      "PANCardNumber":
          _controllers['panCardNumber']?.text ?? _employeeData['PANCardNumber'],
      "ProvidentFundNumber": _controllers['providentFundNumber']?.text ??
          _employeeData['ProvidentFundNumber'],
      "Flag": "OVERWRITE",
      "LoginIpAddress": "",
      "LoginSystemName": "",
    };

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveEmployeePersonalDetails'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('message')) {
        Fluttertoast.showToast(
          msg: data['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      setState(() {
        _isEditing = false;
      });

      Fluttertoast.showToast(
        msg: 'Employee details updated successfully',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      _fetchEmployeeDetails(); // Refresh the data
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to update employee details',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Widget _buildTextField(String label, String key, {bool editable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        enabled: editable && _isEditing,
        controller: _controllers[key]
          ?..text = _employeeData[key]?.toString() ?? '',
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
          filled: true,
          fillColor: editable && _isEditing ? Colors.white : Colors.grey[200],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          if (editable) {
            setState(() {
              _employeeData[key] = value;
            });
          }
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
    int? selectedValue = _employeeData[key];

    final uniqueOptions = options.toSet().toList();

    if (selectedValue != null &&
        !uniqueOptions.any((item) => item[optionKey] == selectedValue)) {
      selectedValue = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
          filled: true,
          fillColor: _isEditing ? Colors.white : Colors.grey[200],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: uniqueOptions.map<DropdownMenuItem<int>>((dynamic item) {
          return DropdownMenuItem<int>(
            value: item[optionKey],
            child: Text(item[optionValue].toString()),
          );
        }).toList(),
        onChanged: _isEditing
            ? (value) {
                setState(() {
                  _employeeData[key] = value ?? 0;
                  _controllers[key]?.text = (value ?? 0).toString();
                });
              }
            : null,
      ),
    );
  }

  Widget _buildDatePickerField(String label, String key,
      {bool editable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: editable && _isEditing
            ? () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _employeeData[key] != null &&
                          _employeeData[key].toString().isNotEmpty
                      ? DateTime.parse(_employeeData[key])
                      : DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Colors.blue.shade800,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black,
                        ),
                        dialogBackgroundColor: Colors.white,
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                  setState(() {
                    _employeeData[key] = formattedDate;
                    _controllers[key]?.text = formattedDate;
                  });
                }
              }
            : null,
        child: AbsorbPointer(
          child: TextField(
            controller: _controllers[key]
              ?..text = _employeeData[key]?.toString() ?? '',
            decoration: InputDecoration(
              labelText: label,
              labelStyle:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
              filled: true,
              fillColor:
                  editable && _isEditing ? Colors.white : Colors.grey[200],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReasonField() {
    return Visibility(
      visible: _isEditing,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          controller: descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Reason',
            labelStyle:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Employee Personal Information',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              String status = _employeeData['status']?.toString().toLowerCase() ?? '';

              // Check if the status is "pending" or "Pending"
              if (status == 'pending') {
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
                if (_isEditing) {
                  if (descriptionController.text.isNotEmpty) {
                    if (_employeeData.isNotEmpty && _employeeData['id'] != null) {
                      _updateEmployeeDetails(_employeeData['id']);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No employee ID found')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a reason')),
                    );
                  }
                } else {
                  setState(() {
                    _isEditing = true;

                    // Initialize the controllers with current data
                    _controllers.forEach((key, controller) {
                      controller.text = _employeeData[key]?.toString() ?? '';
                    });

                    // Set dropdowns to their current values
                    _employeeData['maritalStatus'] ??= maritalStatusList.isNotEmpty
                        ? maritalStatusList[0]['lookUpId']
                        : null;
                    _employeeData['nationality'] ??= nationalityList.isNotEmpty
                        ? nationalityList[0]['lookUpId']
                        : null;
                    _employeeData['religion'] ??= religionList.isNotEmpty
                        ? religionList[0]['lookUpId']
                        : null;
                    _employeeData['casteCategory'] ??= casteCategoryList.isNotEmpty
                        ? casteCategoryList[0]['lookUpId']
                        : null;
                    _employeeData['caste'] ??= casteList.isNotEmpty
                        ? casteList[0]['lookUpId']
                        : null;
                    _employeeData['prefixList'] ??= prefixList.isNotEmpty
                        ? prefixList[0]['lookUpId']
                        : null;
                  });
                }
              }
            },
          ),

        ],
      ),
      body: _employeeData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white, // White background for the form
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Basic Information'),
                    _buildTextField('Employee Number', 'employeeNumber',
                        editable: false),
                    _buildTextField('First Name', 'firstName', editable: false),
                    _buildTextField('Last Name', 'lastName', editable: false),
                    _buildDatePickerField('Hire Date', 'StartDate',
                        editable: false),
                    _buildTextField('Preferred Name', 'preferredName',
                        editable: true),
                    _buildDatePickerField('Date of Birth', 'dateOfBirth',
                        editable: true),
                    _buildSectionHeader('Personal Details'),
                    _buildDropdownField('Marital Status', 'maritalStatus',
                        maritalStatusList, 'lookUpId', 'meaning'),
                    _buildDropdownField('Nationality', 'nationality',
                        nationalityList, 'lookUpId', 'meaning'),
                    _buildDropdownField('Religion', 'religion', religionList,
                        'lookUpId', 'meaning'),
                    _buildDropdownField('Caste Category', 'casteCategory',
                        casteCategoryList, 'lookUpId', 'meaning'),
                    _buildDropdownField(
                        'Caste', 'caste', casteList, 'lookUpId', 'meaning'),
                    _buildTextField('Country of Birth', 'countryOfBirth',
                        editable: true),
                    _buildSectionHeader('Identification'),
                    _buildTextField(
                        'Driver\'s License Number', 'driversLicenseNumber',
                        editable: true),
                    _buildDatePickerField('Driver\'s License Expiry Date',
                        'driversLicenseExpiryDate',
                        editable: true),
                    _buildTextField('Passport Number', 'passportNumber',
                        editable: true),
                    _buildDatePickerField(
                        'Passport Expiry Date', 'passportExpiryDate',
                        editable: true),
                    _buildTextField('Ration Card Number', 'rationCardNumber',
                        editable: true),
                    _buildTextField('Voter ID', 'voterId', editable: true),
                    _buildTextField('PAN Card Number', 'panCardNumber',
                        editable: true),
                    _buildTextField('Aadhaar Number', 'aadhaarNumber',
                        editable: true),
                    _buildSectionHeader('Contact Information'),
                    _buildTextField('Office Phone Number', 'officePhoneNumber',
                        editable: true),
                    _buildTextField(
                        'Personal Phone Number', 'personalPhoneNumber',
                        editable: true),
                    _buildTextField(
                        'Office Email Address', 'officeEmailAddress',
                        editable: true),
                    _buildTextField(
                        'Personal Email Address', 'personalEmailAddress',
                        editable: true),
                    _buildSectionHeader('Other Details'),
                    _buildTextField('AICTE ID', 'aicteId', editable: true),
                    _buildTextField('University ID', 'universityId',
                        editable: true),
                    _buildTextField('Biometric ID', 'biometricId',
                        editable: true),
                    _buildTextField(
                        'Provident Fund Number', 'providentFundNumber',
                        editable: true),
                    _buildTextField('Father\'s Name', 'fatherName',
                        editable: true),
                    _buildTextField('Gender', 'genderName', editable: false),
                    _buildReasonField(),
                  ],
                ),
              ),
            ),
    );
  }
}
