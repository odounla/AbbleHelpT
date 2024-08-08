import 'package:abblehelptech/pages/earnings/earnings_screens.dart';
import 'package:abblehelptech/pages/homes/home_screen.dart';
import 'package:abblehelptech/pages/profile/profile_screens.dart';
import 'package:abblehelptech/pages/task/task_screens.dart';
import 'package:flutter/material.dart';

class BordsScreens extends StatefulWidget {
  const BordsScreens({super.key});

  @override
  State<BordsScreens> createState() => _BordsScreensState();
}

class _BordsScreensState extends State<BordsScreens> with SingleTickerProviderStateMixin {
  late TabController controller;
  int indexSelected = 0;

  void onBarItemClicked(int i) {
    setState(() {
      indexSelected = i;
      controller.index = indexSelected;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: const [
          HomeScreens(),
          TaskScreens(),
          EarningsScreens(),
          ProfileScreens(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Task"),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "Earnings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: indexSelected,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        showSelectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: onBarItemClicked,
      ),
    );
  }
}
