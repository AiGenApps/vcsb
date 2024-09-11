import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'sync_scheme.dart';
import 'sync_operation.dart';

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

  void _addScheme() {
    setState(() {
      _schemes.add(SyncSchemeModel(name: '新方案', operations: []));
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

  void _addOperation(SyncSchemeModel scheme) {
    setState(() {
      scheme.operations.add(SyncOperation(source: '', target: ''));
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

  void _editSchemeName(SyncSchemeModel scheme) {
    TextEditingController controller = TextEditingController(text: scheme.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('修改方案名称'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '输入新的方案名称'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  scheme.name = controller.text;
                });
                _saveSchemes();
                Navigator.of(context).pop();
              },
              child: const Text('保存'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
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

  void _editOperation(SyncOperation operation) async {
    String? newSourcePath = await _pickDirectory();
    if (newSourcePath != null) {
      String? newTargetPath = await _pickDirectory();
      if (newTargetPath != null) {
        setState(() {
          operation.source = newSourcePath;
          operation.target = newTargetPath;
        });
        _saveSchemes();
      }
    }
  }

  void _editSourcePath(SyncOperation operation) async {
    String? newSourcePath = await _pickDirectory();
    if (newSourcePath != null) {
      setState(() {
        operation.source = newSourcePath;
      });
      _saveSchemes();
    }
  }

  void _editTargetPath(SyncOperation operation) async {
    String? newTargetPath = await _pickDirectory();
    if (newTargetPath != null) {
      setState(() {
        operation.target = newTargetPath;
      });
      _saveSchemes();
    }
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
            onExecuteScheme: _executeAllOperations,
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
                  onEditSourcePath: _editSourcePath,
                  onEditTargetPath: _editTargetPath,
                  onExecuteOperation: _executeOperation,
                  onRemoveOperation: _removeOperation,
                  getRemoteUrl: _getRemoteUrl,
                  getRepoType: _getRepoType,
                ),
        ),
      ],
    );
  }
}

class SchemeListView extends StatelessWidget {
  final List<SyncSchemeModel> schemes;
  final VoidCallback onAddScheme;
  final Function(SyncSchemeModel) onSelectScheme;
  final Function(SyncSchemeModel) onEditSchemeName;
  final Function(SyncSchemeModel) onExecuteScheme;
  final Function(SyncSchemeModel) onRemoveScheme;

  const SchemeListView({
    Key? key,
    required this.schemes,
    required this.onAddScheme,
    required this.onSelectScheme,
    required this.onEditSchemeName,
    required this.onExecuteScheme,
    required this.onRemoveScheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onAddScheme,
          child: const Text('添加方案'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: schemes.length,
            itemBuilder: (context, index) {
              final scheme = schemes[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => onSelectScheme(scheme),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            scheme.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => onEditSchemeName(scheme),
                        ),
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () => onExecuteScheme(scheme),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => onRemoveScheme(scheme),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SchemeDetailView extends StatelessWidget {
  final SyncSchemeModel scheme;
  final Function(SyncSchemeModel) onAddOperation;
  final Function(SyncOperation) onEditSourcePath;
  final Function(SyncOperation) onEditTargetPath;
  final Function(SyncOperation) onExecuteOperation;
  final Function(SyncSchemeModel, SyncOperation) onRemoveOperation;
  final Future<String?> Function(String) getRemoteUrl;
  final Future<String> Function(String) getRepoType;

  const SchemeDetailView({
    Key? key,
    required this.scheme,
    required this.onAddOperation,
    required this.onEditSourcePath,
    required this.onEditTargetPath,
    required this.onExecuteOperation,
    required this.onRemoveOperation,
    required this.getRemoteUrl,
    required this.getRepoType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '同步方案: ${scheme.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () => onAddOperation(scheme),
          child: const Text('添加同步操作'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: scheme.operations.length,
            itemBuilder: (context, index) {
              final operation = scheme.operations[index];
              return OperationCard(
                operation: operation,
                onEditSourcePath: onEditSourcePath,
                onEditTargetPath: onEditTargetPath,
                onExecuteOperation: onExecuteOperation,
                onRemoveOperation: (op) => onRemoveOperation(scheme, op),
                getRemoteUrl: getRemoteUrl,
                getRepoType: getRepoType,
              );
            },
          ),
        ),
      ],
    );
  }
}

class OperationCard extends StatelessWidget {
  final SyncOperation operation;
  final Function(SyncOperation) onEditSourcePath;
  final Function(SyncOperation) onEditTargetPath;
  final Function(SyncOperation) onExecuteOperation;
  final Function(SyncOperation) onRemoveOperation;
  final Future<String?> Function(String) getRemoteUrl;
  final Future<String> Function(String) getRepoType;

  const OperationCard({
    Key? key,
    required this.operation,
    required this.onEditSourcePath,
    required this.onEditTargetPath,
    required this.onExecuteOperation,
    required this.onRemoveOperation,
    required this.getRemoteUrl,
    required this.getRepoType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getRemoteUrl(operation.source),
      builder: (context, sourceSnapshot) {
        String sourceRemoteUrl = sourceSnapshot.data ?? '未知';
        return FutureBuilder<String>(
          future: getRepoType(operation.source),
          builder: (context, sourceRepoSnapshot) {
            String sourceRepoType = sourceRepoSnapshot.data ?? '未知类型';
            return FutureBuilder<String?>(
              future: getRemoteUrl(operation.target),
              builder: (context, targetSnapshot) {
                String targetRemoteUrl = targetSnapshot.data ?? '未知';
                return FutureBuilder<String>(
                  future: getRepoType(operation.target),
                  builder: (context, targetRepoSnapshot) {
                    String targetRepoType = targetRepoSnapshot.data ?? '未知类型';
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRepoInfo(true, sourceRepoType, operation.source, sourceRemoteUrl),
                            const Divider(),
                            _buildRepoInfo(false, targetRepoType, operation.target, targetRemoteUrl),
                            const Divider(),
                            _buildOperationControls(sourceRepoType, targetRepoType),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRepoInfo(bool isSource, String repoType, String path, String remoteUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _getRepoIcon(repoType, isSource),
            const SizedBox(width: 8.0),
            Text(
              repoType,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => isSource ? onEditSourcePath(operation) : onEditTargetPath(operation),
            ),
          ],
        ),
        Text('目录: $path'),
        Text('远程仓库: $remoteUrl'),
      ],
    );
  }

  Widget _buildOperationControls(String sourceRepoType, String targetRepoType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => onExecuteOperation(operation),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onRemoveOperation(operation),
            ),
          ],
        ),
        if (sourceRepoType == '未知类型' || targetRepoType == '未知类型')
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '源仓库或目标仓库类型不正确！',
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
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
}
