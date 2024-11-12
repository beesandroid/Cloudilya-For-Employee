import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PermanentAddressScreen extends StatefulWidget {
  const PermanentAddressScreen({super.key});

  @override
  State<PermanentAddressScreen> createState() => _PermanentAddressScreenState();
}

class _PermanentAddressScreenState extends State<PermanentAddressScreen> {
  bool _isEditing = false;
  bool _isCreateMode = false; // This flag will be set for CREATE mode
  Map<String, dynamic> _addressData = {
    "city": "",
    "district": "",
    "state": "",
    "country": "",
    "addressLine1": "",
    "addressLine2": "",
    "mandal": "",
    "pinCode": ""
  };

  @override
  void initState() {
    super.initState();
    _fetchTemporaryAddress();
  }

  Future<void> _fetchTemporaryAddress() async {
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
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeAddressesPermanentDetails'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "GrpCode": "Beesdev",
        "ColCode": colCode,
        "CollegeId": collegeId,
        "AddressId": 0,
        "EmployeeId": employeeId,
        "StartDate": "",
        "EndDate": "",
        "EffectiveDate": "",
        "ChangeReason": "",
        "HomeNumber": "",
        "AddressLine1": "",
        "AddressLine2": "",
        "AddressLine3": "",
        "Mandal": "",
        "PinCode": "",
        "City": "",
        "District": "",
        "State": "",
        "Country": "",
        "UserId": adminUserId,
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "VIEW"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);

      // Check if the list is empty, and switch to CREATE mode
      if (data["employeeAddressesPermanentDetailsList"].isEmpty) {
        setState(() {
          _isCreateMode = true; // Set create mode if the list is empty
        });
      } else {
        setState(() {
          _addressData = data["employeeAddressesPermanentDetailsList"][0];
          _isCreateMode = false; // Default to OVERWRITE if data exists
        });
      }
    } else {
      // Handle error
      print('Failed to load address data');
    }
  }

  Future<void> _saveTemporaryAddress() async {
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
    // If the response is empty, set the flag to "CREATE", otherwise "OVERWRITE"
    final String flag = _isCreateMode ? "CREATE" : "OVERWRITE";

    final requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "AddressId": _addressData["addressId"]??0,
      "EmployeeId": employeeId,
      "StartDate": "",
      "EndDate": "",
      "EffectiveDate": DateTime.now().toIso8601String().split('T').first,
      "ChangeReason": _addressData["changeReason"] ?? "",
      "HomeNumber": _addressData["homeNumber"] ?? "",
      "AddressLine1": _addressData["addressLine1"] ?? "",
      "AddressLine2": _addressData["addressLine2"] ?? "",
      "AddressLine3": _addressData["addressLine3"] ?? "",
      "Mandal": _addressData["mandal"] ?? "",
      "PinCode": _addressData["pinCode"] ?? "",
      "City": _addressData["city"] ?? "",
      "District": _addressData["district"] ?? "",
      "State": _addressData["state"] ?? "",
      "Country": _addressData["country"] ?? "",
      "UserId": adminUserId,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": flag
    };

    // Print the request body for debugging
    print('Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeAddressesPermanentDetails'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      String message = 'Failed to save address!';
      if (responseBody.containsKey('message')) {
        message = responseBody['message'];
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      print('Address saved successfully');
      setState(() {
        _isEditing = false; // Exit editing mode
        _isCreateMode = false; // After saving, set to overwrite mode
      });
      _fetchTemporaryAddress(); // Refresh data after saving
    } else {
      // Handle error
      print('Failed to save address');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  onPressed: () {
                    final String status = _addressData['status']?.toString() ?? '';

                    // Check if the status is "pending" or "Pending"
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
                      if (_isEditing) {
                        _saveTemporaryAddress();
                      }
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    }
                  },
                ),

              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: _addressData["city"]),
              decoration: const InputDecoration(labelText: 'City'),
              enabled: _isEditing,
              onChanged: (value) {
                _addressData["city"] = value;
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: _addressData["district"]),
              decoration: const InputDecoration(labelText: 'District'),
              enabled: _isEditing,
              onChanged: (value) {
                _addressData["district"] = value;
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: _addressData["state"]),
              decoration: const InputDecoration(labelText: 'State'),
              enabled: _isEditing,
              onChanged: (value) {
                _addressData["state"] = value;
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: _addressData["country"]),
              decoration: const InputDecoration(labelText: 'Country'),
              enabled: _isEditing,
              onChanged: (value) {
                _addressData["country"] = value;
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller:
                  TextEditingController(text: _addressData["addressLine1"]),
              decoration: const InputDecoration(labelText: 'Address Line 1'),
              enabled: _isEditing,
              onChanged: (value) {
                _addressData["addressLine1"] = value;
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller:
                  TextEditingController(text: _addressData["addressLine2"]),
              decoration: const InputDecoration(labelText: 'Address Line 2'),
              enabled: _isEditing,
              onChanged: (value) {
                _addressData["addressLine2"] = value;
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: _addressData["mandal"]),
              decoration: const InputDecoration(labelText: 'Mandal'),
              enabled: _isEditing,
              onChanged: (value) {
                _addressData["mandal"] = value;
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: _addressData["pinCode"]),
              decoration: const InputDecoration(labelText: 'Pin Code'),
              enabled: _isEditing,
              onChanged: (value) {
                _addressData["pinCode"] = value;
              },
            ),
          ],
        ),
      ),
    );
  }
}
