import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Experience extends StatefulWidget {
  const Experience({super.key});

  @override
  State<Experience> createState() => _ExperienceState();
}

class _ExperienceState extends State<Experience> {
  List<dynamic> experienceList = [];

  @override
  void initState() {
    super.initState();
    fetchExperienceData();
  }

  // Fetch Employee Experience Data
  Future<void> fetchExperienceData() async {
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeExperience');
    final body =
    {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmpExpId": 0,
      "EmployeeId": "12",
      "StartDate": "",
      "EndDate": "",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "UserId": 1,
      "Flag": "VIEW",
      "EmployeeNumber":"EMP20240011",
      "DisplayandSaveEmployeeExperienceVariable": [
        { "EmpExpId": 0,
          "Organization": 0,
          "Industry": "",
          "Location": "",
          "DateFrom": "",
          "DateTo": "",
          "Designation": 0,
          "Medium": 0,
          "CertificateSubmitted": 0,
          "Certificate": 0,
          "ChooseFile": ""}
      ]
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      setState(() {
        experienceList =
        json.decode(response.body)['displayandSaveEmployeeExperienceList'];
      });
    } else {
      print('Failed to fetch data');
    }
  }

  // Add or Edit experience
  Future<void> saveExperience(String flag, dynamic experienceData) async {
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeExperience');
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmpExpId": experienceData['empExpId'] ?? 0,
      "EmployeeId": "13",
      "StartDate": experienceData['dateFrom'],
      "EndDate": experienceData['dateTo'],
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "UserId": 1,
      "Flag": flag,
      "EmployeeNumber":"EMP20240011",
      "DisplayandSaveEmployeeExperienceVariable": [experienceData]
    };

    // Print the request body
    print('Request Body:123 ${json.encode(body)}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);

      // Print the response body
      print('Response Body: ${response.body}');

      // Check the message in the response
      if (responseBody['message'] == 'Record is Successfully Saved') {
        fetchExperienceData();
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Experience successfully saved!')),
        );

        fetchExperienceData(); // Refresh list after save
      } else {
        // Handle unexpected response message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
              'Failed to save experience: ${responseBody['message']}')),
        );
      }
    } else {
      // Handle non-200 response codes
      print('Failed to save data. Status code: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data. Please try again.')),
      );
    }
  }

  // Delete experience
  // Future<void> deleteExperience(int empExpId) async {
  //   final url = Uri.parse(
  //       'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeExperience');
  //   final body = {
  //     "GrpCode": "Bees",
  //     "ColCode": "0001",
  //     "CollegeId": "1",
  //     "EmpExpId": empExpId,
  //     "EmployeeId": "13",
  //     "StartDate": "",
  //     "EndDate": "",
  //     "LoginIpAddress": "",
  //     "LoginSystemName": "",
  //     "UserId": 1,
  //     "Flag": "DELETE",
  //     "DisplayandSaveEmployeeExperienceVariable": [
  //       { "EmpExpId": 0,
  //         "Organization": 0,
  //         "Industry": "",
  //         "Location": "",
  //         "DateFrom": "",
  //         "DateTo": "",
  //         "Designation": 0,
  //         "Medium": 0,
  //         "CertificateSubmitted": 0,
  //         "Certificate": 0,
  //         "ChooseFile": ""}
  //     ]
  //   };
  //
  //   // Print the request body
  //   print('Request Body: ${json.encode(body)}');
  //
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode(body),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     print(response.body);
  //     fetchExperienceData(); // Refresh list after delete
  //   } else {
  //     print('Failed to delete data');
  //   }
  // }

  // Open dialog for adding or editing experience
  Future<void> openAddEditDialog([dynamic experience]) async {
    final organizationController = TextEditingController(
        text: experience?['organizationName'] ?? '');
    final industryController = TextEditingController(
        text: experience?['industry'] ?? '');
    final locationController = TextEditingController(
        text: experience?['location'] ?? '');
    final dateFromController = TextEditingController(
        text: experience?['dateFrom'] ?? '');
    final dateToController = TextEditingController(
        text: experience?['dateTo'] ?? '');
    final designationController = TextEditingController(
        text: experience?['designationName'] ?? '');
    final mediumController = TextEditingController(
        text: experience?['mediumName'] ?? '');
    final certificateController = TextEditingController(
        text: experience?['certificateName'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 10.0,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    experience == null ? 'Add Experience' : 'Edit Experience',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  _buildTextField(organizationController, 'Organization'),
                  _buildTextField(industryController, 'Industry'),
                  _buildTextField(locationController, 'Location'),
                  _buildTextField(dateFromController, 'From Date'),
                  _buildTextField(dateToController, 'To Date'),
                  _buildTextField(designationController, 'Designation'),
                  _buildTextField(mediumController, 'Medium'),
                  _buildTextField(certificateController, 'Certificate'),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueAccent,
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          final newExperience = {
                            'organizationName': organizationController.text,
                            'industry': industryController.text,
                            'location': locationController.text,
                            'dateFrom': dateFromController.text,
                            'dateTo': dateToController.text,
                            'designationName': designationController.text,
                            'mediumName': mediumController.text,
                            'certificateName': certificateController.text,
                            'empExpId': experience?['empExpId'] ?? 0,
                          };
                          saveExperience(
                            experience == null ? 'CREATE' : 'OVERWRITE',
                            newExperience,
                          ); // Save experience
                        },
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.black54, width: 1.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Experience', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2,color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.add, color: Colors.blueAccent),
        //     onPressed: () {
        //       openAddEditDialog(); // Open dialog for creating new experience
        //     },
        //   ),
        // ],
      ),
      body: Container(
        color: Colors.white,
        child: experienceList.isEmpty
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            strokeWidth: 3,
          ),
        )
            : ListView.builder(
          itemCount: experienceList.length,
          itemBuilder: (context, index) {
            final experience = experienceList[index];
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey[200]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 4,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Organization: ${experience['organizationName']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Industry: ${experience['industry']}',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                    Text('Location: ${experience['location']}',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                    Text('From: ${experience['dateFrom']}',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                    Text('To: ${experience['dateTo']}',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                    Text('Designation: ${experience['designationName']}',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                    Text('Medium: ${experience['mediumName']}',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                    Text('Certificate: ${experience['certificateName']}',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () {
                            openAddEditDialog(experience); // Open dialog for editing experience
                          },
                        ),
                        // Uncomment if delete functionality is needed
                        // IconButton(
                        //   icon: Icon(Icons.delete, color: Colors.redAccent),
                        //   onPressed: () {
                        //     deleteExperience(experience['empExpId']); // Delete experience
                        //   },
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Container(width: 170,
        child: FloatingActionButton(
          onPressed: () {
            openAddEditDialog(); // Open dialog for creating new experience
          },
          backgroundColor: Colors.blue,
          child: Text("Add Experience",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          tooltip: 'Add Experience',
        ),
      ),
    );
  }
}