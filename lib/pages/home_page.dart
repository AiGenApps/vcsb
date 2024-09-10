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
        ),
        body: const TabBarView(
          children: [
            SyncManagementPage(),
            SystemEnvironmentPage(),
          ],
        ),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(text: '同步管理'),
            Tab(text: '系统环境'),
          ],
        ),
      ),
    );
  }
}

// 删除项目管理的所有功能代码
