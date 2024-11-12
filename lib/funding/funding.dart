import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Funding extends StatefulWidget {
  const Funding({super.key});

  @override
  State<Funding> createState() => _FundingState();
}

class _FundingState extends State<Funding> {
  List<dynamic> projects = [];
  bool isLoading = true;

  // TextEditingControllers for CRUD operations
  final TextEditingController _projectTitleController = TextEditingController();
  final TextEditingController _projectDurationController = TextEditingController();
  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();
  final TextEditingController _fundingAgencyNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _amountReceivedController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _taskHandledController = TextEditingController();
  final TextEditingController _helpingTeamController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  int? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
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


    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeFundedProjects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Beesdev",
        "ColCode": colCode,
        "CollegeId": collegeId,
        "UserId": adminUserId,
        "EmployeeId": employeeId,
        "ProjectTittleId": 0,
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "VIEW",
        "DisplayandSaveEmployeeFundedProjectsVariable": [{
          "ProjectTittleId": 0,
          "ProjectTittle": "",
          "ProjectDuration": "",
          "DateFrom": "",
          "DateTo": "",
          "FundingAgencyName": "",
          "Location": "",
          "Status": 0,
          "AmountReceived": 0,
          "Role": "",
          "Taskhandled": "",
          "HelpingTeam": "",
          "Department": 0
        }]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);


      setState(() {
        projects = data['displayandSaveEmployeeFundedProjectsList'] ?? [];
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> _addProject() async {
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
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeFundedProjects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Beesdev",
        "ColCode": colCode,
        "CollegeId": collegeId,
        "UserId": adminUserId,
        "EmployeeId": employeeId,
        "ProjectTittleId": 0,
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "CREATE",
        "DisplayandSaveEmployeeFundedProjectsVariable": [{
          "ProjectTittle": _projectTitleController.text,
          "ProjectDuration": _projectDurationController.text,
          "DateFrom": _dateFromController.text,
          "DateTo": _dateToController.text,
          "FundingAgencyName": _fundingAgencyNameController.text,
          "Location": _locationController.text,
          "AmountReceived": double.tryParse(_amountReceivedController.text) ?? 0,
          "Role": _roleController.text,
          "Taskhandled": _taskHandledController.text,
          "HelpingTeam": _helpingTeamController.text,
          "Department": int.tryParse(_departmentController.text) ?? 0
        }]
      }),
    );

    if (response.statusCode == 200) {
      _fetchProjects();
      final responseBody = jsonDecode(response.body);

      Fluttertoast.showToast(
        msg: responseBody['message'],
        toastLength: Toast.LENGTH_LONG, // or Toast.LENGTH_SHORT
        gravity: ToastGravity.BOTTOM, // can be TOP, CENTER, or BOTTOM
        timeInSecForIosWeb: 1, // duration for iOS Web
        backgroundColor: Colors.black, // background color of the toast
        textColor: Colors.white, // text color of the toast
        fontSize: 16.0, // font size
      );
      print(response.body);
    } else {

      // Handle error
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Add Project'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_projectTitleController, 'Project Title'),

                _buildTextField(_dateFromController, 'Date From'),
                _buildTextField(_dateToController, 'Date To'),
                _buildTextField(_fundingAgencyNameController, 'Funding Agency'),
                _buildTextField(_locationController, 'Location'),
                _buildTextField(_amountReceivedController, 'Amount Received'),
                _buildTextField(_roleController, 'Role'),
                _buildTextField(_taskHandledController, 'Task Handled'),
                _buildTextField(_helpingTeamController, 'Helping Team'),
                _buildTextField(_departmentController, 'Department'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _addProject();
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _editProject(int projectId) async {
    final project = projects.firstWhere((p) => p['projectTittleId'] == projectId);

    _projectTitleController.text = project['projectTittle'] ?? '';
    _projectDurationController.text = project['projectDuration'] ?? '';
    _dateFromController.text = project['dateFrom'] ?? '';
    _dateToController.text = project['dateTo'] ?? '';
    _fundingAgencyNameController.text = project['fundingAgencyName'] ?? '';
    _locationController.text = project['location'] ?? '';
    _amountReceivedController.text = project['amountReceived']?.toString() ?? '';
    _roleController.text = project['role'] ?? '';
    _taskHandledController.text = project['taskhandled'] ?? '';
    _helpingTeamController.text = project['helpingTeam'] ?? '';
    _departmentController.text = project['department']?.toString() ?? '';

    _selectedProjectId = projectId;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(backgroundColor: Colors.white,
          title: Text('Edit Project'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_projectTitleController, 'Project Title'),
                _buildTextField(_projectDurationController, 'Duration'),
                _buildTextField(_dateFromController, 'Date From'),
                _buildTextField(_dateToController, 'Date To'),
                _buildTextField(_fundingAgencyNameController, 'Funding Agency'),
                _buildTextField(_locationController, 'Location'),
                _buildTextField(_amountReceivedController, 'Amount Received'),
                _buildTextField(_roleController, 'Role'),
                _buildTextField(_taskHandledController, 'Task Handled'),
                _buildTextField(_helpingTeamController, 'Helping Team'),
                _buildTextField(_departmentController, 'Department'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _updateProject();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProject() async {
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
    if (_selectedProjectId == null) return;

    final requestBody = jsonEncode({
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "UserId": adminUserId,
      "EmployeeId": employeeId,
      "ProjectTittleId": _selectedProjectId,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "OVERWRITE",
      "DisplayandSaveEmployeeFundedProjectsVariable": [{
        "ProjectTittleId": _selectedProjectId,
        "ProjectTittle": _projectTitleController.text,
        "ProjectDuration": _projectDurationController.text,
        "DateFrom": _dateFromController.text,
        "DateTo": _dateToController.text,
        "FundingAgencyName": _fundingAgencyNameController.text,
        "Location": _locationController.text,
        "AmountReceived": double.tryParse(_amountReceivedController.text) ?? 0,
        "Role": _roleController.text,
        "Taskhandled": _taskHandledController.text,
        "HelpingTeam": _helpingTeamController.text,
        "Department": int.tryParse(_departmentController.text) ?? 0
      }]
    });

    print('Request Body: $requestBody'); // Print the request body

    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeFundedProjects'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      Fluttertoast.showToast(
        msg: responseBody['message'],
        toastLength: Toast.LENGTH_LONG, // or Toast.LENGTH_SHORT
        gravity: ToastGravity.BOTTOM, // can be TOP, CENTER, or BOTTOM
        timeInSecForIosWeb: 1, // duration for iOS Web
        backgroundColor: Colors.black, // background color of the toast
        textColor: Colors.white, // text color of the toast
        fontSize: 16.0, // font size
      );
      _fetchProjects();
    } else {
      print('Error: ${response.body}'); // Handle error
    }
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

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
        title: Text('Employee Funded Projects',style: TextStyle(color: Colors.white),),
        elevation: 10,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          :
      ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];

          return GestureDetector(
            onTap: () {
              // Handle card tap if needed
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20), // Smooth corner radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                    offset: const Offset(0, 6), // Deep shadow for the "crazy" effect
                  ),
                ],
              ),
              child: Card(
                color: Colors.transparent, // Use the gradient background
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  title: Text(
                    project['projectTittle'] ?? 'No Title',
                    style: GoogleFonts.poppins(
                      fontSize: 22, // Larger for better readability
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildInfoRow('Date From', project['dateFrom']),
                      _buildInfoRow('Date To', project['dateTo']),
                      _buildInfoRow('Funding Agency', project['fundingAgencyName']),
                      _buildInfoRow('Location', project['location']),
                      _buildInfoRow('Amount Received', project['amountReceived']),
                      _buildInfoRow('Role', project['role']),
                      _buildInfoRow('Task Handled', project['taskhandled']),
                      _buildInfoRow('Helping Team', project['helpingTeam']),
                      _buildInfoRow('Department Name', project['departmentName']),
                      _buildInfoRow('Approve Status', project['approveStatus']),
                      _buildInfoRow('Common Date', project['commonDate']),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, color: Colors.blueAccent, size: 28),
                    onPressed: () {
                      // Check if the approve status is "pending" or "Pending"
                      final String status = project['approveStatus']?.toString() ?? '';

                      if (status.toLowerCase() == 'pending') {
                        // Show a toast message if the status is pending
                        Fluttertoast.showToast(
                          msg: "Changes sent for approval cannot be edited now",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else {
                        // Allow editing if the status is not pending
                        _editProject(project['projectTittleId']);
                      }
                    },
                    splashRadius: 25, // Larger splash for interaction effect
                    tooltip: "Edit Project",
                  ),

                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Container(width: 180,
        child: FloatingActionButton(
          onPressed: () {
            _showAddDialog();
            // Show create form
          },
          backgroundColor: Colors.blue,
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Add projects",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              SizedBox(width: 20,),
              Icon(CupertinoIcons.add,color: Colors.white,)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value.toString(), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
