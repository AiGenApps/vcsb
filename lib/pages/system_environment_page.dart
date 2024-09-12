import 'package:flutter/material.dart';
import 'dart:io';

class SystemEnvironmentPage extends StatelessWidget {
  const SystemEnvironmentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('系统环境'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '版本控制系统支持',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildVersionControlSupport(
                    context,
                    'GIT',
                    '2.30.1',
                    Icons.call_split,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildVersionControlSupport(
                    context,
                    'SVN',
                    '1.14.1',
                    Icons.source,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            // 其他系统环境信息...
          ],
        ),
      ),
    );
  }

  Widget _buildVersionControlSupport(
    BuildContext context,
    String name,
    String version,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                SizedBox(width: 8),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '版本: $version',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
