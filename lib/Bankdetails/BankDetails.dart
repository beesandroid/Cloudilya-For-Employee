import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BankDetails extends StatefulWidget {
  const BankDetails({super.key});

  @override
  State<BankDetails> createState() => _BankDetailsState();
}

class _BankDetailsState extends State<BankDetails> {
  Map<String, dynamic>? bankDetails;
  bool isLoading = true;
  bool isEditing = false;
  List<dynamic> bankList = [];
  List<dynamic> paymentTypeList = [];
  String? selectedBank;
  String? selectedPaymentType;
  final _accountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBankDetails();
    fetchBankNames();
    fetchPaymentTypes();
  }

  Future<void> fetchBankDetails() async {
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
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveBankDetails');
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "Id": 0,
      "EffectiveDate": "",
      "EmployeeId": employeeId,
      "ProcessingOrder": 0,
      "PayType": 0,
      "Bank": 0,
      "AccountNo": "",
      "IFSCCode": "",
      "PhoneNumber": "",
      "ChangeReason": "",
      "UserId": adminUserId,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "VIEW"
    };

    try {
      final response = await http.post(url, body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          if (data['displayandSaveBankDetailsList'] != null &&
              data['displayandSaveBankDetailsList'].isNotEmpty) {
            bankDetails = data['displayandSaveBankDetailsList'][0];
            isEditing = false;
            _initializeTextFields();
          } else {
            // No bank details found, switch to create mode
            bankDetails = null;
            isEditing = true;
            _clearTextFields();
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('Failed to fetch bank details. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Network error: $e');
    }
  }

  void _initializeTextFields() {
    if (bankDetails != null) {
      _accountController.text = bankDetails!['accountNo'] ?? '';
      _ifscController.text = bankDetails!['ifscCode'] ?? '';
      _phoneController.text = bankDetails!['phoneNumber'] ?? '';
      _reasonController.text = bankDetails!['changeReason'] ?? '';
      selectedBank = bankDetails!['bankFullName'] ?? null;
      selectedPaymentType = bankDetails!['paymentTypeName'] ?? null;
    }
  }

  void _clearTextFields() {
    _accountController.clear();
    _ifscController.clear();
    _phoneController.clear();
    _reasonController.clear();
    selectedBank = null;
    selectedPaymentType = null;
  }

  Future<void> fetchBankNames() async {
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/BankNameDopDown');
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "Flag": "30",
    };

    try {
      final response = await http.post(url, body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          bankList = data['bankNameDopDownList'];
        });
      } else {
        _showError('Failed to fetch bank names. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Network error while fetching bank names: $e');
    }
  }

  Future<void> fetchPaymentTypes() async {
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/CommonLookUpsDropDown');
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "Flag": "29",
    };
    try {
      final response = await http.post(url, body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          paymentTypeList = data['paymentType'];
        });
      } else {
        _showError('Failed to fetch payment types. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Network error while fetching payment types: $e');
    }
  }

  Future<void> saveBankDetails() async {
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
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveBankDetails');

    // Find the selected payment type ID
    final selectedPayType = paymentTypeList.firstWhere(
            (type) => type['meaning'] == selectedPaymentType,
        orElse: () => null);
    final selectedPayTypeId =
    selectedPayType != null ? selectedPayType['lookUpId'] : 0;

    // Find the selected bank ID
    final selectedBankItem = bankList.firstWhere(
            (bank) => bank['meaning'] == selectedBank,
        orElse: () => null);
    final selectedBankId = selectedBankItem != null ? selectedBankItem['lookUpId'] : 0;

    // Determine the flag
    String flag = bankDetails == null ? "CREATE" : "OVERWRITE";

    final body = {
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "Id": bankDetails?['id'] ?? 0,
      "EffectiveDate": bankDetails?['effectiveDate'] ?? "",
      "EmployeeId": employeeId,
      "ProcessingOrder": bankDetails?['processingOrder'] ?? 0,
      "PayType": selectedPayTypeId, // Use the mapped payType ID
      "Bank": selectedBankId, // Use the mapped bank ID
      "AccountNo": _accountController.text,
      "IFSCCode": _ifscController.text,
      "PhoneNumber": _phoneController.text,
      "ChangeReason": _reasonController.text,
      "UserId": adminUserId,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": flag
    };

    print(body); // Debug the body to ensure values are correctly mapped

    try {
      final response = await http.post(url, body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        String message = responseBody['message'] ?? 'Operation successful';

        // Show appropriate toast based on the flag
        if (flag == "CREATE") {
          _showSuccess(message);
        } else {
          _showSuccess(message);
        }

        setState(() {
          isEditing = false;
        });
        fetchBankDetails(); // Refresh after saving
      } else {
        _showError('Failed to save bank details. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Network error while saving bank details: $e');
    }
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red, // Red for errors
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green, // Green for success
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Bank Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!isLoading)
            IconButton(
              icon: Icon(
                isEditing ? Icons.save : Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                final String status = bankDetails?['status']?.toString() ?? '';

                // Check if the status is "pending" (case-insensitive check)
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
                  if (isEditing) {
                    // Validate inputs before saving
                    if (_validateInputs()) {
                      saveBankDetails();
                    }
                  } else {
                    setState(() {
                      isEditing = true;
                    });
                  }
                }
              },
            ),

        ],
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
      body: Container(
        decoration: BoxDecoration(),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdownField(
                    'Bank Name', selectedBank, bankList, (value) {
                  if (isEditing) {
                    setState(() {
                      selectedBank = value;
                    });
                  }
                }, isEnabled: isEditing),
                SizedBox(height: 16.0),
                _buildDropdownField('Payment Type',
                    selectedPaymentType, paymentTypeList, (value) {
                      if (isEditing) {
                        setState(() {
                          selectedPaymentType = value;
                        });
                      }
                    }, isEnabled: isEditing),
                SizedBox(height: 16.0),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: (isEditing &&
                      selectedPaymentType != null &&
                      selectedPaymentType != 'Cash')
                      ? Column(
                    key: ValueKey('textFields'),
                    children: [
                      _buildEditableField(
                          'Account No', _accountController,
                          isEnabled: isEditing),
                      SizedBox(height: 16.0),
                      _buildEditableField(
                          'IFSC Code', _ifscController,
                          isEnabled: isEditing),
                      SizedBox(height: 16.0),
                      _buildEditableField(
                          'Phone Number', _phoneController,
                          isEnabled: isEditing),
                      SizedBox(height: 16.0),
                      _buildEditableField(
                          'Change Reason', _reasonController,
                          isEnabled: isEditing),
                    ],
                  )
                      : SizedBox.shrink(),
                ),
                if (isEditing && bankDetails == null) ...[
                  // In create mode, ensure text fields are shown based on payment type
                  // Already handled by the AnimatedSwitcher above
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _validateInputs() {
    if (selectedBank == null || selectedBank!.isEmpty) {
      _showError('Please select a bank.');
      return false;
    }
    if (selectedPaymentType == null || selectedPaymentType!.isEmpty) {
      _showError('Please select a payment type.');
      return false;
    }
    if (selectedPaymentType != 'Cash') {
      if (_accountController.text.isEmpty) {
        _showError('Please enter your account number.');
        return false;
      }
      if (_ifscController.text.isEmpty) {
        _showError('Please enter your IFSC code.');
        return false;
      }
      if (_phoneController.text.isEmpty) {
        _showError('Please enter your phone number.');
        return false;
      }
      if (_reasonController.text.isEmpty) {
        _showError('Please provide a reason for changes.');
        return false;
      }
    }
    return true;
  }

  Widget _buildDropdownField(String label, String? selectedValue,
      List<dynamic> items, ValueChanged<String?> onChanged,
      {bool isEnabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 12.0,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: selectedValue,
          items: items
              .map<DropdownMenuItem<String>>((item) => DropdownMenuItem<String>(
            value: item['meaning'],
            child: Text(item['meaning'],
                style:
                TextStyle(fontSize: 16.0, color: Colors.black87)),
          ))
              .toList(),
          onChanged: isEnabled ? onChanged : null,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
          ),
          dropdownColor: Colors.white,
          disabledHint: Text(selectedValue ?? ''),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {bool isEnabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 12.0,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          enabled: isEnabled,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16.0,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            filled: true,
            fillColor: isEnabled ? Colors.white : Colors.grey.shade200,
          ),
        ),
      ),
    );
  }
}
