import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeFundedProjects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Beesdev",
        "ColCode": "0001",
        "CollegeId": "1",
        "UserId": 1,
        "EmployeeId": "49",
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
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayandSaveEmployeeFundedProjects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Beesdev",
        "ColCode": "0001",
        "CollegeId": "1",
        "UserId": 1,
        "EmployeeId": "49",
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
    if (_selectedProjectId == null) return;

    final requestBody = jsonEncode({
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "UserId": 1,
      "EmployeeId": "49",
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
          : ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return Card(color: Colors.white,

           margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(
                project['projectTittle'] ?? 'No Title',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editProject(project['projectTittleId']),
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
