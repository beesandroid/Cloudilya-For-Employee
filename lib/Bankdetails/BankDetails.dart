import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

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
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveBankDetails');
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "Id": 0,
      "EffectiveDate": "",
      "EmployeeId": "17051",
      "ProcessingOrder": 0,
      "PayType": 0,
      "Bank": 0,
      "AccountNo": "",
      "IFSCCode": "",
      "PhoneNumber": "",
      "ChangeReason": "",
      "UserId": 2,
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
        setState(() {
          bankDetails = data['displayandSaveBankDetailsList'] != null
              ? data['displayandSaveBankDetailsList'][0]
              : null;
          isLoading = false;
          _initializeTextFields();
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
      }
    } catch (e) {}
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
      }
    } catch (e) {
      // Handle error
    }
  }
  Future<void> saveBankDetails() async {
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveBankDetails');

    // Find the selected payment type ID
    final selectedPayTypeId = selectedPaymentType != null
        ? paymentTypeList.firstWhere((type) => type['meaning'] == selectedPaymentType)['lookUpId']
        : bankDetails?['payType'];  // Default to existing payType if none is selected

    final body = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "Id": bankDetails?['id'] ?? 0,
      "EffectiveDate": bankDetails?['effectiveDate'] ?? "",
      "EmployeeId": "17051",
      "ProcessingOrder": bankDetails?['processingOrder'] ?? 0,
      "PayType": selectedPayTypeId,  // Use the mapped payType ID
      "Bank": selectedBank != null
          ? bankList
          .firstWhere((bank) => bank['meaning'] == selectedBank)['lookUpId']
          : bankDetails?['bank'],
      "AccountNo": _accountController.text,
      "IFSCCode": _ifscController.text,
      "PhoneNumber": _phoneController.text,
      "ChangeReason": _reasonController.text,
      "UserId": 2,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "OVERWRITE"
    };

    print(body);  // You can debug the body to ensure values are correctly mapped

    try {
      final response = await http.post(url, body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        Fluttertoast.showToast(
          msg: responseBody['message'],
          toastLength: Toast.LENGTH_LONG, // or Toast.LENGTH_SHORT
          gravity: ToastGravity.BOTTOM, // can be TOP, CENTER, or BOTTOM
          timeInSecForIosWeb: 1, // duration for iOS Web
          backgroundColor: Colors.black, // background color of the toast
          textColor: Colors.white, // text color of the toast
          fontSize: 16.0, // font size
        );
        setState(() {
          isEditing = false;
        });
        fetchBankDetails();  // Refresh after saving
      }
    } catch (e) {
      // Handle exception
    }
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
          if (!isLoading && selectedBank != null)
            IconButton(
              icon: Icon(
                isEditing ? Icons.save : Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                if (isEditing) {
                  saveBankDetails();
                } else {
                  setState(() {
                    isEditing = true;
                  });
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
            : selectedBank == null
                ? Center(child: Text('No bank details found.'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDropdownField(
                              'Bank Name', selectedBank, bankList, (value) {
                            setState(() {
                              selectedBank = value;
                            });
                          }),
                          SizedBox(height: 16.0),
                          _buildDropdownField('Payment Type',
                              selectedPaymentType, paymentTypeList, (value) {
                            setState(() {
                              selectedPaymentType = value;
                            });
                          }),
                          SizedBox(height: 16.0),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 500),
                            child: selectedPaymentType != 'Cash'
                                ? Column(
                                    key: ValueKey(selectedPaymentType),
                                    children: [
                                      _buildEditableField(
                                          'Account No', _accountController),
                                      _buildEditableField(
                                          'IFSC Code', _ifscController),
                                      _buildEditableField(
                                          'Phone Number', _phoneController),
                                      _buildEditableField(
                                          'Change Reason', _reasonController),
                                    ],
                                  )
                                : SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String? selectedValue,
      List<dynamic> items, ValueChanged<String?> onChanged) {
    // Debug print statements
    // print('Selected Value: $selectedValue');
    // print('Dropdown Items: ${items.map((item) => item['meaning']).toList()}');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
          onChanged: isEditing ? onChanged : null,
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
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
          enabled: isEditing,
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
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
