import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  List<dynamic> employeeExpensesList = [];
  bool isLoading = false;
  String? pickedFilePath;

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
    setState(() {
      isLoading = true;
    });

    requestBody['Flag'] = flag;
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
        if (data.containsKey('message') && data['message'] != null) {
          // Show the message from the response in a snackbar
          _showSnackbar(data['message']);
        }


        print(data);
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(String message) {
    _showSnackbar(message);
  }

  void _showExpenseForm(BuildContext context, String flag, {dynamic expense}) {
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
    final fileNameController = TextEditingController(
        text:
            pickedFilePath != null ? pickedFilePath : requestBody['FileName']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                _buildTextField(fileNameController, 'File Name',
                    readOnly: true),
                SizedBox(height: 10),
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: _pickFile,
                  child: const Text('Pick File',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel',style: TextStyle(color: Colors.black),),
            ),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
                  "FileName": pickedFilePath ?? fileNameController.text,
                };

                requestBody['Amount'] = amountController.text;
                requestBody['BillName'] = billNameController.text;
                requestBody['BillDate'] = billDateController.text;
                requestBody['Description'] = descriptionController.text;
                requestBody['FileName'] =
                    pickedFilePath ?? fileNameController.text;

                // Use 'CREATE' or 'OVERWRITE' based on the flag
                _fetchExpenses(flag, additionalParams: updatedParams).then((_) {
                  // Refresh the list after saving
                  _fetchExpenses('VIEW');
                });
              },
              child: const Text('Save',style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        pickedFilePath = result.files.single.path;
      });
    }
  }

  // Build a custom text field
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
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
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
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expenses',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.white,
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
                return
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              expense['billName'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue, // Accent color for title
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  'Amount: ${expense['amount']}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Description: ${expense['description']}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Status: ${expense['adminStatus']}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Date: ${expense['commonDate']}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),   Text(
                                  'fileName: ${expense['fileName']}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.black, // Accent color for the icon
                              ),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                // You can add a delete option if needed
                                // PopupMenuItem(
                                //   value: 'delete',
                                //   child: Text(
                                //     'Delete',
                                //     style: TextStyle(
                                //       color: Colors.blue.shade900,
                                //       fontWeight: FontWeight.bold,
                                //     ),
                                //   ),
                                // ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showExpenseForm(context, 'OVERWRITE', expense: expense);
                                } else if (value == 'delete') {
                                  _performDelete(expense);
                                }
                              },
                            ),
                          ),
                          const Divider(thickness: 1, color: Colors.grey), // Add divider
                          const SizedBox(height: 8),
                        ],
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
                  // Reload the expenses list after deletion
                });
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
