import 'package:flutter/material.dart';
import 'package:logitrust_drivers/tabPages/earning_tab.dart';
import 'package:logitrust_drivers/tabPages/home_tab.dart';
import 'package:logitrust_drivers/tabPages/profile_tab.dart';
import 'package:logitrust_drivers/tabPages/ratings_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin
{
  TabController? tabController;
  int selectedIndex = 0;

  onItemClicked(int index)
  {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });

  }

  @override
  void initState() {
    
    super.initState();

    tabController = TabController(length: 4, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: const [
          HomeTabPage(),
          EarningsTabPage(),
          RatingsTabPage(),
          ProfileTabPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label:' Home ',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label:' Trips ',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label:' Earnings',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label:' Profile',
          ),
        ],

        unselectedItemColor: Colors.white54,
        selectedItemColor: Colors.white,
        backgroundColor: const Color.fromARGB(230, 1, 19, 3) ,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:const TextStyle(fontSize: 14),
        showSelectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}