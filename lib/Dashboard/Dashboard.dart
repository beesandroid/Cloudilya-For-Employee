import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloudilyaforemployee/Attendence/Attendence.dart';
import 'package:cloudilyaforemployee/biometric/Biometric.dart';
import '../Absence/Absence.dart';
import '../MApplications/MyApplications.dart';
import '../MaterialUploading/view.dart';
import '../MyInfo/Employment.dart';
import '../MyInfo/PayAllotment.dart';
import '../Requests/requests.dart';
import 'package:google_fonts/google_fonts.dart';

import '../finance/finance.dart';

class DashboardHomePage extends StatefulWidget {
  @override
  _DashboardHomePageState createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  String? employeeId;
  String? userType;
  String? finYear;
  String? acYear;
  String? adminUserId;
  String? collegeId;
  String? colCode;
  String? collegename;

  @override
  void initState() {
    super.initState();
    _loadEmployeeDetails();
  }

  Future<void> _loadEmployeeDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('userType');
      finYear = prefs.getString('finYear');
      acYear = prefs.getString('acYear');
      adminUserId = prefs.getString('adminUserId');
      employeeId = prefs.getString('userName');
      collegeId = prefs.getString('collegeId');
      colCode = prefs.getString('colCode');
      collegename = prefs.getString('collegename');
      print("college:"+collegename.toString());

    });
  }
//EMP20240932
  @override
  Widget build(BuildContext context) {
    // Using ListView for scrollable content
    return Scaffold(
      backgroundColor: Colors.white, // Set background to white

      // Remove AppBar and make content scrollable
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        children: [
          _buildUserInfoCard(),
          SizedBox(height: 20.0),
          _buildGridMenu(context),
        ],
      ),
    );
  }

  // Redesigned User Info Card
  Widget _buildUserInfoCard() {
    return Card(
      elevation: 10, // Soft elevation for a floating effect
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.grey.withOpacity(0.3),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

        ),
        child: Row(
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 35, // Compact size
              backgroundImage: AssetImage('assets/profilepic.jpeg'),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(width: 15),
            // User Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Name
                  Text(
                    'R Jagadeesh',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  // User Information Rows
                  _buildUserInfoRow('College : ', collegename ?? 'Loading...'),

                  _buildUserInfoRow('Emp Number : ', employeeId ?? 'Loading...'),


                  _buildUserInfoRow('Academic Year : ', acYear ?? 'Loading...'),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Helper method to build user information rows

  // Grid Menu for navigation
  Widget _buildGridMenu(BuildContext context) {
    return GridView.builder(
      itemCount: _menuItems.length,
      shrinkWrap: true, // Shrink to fit content
      physics: NeverScrollableScrollPhysics(), // Disable internal scrolling
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns
        crossAxisSpacing: 12, // Reduced spacing for compactness
        mainAxisSpacing: 12,
        childAspectRatio: 0.8, // Adjusted for better fit
      ),
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        return _buildCardGridTile(context, item);
      },
    );
  }

  // Define menu items in a list for scalability
  final List<_MenuItem> _menuItems = [
    _MenuItem(
      title: 'Attendance',
      icon: Icons.how_to_reg, // Represents registration/check-in
      screen: AttendanceScreen(),
      color: Colors.blueAccent,
    ),
    _MenuItem(
      title: 'Material',
      icon: Icons.menu_book, // Represents educational materials
      screen: EmployeeMaterialScreen(),
      color: Colors.purpleAccent,
    ),
    _MenuItem(
      title: 'Biometrics',
      icon: Icons.fingerprint, // Represents biometric features
      screen: BiometricDisplayScreen(),
      color: Colors.tealAccent,
    ),
    _MenuItem(
      title: 'My Application',
      icon: Icons.person, // Represents user-specific applications
      screen: Myapplications(),
      color: Colors.greenAccent,
    ),
    _MenuItem(
      title: 'Requests',
      icon: Icons.mail_outline, // Represents messaging or requests
      screen: Requests(),
      color: Colors.orangeAccent,
    ),

    _MenuItem(
      title: 'Absence',
      icon: Icons.event_busy, // Represents absence or busy status
      screen: Absence(),
      color: Colors.redAccent,
    ),
     _MenuItem(
      title: 'Finance',
      icon: EvaIcons.briefcaseOutline, // Represents biometric features
      screen: FinanceScreen(),
      color: Colors.blue,
    ), _MenuItem(
      title: 'Pay Allotment',
      icon: FontAwesomeIcons.moneyBillTransfer, // Represents biometric features
      screen: PayAllotment(),
      color: Colors.brown,
    ),_MenuItem(
      title: 'Employment Details',
      icon: FontAwesomeIcons.addressCard, // Represents biometric features
      screen: Employment(),
      color: Colors.green,
    ),
  ];

  // Helper method to build individual grid tiles
  Widget _buildCardGridTile(BuildContext context, _MenuItem item) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Get.to(() => item.screen);
      },
      child: Card(
        elevation: 5, // Slightly reduced elevation for subtlety
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: Colors.grey.withOpacity(0.3),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Reduced padding for compactness
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with accent color
              CircleAvatar(
                backgroundColor: item.color.withOpacity(0.1),
                radius: 20, // Reduced radius for smaller tiles
                child: Icon(
                  item.icon,
                  size: 20, // Adjusted size for better fit
                  color: item.color,
                ),
              ),
              SizedBox(height: 10),
              // Menu Item Title
              Text(
                item.title,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 12, // Further reduced font size
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // Prevents text overflow
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper class for menu items
class _MenuItem {
  final String title;
  final IconData icon;
  final Widget screen;
  final Color color;

  _MenuItem({
    required this.title,
    required this.icon,
    required this.screen,
    required this.color,
  });
}
