import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TemporaryAddressScreen extends StatefulWidget {
  const TemporaryAddressScreen({super.key});

  @override
  State<TemporaryAddressScreen> createState() => _TemporaryAddressScreenState();
}

class _TemporaryAddressScreenState extends State<TemporaryAddressScreen> {
  bool _isEditing = false;
  bool _isCreateFlag = false; // New flag to determine CREATE or OVERWRITE
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
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeAddressTemporary'),
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
      if (data["displayandSaveEmployeeAddressTemporaryList"].isNotEmpty) {
        setState(() {
          _addressData =
          data["displayandSaveEmployeeAddressTemporaryList"][0];
          _isCreateFlag = false; // Existing address, use OVERWRITE
        });
      } else {
        setState(() {
          _isCreateFlag = true; // No existing address, use CREATE
          // Optionally reset _addressData or keep as is for new entry
          _addressData = {
            "city": "",
            "district": "",
            "state": "",
            "country": "",
            "addressLine1": "",
            "addressLine2": "",
            "mandal": "",
            "pinCode": ""
          };
        });
      }
    } else {
      // Handle error
      print('Failed to load address data');
      setState(() {
        _isCreateFlag = true; // Assume CREATE on failure to fetch
      });
    }
  }

  Future<void> _saveTemporaryAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final adminUserId = prefs.getString('adminUserId');
    final employeeId = prefs.getInt('employeeId');
    final collegeId = prefs.getString('collegeId');
    final colCode = prefs.getString('colCode');
    String formattedDate = DateTime.now().toIso8601String().split('T')[0];
    final requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": colCode ?? "0001", // Use fetched value or default
      "CollegeId": collegeId ?? "1", // Use fetched value or default
      "AddressId": _isCreateFlag ? 0 : (_addressData["addressId"] ?? 0),
      "EmployeeId": employeeId ?? 0,
      "StartDate": _addressData["startDate"] ?? "",
      "EndDate": _addressData["endDate"] ?? "",
      "EffectiveDate": formattedDate,
      // Today's date in ISO format
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
      "UserId": adminUserId ?? "",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": _isCreateFlag ? "CREATE" : "OVERWRITE"
    };

    // Print the request body for debugging
    print('Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeAddressTemporary'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    // Print the response for debugging
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      String message = 'Failed to save address!';
      if (responseBody.containsKey('message') && responseBody['message'].isNotEmpty) {
        message = responseBody['message'];
      } else {
        message = _isCreateFlag
            ? 'Address created successfully!'
            : 'Address updated successfully!';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      // Optionally handle successful save, e.g., show a message
      print('Address saved successfully');
      setState(() {
        _isEditing = false; // Exit editing mode
        _isCreateFlag = false; // After creation, switch to overwrite mode
      });
      _fetchTemporaryAddress(); // Refresh data after saving
    } else {
      // Handle error
      print('Failed to save address');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save address. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end,
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
            _buildTextField(
              label: 'City',
              initialValue: _addressData["city"],
              enabled: _isEditing,
              onChanged: (value) {
                _addressData["city"] = value;
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              label: 'District',
              initialValue: _addressData["district"],
              enabled: _isEditing,
              onChanged: (value) {
                _addressData["district"] = value;
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              label: 'State',
              initialValue: _addressData["state"],
              enabled: _isEditing,
              onChanged: (value) {
                _addressData["state"] = value;
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              label: 'Country',
              initialValue: _addressData["country"],
              enabled: _isEditing,
              onChanged: (value) {
                _addressData["country"] = value;
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              label: 'Address Line 1',
              initialValue: _addressData["addressLine1"],
              enabled: _isEditing,
              onChanged: (value) {
                _addressData["addressLine1"] = value;
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              label: 'Address Line 2',
              initialValue: _addressData["addressLine2"],
              enabled: _isEditing,
              onChanged: (value) {
                _addressData["addressLine2"] = value;
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              label: 'Mandal',
              initialValue: _addressData["mandal"],
              enabled: _isEditing,
              onChanged: (value) {
                _addressData["mandal"] = value;
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              label: 'Pin Code',
              initialValue: _addressData["pinCode"],
              enabled: _isEditing,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _addressData["pinCode"] = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build TextFields to avoid repetition
  Widget _buildTextField({
    required String label,
    required String? initialValue,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      decoration: InputDecoration(labelText: label),
      enabled: enabled,
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}
