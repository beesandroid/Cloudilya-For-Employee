import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart'; // For date formatting

class EmployeeQualificationsScreen extends StatefulWidget {
  const EmployeeQualificationsScreen({Key? key}) : super(key: key);

  @override
  _EmployeeQualificationsScreenState createState() =>
      _EmployeeQualificationsScreenState();
}

class _EmployeeQualificationsScreenState
    extends State<EmployeeQualificationsScreen> {
  final String _apiUrl =
      'https://beessoftware.cloud/CoreAPIPreprod/CloudilyaMobileAPP/DisplayandSaveEmployeeQualifications';
  final String _dropdownApiUrl =
      'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/CommonLookUpsDropDown';

  List<dynamic> _qualifications = [];
  List<dynamic> qualificationList = [];
  List<dynamic> graduationLevelList = [];
  List<dynamic> specializationList = [];
  List<dynamic> universityList = [];
  List<dynamic> mediumList = [];
  List<dynamic> divisionList = [];

  bool _isLoading = true;
  bool _isEditing = false;
  int? _editingEmpQualId;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _graduationDateController =
  TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _institutionAddressController =
  TextEditingController();
  final TextEditingController _gpaController = TextEditingController();

  // Dropdown selections
  int? selectedQualification;
  int? selectedGraduationLevel;
  int? selectedSpecialization;
  int? selectedUniversity;
  int? selectedMedium;
  int? selectedDivision;

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  // Fetch Dropdown Data
  Future<void> fetchDropdownData() async {
    try {
      await fetchLookups(23, (data) {
        qualificationList = data['qualificationList'] ?? [];
      });
      await fetchLookups(37, (data) {
        graduationLevelList = data['graduationLevelList'] ?? [];
      });
      await fetchLookups(38, (data) {
        specializationList = data['spcializationDropownList'] ?? [];
      });
      await fetchLookups(39, (data) {
        universityList = data['universityDropownList'] ?? [];
      });
      await fetchLookups(13, (data) {
        mediumList = data['mediumList'] ?? [];
      });
      await fetchLookups(40, (data) {
        divisionList = data['divisionList'] ?? [];
      });

      // After fetching all dropdowns, fetch qualifications
      await fetchQualifications();

      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to fetch dropdown data',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
      print('Error: $e');
    }
  }

  Future<void> fetchLookups(
      int flag, Function(Map<String, dynamic>) callback) async {
    final response = await http.post(
      Uri.parse(_dropdownApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Beesdev",
        "ColCode": "0001",
        "Flag": flag,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      callback(data);
    } else {
      print('Failed to fetch data for flag: $flag');
    }
  }

  // Fetch Qualifications (Read)
  Future<void> fetchQualifications() async {
    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmpQualId": 0,
      "EmployeeId": "13",
      "StartDate": "",
      "EndDate": "",
      "UserId": 1,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "VIEW",
      "EmployeeQualificationVariable": [
        {
          "EmpQualId": 0,
          "QualificationId": 0,
          "GraduationDate": "",
          "Level": 0,
          "SpecializationId": 0,
          "University": 0,
          "Institution": "",
          "InstitutionAddress": "",
          "Medium": 0,
          "GPA": 0,
          "Division": 0
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final qualificationsList =
            responseBody['displayandSaveEmployeeQualificationsList'] ?? [];

        setState(() {
          _qualifications = qualificationsList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
          msg: 'Failed to fetch qualifications',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: 'An error occurred while fetching data',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
      print('Exception: $e');
    }
  }

  // Create or Update Qualification
  Future<void> createOrUpdateQualification(String flag) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final Map<String, dynamic> qualificationData = {
      "EmpQualId": flag == "CREATE" ? 0 : _editingEmpQualId ?? 0,
      "QualificationId": selectedQualification ?? 0,
      "GraduationDate": _graduationDateController.text,
      "Level": selectedGraduationLevel ?? 0,
      "SpecializationId": selectedSpecialization ?? 0,
      "University": selectedUniversity ?? 0,
      "Institution": _institutionController.text,
      "InstitutionAddress": _institutionAddressController.text,
      "Medium": selectedMedium ?? 0,
      "GPA": double.tryParse(_gpaController.text) ?? 0.0,
      "Division": selectedDivision ?? 0,
    };

    final Map<String, dynamic> requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmpQualId": flag == "CREATE" ? 0 : _editingEmpQualId ?? 0,
      "EmployeeId": "13",
      "Flag": flag,
      "UserId": "1",
      "StartDate": "",
      "EndDate": "",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "EmployeeQualificationVariable": [qualificationData],
    };

    print('Request Body: ${json.encode(requestBody)}'); // Debugging

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final data = json.decode(response.body);
        final message = responseBody['message'] ;
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



        await fetchQualifications(); // Refresh the list

        setState(() {
          _isEditing = false; // Disable editing after operation
          _editingEmpQualId = null; // Reset editing ID
          _formKey.currentState!.reset(); // Reset the form
          // Reset dropdown selections
          selectedQualification = null;
          selectedGraduationLevel = null;
          selectedSpecialization = null;
          selectedUniversity = null;
          selectedMedium = null;
          selectedDivision = null;
          // Clear text fields
          _graduationDateController.clear();
          _institutionController.clear();
          _institutionAddressController.clear();
          _gpaController.clear();
        });
      } else {

        print('Error: ${response.statusCode}');
      }
    } catch (e) {

      print('Exception: $e');
    }
  }

  // UI Form including Dropdowns
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),

        title:  Text('Employee Qualifications',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Qualification Section
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Qualification Details',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        buildDropdown(
                          "Qualification",
                          qualificationList,
                          selectedQualification,
                              (value) {
                            setState(() {
                              selectedQualification = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedGraduationLevel != null
                                  ? DateTime.now()
                                  : DateTime(2000),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                              setState(() {
                                _graduationDateController.text =
                                    formattedDate;
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _graduationDateController,
                              decoration: const InputDecoration(
                                labelText: 'Graduation Date (YYYY-MM-DD)',
                                suffixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter graduation date';
                                }
                                // Optional: Add date format validation here
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildDropdown(
                          "Graduation Level",
                          graduationLevelList,
                          selectedGraduationLevel,
                              (value) {
                            setState(() {
                              selectedGraduationLevel = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        buildDropdown(
                          "Specialization",
                          specializationList,
                          selectedSpecialization,
                              (value) {
                            setState(() {
                              selectedSpecialization = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9, // 90% of the screen width
                          child: buildDropdown(
                            "University",
                            universityList,
                            selectedUniversity,
                                (value) {
                              setState(() {
                                selectedUniversity = value;
                              });
                            },
                          ),
                        )


                        ,
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _institutionController,
                          decoration: const InputDecoration(
                            labelText: 'Institution',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter institution';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _institutionAddressController,
                          decoration: const InputDecoration(
                            labelText: 'Institution Address',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter institution address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        buildDropdown(
                          "Medium",
                          mediumList,
                          selectedMedium,
                              (value) {
                            setState(() {
                              selectedMedium = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _gpaController,
                          decoration: const InputDecoration(
                            labelText: 'Percentage/GPA',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter GPA';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        buildDropdown(
                          "Division",
                          divisionList,
                          selectedDivision,
                              (value) {
                            setState(() {
                              selectedDivision = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Action Buttons
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isEditing) {
                        createOrUpdateQualification("OVERWRITE");
                      } else {
                        createOrUpdateQualification("CREATE");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Update Qualification' : 'Add Qualification',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'Existing Qualifications',
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _qualifications.isEmpty
                    ? const Center(
                  child: Text(
                    'No qualifications found.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _qualifications.length,
                  itemBuilder: (context, index) {
                    final qualification = _qualifications[index];
                    return Card(color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 0),
                      child: ListTile(
                        title: Text(
                          qualification['qualification'] ?? 'N/A',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Graduation Date: ${qualification['graduationDate'] ?? 'N/A'}\n'
                              'Level: ${qualification['level'] ?? 'N/A'}\n'
                              'Specialization: ${qualification['specialization'] ?? 'N/A'}\n'
                              'University: ${qualification['university'] ?? 'N/A'}\n'
                              'Institution: ${qualification['institution'] ?? 'N/A'}\n'
                              'GPA: ${qualification['percentageOrGPA'] ?? 'N/A'}\n'
                              'Division: ${qualification['division'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            populateForm(qualification);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build Dropdown Method
  Widget buildDropdown(String label, List<dynamic> list, int? selectedValue,
      ValueChanged<int?> onChanged) {
    return DropdownButtonFormField<int>(
      value: list.any((item) => item['lookUpId'] == selectedValue)
          ? selectedValue
          : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: list.map((item) {
        return DropdownMenuItem<int>(
          value: item['lookUpId'],
          child: Text(item['meaning'], overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select a $label' : null,
      hint: Text('Select $label'),
    );
  }

  void populateForm(Map<String, dynamic> qualification) {
    _editingEmpQualId = qualification['empQualId'];
    selectedQualification = qualification['qualificationId'];
    _graduationDateController.text = qualification['graduationDate'] ?? '';
    selectedGraduationLevel = qualification['level'];
    selectedSpecialization = qualification['specializationId'];
    selectedUniversity = qualification['university'];
    _institutionController.text = qualification['institution'] ?? '';
    _institutionAddressController.text = qualification['institutionAddress'] ?? '';
    selectedMedium = qualification['medium'];
    _gpaController.text = qualification['percentageOrGPA']?.toString() ?? '0.0';
    selectedDivision = qualification['division'];
    setState(() {
      _isEditing = true;
    });
  }
}
