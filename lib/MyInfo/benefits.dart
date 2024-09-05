import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Benefits extends StatefulWidget {
  const Benefits({super.key});

  @override
  State<Benefits> createState() => _BenefitsState();
}

class _BenefitsState extends State<Benefits> {
  List<dynamic> employeeBenefits = [];

  @override
  void initState() {
    super.initState();
    fetchEmployeeBenefits();
  }

  Future<void> fetchEmployeeBenefits() async {
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeBenifitsDisplay');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "Id": 0,
        "EmployeeId": 2,
        "BenifitType": "",
        "UserId": "1",
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
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        employeeBenefits = data['employeeBenifitsDisplayList'];
      });
    } else {
      // Handle the error
      print('Failed to load employee benefits');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Employee Benefits',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: employeeBenefits.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: employeeBenefits.length,
              itemBuilder: (context, index) {
                final benefit = employeeBenefits[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 25,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Benefit Type: ${benefit['benifitType'] ?? 'N/A'}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.account_balance_wallet,
                            color: Colors.grey,
                            text: 'Policy No: ${benefit['policyNo'] ?? 'N/A'}',
                          ),
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.monetization_on,
                            color: Colors.grey,
                            text:
                                'Premium Amount: ₹${benefit['premiumAmount']?.toStringAsFixed(2) ?? 'N/A'}',
                          ),
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.calendar_today,
                            color: Colors.grey,
                            text:
                                'Premium Period: ${benefit['premiumPeriodName'] ?? 'N/A'}',
                          ),
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.person,
                            color: Colors.grey,
                            text: 'Nominee: ${benefit['nomineeName'] ?? 'N/A'}',
                          ),
                          const SizedBox(height: 10),
                          if (benefit['submitDocuments'] != null &&
                              benefit['submitDocuments'].isNotEmpty)
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
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              overflow:
                  isDocument ? TextOverflow.ellipsis : TextOverflow.visible,
            ),
          ),
        ),
      ],
    );
  }
}
