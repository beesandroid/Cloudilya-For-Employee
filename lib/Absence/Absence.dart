import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Absence extends StatefulWidget {
  const Absence({super.key});

  @override
  State<Absence> createState() => _AbsenceState();
}

class _AbsenceState extends State<Absence> with SingleTickerProviderStateMixin {
  List<dynamic> employeeLeavesDisplayList = [];
  List<bool> isOpenList = [];

  @override
  void initState() {
    super.initState();
    fetchEmployeeLeaves();
  }

  Future<void> fetchEmployeeLeaves() async {
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveEmployeeLeaves');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "GrpCode": "beesdev",
        "ColCode": "0001",
        "CollegeId": "1",
        "EmployeeId": "2",
        "LeaveId": "0",
        "Description": "",
        "Balance": "0",
        "Flag": "DISPLAY"
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        employeeLeavesDisplayList = responseData['employeeLeavesDisplayList'];
        isOpenList =
            List.generate(employeeLeavesDisplayList.length, (index) => false);
      });
    } else {
      print('Failed to load data');
    }
  }

  Future<void> fetchLeaveDetails(String leaveId) async {
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveEmployeeLeaves');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "GrpCode": "beesdev",
        "ColCode": "0001",
        "CollegeId": "1",
        "EmployeeId": "2",
        "LeaveId": leaveId,
        "Description": "",
        "Balance": "0",
        "Flag": "DISPLAY"
      }),
    );

    if (response.statusCode == 200) {
      final leaveDetails = jsonDecode(response.body);

      // Pass the leave details and the context to the showLeaveDetails function
      showLeaveDetails(leaveDetails);
    } else {
      print('Failed to load leave details');
    }
  }

  void showLeaveDetails(Map<String, dynamic> leaveResponse) {
    List<dynamic> leaves = leaveResponse["employeeLeavesDisplayList"];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(backgroundColor: Colors.white,
          title: Text('Leave Details'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: leaves.length,
              itemBuilder: (context, index) {
                var leave = leaves[index];

                // Decode the base64-encoded image if available
                Image leaveImage;
                if (leave['photo1'] != null && leave['photo1'].isNotEmpty) {
                  try {
                    leaveImage = Image.memory(base64Decode(leave['photo1']));
                  } catch (e) {
                    // If there's an issue decoding the image, fallback to a placeholder
                    leaveImage = Image.asset('assets/placeholder_image.png');
                  }
                } else {
                  leaveImage = Image.asset(
                      'assets/placeholder_image.png'); // or Icon if no image is provided
                }

                return Card(color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // On tap, show a dialog with the zoomed image
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(backgroundColor: Colors.white,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            leaveImage, // Show the zoomed image
                                            SizedBox(height: 10),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text(
                                                'Close',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                child: leaveImage, // Display the image
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Month: ${leave['monthName']}, ${leave['year']}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                            "Accrued Type: ${leave['accruedTypeName'] ?? 'N/A'}"),
                        Text("Balance: ${leave['balance']}"),
                        Text("Accrued Date: ${leave['accruedDate'] ?? 'N/A'}"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
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
        title: const Text('Absence Details',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.white,
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
      ),
      body: employeeLeavesDisplayList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: ExpansionPanelList(
                  elevation: 1,
                  expandedHeaderPadding: const EdgeInsets.all(10),
                  animationDuration: const Duration(milliseconds: 400),
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      isOpenList[index] = !isOpenList[index];
                    });
                  },
                  children: employeeLeavesDisplayList
                      .map<ExpansionPanel>((leaveData) {
                    int index = employeeLeavesDisplayList.indexOf(leaveData);
                    return ExpansionPanel(
                      backgroundColor: Colors.white,
                      canTapOnHeader: true,
                      isExpanded: isOpenList[index],
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 4,
                                spreadRadius: 2,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: ListTile(
                            leading: AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: const Icon(
                                Icons.expand_more,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              leaveData['absenceName'] ?? 'No Absence Name',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'Accrued: ${leaveData['accrued']} | Balance: ${leaveData['balance']}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                      body: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.fastOutSlowIn,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        child: AnimatedOpacity(
                          opacity: isOpenList[index] ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow('Accrual Period:',
                                    leaveData['accrualPeriodName'] ?? 'N/A'),
                                _buildDetailRow('Last Accrued:',
                                    leaveData['lastAccruedDate'] ?? 'N/A'),
                                _buildDetailRow('Accrued:',
                                    leaveData['accrued'].toString()),
                                _buildDetailRow('Balance:',
                                    leaveData['balance'].toString()),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue),
                                  onPressed: () {
                                    fetchLeaveDetails(
                                        leaveData['leaveId'].toString());
                                  },
                                  child: const Text(
                                    'View Details',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
