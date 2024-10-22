import 'package:cloudilyaemployee/main.dart';
import 'package:flutter/material.dart';
import '../Address/Address.dart';
import '../Awards/Awards.dart';
import '../Bankdetails/BankDetails.dart';
import '../Dependents/Dependents.dart';
import '../Expences/Expences.dart';
import '../Papers/Conference.dart';
import '../Papers/Manual.dart';
import '../Qualifications.dart';
import '../TaxBenefits/TaxBenefits.dart';
import '../biometric/Biometric.dart';
import '../experience/Experience.dart';
import '../finance/finance.dart';
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


class CustomDrawer extends StatelessWidget {
  bool isLoggedIn = true; // Define your login status here (replace with actual logic)

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ListView(
        physics: BouncingScrollPhysics(),
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
                  'John Doe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerContent(context),
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
              _buildDrawerItem(context, EvaIcons.person, 'Employee Info', EmployeeInfo()),
              _buildDrawerItem(context, EvaIcons.creditCard, 'Benefits', Benefits()),
              _buildDrawerItem(context, EvaIcons.creditCardOutline, 'Pay Allotment', PayAllotment()),
              _buildDrawerItem(context, EvaIcons.briefcaseOutline, 'Employment', Employment()),
              _buildDrawerItem(context, EvaIcons.calendarOutline, 'Expenses', Expenses()),
              _buildDrawerItem(context, EvaIcons.peopleOutline, 'Dependents', Dependents()),
              _buildDrawerItem(context, EvaIcons.briefcase, 'Funding', Funding()),
              _buildDrawerItem(context, EvaIcons.activityOutline, 'Experience', Experience()),
              _buildDrawerItem(context, EvaIcons.bookOutline, 'Bank Details', BankDetails()),
              _buildDrawerItem(context, EvaIcons.printer, 'Biometrics', BiometricDisplayScreen()),
              _buildDrawerItem(context, EvaIcons.percentOutline, 'Tax Benefits', TaxBenefits()),
              _buildDrawerItem(context, EvaIcons.homeOutline, 'Address', Address()),
              _buildDrawerItem(context, EvaIcons.awardOutline, 'Awards', Awards()),
              _buildDrawerItem(context, EvaIcons.briefcaseOutline, 'Finance', FinanceScreen()),
              _buildDrawerItem(context, EvaIcons.bookOutline, 'Conference', Conference()),
              _buildDrawerItem(context, EvaIcons.fileText, 'Employee Papers', EmployeePapersConferencesScreen()),
              _buildDrawerItem(context, EvaIcons.bookOpenOutline, 'Employee Qualification', EmployeeQualificationsScreen()),
            ],
          ),
        ),
        _buildDrawerItem(context, EvaIcons.archiveOutline, 'Complaints', ComplaintsDropdownMenus()),
        _buildDrawerItem(context, EvaIcons.shareOutline, 'Share app and Review', Promotion()),

        // Logout item
        _buildDrawerItem(context, EvaIcons.logOutOutline, 'Logout', null, logout: true),
      ],
    );
  }

  // Updated _buildDrawerItem to handle logout with a condition
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget? destination, {bool logout = false}) {
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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SplashScreen(isLoggedIn: isLoggedIn)));// Clear preferences


        }
            : () {
          if (destination != null) {
            Navigator.of(context).push(_createRoute(destination));
          }
        },
      ),
    );
  }

  // Custom page transition animation
  Route _createRoute(Widget destination) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
