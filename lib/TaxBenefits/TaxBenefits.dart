import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class TaxBenefits extends StatefulWidget {
  const TaxBenefits({super.key});

  @override
  State<TaxBenefits> createState() => _TaxBenefitsState();
}

class _TaxBenefitsState extends State<TaxBenefits> {
  late Future<List<dynamic>> _taxBenefits;
  String? _attachmentPath;

  @override
  void initState() {
    super.initState();
    _taxBenefits = fetchTaxBenefits();
  }

  Future<List<dynamic>> fetchTaxBenefits() async {
    const String apiUrl = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeTaxBenifits';

    Map<String, dynamic> requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "3",
      "Id": 0,
      "UserId": 1,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "VIEW",
      "EmployeeTaxBenifitsVariable": [{
        "Id": 0,
        "DeductionId": 0,
        "SectionId": 0,
        "MaxLimit": 0,
        "Usage": 0,
        "Attachment": "",
        "Proof": 0
      }]
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['employeeTaxBenifitsList'] as List<dynamic>;
    } else {
      throw Exception('Failed to load tax benefits');
    }
  }

  Future<void> addOrEditTaxBenefit(
      String flag, String deductionName, String section, double maxLimit, double usage, String attachment, int id) async {
    const String apiUrl = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeTaxBenifits';

    Map<String, dynamic> requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "3",
      "Id": id,
      "UserId": 1,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": flag,
      "EmployeeTaxBenifitsVariable": [{
        "Id": id,
        "DeductionId": 0,
        "SectionId": 0,
        "MaxLimit": maxLimit,
        "Usage": usage,
        "Attachment": attachment,
        "Proof": 0
      }]
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print(response.body);
      final responseBody = jsonDecode(response.body);
      String message = responseBody['message'] ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() {
        _taxBenefits = fetchTaxBenefits();
      });
    } else {
      throw Exception('Failed to add or edit tax benefit');
    }
  }

  void _showAddDialog(
      {String? deductionName, String? section, double? maxLimit, double? usage, String? attachment, int id = 0}) {

    final TextEditingController deductionNameController = TextEditingController(text: deductionName ?? '');
    final TextEditingController sectionController = TextEditingController(text: section ?? '');
    final TextEditingController maxLimitController = TextEditingController(text: maxLimit?.toString() ?? '');
    final TextEditingController usageController = TextEditingController(text: usage?.toString() ?? '');
    _attachmentPath = attachment;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(backgroundColor: Colors.white,
          title: Text(id == 0 ? 'Add Tax Benefit' : 'Edit Tax Benefit'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: deductionNameController,
                    decoration: const InputDecoration(labelText: 'Deduction Name'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: sectionController,
                    decoration: const InputDecoration(labelText: 'Section'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: maxLimitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max Limit'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: usageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Usage'),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      _attachmentPath = result.files.single.path;
                      setState(() {});
                    }
                  },
                  child: const Text('Pick Attachment'),
                ),
                _attachmentPath != null ? Text('Selected: $_attachmentPath') : const Text('No file selected'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                addOrEditTaxBenefit(
                  id == 0 ? 'CREATE' : 'OVERWRITE',
                  deductionNameController.text,
                  sectionController.text,
                  double.parse(maxLimitController.text),
                  double.parse(usageController.text),
                  _attachmentPath ?? '',
                  id,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
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
        title: Text('Tax Benefits',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
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

 // Futuristic icon color
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddDialog(),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _taxBenefits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found', style: TextStyle(color: Colors.black87)));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final benefit = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: () {
                      // Add a cool animation here on tap
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8), // Light glass-like effect
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [

                        ],
                        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
                      ),
                      child: ListTile(
                        title: Text(
                          benefit['deductionName'] ?? 'No Name',style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Section: ${benefit['section'] ?? ''}\n'
                              'Max Limit: ₹${benefit['maxLimit']}\n'
                              'Usage: ₹${benefit['usage']}\n'
                              'Proof: ${benefit['proofName'] ?? ''}\n'
                              'Attachment: ${benefit['attachment'] ?? 'None'}\n'
                              'Status: ${benefit['status']}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showAddDialog(
                              deductionName: benefit['deductionName'],
                              section: benefit['section'],
                              maxLimit: benefit['maxLimit']?.toDouble(),
                              usage: benefit['usage']?.toDouble(),
                              attachment: benefit['attachment'],
                              id: benefit['id'],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      backgroundColor: Colors.white, // Light background
    );
  }
}