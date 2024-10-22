import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Conference extends StatefulWidget {
  @override
  _ConferenceState createState() => _ConferenceState();
}

class _ConferenceState extends State<Conference> {
  List<dynamic> employeeConferences = [];
  List<dynamic> titleDropdownList = [];
  List<dynamic> nationalAndInternationalList = [];
  String? selectedTitle;
  String? selectedInternationalNational;
  String? selectedConferenceId;

  bool isLoading = true; // Added loading state

  final _formKey = GlobalKey<FormState>();

  final TextEditingController conferenceNameController =
  TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController organizingInstitutionController =
  TextEditingController();
  final TextEditingController placeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchConferenceData();
  }

  void fillFieldsForEdit(int index) {
    final conference = employeeConferences[index];
    setState(() {
      selectedConferenceId = conference['id']?.toString();
      selectedTitle = titleDropdownList
          .firstWhere(
            (item) =>
        item['titleId'].toString() ==
            conference['titleId'].toString(),
        orElse: () => null,
      )?['titleId']
          ?.toString();
      selectedInternationalNational = nationalAndInternationalList
          .firstWhere(
            (item) =>
        item['lookUpId'].toString() ==
            conference['internationalNational'].toString(),
        orElse: () => null,
      )?['lookUpId']
          ?.toString();

      conferenceNameController.text =
          conference['nameoftheconference'] ?? '';
      dateController.text = conference['date'] ?? '';
      organizingInstitutionController.text =
          conference['organizingInstitutions'] ?? '';
      placeController.text = conference['placeOfConference'] ?? '';
    });
  }

  Future<void> fetchConferenceData() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeePapersConferencesSave'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "GrpCode": "Beesdev",
          "ColCode": "0001",
          "CollegeId": "1",
          "EmployeeId": "17051",
          "Id": 0,
          "UserId": 1,
          "LoginIpAddress": "",
          "LoginSystemName": "",
          "Flag": "VIEW",
          "EmployeePapersConferencesSaveVariable": [
            {
              "Id": 0,
              "Nameoftheconference": "",
              "InternationalorNational": 0,
              "TitleId": 0,
              "Date": "",
              "OrganizingInstitutions": "",
              "PlaceoftheConference": ""
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        Fluttertoast.showToast(
          msg: data['message'] ?? 'Data fetched successfully',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        setState(() {
          employeeConferences = data['employeePapersConferencesSaveList'] ?? [];
          titleDropdownList = employeeConferences.isNotEmpty
              ? employeeConferences[0]['titleDropdownList'] ?? []
              : [];
          nationalAndInternationalList = employeeConferences.isNotEmpty
              ? employeeConferences[0]['nationalandInternationalList'] ?? []
              : [];
          isLoading = false; // Data has been fetched
        });
      } else {
        throw Exception('Failed to load conference data');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading on error
      });
      Fluttertoast.showToast(
        msg: 'Error fetching data: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> saveConferenceData({required String flag, String? id}) async {
    if (_formKey.currentState!.validate()) {
      final requestBody = {
        "GrpCode": "Beesdev",
        "ColCode": "0001",
        "CollegeId": "1",
        "EmployeeId": "17051",
        "Id": id != null ? int.parse(id) : 0,
        "UserId": 1,
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": flag,
        "EmployeePapersConferencesSaveVariable": [
          {
            "Id": id != null ? int.parse(id) : 0,
            "Nameoftheconference": conferenceNameController.text,
            "InternationalorNational":
            int.tryParse(selectedInternationalNational ?? '') ?? 0,
            "TitleId": int.tryParse(selectedTitle ?? '') ?? 0,
            "Date": dateController.text,
            "OrganizingInstitutions": organizingInstitutionController.text,
            "PlaceoftheConference": placeController.text
          }
        ]
      };
      print("Request Body: ${jsonEncode(requestBody)}");
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeePapersConferencesSave'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: responseBody['message'] ?? 'Operation successful',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0, // font size
        );
        fetchConferenceData(); // Refresh data
        clearFields();
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to save conference!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  void clearFields() {
    conferenceNameController.clear();
    dateController.clear();
    organizingInstitutionController.clear();
    placeController.clear();
    setState(() {
      selectedTitle = null;
      selectedInternationalNational = null;
      selectedConferenceId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Conference",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
        child: Column(
          children: [
            // Form to Add/Edit Conference
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.white,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedTitle,
                          hint: Text('Select Title'),
                          onChanged: (newValue) {
                            setState(() {
                              selectedTitle = newValue;
                            });
                          },
                          items: titleDropdownList
                              .map<DropdownMenuItem<String>>((item) {
                            return DropdownMenuItem<String>(
                              value: item['titleId']?.toString(),
                              child: Text(item['title'] ?? 'No Title'),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a title';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedInternationalNational,
                          hint: Text('Select National/International'),
                          onChanged: (newValue) {
                            setState(() {
                              selectedInternationalNational = newValue;
                            });
                          },
                          items: nationalAndInternationalList
                              .map<DropdownMenuItem<String>>((item) {
                            return DropdownMenuItem<String>(
                              value: item['lookUpId']?.toString(),
                              child: Text(item['meaning'] ?? 'No Meaning'),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an option';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: conferenceNameController,
                          decoration: InputDecoration(
                              labelText: 'Name of the Conference'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a conference name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: dateController,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            hintText: 'YYYY-MM-DD',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a date';
                            }
                            // You can add more date validation here if needed
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: organizingInstitutionController,
                          decoration: InputDecoration(
                              labelText: 'Organizing Institutions'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter organizing institutions';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: placeController,
                          decoration:
                          InputDecoration(labelText: 'Place of Conference'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the place of the conference';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          onPressed: () => saveConferenceData(
                              flag: selectedConferenceId != null
                                  ? "OVERWRITE"
                                  : "CREATE",
                              id: selectedConferenceId),
                          child: Text(
                            selectedConferenceId != null
                                ? 'Update Conference'
                                : 'Add Conference',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Conference List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Conference List Section
            Container(
              height: 400, // Adjust the height as needed
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : employeeConferences.isNotEmpty
                  ? ListView.builder(
                itemCount: employeeConferences.length,
                itemBuilder: (context, index) {
                  final conference = employeeConferences[index];
                  return Card(
                    color: Colors.white,
                    elevation: 4,
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        conference['nameoftheconference'] ?? 'No Name Provided',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          'Date: ${conference['date'] ?? 'N/A'}\n'
                              'Organized by: ${conference['organizingInstitutions'] ?? 'N/A'}\n'
                              'Location: ${conference['placeOfConference'] ?? 'N/A'}'),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          fillFieldsForEdit(index);
                        },
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Text(
                  "No conferences listed",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
