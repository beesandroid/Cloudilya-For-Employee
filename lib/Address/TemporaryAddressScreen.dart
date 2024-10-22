import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TemporaryAddressScreen extends StatefulWidget {
  const TemporaryAddressScreen({super.key});

  @override
  State<TemporaryAddressScreen> createState() => _TemporaryAddressScreenState();
}

class _TemporaryAddressScreenState extends State<TemporaryAddressScreen> {
  bool _isEditing = false;
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
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeAddressTemporary'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "GrpCode": "Beesdev",
        "ColCode": "0001",
        "CollegeId": "1",
        "AddressId": 0,
        "EmployeeId": "3",
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
        "UserId": 1,
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "VIEW"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["displayandSaveEmployeeAddressTemporaryList"].isNotEmpty) {
        setState(() {
          _addressData = data["displayandSaveEmployeeAddressTemporaryList"][0];
        });
      }
    } else {
      // Handle error
      print('Failed to load address data');
    }
  }

  Future<void> _saveTemporaryAddress() async {
    final requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "AddressId": _addressData["addressId"],
      "EmployeeId": _addressData["employeeId"],
      "StartDate": _addressData["startDate"],
      "EndDate": _addressData["endDate"],
      "EffectiveDate": DateTime.now().toIso8601String(),
      // Today's date in ISO format
      "ChangeReason": _addressData["changeReason"],
      "HomeNumber": _addressData["homeNumber"],
      "AddressLine1": _addressData["addressLine1"],
      "AddressLine2": _addressData["addressLine2"],
      "AddressLine3": _addressData["addressLine3"],
      "Mandal": _addressData["mandal"],
      "PinCode": _addressData["pinCode"],
      "City": _addressData["city"],
      "District": _addressData["district"],
      "State": _addressData["state"],
      "Country": _addressData["country"],
      "UserId": 1,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "OVERWRITE"
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
      String message = 'Failed to save conference!';
      if (responseBody.containsKey('message')) {
        message = responseBody['message'];
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      // Optionally handle successful save, e.g., show a message
      print('Address saved successfully');
      setState(() {
        _isEditing = false; // Exit editing mode
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
            Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  onPressed: () {
                    if (_isEditing) {
                      _saveTemporaryAddress();
                    }
                    setState(() {
                      _isEditing = !_isEditing;
                    });
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
