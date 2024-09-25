import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmployeePapersConferencesScreen extends StatefulWidget {
  @override
  _EmployeePapersConferencesScreenState createState() => _EmployeePapersConferencesScreenState();
}

class _EmployeePapersConferencesScreenState extends State<EmployeePapersConferencesScreen> {
  List<dynamic> employeePapersConferencesSaveList = [];
  bool isLoading = true;

  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController institutionController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  bool isInternational = false; // Checkbox for International/National

  int? selectedConferenceId; // For tracking which conference is being edited

  @override
  void initState() {
    super.initState();
    fetchEmployeePapersConferencesSave('VIEW');
  }

  // API call function
  Future<void> fetchEmployeePapersConferencesSave(String flag) async {
    setState(() {
      isLoading = true;
    });

    final url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeePapersConferencesSave';
    final body = jsonEncode({
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "49",
      "Id": selectedConferenceId ?? 0,
      "UserId": 1,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": flag,
      "EmployeePapersConferencesSaveVariable": [
        {
          "Id": selectedConferenceId ?? 0,
          "Nameoftheconference": nameController.text,
          "InternationalorNational": isInternational ? 1 : 0,
          "TitleId": 0,
          "Date": dateController.text,
          "OrganizingInstitutions": institutionController.text,
          "PlaceoftheConference": placeController.text
        }
      ]
    });
    print(body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        final responseBody = jsonDecode(response.body);

        // Check if the message key is present
        if (responseBody.containsKey('message')) {
          // Show Snackbar with the message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseBody['message']),
              duration: Duration(seconds: 4),
            ),
          );
        }
        setState(() {
          employeePapersConferencesSaveList = responseData['employeePapersConferencesSaveList'];
          isLoading = false;
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

  // Function to handle CRUD operations
  void performSave() {
    fetchEmployeePapersConferencesSave(selectedConferenceId == null ? 'CREATE' : 'OVERWRITE').then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Conference ${selectedConferenceId == null ? 'created' : 'updated'} successfully!'),
      ));
      clearFields(); // Clear fields after saving
    });
  }

  // Function to clear input fields for adding a new conference
  void addNewConference() {
    setState(() {
      clearFields();
      selectedConferenceId = null;
    });
  }

  // Function to populate the fields for editing
  void editConference(int id, String name, String institution, String place, String date, bool international) {
    setState(() {
      selectedConferenceId = id;
      nameController.text = name;
      institutionController.text = institution;
      placeController.text = place;
      dateController.text = date;
      isInternational = international;
    });
  }

  // Clear the text fields
  void clearFields() {
    nameController.clear();
    institutionController.clear();
    placeController.clear();
    dateController.clear();
    isInternational = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AnimatedCard for inputs
              Card(color: Colors.white,

                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Conference Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.event_note),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: institutionController,
                        decoration: InputDecoration(
                          labelText: 'Organizing Institution',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: placeController,
                        decoration: InputDecoration(
                          labelText: 'Place of Conference',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'Date (YYYY-MM-DD)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Text("International Conference"),
                          Checkbox(
                            value: isInternational,
                            onChanged: (bool? value) {
                              setState(() {
                                isInternational = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Save and Add New Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: performSave,
                    icon: Icon(Icons.save,color: Colors.white),
                    label: Text('Save',style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: addNewConference,
                    icon: Icon(Icons.add,color: Colors.white,),
                    label: Text('Add New',style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              Text(
                'Conference List:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: employeePapersConferencesSaveList.length,
                itemBuilder: (context, index) {
                  var conference = employeePapersConferencesSaveList[index];
                  return
                    Card(color: Colors.white,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.grey.withOpacity(0.4),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conference['nameoftheconference'] ?? 'No Conference Name',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.blueAccent),
                                SizedBox(width: 8),
                                Text(
                                  'Date: ${conference['date']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.person, size: 16, color: Colors.orangeAccent),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Name: ${conference['name']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.business, size: 16, color: Colors.green),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Organizing Institutions: ${conference['organizingInstitutions']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Place: ${conference['placeOfConference']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.check_circle, size: 16, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Status: ${conference['status']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: Icon(Icons.edit, size: 16, color: Colors.white),
                                label: Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  editConference(
                                    conference['id'],
                                    conference['nameoftheconference'] ?? '',
                                    conference['organizingInstitutions'] ?? '',
                                    conference['placeoftheconference'] ?? '',
                                    conference['date'] ?? '',
                                    conference['internationalorNational'] == 1,
                                  );
                                },
                              ),
                            ),
                          ],
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

void main() => runApp(MaterialApp(home: EmployeePapersConferencesScreen()));
