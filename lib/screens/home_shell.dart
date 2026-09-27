import 'package:flutter/material.dart';

import '../theme.dart';
import 'food_tracker_screen.dart';
import 'planner_screen.dart';
import 'progress_screen.dart';

/// Bottom navigation: Planner | Progress | Food.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const PlannerTab(),
          const ProgressTab(),
          FoodTrackerScreen(weekday: DateTime.now().weekday, embedded: true),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.red.withValues(alpha: 0.2),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: AppColors.red),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            selectedIcon: Icon(Icons.show_chart, color: AppColors.red),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant, color: AppColors.red),
            label: 'Food',
          ),
        ],
      ),
    );
  }
}
