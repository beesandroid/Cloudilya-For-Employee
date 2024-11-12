import 'package:cloudilyaforemployee/main.dart';
import 'package:flutter/material.dart';
import '../Address/Address.dart';
import '../Awards/Awards.dart';
import '../Bankdetails/BankDetails.dart';
import '../Dependents/Dependents.dart';
import '../Expences/Expences.dart';
import '../NoticeBoard.dart';
import '../Papers/Conference.dart';
import '../Papers/Manual.dart';
import '../Qualifications.dart';
import '../TaxBenefits/TaxBenefits.dart';
import '../biometric/Biometric.dart';
import '../experience/Experience.dart';
import '../MyInfo/Employment.dart';
import '../MyInfo/PayAllotment.dart';
import '../MyInfo/benefits.dart';
import '../MyInfo/empInfo.dart';
import '../funding/funding.dart';
import 'Complaints.dart';
import 'Share.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // Required for Android exit

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? employeeName = "John Doe";
  String? employeeId =
      "N/A"; // Default values, will be replaced with actual data
  String? userType, finYear, acYear, adminUserId, collegeId, colCode;

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
      employeeId = prefs.getInt('employeeId')?.toString() ?? "N/A";
      collegeId = prefs.getString('collegeId');
      colCode = prefs.getString('colCode');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Column(
        children: <Widget>[
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/image.png'),
                  backgroundColor: Colors.grey.shade200,
                ),
                SizedBox(height: 10),
                Text(
                  'Employee ID: ${employeeId ?? 'N/A'}',
                  // Display fetched employee ID
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Wrapping with Expanded to ensure it doesn't overflow
          Expanded(
            child: SingleChildScrollView(
              child: _buildDrawerContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerContent(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            leading: Icon(EvaIcons.personOutline, color: Colors.white),
            title: Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              _buildDrawerItem(
                  context, EvaIcons.person, 'Employee Info', EmployeeInfo()),
              _buildDrawerItem(
                  context, EvaIcons.creditCard, 'Benefits', Benefits()),
              _buildDrawerItem(context, EvaIcons.creditCardOutline,
                  'Pay Allotment', PayAllotment()),
              _buildDrawerItem(context, EvaIcons.briefcaseOutline, 'Employment',
                  Employment()),
              _buildDrawerItem(
                  context, EvaIcons.calendarOutline, 'Expenses', Expenses()),
              _buildDrawerItem(
                  context, EvaIcons.peopleOutline, 'Dependents', Dependents()),
              _buildDrawerItem(
                  context, EvaIcons.briefcase, 'Funding', Funding()),
              _buildDrawerItem(context, EvaIcons.activityOutline, 'Experience',
                  Experience()),
              _buildDrawerItem(
                  context, EvaIcons.bookOutline, 'Bank Details', BankDetails()),
              _buildDrawerItem(context, EvaIcons.printer, 'Biometrics',
                  BiometricDisplayScreen()),
              _buildDrawerItem(context, EvaIcons.percentOutline, 'Tax Benefits',
                  TaxBenefits()),
              _buildDrawerItem(
                  context, EvaIcons.homeOutline, 'Address', Address()),
              _buildDrawerItem(
                  context, EvaIcons.awardOutline, 'Awards', Awards()),
              _buildDrawerItem(
                  context, EvaIcons.bookOutline, 'Conference', Conference()),
              _buildDrawerItem(context, EvaIcons.fileText, 'Employee Papers',
                  EmployeePapersConferencesScreen()),
              _buildDrawerItem(context, EvaIcons.bookOpenOutline,
                  'Employee Qualification', EmployeeQualificationsScreen()),
            ],
          ),
        ),
        _buildDrawerItem(context, EvaIcons.archiveOutline, 'Complaints',
            ComplaintsDropdownMenus()),
        _buildDrawerItem(context, EvaIcons.shareOutline, 'Share app and Review',
            Promotion()),
        _buildDrawerItem(
            context, EvaIcons.map, 'NoticeboardUpload', NoticeboardUpload()),

        // Logout item
        _buildDrawerItem(context, EvaIcons.logOutOutline, 'Logout', null,
            logout: true),
      ],
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, Widget? destination,
      {bool logout = false}) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(
          title,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        onTap: logout
            ? () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SplashScreen(
                            isLoggedIn: false))); // Clear preferences
              }
            : () {
                if (destination != null) {
                  Navigator.of(context).push(_createRoute(destination));
                }
              },
      ),
    );
  }

  Route _createRoute(Widget destination) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
