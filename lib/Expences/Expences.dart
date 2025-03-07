import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {

  List<dynamic> employeeExpensesList = [];
  bool isLoading = false;

  Map<String, dynamic> requestBody = {

    "GrpCode": "Beesdev",
    "ColCode": "0001",
    "CollegeId": "1",
    "EmployeeId": "3",
    "ExpenceId": "0",
    "Amount": "6000",
    "BillName": "gdfgfd",
    "BillDate": "2024-09-06",
    "Description": "fdfsf",
    "FileName": "",
    "LoginIpAddress": "",
    "LoginSystemName": "",
    "Flag": "VIEW"
  };


  @override
  void initState() {
    super.initState();
    _fetchExpenses('VIEW');
  }
  Future<void> _fetchExpenses(String flag,
      {Map<String, dynamic>? additionalParams}) async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType') ?? '';
    final finYearId = prefs.getInt('finYearId') ?? 0;
    final acYearId = prefs.getInt('acYearId') ?? 0;
    final adminUserId = prefs.getString('adminUserId') ?? '';
    final acYear = prefs.getString('acYear') ?? '';
    final finYear = prefs.getString('finYear') ?? '';
    final employeeId = prefs.getInt('employeeId') ?? 0;
    final collegeId = prefs.getString('collegeId') ?? '';
    final colCode = prefs.getString('colCode') ?? '';
    print(requestBody);

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    // Update requestBody with the SharedPreferences values
    requestBody['Flag'] = flag;
    requestBody['ColCode'] = colCode;
    requestBody['CollegeId'] = collegeId;
    requestBody['EmployeeId'] = employeeId.toString();
    requestBody['UserType'] = userType;
    requestBody['FinYearId'] = finYearId.toString();
    requestBody['AcYearId'] = acYearId.toString();
    requestBody['AdminUserId'] = adminUserId;
    requestBody['AcYear'] = acYear;
    requestBody['FinYear'] = finYear;

    if (additionalParams != null) {
      requestBody.addAll(additionalParams);
    }

    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIpreprod/CloudilyaMobileAPP/SelfServiceEmployeeExpences');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        if (data.containsKey('message')) {
          // Show Toast with the message
          Fluttertoast.showToast(
            msg: data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        setState(() {
          employeeExpensesList = data['employeeExpencesList'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Network error: $e');
    }
  }


  void _showSnackbar(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showExpenseForm(BuildContext context, String flag, {dynamic expense}) {
    String? pickedFilePath = expense != null ? expense['fileName'] : null;

    final amountController = TextEditingController(
        text: expense != null
            ? expense['amount'].toString()
            : requestBody['Amount']);
    final billNameController = TextEditingController(
        text: expense != null ? expense['billName'] : requestBody['BillName']);
    final billDateController = TextEditingController(
        text: expense != null ? expense['billDate'] : requestBody['BillDate']);
    final descriptionController = TextEditingController(
        text: expense != null
            ? expense['description']
            : requestBody['Description']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                  flag == 'CREATE' ? 'Create New Expense' : 'Overwrite Expense'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(amountController, 'Amount',
                        keyboardType: TextInputType.number),
                    _buildTextField(billNameController, 'Bill Name'),
                    _buildDatePicker(context, billDateController, 'Bill Date'),
                    _buildTextField(descriptionController, 'Description'),
                    const SizedBox(height: 10),
                    Text(
                      'File: ${pickedFilePath?.split('/').last ?? 'No file selected'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      onPressed: () async {
                        FilePickerResult? result =
                        await FilePicker.platform.pickFiles();
                        if (result != null) {
                          setState(() {
                            // Extract just the file name
                            pickedFilePath = result.files.single.path;
                          });
                        }
                      },
                      child: const Text(
                        'Pick File',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue),
                  onPressed: () {
                    Navigator.pop(context);
                    final updatedParams = {
                      "ExpenceId": expense != null
                          ? expense['expenceId'].toString()
                          : requestBody['ExpenceId'],
                      "Amount": amountController.text,
                      "BillName": billNameController.text,
                      "BillDate": billDateController.text,
                      "Description": descriptionController.text,
                      "FileName": pickedFilePath != null
                          ? pickedFilePath!.split('/').last // Send only the file name
                          : (expense != null
                          ? expense['fileName']
                          : requestBody['FileName']),
                    };

                    requestBody['Amount'] = amountController.text;
                    requestBody['BillName'] = billNameController.text;
                    requestBody['BillDate'] = billDateController.text;
                    requestBody['Description'] = descriptionController.text;
                    requestBody['FileName'] = pickedFilePath != null
                        ? pickedFilePath!.split('/').last // Send only the file name
                        : (expense != null
                        ? expense['fileName']
                        : requestBody['FileName']);

                    _fetchExpenses(flag, additionalParams: updatedParams)
                        .then((_) {
                      _fetchExpenses('VIEW');
                    });
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool readOnly = false,
        TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey[600]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        keyboardType: keyboardType,
        readOnly: readOnly,
      ),
    );
  }

  Widget _buildDatePicker(
      BuildContext context, TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey[600]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onTap: () async {
          DateTime? date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            controller.text = date.toString().split(' ')[0];
          }
        },
      ),
    );
  }

  void _performDelete(dynamic expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _fetchExpenses('DELETE',
                    additionalParams: {"ExpenceId": expense['expenceId']})
                    .then((_) {
                  _fetchExpenses('VIEW');
                });
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expenses',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchExpenses('VIEW'),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: employeeExpensesList.length,
        itemBuilder: (context, index) {
          final expense = employeeExpensesList[index];
          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: Icon(
                  Icons.receipt_long,
                  color: Colors.blue.shade900,
                  size: 36,
                ),
                title: Text(
                  expense['billName'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blue.shade900,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Amount: ${expense['amount']}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Description: ${expense['description']}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Status: ${expense['adminStatus']}',
                      style: TextStyle(
                        color: expense['adminStatus'] == 'Approved'
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Date: ${expense['commonDate']}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'File: ${expense['fileName'].split('/').last}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.blue.shade900,
                  ),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    String status = expense['adminStatus']?.toString().toLowerCase() ?? '';

                    if (value == 'edit') {
                      if (status == 'pending') {
                        // Show a toast message and prevent editing
                        Fluttertoast.showToast(
                          msg: "Changes sent for approval cannot be edited now.",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else {
                        _showExpenseForm(context, 'OVERWRITE', expense: expense);
                      }
                    } else if (value == 'delete') {
                      _performDelete(expense);
                    }
                  },

                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExpenseForm(context, 'CREATE'),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
