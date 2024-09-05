import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Approvals extends StatefulWidget {
  const Approvals({super.key});

  @override
  State<Approvals> createState() => _ApprovalsState();
}

class _ApprovalsState extends State<Approvals> {
  late Future<List<Approval>> _approvals;

  @override
  void initState() {
    super.initState();
    _approvals = _fetchApprovals();
  }

  Future<List<Approval>> _fetchApprovals() async {
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/MyApprovalDisplay'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "BEES",
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
      final List<dynamic> data = jsonDecode(response.body)['myApprovalDisplayDisplay'];
      return data.map((item) => Approval.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load approvals');
    }
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
        return Colors.grey; // Fallback color
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      body: Container(
        color: Colors.white,
        child: FutureBuilder<List<Approval>>(
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
                  final statusColor = _getStatusColor(approval.status);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      color: Colors.white,
                      shadowColor: Colors.blueAccent.withOpacity(0.2),
                      child: ListTile(
                        title: Text(
                          approval.interfaceName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: ${approval.status}',
                              style: TextStyle(
                                color: statusColor,fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),     Text(
                              'Status: ${'Request Date: ${approval.requestDate}'}',
                              style: TextStyle(
                                fontSize: 14,fontWeight: FontWeight.bold
                              ),),

                          ],
                        ),
                        trailing: Text(
                          approval.roleName,
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}

class Approval {
  final int slNo;
  final String interfaceName;
  final String status;
  final String requestDate;
  final String roleName;

  Approval({
    required this.slNo,
    required this.interfaceName,
    required this.status,
    required this.requestDate,
    required this.roleName,
  });

  factory Approval.fromJson(Map<String, dynamic> json) {
    return Approval(
      slNo: json['slNo'],
      interfaceName: json['interfaceName'] ?? '',
      status: json['status'] ?? 'Unknown',
      requestDate: json['requestDate'] ?? '',
      roleName: json['roleName'] ?? 'Unknown',
    );
  }
}
