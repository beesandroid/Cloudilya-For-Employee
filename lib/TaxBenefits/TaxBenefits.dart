import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import 'model.dart';

class TaxBenefits extends StatefulWidget {
  const TaxBenefits({super.key});

  @override
  State<TaxBenefits> createState() => _TaxBenefitsState();
}

class _TaxBenefitsState extends State<TaxBenefits> {
  late Future<List<dynamic>> _taxBenefits;
  String? _attachmentPath;
  List sections = [];
  List deductions = [];
  int? selectedSectionId;
  int? selectedDeductionId;
  final TextEditingController deductionNameController = TextEditingController();
  final TextEditingController maxLimitController = TextEditingController();
  final TextEditingController usageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _taxBenefits = fetchTaxBenefits();
    fetchSections();
  }

  Future<void> fetchDeduction(int? sectionId) async {
    if (sectionId == null) return;

    try {
      final requestBody = jsonEncode({
        "GrpCode": "BEESDEV",
        "ColCode": "0001",
        "Section": sectionId,
      });

      print('Fetching deductions for section: $sectionId');
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmpoyeeDeductionsDropDown'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Deductions fetched: ${data['empoyeeDeductionsDropDownList']}');
        setState(() {
          deductions = (data['empoyeeDeductionsDropDownList'] as List)
              .map((json) => Deduction.fromJson(json))
              .toList();
        });
      } else {
        print('Failed to load deductions: ${response.body}');
      }
    } catch (e) {
      print('Error fetching deductions: $e');
    }
  }

  Future<void> fetchSections() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeSectionDropDownForDeductions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "GrpCode": "BEESDEV",
          "ColCode": "0001",
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
            'Sections fetched: ${data['employeeSectionDropDownForDeductionsList']}');
        setState(() {
          sections = (data['employeeSectionDropDownForDeductionsList'] as List)
              .map((json) => Section.fromJson(json))
              .toList();
        });
      } else {
        print('Failed to load sections: ${response.body}');
      }
    } catch (e) {
      print('Error fetching sections: $e');
    }
  }

  Future<List<dynamic>> fetchTaxBenefits() async {
    const String apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeTaxBenifits';
    Map<String, dynamic> requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "17051",
      "Id": 0,
      "UserId": 1,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "VIEW",
      "EmployeeTaxBenifitsVariable": [
        {
          "Id": 0,
          "DeductionId": 0,
          "SectionId": 0,
          "MaxLimit": 0,
          "Usage": 0,
          "Attachment": "",
          "Proof": 0
        }
      ]
    };
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print(responseBody);
      return responseBody['employeeTaxBenifitsList'] as List<dynamic>;
    } else {
      throw Exception('Failed to load tax benefits');
    }
  }

  Future<void> addOrEditTaxBenefit(
      String flag,
      String deductionName,
      String section,
      double maxLimit,
      double usage,
      String attachment,
      int id) async {
    const String apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeTaxBenifits';
    Map<String, dynamic> requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "17051",
      "Id": id,
      "UserId": 1,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": flag,
      "EmployeeTaxBenifitsVariable": [
        {
          "Id": id,
          "DeductionId": selectedDeductionId,
          "SectionId": selectedSectionId,
          "MaxLimit": maxLimit,
          "Usage": usage,
          "Attachment": attachment,
          "Proof": 0
        }
      ]
    };
    print(requestBody);

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print(response.body);
      final responseBody = jsonDecode(response.body);
      Fluttertoast.showToast(
        msg: responseBody['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        _taxBenefits = fetchTaxBenefits();
      });
    } else {
      throw Exception('Failed to add or edit tax benefit');
    }
  }

  Future<String> _convertFileToBase64(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  void _onSave() async {
    String deductionName = deductionNameController.text;
    String section = selectedSectionId?.toString() ?? '';
    double maxLimit = double.tryParse(maxLimitController.text) ?? 0.0;
    double usage = double.tryParse(usageController.text) ?? 0.0;

    String attachmentBase64 = '';
    if (_attachmentPath != null) {
      attachmentBase64 = await _convertFileToBase64(_attachmentPath!);
    }

    addOrEditTaxBenefit(
      'CREATE',
      deductionName,
      section,
      maxLimit,
      usage,
      attachmentBase64,
      0, // ID is 0 for new entries
    );
    deductionNameController.clear();
    maxLimitController.clear();
    usageController.clear();
    setState(() {
      selectedSectionId = null;
      selectedDeductionId = null;
      _attachmentPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tax Benefits',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Sections'),
                value: selectedSectionId,
                items: sections.map<DropdownMenuItem<int>>((section) {
                  return DropdownMenuItem<int>(
                    value: section.sectionId,
                    child: Text(section.section),
                  );
                }).toList(),
                onChanged: (int? newValue) async {
                  if (newValue != null) {
                    setState(() {
                      selectedSectionId = newValue;
                      deductions.clear();
                      selectedDeductionId = null;
                    });
                    await fetchDeduction(selectedSectionId);
                  }
                },
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Deductions'),
                value: selectedDeductionId,
                items: deductions.map<DropdownMenuItem<int>>((deduction) {
                  return DropdownMenuItem<int>(
                    value: deduction.deductionId,
                    child: Text(deduction.deductionName),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    final selectedDeduction = deductions.firstWhere(
                          (deduction) => deduction.deductionId == newValue,
                    );
                    print('Selected deduction: $selectedDeduction');
                    setState(() {
                      selectedDeductionId = newValue;
                      maxLimitController.text = selectedDeduction.maxLimit.toString();
                    });
                  }
                },
              ),
              const SizedBox(height: 10),

              TextField(
                controller: maxLimitController,
                keyboardType: TextInputType.number,
                enabled: false,
                decoration: InputDecoration(labelText: 'Max Limit'),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: usageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Usage'),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () async {
                  String? path = (await FilePicker.platform.pickFiles())?.files.first.path;
                  if (path != null) {
                    setState(() {
                      _attachmentPath = path;
                    });
                  }
                },
                child: Text('Upload Attachment', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),

              Text(
                _attachmentPath != null ? 'Selected Attachment: $_attachmentPath' : 'No Attachment Selected',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),

              Container(
                width: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    _onSave();
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),

              FutureBuilder<List<dynamic>>(
                future: _taxBenefits,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No tax benefits found.'));
                  }

                  final taxBenefits = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: taxBenefits.length,
                    itemBuilder: (context, index) {
                      final benefit = taxBenefits[index];
                      return Card(
                        elevation: 8,
                        margin: EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            title: Text(
                              benefit['deductionName']?.toString() ?? 'No Deduction Name',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5),
                                Text('Sections: ${benefit['section']?.toString() ?? 'N/A'}'),
                                SizedBox(height: 5),
                                Text('Max Limit: ${benefit['maxLimit']?.toString() ?? 'N/A'}'),
                                SizedBox(height: 5),
                                Text('Usage: ${benefit['usage']?.toString() ?? 'N/A'}'),
                                SizedBox(height: 5),
                                Text('Proof: ${benefit['proofName']?.toString() ?? 'N/A'}'),
                                SizedBox(height: 5),
                                Text('Attachment: ${benefit['attachment']?.toString() ?? 'N/A'}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue.shade600),
                              onPressed: () {
                                setState(() {
                                  deductionNameController.text = benefit['deductionName']?.toString() ?? '';
                                  maxLimitController.text = benefit['maxLimit']?.toString() ?? '';
                                  usageController.text = benefit['usage']?.toString() ?? '';
                                  selectedDeductionId = benefit['deductionId'];
                                  selectedSectionId = benefit['sectionId'];
                                  _attachmentPath = benefit['attachment'];
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}
