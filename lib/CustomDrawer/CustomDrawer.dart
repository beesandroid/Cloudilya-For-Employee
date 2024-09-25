import 'package:flutter/material.dart';
import '../Address/Address.dart';
import '../Awards/Awards.dart';
import '../Bankdetails/BankDetails.dart';
import '../Dependents/Dependents.dart';
import '../Expences/Expences.dart';
import '../TaxBenefits/TaxBenefits.dart';
import '../biometric/Biometric.dart';
import '../experience/Experience.dart';
import '../finance/finance.dart';
import '../MyInfo/Employment.dart';
import '../MyInfo/PayAllotment.dart';
import '../MyInfo/Salarypayout.dart';
import '../MyInfo/benefits.dart';
import '../MyInfo/empInfo.dart';
import '../Papers/viewpager.dart';
import '../TimeSheet/TimeSheet.dart';
import '../funding/funding.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Drawer(
        backgroundColor: Colors.transparent,
        child: ListView(
          padding: EdgeInsets.zero,
          physics: BouncingScrollPhysics(), // Smooth scrolling
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
            color: Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),

                  ),
                ],
              ),
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black45,
                          offset: Offset(2, 2),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerContent(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          leading: Icon(Icons.info, color: Colors.black),
          title: Text(
            'Profile',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold
              ,
            ),
          ),
          iconColor: Colors.black,
          backgroundColor: Colors.black12,
          collapsedIconColor: Colors.black,
          children: <Widget>[
            _buildDrawerItem(context, Icons.bento, 'EmployeeInfo', EmployeeInfo()),
            _buildDrawerItem(context, Icons.bento, 'Benefits', Benefits()),
            _buildDrawerItem(context, Icons.payment, 'Pay Allotment', Payallotment()),
            _buildDrawerItem(context, Icons.wordpress, 'Employment', Employement()),
            _buildDrawerItem(context, Icons.money_off_sharp, 'Expenses', Expenses()),
            _buildDrawerItem(context, Icons.family_restroom, 'Dependents', Dependents()),
            _buildDrawerItem(context, Icons.attach_money_rounded, 'Funding', Funding()),
            _buildDrawerItem(context, Icons.work, 'Experience', Experience()),
            _buildDrawerItem(context, Icons.comment_bank, 'BankDetails', BankDetails()),
            _buildDrawerItem(context, Icons.fingerprint, 'Biometrics', BiometricDisplayScreen()),
            _buildDrawerItem(context, Icons.work, 'TaxBenefits', TaxBenefits()),
            _buildDrawerItem(context, Icons.bookmark_added, 'Address', Address()),
            _buildDrawerItem(context, Icons.trolley, 'Awards', Awards()),
            _buildDrawerItem(context, Icons.work, 'Finance', FinanceScreen()),
            _buildDrawerItem(context, Icons.panorama_fish_eye, 'Employee Papers and Manual', ViewPager()),
          ],
        ),
        _buildDrawerItem(context, Icons.timeline, 'TimeSheet', TimeSheetPage()),
        _buildDrawerItem(context, Icons.money, 'Salary Breakup', SalaryBreakupScreen()),
        _buildDrawerItem(context, Icons.logout, 'Logout', TimeSheetPage()),
      ],
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        Navigator.of(context).push(_createRoute(destination));
      },
    );
  }

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
