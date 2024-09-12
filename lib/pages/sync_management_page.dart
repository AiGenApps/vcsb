import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/sync_scheme.dart';
import '../models/sync_operation.dart';
import '../widgets/scheme_list_view.dart';
import '../widgets/scheme_detail_view.dart';

class SyncManagementPage extends StatefulWidget {
  const SyncManagementPage({super.key});

  @override
  _SyncManagementPageState createState() => _SyncManagementPageState();
}

class _SyncManagementPageState extends State<SyncManagementPage> {
  List<SyncSchemeModel> _schemes = [];
  SyncSchemeModel? _selectedScheme;

  @override
  void initState() {
    super.initState();
    _loadSchemes();
  }

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/vcsb';
    final filePath = '$path/.vcsb_rc';

    // 确保目录存在
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return filePath;
  }

  void _loadSchemes() async {
    final filePath = await _getFilePath();
    final file = File(filePath);
    if (await file.exists()) {
      final content = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(content);
      setState(() {
        _schemes = jsonData.map((e) => SyncSchemeModel.fromJson(e)).toList();
      });
    }
  }

  void _saveSchemes() async {
    final filePath = await _getFilePath();
    final file = File(filePath);
    final content = jsonEncode(_schemes.map((e) => e.toJson()).toList());
    await file.writeAsString(content);
  }

  void _executeAllOperations(SyncSchemeModel scheme) {
    // 执行方案中的所有同步操作
  }

  void _executeOperation(SyncOperation operation) {
    // 执行单个同步操作
  }

  void _addScheme(String name) {
    setState(() {
      _schemes.add(SyncSchemeModel(name: name, operations: []));
    });
    _saveSchemes();
  }

  void _removeScheme(SyncSchemeModel scheme) {
    setState(() {
      _schemes.remove(scheme);
      if (_selectedScheme == scheme) {
        _selectedScheme = null;
      }
    });
    _saveSchemes();
  }

  void _editSchemeName(SyncSchemeModel scheme, String newName) {
    setState(() {
      scheme.name = newName;
    });
    _saveSchemes();
  }

  void _addOperation(SyncSchemeModel scheme) {
    setState(() {
      SyncOperation newOperation = SyncOperation(
        source: '',
        target: '',
        name: '新建操作 ${scheme.operations.length + 1}', // 添加这一行
      );
      scheme.operations.add(newOperation);
    });
    _saveSchemes();
  }

  Future<String?> _pickDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    return selectedDirectory;
  }

  void _removeOperation(SyncSchemeModel scheme, SyncOperation operation) {
    setState(() {
      scheme.operations.remove(operation);
    });
    _saveSchemes();
  }

  void _updateOperation(SyncOperation operation,
      {String? source, String? target}) {
    setState(() {
      if (source != null) operation.source = source;
      if (target != null) operation.target = target;
    });
    _saveSchemes();
  }

  Future<String?> _getRemoteUrl(String path) async {
    if (await Directory('$path/.git').exists()) {
      // Git repository
      final result = await Process.run(
          'git', ['-C', path, 'config', '--get', 'remote.origin.url']);
      return result.stdout.toString().trim();
    } else if (await File('$path/.svn/entries').exists()) {
      // SVN repository
      final result =
          await Process.run('svn', ['info', '--show-item', 'url', path]);
      return result.stdout.toString().trim();
    }
    return null;
  }

  Future<String> _getRepoType(String path) async {
    if (await Directory('$path/.git').exists()) {
      return 'Git 仓库';
    } else if (await File('$path/.svn/entries').exists()) {
      return 'SVN 仓库';
    }
    return '未知类型';
  }

  Icon _getRepoIcon(String repoType, bool isSource) {
    if (isSource) {
      switch (repoType) {
        case 'Git 仓库':
          return const Icon(Icons.source, color: Colors.green);
        case 'SVN 仓库':
          return const Icon(Icons.source, color: Colors.blue);
        default:
          return const Icon(Icons.source, color: Colors.grey);
      }
    } else {
      switch (repoType) {
        case 'Git 仓库':
          return const Icon(Icons.file_download, color: Colors.green);
        case 'SVN 仓库':
          return const Icon(Icons.file_download, color: Colors.blue);
        default:
          return const Icon(Icons.file_download, color: Colors.grey);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SchemeListView(
            schemes: _schemes,
            onAddScheme: _addScheme,
            onSelectScheme: (scheme) {
              setState(() {
                _selectedScheme = scheme;
              });
            },
            onEditSchemeName: _editSchemeName,
            onRemoveScheme: _removeScheme,
          ),
        ),
        Expanded(
          flex: 2,
          child: _selectedScheme == null
              ? const Center(child: Text('请选择一个同步方案'))
              : SchemeDetailView(
                  scheme: _selectedScheme!,
                  onAddOperation: _addOperation,
                  onRemoveOperation: _removeOperation,
                  onUpdateOperation: _updateOperation,
                  onExecuteOperation: _executeOperation,
                ),
        ),
      ],
    );
  }
}
