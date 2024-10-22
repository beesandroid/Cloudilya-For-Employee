import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TimeSheetPage extends StatefulWidget {
  const TimeSheetPage({super.key});

  @override
  State<TimeSheetPage> createState() => _TimeSheetPageState();
}

class _TimeSheetPageState extends State<TimeSheetPage> {
  DateTime? fromDate;
  DateTime? toDate;
  List<dynamic> timeSheetData = [];
  bool isLoading = false;

  // Form fields for adding/updating timesheet
  final _formKey = GlobalKey<FormState>();
  TextEditingController taskIdController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  int? detailId; // For update purposes

  @override
  void initState() {
    super.initState();
    fetchTimeSheetData();
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        // Format date to 'yyyy-MM-dd' and set to controller
        dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  Future<void> fetchTimeSheetData() async {
    setState(() {
      isLoading = true;
    });

    String fromDateStr =
        fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : "";
    String toDateStr =
        toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : "";

    var response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/TimeSheetDisplayForEmployee'),
      body: json.encode({
        "GrpCode": "BEESDEV",
        "ColCode": "0001",
        "CollegeId": "1",
        "EmployeeId": 9,
        "FromDate": fromDateStr,
        "ToDate": toDateStr
      }),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      setState(() {
        timeSheetData =
            json.decode(response.body)['timeSheetDisplayForEmployeeList'];
      });
    } else {
      print('Failed to fetch data');
    }

    setState(() {
      isLoading = false;
    });
  }



  Future<void> addOrUpdateTimeSheet({String flag = "CREATE"}) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Validate date format before parsing
        if (dateController.text.isEmpty) {
          throw FormatException("Date cannot be empty");
        }

        // Parse the date
        DateTime date = DateTime.parse(dateController.text);

        // Use DateFormat to parse time in 12-hour format
        DateFormat timeFormat = DateFormat.jm(); // 'jm' stands for 12-hour time

        DateTime startTime = timeFormat.parse(startTimeController.text); // Convert "09:30 PM" to 24-hour format
        DateTime endTime = timeFormat.parse(endTimeController.text); // Convert "09:30 PM" to 24-hour format

        // Set DetailId, TimeSheetId, TaskId to 0 if the flag is "CREATE"
        int detailIdValue = (flag == "CREATE") ? 0 : detailId ?? 23396;
        int timeSheetIdValue = (flag == "CREATE") ? 0 : 1256;
        int taskIdValue = (flag == "CREATE") ? 0 : int.parse(taskIdController.text);

        var requestBody = {
          "GrpCode": "BEESDEV",
          "ColCode": "0001",
          "CollegeId": "1",
          "TimeSheetId": timeSheetIdValue, // Conditional value based on flag
          "EmployeeId": 9,
          "Date": DateFormat('yyyy-MM-dd').format(date),
          "DetailId": detailIdValue, // Conditional value based on flag
          "UserId": 1,
          "LoginIpAddress": "",
          "LoginSystemName": "",
          "Flag": flag,
          "SaveEmployeeTimeSheetVariable": [
            {
              "DetailId": detailIdValue, // Conditional value based on flag
              "TimeSheetId": timeSheetIdValue, // Conditional value based on flag
              "TaskId": taskIdValue, // Conditional value based on flag
              "Date": DateFormat('yyyy-MM-dd').format(date),
              "StartTime": DateFormat('HH:mm').format(startTime), // Convert to 24-hour format
              "EndTime": DateFormat('HH:mm').format(endTime), // Convert to 24-hour format
              "Hours": endTime.difference(startTime).inHours, // Calculate the hours correctly
              "Description": descriptionController.text,
              "Status": 0
            }
          ]
        };

        print(requestBody);

        var response = await http.post(
          Uri.parse(
              'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveEmployeeTimeSheetSummary'),
          body: json.encode(requestBody),
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode == 200) {
          print(response.body);
          final responseBody = jsonDecode(response.body);

          // Check if the message key is present
          if (responseBody.containsKey('message')) {
            fetchTimeSheetData();
            // Show Snackbar with the message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseBody['message']),
                duration: Duration(seconds: 4),
              ),
            );
          }
          Navigator.of(context).pop(); // Close the dialog
          fetchTimeSheetData(); // Refresh data
        } else {
          print('Failed to save data');
        }
      } catch (e) {
        // Handle any exceptions, including FormatException
        print('Error: $e');
        // Optionally show a dialog to inform the user
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Please enter a valid date format (YYYY-MM-DD)"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> pickDateRange() async {
    DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dateRange != null) {
      setState(() {
        fromDate = dateRange.start;
        toDate = dateRange.end;
      });
      fetchTimeSheetData();
    }
  }

  void showAddTimeSheetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Time Sheet"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextField(
                  controller: dateController,
                  readOnly: true, // Prevent user from typing manually
                  onTap: () => selectDate(context), // Open date picker on tap
                  decoration: InputDecoration(
                    labelText: "Select Date",
                    hintText: "YYYY-MM-DD",
                  ),
                ),
                TextFormField(
                  controller: startTimeController,
                  decoration:
                      InputDecoration(labelText: "Start Time (HH:MM AM/PM)"),
                  validator: (value) =>
                      value!.isEmpty ? "Enter start time" : null,
                ),
                TextFormField(
                  controller: endTimeController,
                  decoration:
                      InputDecoration(labelText: "End Time (HH:MM AM/PM)"),
                  validator: (value) =>
                      value!.isEmpty ? "Enter end time" : null,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: "Description"),
                  validator: (value) =>
                      value!.isEmpty ? "Enter a description" : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                addOrUpdateTimeSheet();
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
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
        title: const Text(
          'Time Sheet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: pickDateRange,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : timeSheetData.isEmpty
              ? const Center(child: Text("No data available"))
              : ListView.builder(
                  itemCount: timeSheetData.length,
                  itemBuilder: (context, index) {
                    var timeSheet = timeSheetData[index];
                    return Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    color: Colors.blueAccent),
                                SizedBox(width: 8),
                                Text(
                                  timeSheet['period']?.toString() ?? '',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    // Call the edit function
                                    showEditTimeSheetDialog(timeSheet);
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.assignment_turned_in,
                                    color: Colors.green),
                                SizedBox(width: 8),
                                Text("Status: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54)),
                                Text(timeSheet['statusName']?.toString() ?? '',
                                    style: TextStyle(color: Colors.black87)),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: Colors.redAccent),
                                SizedBox(width: 8),
                                Text("Work Location: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54)),
                                Expanded(
                                  child: Text(
                                    timeSheet['workLocation']?.toString() ?? '',
                                    style: TextStyle(color: Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    color: Colors.orange),
                                SizedBox(width: 8),
                                Text("Date: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54)),
                                Text(timeSheet['date']?.toString() ?? '',
                                    style: TextStyle(color: Colors.black87)),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.timeline,
                                    color: Colors.purpleAccent),
                                SizedBox(width: 8),
                                Text("Period: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54)),
                                Text(timeSheet['period']?.toString() ?? '',
                                    style: TextStyle(color: Colors.black87)),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.description, color: Colors.blueGrey),
                                SizedBox(width: 8),
                                Text("Description: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54)),
                                Expanded(
                                  child: Text(
                                    timeSheet['description']?.toString() ?? '',
                                    style: TextStyle(color: Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: showAddTimeSheetDialog,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

// Method to show the edit dialog with existing data
  void showEditTimeSheetDialog(dynamic timeSheet) {
    // Populate the form with existing values for editing
    taskIdController.text = timeSheet['taskId'].toString();
    dateController.text = timeSheet['date'].toString();
    startTimeController.text = timeSheet['startTime'].toString();
    endTimeController.text = timeSheet['endTime'].toString();
    descriptionController.text = timeSheet['description'].toString();
    detailId = timeSheet['detailId'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Time Sheet"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: taskIdController,
                  decoration: InputDecoration(labelText: "Task ID"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value!.isEmpty ? "Enter a valid Task ID" : null,
                ),
                TextField(
                  controller: dateController,
                  readOnly: true, // Prevent user from typing manually
                  onTap: () => selectDate(context), // Open date picker on tap
                  decoration: InputDecoration(
                    labelText: "Select Date",
                    hintText: "YYYY-MM-DD",
                  ),
                ),
                TextFormField(
                  controller: startTimeController,
                  decoration:
                  InputDecoration(labelText: "Start Time (HH:MM AM/PM)"),
                  validator: (value) =>
                  value!.isEmpty ? "Enter start time" : null,
                ),
                TextFormField(
                  controller: endTimeController,
                  decoration:
                  InputDecoration(labelText: "End Time (HH:MM AM/PM)"),
                  validator: (value) =>
                  value!.isEmpty ? "Enter end time" : null,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: "Description"),
                  validator: (value) =>
                  value!.isEmpty ? "Enter a description" : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                addOrUpdateTimeSheet(flag: "UPDATE"); // Update flag
              },
              child: Text("Update"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

}
