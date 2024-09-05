import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';

class EmployeeTimeTableScreen extends StatefulWidget {
  const EmployeeTimeTableScreen({super.key});

  @override
  State<EmployeeTimeTableScreen> createState() => _EmployeeTimeTableScreenState();
}

class _EmployeeTimeTableScreenState extends State<EmployeeTimeTableScreen> {
  Map<String, List<dynamic>> _timeTableData = {};
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchTimeTable(date: _formatDate(_selectedDate)); // Fetch timetable for today
  }

  Future<void> _fetchTimeTable({required String date}) async {
    const url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeTimeTableDisplay';
    final requestBody = {
      "GrpCode": "bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "2",
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
      print(data);
      final List<dynamic> rawTimeTableData = data['employeeTimeTableDisplayList'] ?? [];
      final filteredData = rawTimeTableData.where((item) => item['date'] == date).toList();

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
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              dayDataList.isNotEmpty && dayDataList.any((dayData) => dayData.containsKey('period$i'))
                                  ? dayDataList.firstWhere((dayData) => dayData.containsKey('period$i'))['period$i'] ?? ''
                                  : '',
                              style: TextStyle(color: Colors.black),
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
