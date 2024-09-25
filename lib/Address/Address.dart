import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Address extends StatefulWidget {
  const Address({super.key});

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {
  bool isEditable = false;

  // Temporary address controllers
  TextEditingController tempCityController = TextEditingController();
  TextEditingController tempDistrictController = TextEditingController();
  TextEditingController tempStateController = TextEditingController();
  TextEditingController tempAddressLine1Controller = TextEditingController();
  TextEditingController tempAddressLine2Controller = TextEditingController();
  TextEditingController tempAddressLine3Controller = TextEditingController();
  TextEditingController tempPinCodeController = TextEditingController();
  TextEditingController tempHomeNumberController = TextEditingController();
  int tempAddressId = 0;

  // Permanent address controllers
  TextEditingController permCityController = TextEditingController();
  TextEditingController permDistrictController = TextEditingController();
  TextEditingController permStateController = TextEditingController();
  TextEditingController permAddressLine1Controller = TextEditingController();
  TextEditingController permAddressLine2Controller = TextEditingController();
  TextEditingController permAddressLine3Controller = TextEditingController();
  TextEditingController permPinCodeController = TextEditingController();
  TextEditingController permHomeNumberController = TextEditingController();
  int permAddressId = 0;

  @override
  void initState() {
    super.initState();
    fetchTemporaryAddress();
    fetchPermanentAddress();
  }

  // Fetch temporary address
  Future<void> fetchTemporaryAddress() async {
    const url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeAddressTemporary';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "GrpCode":"Beesdev",
          "ColCode":"0001",
          "CollegeId":"1",
          "AddressId":0,
          "EmployeeId":"3",
          "StartDate":"",
          "EndDate":"",
          "EffectiveDate":"",
          "ChangeReason":"",
          "HomeNumber":"",
          "AddressLine1":"",
          "AddressLine2":"",
          "AddressLine3":"",
          "Mandal":"",
          "PinCode":"",
          "City":"",
          "District":"",
          "State":"",
          "Country":"",
          "UserId":1,
          "LoginIpAddress":"",
          "LoginSystemName":"",
          "Flag":"VIEW"
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['displayandSaveEmployeeAddressTemporaryList'][0];
        setState(() {
          tempCityController.text = data['city'] ?? '';
          tempDistrictController.text = data['district'] ?? '';
          tempStateController.text = data['state'] ?? '';
          tempAddressLine1Controller.text = data['addressLine1'] ?? '';
          tempAddressLine2Controller.text = data['addressLine2'] ?? '';
          tempAddressLine3Controller.text = data['addressLine3'] ?? '';
          tempPinCodeController.text = data['pinCode'] ?? '';
          tempHomeNumberController.text = data['homeNumber'] ?? '';
          tempAddressId=data['addressId']??0;
        });
      } else {
        showErrorDialog('Failed to fetch temporary address: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog('An error occurred while fetching temporary address: $error');
    }
  }

  // Fetch permanent address
  Future<void> fetchPermanentAddress() async {
    const url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeAddressesPermanentDetails';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "GrpCode":"Beesdev",
          "ColCode":"0001",
          "CollegeId":"1",
          "AddressId":0,
          "EmployeeId":"3",
          "StartDate":"",
          "EndDate":"",
          "EffectiveDate":"",
          "ChangeReason":"",
          "HomeNumber":"",
          "AddressLine1":"",
          "AddressLine2":"",
          "AddressLine3":"",
          "Mandal":"",
          "PinCode":"",
          "City":"",
          "District":"",
          "State":"",
          "Country":"",
          "UserId":1,

          "LoginIpAddress":"",
          "LoginSystemName":"",
          "Flag":"VIEW"
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          permCityController.text = data['city'] ?? '';
          permDistrictController.text = data['district'] ?? '';
          permStateController.text = data['state'] ?? '';
          permAddressLine1Controller.text = data['addressLine1'] ?? '';
          permAddressLine2Controller.text = data['addressLine2'] ?? '';
          permAddressLine3Controller.text = data['addressLine3'] ?? '';
          permPinCodeController.text = data['pinCode'] ?? '';
          permAddressId=data['addressId']??0;

        });
      } else {
        showErrorDialog('Failed to fetch permanent address: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog('An error occurred while fetching permanent address: $error');
    }
  }

  // Save temporary address
  Future<void> saveTemporaryAddress() async {
    const url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeAddressTemporary';
    final requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "AddressId": tempAddressId,
      "EmployeeId": "3",
      "City": tempCityController.text,
      "District": tempDistrictController.text,
      "State": tempStateController.text,
      "AddressLine1": tempAddressLine1Controller.text,
      "AddressLine2": tempAddressLine2Controller.text,
      "AddressLine3": tempAddressLine3Controller.text,
      "PinCode": tempPinCodeController.text,
      "HomeNumber": tempHomeNumberController.text,
      "Flag": "OVERWRITE",
      "StartDate":"",
      "EndDate":"",
      "EffectiveDate":"",
      "ChangeReason":"",
      "UserId": 1,
      "LoginIpAddress": "103.52.37.34",
      "LoginSystemName": "DESKTOP-1ONUPTO",
    "Mandal":"",
    "Country":""
    };
    print(requestBody);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
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

      } else {
        showErrorDialog('Failed to save temporary address: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog('An error occurred while saving temporary address: $error');
    }
  }

  // Save permanent address
  Future<void> savePermanentAddress() async {
    const url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeAddressesPermanentDetails';
    final requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "AddressId": permAddressId,
      "EmployeeId": "3",
      "City": permCityController.text,
      "District": permDistrictController.text,
      "State": permStateController.text,
      "AddressLine1": permAddressLine1Controller.text,
      "AddressLine2": permAddressLine2Controller.text,
      "AddressLine3": permAddressLine3Controller.text,
      "PinCode": permPinCodeController.text,
      "HomeNumber": permHomeNumberController.text,
      "Flag": "OVERWRITE",
      "StartDate":"",
      "EndDate":"",
      "EffectiveDate":"",
      "ChangeReason":"",
      "UserId": 1,
      "LoginIpAddress": "103.52.37.34",
      "LoginSystemName": "DESKTOP-1ONUPTO",  "Mandal":"",
      "Country":"",
    "Mandal":"",
    "Country":""
    };
    print(requestBody);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
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

      } else {
        showErrorDialog('Failed to save permanent address: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog('An error occurred while saving permanent address: $error');
    }
  }

  // Show error dialog
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show success dialog
  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Enable editing
  void enableEditing() {
    setState(() {
      isEditable = !isEditable;
    });
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
        title: const Text('Employee Address',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        actions: [
          IconButton(
            icon: Icon(isEditable ? Icons.check : Icons.edit),
            onPressed: enableEditing,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Temporary Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            buildTextField('City', tempCityController),
            buildTextField('District', tempDistrictController),
            buildTextField('State', tempStateController),
            buildTextField('Address Line 1', tempAddressLine1Controller),
            buildTextField('Address Line 2', tempAddressLine2Controller),
            buildTextField('Address Line 3', tempAddressLine3Controller),
            buildTextField('Pin Code', tempPinCodeController),
            buildTextField('Home Number', tempHomeNumberController),
            buildTextField('Address', tempHomeNumberController),
            const SizedBox(height: 16),
            const Text('Permanent Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            buildTextField('City', permCityController),
            buildTextField('District', permDistrictController),
            buildTextField('State', permStateController),
            buildTextField('Address Line 1', permAddressLine1Controller),
            buildTextField('Address Line 2', permAddressLine2Controller),
            buildTextField('Address Line 3', permAddressLine3Controller),
            buildTextField('Pin Code', permPinCodeController),
            const SizedBox(height: 16),
            if (isEditable) ...[
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: (){  saveTemporaryAddress();
    savePermanentAddress();},
                child: const Text('Save Address',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              ),
              const SizedBox(height: 8),

            ],
          ],
        ),
      ),
    );
  }

  // Reusable text field widget
  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        enabled: isEditable,
      ),
    );
  }
}
