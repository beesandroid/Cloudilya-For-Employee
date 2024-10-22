import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'PermanentAddressScreen.dart';
import 'TemporaryAddressScreen.dart';

class Address extends StatefulWidget {
  const Address({super.key});

  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController; // Declare PageController

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController(); // Initialize PageController
    _tabController.addListener(() {
      _pageController.jumpToPage(_tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose(); // Dispose of PageController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),iconTheme: IconThemeData(color: Colors.white),
        title: const Text('Address',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
        bottom: TabBar(


          controller: _tabController,
          tabs: const [
            Tab(
              child: Text(
                'Temporary Address',
                style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white ), // Bold text
              ),
            ),
            Tab(
              child: Text(
                'Permanent Address',
                style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white), // Bold text
              ),
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: const [
          TemporaryAddressScreen(),
          PermanentAddressScreen(),
        ],
      ),
    );
  }
}



