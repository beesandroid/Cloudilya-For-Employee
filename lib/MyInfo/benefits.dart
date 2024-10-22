import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Benefits extends StatefulWidget {
  const Benefits({super.key});

  @override
  State<Benefits> createState() => _BenefitsState();
}

class _BenefitsState extends State<Benefits> {
  List<dynamic> employeeBenefits = [];
  String message = '';

  @override
  void initState() {
    super.initState();
    fetchEmployeeBenefits();
  }

  Future<void> fetchEmployeeBenefits() async {
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

    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeBenifitsDisplay');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {
            "GrpCode": "Beesdev",
            "ColCode": colCode,
            "CollegeId": collegeId,
            "Id": 0,
            "EmployeeId":employeeId ,
            "BenifitType": "",
            "UserId": adminUserId,
            "Coverage": "0",
            "PolicyNo": "",
            "MentallyDisabled": "0",
            "PremiumAmount": "0",
            "PremiumPeriod": "0",
            "EmployerContribution": "0",
            "PremiumPaymentTerm": "",
            "Nominee": "0",
            "MaturityAmount": "0",
            "CoverageStartDate": "",
            "CoverageEndDate": "",
            "PremiumStartDate": "",
            "PremiumEndDate": "",
            "SubmitDocuments": "",
            "LoginIpAddress": "",
            "LoginSystemName": "",
            "Flag": "VIEW"
          }
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        employeeBenefits = data['employeeBenifitsDisplayList'];
        message = data['message'] ?? '';
      });
    } else {
      // Handle the error
      print('Failed to load employee benefits');
      setState(() {
        message = 'Failed to load employee benefits.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
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
          'Employee Benefits',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: employeeBenefits.isEmpty
          ? Center(
        child: Text(
          message.isNotEmpty ? message : 'Employee doesnt have any benefits',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : ListView.builder(
        itemCount: employeeBenefits.length,
        itemBuilder: (context, index) {
          final benefit = employeeBenefits[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: GestureDetector(
              onTap: () {
                // Handle card tap if needed
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.8),
                      Colors.white.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Card(
                  color: Colors.transparent, // Use gradient background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 0, // Remove card elevation since we handle it with a shadow
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Benefit Type: ${benefit['benifitType'] ?? 'N/A'}',
                          style: GoogleFonts.poppins(
                            color: Colors.blue.shade900,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          icon: Icons.account_balance_wallet,
                          color: Colors.grey,
                          text: 'Policy No: ${benefit['policyNo'] ?? 'N/A'}',
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          icon: Icons.currency_rupee,
                          color: Colors.grey,
                          text: 'Premium Amount: ₹${benefit['premiumAmount']?.toStringAsFixed(2) ?? 'N/A'}',
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          color: Colors.grey,
                          text: 'Premium Period: ${benefit['premiumPeriodName'] ?? 'N/A'}',
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          icon: Icons.person,
                          color: Colors.grey,
                          text: 'Nominee: ${benefit['nomineeName'] ?? 'N/A'}',
                        ),
                        const SizedBox(height: 10),
                        if (benefit['submitDocuments'] != null && benefit['submitDocuments'].isNotEmpty)
                          _buildDetailRow(
                            icon: Icons.file_present,
                            color: Colors.grey,
                            text: 'Documents: ${benefit['submitDocuments']}',
                            isDocument: true,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color color,
    required String text,
    bool isDocument = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              overflow: isDocument ? TextOverflow.ellipsis : TextOverflow.visible,
            ),
          ),
        ),
      ],
    );
  }
}
