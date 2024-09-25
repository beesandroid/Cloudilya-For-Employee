import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class Approvals extends StatefulWidget {
  const Approvals({super.key});

  @override
  State<Approvals> createState() => _ApprovalsState();
}

class _ApprovalsState extends State<Approvals> {
  late Future<List<dynamic>> _approvals;
  bool _isLoading = false;

  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _approvals = _fetchApprovals();
  }

  Future<List<dynamic>> _fetchApprovals() async {
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/MyApprovalDisplay'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Beesdev",
        "ColCode": "0001",
        "CollegeId": "1",
        "UserType": "EMPLOYEE",
        "EmployeeId": "15758",
        "ApprovalId": 0,
        "Interface": 0,
        "RequestDate": "",
        "Role": "10048",
        "Flag": "DISPLAY",
        "Status": ""
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(response.body)['myApprovalDisplayDisplay'];
      return data;
    } else {
      throw Exception('Failed to load approvals');
    }
  }

  Future<void> _fetchDetails(
      int approvalId,
      int studentId,
      String interfaceName,
      String userType,
      int interfaceValue,
      int notificationId,
      dynamic requestDate, // Allow dynamic type for flexibility
      ) async {
    DateTime parsedDate;

    // Check if requestDate is a String or DateTime
    if (requestDate is String) {
      try {
        // Parse the date string based on the expected format
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
    final formattedRequestDate = DateFormat('yyyy-MM-dd').format(parsedDate);

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
      "UserId": "5",
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
                      borderSide: BorderSide(color: Colors.grey.shade400),
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
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final description = _descriptionController.text;
                await _handleApprovalOrRejection(
                  notificationId,
                  3, // EmployeeId example
                  formattedRequestDate,
                  description,
                  "APPROVED",
                );
              },
              child: const Text(
                "Approve",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final description = _descriptionController.text;
                await _handleApprovalOrRejection(
                  notificationId,
                  3, // EmployeeId example
                  formattedRequestDate,
                  description,
                  "REJECTED",
                );
              },
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
      String flag, // "APPROVED" or "REJECTED"
      ) async {
    final requestBody = jsonEncode({
      "GrpCode": "BEESDEV",
      "ColCode": "0001",
      "CollegeId": 1,
      "Id": 0,
      "NotificationId": notificationId,
      "EmployeeId": employeeId,
      "RequestDate": requestDate,
      "ApprovedBy": 0,
      "Description": description,
      "Flag": flag,
      "SubFlag": "Expenses"
    });

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeApproveAndRejectedDetails'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      print('Response: ${response.body}');
      final details = jsonDecode(response.body);
      if (details.containsKey('message')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(details['message']),
            backgroundColor: Colors.red, // Customize color if needed
            duration: const Duration(seconds: 3), // Duration of Snackbar
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
        return Colors.deepOrange;
      case 'reject':
        return Colors.redAccent;
      case 'approve':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        color: Colors.white,
        child: FutureBuilder<List<dynamic>>(
          future: _approvals,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No approvals found',
                  style: TextStyle(color: Colors.black54),
                ),
              );
            } else {
              final approvals = snapshot.data!;
              return ListView.builder(
                itemCount: approvals.length,
                itemBuilder: (context, index) {
                  final approval = approvals[index];
                  final status = approval['status'] ?? 'unknown';
                  final interfaceName = approval['interfaceName'] ?? 'N/A';
                  final requestDate = approval['requestDate'] ?? 'N/A';
                  final roleName = approval['roleName'] ?? 'N/A';
                  final approvalId = approval['approvalId'];
                  final studentId = approval['studentId'];
                  final userType = approval['userType'];

                  final interfaceValue =
                      approval['interface'] ?? 0; // Default to 0 if not present
                  final notificationId = approval['notificationId'] ??
                      0; // Default to 0 if not present
                  print(userType);

                  final statusColor = _getStatusColor(status);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        color: Colors.white,
                        shadowColor: Colors.blueAccent.withOpacity(0.2),
                        child: ListTile(
                          title: Text(
                            interfaceName,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status: $status',
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Request Date: $requestDate',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                roleName,
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _fetchDetails(
                                    approvalId,
                                    studentId,
                                    interfaceName,
                                    userType,
                                    interfaceValue,
                                    notificationId,
                                    requestDate,
                                  );
                                  // Handle the tap action
                                  // You can call the method to fetch details or navigate to another screen
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  // Optional: Add padding for better touch area
                                  child: Text(
                                    "View Details",
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
