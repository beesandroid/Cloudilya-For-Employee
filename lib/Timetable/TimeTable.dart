import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';

class EmployeeTimeTableScreen extends StatefulWidget {
  const EmployeeTimeTableScreen({super.key});

  @override
  State<EmployeeTimeTableScreen> createState() =>
      _EmployeeTimeTableScreenState();
}

class _EmployeeTimeTableScreenState extends State<EmployeeTimeTableScreen> {
  Map<String, List<dynamic>> _timeTableData = {};
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _topics = [];
  String? _selectedTopic;

  @override
  void initState() {
    super.initState();
    _fetchTimeTable(date: _formatDate(_selectedDate)); // Fetch timetable for today
  }

  Future<void> _fetchTimeTable({required String date}) async {
    const url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeTimeTableDisplay';
    final requestBody = {
      "GrpCode": "beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "49",
      "ScheduleId": 0,
    };

    print(requestBody);
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> rawTimeTableData = data['employeeTimeTableDisplayList'] ?? [];
      final filteredData = rawTimeTableData.where((item) => item['date'] == date).toList();
      print(filteredData);

      setState(() {
        _timeTableData = {date: filteredData};
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Failed to load timetable');
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  Future<void> _callApiWithScheduleId(int scheduleId) async {
    const url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeTimeTableDisplay';
    final requestBody = {
      "GrpCode": "beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "49",
      "ScheduleId": scheduleId,
    };

    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestBody),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['employeeTimeTableDisplayList'] != null &&
          data['employeeTimeTableDisplayList'].isNotEmpty) {
        final timetableData = data['employeeTimeTableDisplayList'][0];
        _showTimeTableDialog(timetableData);
      } else {
        _showMessageDialog("No timetable data available for Schedule ID: $scheduleId");
      }
    } else {
      print('Failed to load details for ScheduleId: $scheduleId');
      _showMessageDialog("Failed to load details for Schedule ID: $scheduleId");
    }
  }
  Future<void> _updateTopic({
    required String employeeId,
    required String scheduleId,
    required String topicId,
  }) async {
    final url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeTopicUpdate';
    final requestBody = {
      "GrpCode": "BEESdev",
      "ColCode": "0001",
      "EmployeeId": employeeId,
      "TopicId": topicId,
      "ScheduleId": scheduleId
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'] ?? 'No message';

        // Show toast message
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Close the dialog

      } else {
        // Handle error
        Fluttertoast.showToast(
          msg: 'Failed to update topic',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      // Handle error
      Fluttertoast.showToast(
        msg: 'Error: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }



  Future<void> _fetchTopics({
    required String programId,
    required String branchId,
    required int semId,
    required int regulationId,
    required String courseId,
  }) async {
    final url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeTopicDropDown';
    final requestBody = {
      "GrpCode": "BEESdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "ProgramId":"1",
      "BranchId":"2",
      "SemId":1,
      "RegulationId":1123,
      "CourseId":"1466"
      // "ProgramId": programId,
      // "BranchId": branchId,
      // "SemId": semId,
      // "RegulationId": regulationId,
      // "CourseId": courseId
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        final List<dynamic> topics = data['topicDropDownForTimeTableList'];
        setState(() {
          _topics = topics.map((item) => {
            'id': item['topicId'],
            'name': item['topicName']
          }).toList();
        });
      } else {
        // Handle error
        print('Failed to load topics');
      }
    } catch (e) {
      // Handle error
      print('Error: $e');
    }
  }

  void _showTimeTableDialog(Map<String, dynamic> timetableData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Get required values from timetableData
        String programId = timetableData['programId']?.toString() ?? '1';
        String branchId = timetableData['branchId']?.toString() ?? '2';
        int semId = timetableData['semId'] ?? 1;
        int regulationId = timetableData['regulationId'] ?? 1123;
        String courseId = timetableData['courseId']?.toString() ?? '1466';
        String employeeId = timetableData['employeeId']?.toString() ?? '49';  // Assuming employeeId is available in timetableData
        String scheduleId = timetableData['scheduleId']?.toString() ?? '40057'; // Assuming scheduleId is available in timetableData

        return AlertDialog(
          title: Text('Timetable Details'),backgroundColor: Colors.white,
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // Fetch topics when the dialog is opened
              _fetchTopics(
                programId: programId,
                branchId: branchId,
                semId: semId,
                regulationId: regulationId,
                courseId: courseId,
              ).then((_) {
                setState(() {}); // Update the dialog state with fetched topics
              });

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('College: ${timetableData['collegeName'] ?? 'N/A'}'),
                    Text('Program: ${timetableData['programName'] ?? 'N/A'}'),
                    Text('Branch: ${timetableData['branchName'] ?? 'N/A'}'),
                    Text('Course: ${timetableData['courseName'] ?? 'N/A'}'),
                    Text('Semester: ${timetableData['semester'] ?? 'N/A'}'),
                    Text('Section: ${timetableData['sectionName'] ?? 'N/A'}'),
                    Text('Faculty: ${timetableData['facultyName'] ?? 'N/A'}'),
                    Text('Start Time: ${timetableData['startTime'] ?? 'N/A'}'),
                    Text('End Time: ${timetableData['endTime'] ?? 'N/A'}'),
                    Text('Attendance: ${timetableData['attendance'] == 1 ? 'Present' : 'Absent'}'),
                    Text('Class: ${timetableData['class'] ?? 'N/A'}'),
                    SizedBox(height: 20), // Space between content and dropdown
                    if (_topics.isNotEmpty)
                      Container(
                        width: double.infinity,
                        child:
                        DropdownButtonFormField<String>(
                          value: _selectedTopic,
                          hint: Text('Select Topic'),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedTopic = newValue;
                            });
                          },

                          items: _topics.map<DropdownMenuItem<String>>((topic) {
                            return DropdownMenuItem<String>(
                              value: topic['id'].toString(),
                              child: Text(topic['name']),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),


                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Save',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              onPressed: () {
                if (_selectedTopic != null) {
                  _updateTopic(
                    employeeId: employeeId,
                    scheduleId: scheduleId,
                    topicId: _selectedTopic!,
                  ).then((_) {
                    setState(() {}); // Update the dialog state with response message
                  });
                }
                }

            ),
            TextButton(
              child: Text('Close',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _showMessageDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Message'),backgroundColor: Colors.white,
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeTable() {
    return ListView.builder(
      itemCount: _timeTableData.keys.length,
      itemBuilder: (context, index) {
        final date = _timeTableData.keys.elementAt(index);
        final dayDataList = _timeTableData[date] ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Table(
                border: TableBorder.symmetric(
                  inside: BorderSide(color: Colors.black.withOpacity(0.2), width: 1),
                  outside: BorderSide.none,
                ),
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(4),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                    ),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Period',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Subject',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (int i = 1; i <= 10; i++)
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                      ),
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Period $i', style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        TableCell(
                          child: GestureDetector(
                            onTap: () {
                              final periodKey = 'period$i';
                              final periodData = dayDataList.isNotEmpty
                                  ? dayDataList.firstWhere((dayData) => dayData.containsKey(periodKey))[periodKey]
                                  : '';

                              if (periodData.isNotEmpty) {
                                final scheduleId = int.tryParse(
                                  periodData.split('*').last,
                                );
                                if (scheduleId != null) {
                                  _callApiWithScheduleId(scheduleId);
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                dayDataList.isNotEmpty &&
                                    dayDataList.any((dayData) => dayData.containsKey('period$i'))
                                    ? dayDataList.firstWhere((dayData) =>
                                    dayData.containsKey('period$i'))['period$i'] ??
                                    ''
                                    : '',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(0),
                child: TableCalendar(
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.purpleAccent,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(color: Colors.black),
                    weekendTextStyle: TextStyle(color: Colors.redAccent),
                    outsideTextStyle: TextStyle(color: Colors.grey),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.black),
                    weekendStyle: TextStyle(color: Colors.redAccent),
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(color: Colors.black, fontSize: 16),
                    formatButtonTextStyle: TextStyle(color: Colors.black),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                  ),
                  focusedDay: _selectedDate,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2025, 12, 31),
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _isLoading = true;
                      _fetchTimeTable(date: _formatDate(selectedDay));
                    });
                  },
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.black))
                    : _timeTableData.isNotEmpty
                    ? _buildTimeTable()
                    : Center(child: Text('No timetable data available', style: TextStyle(color: Colors.black))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
