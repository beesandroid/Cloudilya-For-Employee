import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Approvals extends StatefulWidget {
  const Approvals({super.key});

  @override
  State<Approvals> createState() => _ApprovalsState();
}

class _ApprovalsState extends State<Approvals> {
  late Future<List<dynamic>> _approvals;

  final TextEditingController _descriptionController = TextEditingController();
  List<String> _interfaceNames = []; // List to store unique interface names
  String? _selectedInterface; // The currently selected interface filter
  DateTime? _selectedStartDate; // Selected start date for filtering
  DateTime? _selectedEndDate; // Selected end date for filtering

  @override
  void initState() {
    super.initState();
    _approvals = _fetchApprovals();
  }

  Future<List<dynamic>> _fetchApprovals() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');
    final finYearId = prefs.getInt('finYearId');
    final acYearId = prefs.getInt('acYearId');
    final adminUserId = prefs.getString('adminUserId');
    final acYear = prefs.getString('acYear');
    final finYear = prefs.getString('finYear');
    final userName = prefs.getString('userName');
    final employeeId = prefs.getInt('employeeId');
    final collegeId = prefs.getString('collegeId');
    final colCode = prefs.getString('colCode');
    print(employeeId);
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/MyApprovalDisplay'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Beesdev",
        "ColCode": colCode,
        "CollegeId": collegeId,
        "UserType": "EMPLOYEE",
        "EmployeeId": employeeId,
        "ApprovalId": 0,
        "Interface": 0,
        "RequestDate": "",
        "Role": userName,
        "Flag": "DISPLAY",
        "Status": ""
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      final List<dynamic> data =
      jsonDecode(response.body)['myApprovalDisplayDisplay'];

      // Extract unique interface names
      final List<String> fetchedInterfaceNames =
      data.map((item) => item['interfaceName'].toString()).toSet().toList();

      setState(() {
        _interfaceNames = fetchedInterfaceNames;
      });

      return data;
    } else {
      throw Exception('Failed to load approvals');
    }
  }

  void _filterApprovals(String? selectedInterface) {
    setState(() {
      _selectedInterface = selectedInterface;
    });
  }

  Future<void> _pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Future<void> _pickEndDate() async {
    DateTime initialDate = _selectedEndDate ?? DateTime.now();
    DateTime firstDate = _selectedStartDate ?? DateTime(2000);
    DateTime lastDate = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  Widget _buildInterfaceFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: _selectedInterface == null,
            backgroundColor: Colors.white.withOpacity(0.3),
            selectedColor: Colors.blue,
            labelStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            onSelected: (selected) {
              _filterApprovals(selected ? null : _selectedInterface);
            },
          ),
          const SizedBox(width: 8),
          ..._interfaceNames.map((interfaceName) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(interfaceName),
                selected: _selectedInterface == interfaceName,
                backgroundColor: Colors.white,
                selectedColor: Colors.blue,
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (selected) {
                  _filterApprovals(selected ? interfaceName : null);
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _pickStartDate,
          icon: const Icon(
            Icons.calendar_today,
            color: Colors.white,
          ),
          label: Text(
            _selectedStartDate == null
                ? 'Start Date'
                : DateFormat('dd-MM-yyyy').format(_selectedStartDate!),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        // End Date Picker
        ElevatedButton.icon(
          onPressed: _pickEndDate,
          icon: const Icon(
            Icons.calendar_today,
            color: Colors.white,
          ),
          label: Text(
            _selectedEndDate == null
                ? 'End Date'
                : DateFormat('dd-MM-yyyy').format(_selectedEndDate!),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
        ),
        if (_selectedStartDate != null || _selectedEndDate != null)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.red),
            onPressed: () {
              setState(() {
                _selectedStartDate = null;
                _selectedEndDate = null;
              });
            },
          ),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        _buildInterfaceFilterChips(),
        const SizedBox(height: 10),
        _buildDateFilter(),
      ],
    );
  }

  Future<void> _fetchDetails(
      int approvalId,
      int studentId,
      String interfaceName,
      String userType,
      int interfaceValue,
      int notificationId,
      dynamic requestDate,
      int Id,
      String status, // New parameter for status
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final adminUserId = prefs.getString('adminUserId');
    final employeeId = prefs.getInt('employeeId');

    DateTime parsedDate;
    if (requestDate is String) {
      try {
        parsedDate = DateFormat('dd-MM-yyyy').parse(requestDate);
      } catch (e) {
        throw FormatException(
            'Invalid date format. Expected format: dd-MM-yyyy');
      }
    } else if (requestDate is DateTime) {
      parsedDate = requestDate;
    } else {
      throw ArgumentError('Invalid requestDate format');
    }

    // Format the parsedDate to yyyy-MM-dd
    final formattedRequestDate =
    DateFormat('yyyy-MM-dd').format(parsedDate);

    final requestBody = jsonEncode({
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "ApprovalId": approvalId.toString(),
      "UserType": userType,
      "StudentId": studentId.toString(),
      "Interface": interfaceValue.toString(),
      "Id": "0",
      "NotificationId": notificationId.toString(),
      "RequestDate": formattedRequestDate,
      "InterfaceName": interfaceName,
      "UserId": adminUserId,
      "ApprovedBy": "0"
    });

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/LevelWiseDisplay'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final details = jsonDecode(response.body);

      final sections = <Widget>[];

      if (details['employeeDetailsForApprovalList'] != null &&
          (details['employeeDetailsForApprovalList'] as List).isNotEmpty) {
        sections.add(
          _formatSection('Employee Details For Approval',
              details['employeeDetailsForApprovalList']),
        );
      }

      if (details['employeePapersTabDisplayList'] != null &&
          (details['employeePapersTabDisplayList'] as List).isNotEmpty) {
        sections.add(
          _formatSection('Employee Papers Tab Display List',
              details['employeePapersTabDisplayList']),
        );
      }

      if (details['employeePapersConferencesTabTempDisplayList'] != null &&
          (details['employeePapersConferencesTabTempDisplayList'] as List)
              .isNotEmpty) {
        sections.add(
          _formatSection('Employee Papers Conferences Tab Temp Display List',
              details['employeePapersConferencesTabTempDisplayList']),
        );
      }

      final detailsWidget = sections.isNotEmpty
          ? Column(children: sections)
          : const Text('No data available', style: TextStyle(fontSize: 16));

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          title: const Center(
            child: Text(
              "Approval Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                detailsWidget,
                const SizedBox(height: 20),
                const Text(
                  "Description:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: "Enter description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      BorderSide(color: Colors.grey.shade400),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: status.toLowerCase() == 'pending'
                  ? () async {
                final description = _descriptionController.text;
                await _handleApprovalOrRejection(
                  notificationId,
                  employeeId!,
                  formattedRequestDate,
                  description,
                  "APPROVED",
                  Id,
                );
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  _approvals = _fetchApprovals(); // Refresh the approvals list
                });
              }
                  : null, // Disable button if not "pending"
              child: const Text(
                "Approve",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: status.toLowerCase() == 'pending'
                  ? () async {
                final description = _descriptionController.text;
                await _handleApprovalOrRejection(
                    notificationId,
                    employeeId!,
                    formattedRequestDate,
                    description,
                    "REJECTED",
                    Id);
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  _approvals = _fetchApprovals(); // Refresh the approvals list
                });
              }
                  : null, // Disable button if not "pending"
              child: const Text(
                "Reject",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      throw Exception('Failed to load details');
    }
  }

  Future<void> _handleApprovalOrRejection(
      int notificationId,
      int employeeId,
      String requestDate,
      String description,
      String flag,
      int Id,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final adminUserId = prefs.getString('adminUserId');
    final employee = prefs.getInt('employeeId');
    print(employee);

    final requestBody = jsonEncode({
      "GrpCode": "BEESDEV",
      "ColCode": "0001",
      "CollegeId": 1,
      "Id": Id,
      "NotificationId": notificationId,
      "EmployeeId": adminUserId,
      "RequestDate": requestDate,
      "ApprovedBy": employeeId,
      "Description": description,
      "Flag": flag,
      "SubFlag": "Expenses",
    });
    print(requestBody);

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeApproveAndRejectedDetails'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final details = jsonDecode(response.body);
      if (details.containsKey('message')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(details['message']),
            backgroundColor: flag == "APPROVED" ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      throw Exception('Failed to submit approval/rejection');
    }
  }

  Widget _formatSection(String title, List<dynamic> list) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ..._formatList(list),
        ],
      ),
    );
  }

  List<Widget> _formatList(List<dynamic> list) {
    return list.map<Widget>((item) {
      if (item is Map) {
        final filteredEntries = item.entries.where((entry) {
          return entry.value != null && !(entry.value is int);
        });
        if (filteredEntries.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: filteredEntries.map<Widget>((entry) {
                final formattedKey = _camelCaseToTitleCase(entry.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$formattedKey: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(
                          text: '${entry.value}',
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
      }
      return Text(item.toString(), style: const TextStyle(fontSize: 16));
    }).toList();
  }

  String _camelCaseToTitleCase(String camelCaseString) {
    final buffer = StringBuffer();
    for (int i = 0; i < camelCaseString.length; i++) {
      final char = camelCaseString[i];
      if (i > 0 && char == char.toUpperCase()) {
        buffer.write(' ');
      }
      buffer.write(char.toUpperCase());
    }
    return buffer.toString();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'approved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 20), // Adjusted space for better UI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildFilters(), // Add filter chips and date filters
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _approvals,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                            color: Colors.redAccent),
                      ),
                    );
                  } else if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No approvals found',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  } else {
                    final approvals = snapshot.data!.where((approval) {
                      // Apply interface filter
                      if (_selectedInterface != null) {
                        if (approval['interfaceName'] == null ||
                            approval['interfaceName']
                                .toString() !=
                                _selectedInterface) {
                          return false;
                        }
                      }

                      // Apply date filter
                      if (_selectedStartDate != null ||
                          _selectedEndDate != null) {
                        String requestDateStr =
                            approval['requestDate'] ?? '';
                        if (requestDateStr.isEmpty) {
                          return false;
                        }
                        DateTime? requestDate;
                        try {
                          requestDate = DateFormat('dd-MM-yyyy')
                              .parse(requestDateStr);
                        } catch (e) {
                          return false;
                        }

                        if (_selectedStartDate != null &&
                            requestDate
                                .isBefore(_selectedStartDate!)) {
                          return false;
                        }

                        if (_selectedEndDate != null &&
                            requestDate
                                .isAfter(_selectedEndDate!)) {
                          return false;
                        }
                      }

                      return true; // Approval matches all filters
                    }).toList();

                    return approvals.isEmpty
                        ? const Center(
                      child: Text(
                        'No approvals match the selected filter.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                        : ListView.builder(
                      itemCount: approvals.length,
                      itemBuilder: (context, index) {
                        final approval = approvals[index];
                        final status =
                            approval['status']?.toString().toLowerCase() ??
                                'unknown';
                        final interfaceName =
                            approval['interfaceName'] ?? 'N/A';
                        final requestDate =
                            approval['requestDate'] ?? 'N/A';
                        final roleName =
                            approval['roleName'] ?? 'N/A';
                        final approvalId =
                        approval['approvalId'];
                        final Id = approval['Id'];
                        final studentId =
                        approval['studentId'];
                        final userType =
                        approval['userType'];
                        final interfaceValue =
                            approval['interface'] ?? 0;
                        final notificationId =
                            approval['notificationId'] ?? 0;

                        final statusColor =
                        _getStatusColor(status);

                        return AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            color: Colors.white,
                            shadowColor: Colors.blueAccent
                                .withOpacity(0.2),
                            child: ListTile(
                              title: Text(
                                interfaceName,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight:
                                  FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Request Date: $requestDate',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                        FontWeight.bold),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Text(
                                    roleName,
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (status == 'pending') {
                                        _fetchDetails(
                                          approvalId,
                                          studentId,
                                          interfaceName,
                                          userType,
                                          interfaceValue,
                                          notificationId,
                                          requestDate,
                                          Id ?? 0,
                                          status, // Pass the status
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                            context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'This approval has already been ${status == 'approved' ? 'approved' : 'rejected'}.',
                                            ),
                                            backgroundColor:
                                            Colors.blue,
                                            duration:
                                            const Duration(
                                                seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding:
                                      const EdgeInsets.all(8.0),
                                      child: const Text(
                                        "View Details",
                                        style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight:
                                          FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
