import 'package:flutter/material.dart';
import 'project_management_page.dart';
import 'sync_management_page.dart';
import 'system_environment_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const ProjectManagementPage(),
    const SyncManagementPage(),
    const SystemEnvironmentPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VCSB'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: '项目管理'),
          BottomNavigationBarItem(icon: Icon(Icons.sync), label: '同步管理'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '系统环境'),
        ],
      ),
    );
  }
}
