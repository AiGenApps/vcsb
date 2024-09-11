import 'package:flutter/material.dart';
import 'dart:io';

class SystemEnvironmentPage extends StatefulWidget {
  const SystemEnvironmentPage({super.key});

  @override
  State<SystemEnvironmentPage> createState() => _SystemEnvironmentPageState();
}

class _SystemEnvironmentPageState extends State<SystemEnvironmentPage> {
  bool _gitSupported = false;
  bool _svnSupported = false;
  String _gitVersion = '';
  String _svnVersion = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkEnvironment();
  }

  Future<void> _checkEnvironment() async {
    if (!mounted) return;

    try {
      final gitResult = await _checkCommand('git');
      final svnResult = await _checkCommand('svn');
      if (mounted) {
        setState(() {
          _gitSupported = gitResult.supported;
          _svnSupported = svnResult.supported;
          _gitVersion = gitResult.version;
          _svnVersion = svnResult.version;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('环境检查出错: $e');
    }
  }

  Future<CommandResult> _checkCommand(String command) async {
    try {
      final result = await Process.run(command, ['--version']);
      if (result.exitCode == 0) {
        return CommandResult(
          supported: true,
          version: result.stdout.toString().split('\n').first.trim(),
        );
      }
    } catch (e) {
      // 命令不存在或执行出错
    }
    return CommandResult(supported: false, version: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('系统环境'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '版本控制系统支持',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSupportCard(
                      'Git',
                      _gitSupported,
                      _gitVersion,
                      Icons.code,
                      Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    _buildSupportCard(
                      'SVN',
                      _svnSupported,
                      _svnVersion,
                      Icons.storage,
                      Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSupportCard(String title, bool isSupported, String version,
      IconData icon, Color color) {
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
                Icon(icon, size: 32, color: color),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  isSupported ? Icons.check_circle : Icons.cancel,
                  color: isSupported ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  isSupported ? '支持' : '不支持',
                  style: TextStyle(
                    fontSize: 16,
                    color: isSupported ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (isSupported && version.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '版本: $version',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CommandResult {
  final bool supported;
  final String version;

  CommandResult({required this.supported, required this.version});
}
