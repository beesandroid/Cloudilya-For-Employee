import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Awards extends StatefulWidget {
  const Awards({super.key});

  @override
  State<Awards> createState() => _AwardsState();
}

class _AwardsState extends State<Awards> {
  List awards = [];
  List states = [];
  List countryList = [];// List to store states
  final _formKey = GlobalKey<FormState>();
  bool isEdit = false; // To track if we're editing an award
  int? selectedStateId; // To store the selected state ID

  // TextEditingControllers for form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController instituteController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController cashAmountController = TextEditingController();
  TextEditingController countryController = TextEditingController(); // New
  TextEditingController stateController = TextEditingController(); // New
  int? editingAwardId; // To track the AwardId of the award being edited

  @override
  void initState() {
    super.initState();
    fetchStates();
    fetchAwards();
    fetchCountries();
  }

  // Fetch awards from the API
  Future<void> fetchAwards() async {
    const url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeAwards';
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "13",
      "AwardId": 159,
      "UserId": 1,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "VIEW",
      "DisplayandSaveEmployeeAwardsVariable": [{
        "AwardId": 159,
        "NameOfTheAward": "sdsd",
        "AwardType": 206,
        "Country": 99,
        "State": 0,
        "InstituteName": "Satya",
        "Category": "dance",
        "YearOfAward": 2020,
        "Type": 209,
        "CashAmount": 15000.0
      }]
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final message = data['message'];

      if (data['displayandSaveEmployeeAwardsList'].isEmpty && message != null && message.isNotEmpty) {
        // Show SnackBar if message exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
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
    const url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StateDropdownforAwards';
    final body = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "MasterLookUpId": 99,
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


  // Create or Update award based on flag
  Future<void> createOrUpdateAward(String flag) async {
    const url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeAwards';
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "13",
      "AwardId": editingAwardId ?? 159,
      "UserId": 1,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": flag,
      "DisplayandSaveEmployeeAwardsVariable": [{
        "AwardId": editingAwardId ?? 159,
        "NameOfTheAward": nameController.text,
        "AwardType": 206,
        "Country": int.parse(countryController.text), // New
        "State": selectedStateId ?? 0, // State ID from the dropdown
        "InstituteName": instituteController.text,
        "Category": categoryController.text,
        "YearOfAward": int.parse(yearController.text),
        "Type": 209,
        "CashAmount": double.parse(cashAmountController.text),
      }]
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
      if (data['displayandSaveEmployeeAwardsList'].isEmpty && message != null && message.isNotEmpty) {
        // Show SnackBar if message exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      print(response.body);
      fetchAwards(); // Refresh the list
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
    const url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/CommonLookUpsDropDown';
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
  void populateFields(Map<String, dynamic> award) {
    nameController.text = award['nameOfTheAward'] ?? '';
    instituteController.text = award['instituteName'] ?? '';
    categoryController.text = award['category'] ?? '';
    yearController.text = award['yearOfAward']?.toString() ?? '';
    cashAmountController.text = award['cashAmount']?.toString() ?? '';
    countryController.text = award['country']?.toString() ?? '';
    selectedStateId = award['state']; // Set the selected state
    editingAwardId = award['awardId'];
    setState(() {
      isEdit = true;
    });
  }

  // Clear form fields
  void clearForm() {
    nameController.clear();
    instituteController.clear();
    categoryController.clear();
    yearController.clear();
    cashAmountController.clear();
    countryController.clear();
    selectedStateId = null; // Clear selected state
    editingAwardId = null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Awards',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Form to Add/Edit Awards
              Card(
                color: Colors.white,
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Award Details',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(labelText: 'Name of the Award'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: instituteController,
                            decoration: const InputDecoration(labelText: 'Institute Name'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: categoryController,
                            decoration: const InputDecoration(labelText: 'Category'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: yearController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Year of Award'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: cashAmountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Cash Amount'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField(
                            decoration: const InputDecoration(labelText: 'Country'),
                            items: countryList.map<DropdownMenuItem<int>>((country) {
                              return DropdownMenuItem<int>(
                                value: country['lookUpId'],
                                child: Text(country['meaning']),
                              );
                            }).toList(),
                            onChanged: (int? selectedCountryId) {
                              if (selectedCountryId != null) {
                                countryController.text = selectedCountryId.toString();
                                fetchStates(); // Fetch states for selected country
                              }
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField<int>(
                            value: selectedStateId,
                            onChanged: (value) {
                              setState(() {
                                selectedStateId = value;
                              });
                            },
                            items: states.map((state) {
                              return DropdownMenuItem<int>(
                                value: state['lookUpId'],
                                child: Text(state['meaning']),
                              );
                            }).toList(),
                            decoration: const InputDecoration(labelText: 'State'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    createOrUpdateAward(isEdit ? 'OVERWRITE' : 'CREATE');
                                  }
                                },
                                child: Text(isEdit ? 'Update Award' : 'Add Award',style: TextStyle(color: Colors.white),),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: clearForm,
                                child: const Text('Clear Form',style: TextStyle(color: Colors.white),),
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
                  return Card(color: Colors.white,
                    elevation: 5,
                    child: ListTile(
                      title: Text(award['nameOfTheAward'] ?? 'No Name',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Institute: ${award['instituteName'] ?? ''}'),
                          Text('Category: ${award['category'] ?? ''}'),
                          Text('Year: ${award['yearOfAward'] ?? ''}'),
                          Text('Cash Amount: ${award['cashAmount'] ?? ''}'),
                          Text('Country: ${award['countryName'] ?? ''}'), // New
                          Text('State: ${award['stateName'] ?? ''}'), // New
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          populateFields(award);
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
