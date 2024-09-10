import 'package:flutter/material.dart';
import 'sync_management_page.dart';
import 'system_environment_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 同步管理和系统环境两个Tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text('VCSB'),
          backgroundColor: Colors.grey[200],
          elevation: 0,
        ),
        body: const TabBarView(
          children: [
            SyncManagementPage(),
            SystemEnvironmentPage(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            boxShadow: [
              BoxShadow(
                color: Colors.grey[500]!,
                offset: Offset(4, 4),
                blurRadius: 15,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.white,
                offset: Offset(-4, -4),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TabBar(
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.transparent,
            ),
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.sync), text: '同步管理'),
              Tab(icon: Icon(Icons.settings), text: '设置'),
            ],
          ),
        ),
      ),
    );
  }
}
