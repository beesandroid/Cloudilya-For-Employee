import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Awards extends StatefulWidget {
  const Awards({super.key});

  @override
  State<Awards> createState() => _AwardsState();
}

class _AwardsState extends State<Awards> {
  List awards = [];
  List states = [];
  List awardTypes = [];
  List typesList = [];
  int? selectedCountryId;
  List countryList = [];
  final _formKey = GlobalKey<FormState>();
  bool isEdit = false;
  int? selectedStateId;
  int? selectedAwardTypeId;
  int? typeId;
  int? editingAwardId;

  // TextEditingControllers for form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController instituteController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController cashAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAwards();
    fetchAwardTypes();
    fetchTypes();
    fetchCountries();
  }

  Future<void> fetchAwardTypes() async {
    const url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/AwardTypeDropdown';
    final body = {"GrpCode": "Beesdev", "ColCode": "0001", "Flag": "AWARDTYPE"};

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['awardTypeDropdownList'] != null) {
        setState(() {
          awardTypes = List<dynamic>.from(data['awardTypeDropdownList'] ?? []);
        });
      } else {
        print('No award types found');
      }
    } else {
      print('Failed to load award types');
    }
  }

  Future<void> fetchTypes() async {
    const url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/AwardTypeDropdown';
    final body = {"GrpCode": "Beesdev", "ColCode": "0001", "Flag": "TYPE"};

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        typesList = data['typeDropdownList'];
      });
    } else {
      print('Failed to load types');
    }
  }

  // Fetch awards from the API
  Future<void> fetchAwards() async {
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

    const url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeAwards';
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "EmployeeId": employeeId,
      "AwardId": 0,
      "UserId": adminUserId,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "VIEW",
      "DisplayandSaveEmployeeAwardsVariable": [
        {
          "AwardId": 0,
          "NameOfTheAward": "",
          "AwardType": 0,
          "Country": 0,
          "State": 0,
          "InstituteName": "",
          "Category": "",
          "YearOfAward": 0,
          "Type": 0,
          "CashAmount": 0
        }
      ]
    };
    print(body);

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      final message = data['message'];

      if (data['displayandSaveEmployeeAwardsList'].isEmpty &&
          message != null &&
          message.isNotEmpty) {
        // Show SnackBar if message exists
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
        awards = data['displayandSaveEmployeeAwardsList'];
      });
    } else {
      // Handle error
      print('Failed to load awards');
    }
  }

  Future<void> fetchStates() async {
    const url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StateDropdownforAwards';
    final body = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "MasterLookUpId": selectedCountryId ?? 99,
      "Flag": "STATE"
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        states = data['stateDropdownforAwardsList'];
      });
    } else {
      print('Failed to load states');
    }
  }

  Future<void> createOrUpdateAward(String flag) async {
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
    const url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeAwards';
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "EmployeeId": employeeId,
      "AwardId": editingAwardId ?? 0,
      "UserId": adminUserId,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": flag,
      "DisplayandSaveEmployeeAwardsVariable": [
        {
          "AwardId": editingAwardId ?? 0,
          "NameOfTheAward": nameController.text,
          "AwardType": selectedAwardTypeId ?? 0,
          "Country": selectedCountryId ?? 0,
          "State": selectedStateId ?? 0,
          "InstituteName": instituteController.text,
          "Category": categoryController.text,
          "YearOfAward": int.tryParse(yearController.text) ?? 0,
          "Type": typeId ?? 0,
          "CashAmount": double.tryParse(cashAmountController.text) ?? 0.0,
        }
      ]
    };

    print(body);

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final message = data['message'];
      print(data);

      if (data['displayandSaveEmployeeAwardsList'].isEmpty &&
          message != null &&
          message.isNotEmpty) {
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
      print(response.body);
      await fetchAwards(); // Refresh the list
      clearForm(); // Clear form after saving
      setState(() {
        isEdit = false;
      });
    } else {
      // Handle error
      print('Failed to save award');
    }
  }

  Future<void> fetchCountries() async {
    const url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/CommonLookUpsDropDown';
    final body = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "Flag": 9,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        countryList = data['countryList'];
      });
    } else {
      print('Failed to load countries');
    }
  }

  // Populate form fields for editing
  Future<void> populateFields(Map<String, dynamic> award) async {
    nameController.text = award['nameOfTheAward'] ?? '';
    instituteController.text = award['instituteName'] ?? '';
    categoryController.text = award['category'] ?? '';
    yearController.text = award['yearOfAward']?.toString() ?? '';
    cashAmountController.text = award['cashAmount']?.toString() ?? '';

    selectedCountryId = award['country'];
    selectedStateId = award['state'];
    selectedAwardTypeId = award['awardType'];
    typeId = award['type'];
    editingAwardId = award['awardId'];

    await fetchStates(); // Ensure states are fetched before rebuilding

    setState(() {
      isEdit = true; // Set to edit mode
    });
  }

  // Clear form fields
  void clearForm() {
    nameController.clear();
    instituteController.clear();
    categoryController.clear();
    yearController.clear();
    cashAmountController.clear();
    selectedCountryId = null;
    selectedStateId = null;
    selectedAwardTypeId = null;
    typeId = null;
    editingAwardId = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Employee Awards',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // Add Edit Button
          if (isEdit)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEdit = true; // Set to edit mode
                });
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Form to Add/Edit Awards
              Card(
                color: Colors.white,
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Award Details',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                                labelText: 'Name of the Award'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: instituteController,
                            decoration: const InputDecoration(
                                labelText: 'Institute Name'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField<int>(
                            value: selectedAwardTypeId, // Set the value
                            decoration:
                                const InputDecoration(labelText: 'Award Type'),
                            items: awardTypes
                                .map<DropdownMenuItem<int>>((awardType) {
                              return DropdownMenuItem<int>(
                                value: awardType['lookUpId'],
                                child: Text(awardType['meaning']),
                              );
                            }).toList(),
                            onChanged: (int? value) {
                              setState(() {
                                selectedAwardTypeId = value;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: yearController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Year of Award'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: cashAmountController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Cash Amount'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField<int>(
                            value: selectedCountryId,
                            decoration:
                                const InputDecoration(labelText: 'Country'),
                            items: countryList.map((country) {
                              return DropdownMenuItem<int>(
                                value: country['lookUpId'],
                                child: Text(country['meaning']),
                              );
                            }).toList(),
                            onChanged: (int? value) async {
                              setState(() {
                                selectedCountryId = value;
                                selectedStateId =
                                    null; // Reset state when country changes
                              });
                              await fetchStates(); // Fetch states for the selected country
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField<int>(
                            value: selectedStateId,
                            decoration:
                                const InputDecoration(labelText: 'State'),
                            items: states.map((state) {
                              return DropdownMenuItem<int>(
                                value: state['lookUpId'],
                                child: Text(state['meaning']),
                              );
                            }).toList(),
                            onChanged: (int? value) {
                              setState(() {
                                selectedStateId = value;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField<int>(
                            value: typeId,
                            onChanged: (int? value) {
                              setState(() {
                                typeId = value;
                              });
                            },
                            items: typesList.map((type) {
                              return DropdownMenuItem<int>(
                                value: type['lookUpId'],
                                child: Text(type['meaning']),
                              );
                            }).toList(),
                            decoration:
                                const InputDecoration(labelText: 'Type'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // If in edit mode, call with 'OVERWRITE' flag
                                    // Otherwise, call with 'CREATE' flag
                                    createOrUpdateAward(
                                        isEdit ? 'OVERWRITE' : 'CREATE');
                                  }
                                },
                                child: Text(isEdit ? 'Edit Award' : 'Add Award',
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Display List of Awards
              const Text(
                'Awards List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: awards.length,
                itemBuilder: (context, index) {
                  final award = awards[index];
                  return Card(
                    color: Colors.white,
                    elevation: 5,
                    child: ListTile(
                      title: Text(
                        award['nameOfTheAward'] ?? 'No Name',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Institute: ${award['instituteName'] ?? 'Unknown Institute'}'),

                          Text(
                              'Year: ${award['yearOfAward']?.toString() ?? 'Unknown Year'}'),
                          Text(
                              'Cash Amount: ${award['cashAmount']?.toString() ?? 'N/A'}'),
                          Text(
                              'Country: ${award['countryName'] ?? 'Unknown Country'}'),
                          Text(
                              'State: ${award['stateName'] ?? 'Unknown State'}'),
                          Text(
                              'Status: ${award['status'] ?? 'Unknown State'}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final String status = award['status']?.toString() ?? '';

                          if (status.toLowerCase() == 'pending') {
                            // Show a toast message if the award status is pending
                            Fluttertoast.showToast(
                              msg: "Changes sent for approval cannot be edited now",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          } else {
                            // Allow editing if the status is not pending
                            await populateFields(award);
                          }
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
    );
  }
}
