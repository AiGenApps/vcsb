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
  List<SyncScheme> _schemes = [];
  SyncScheme? _selectedScheme;

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
        _schemes = jsonData.map((e) => SyncScheme.fromJson(e)).toList();
      });
    }
  }

  void _saveSchemes() async {
    final filePath = await _getFilePath();
    final file = File(filePath);
    final content = jsonEncode(_schemes.map((e) => e.toJson()).toList());
    await file.writeAsString(content);
  }

  void _executeAllOperations(SyncScheme scheme) {
    // 执行方案中的所有同步操作
  }

  void _executeOperation(SyncOperation operation) {
    // 执行单个同步操作
  }

  void _addScheme() {
    setState(() {
      _schemes.add(SyncScheme(name: '新方案', operations: []));
    });
    _saveSchemes();
  }

  void _removeScheme(SyncScheme scheme) {
    setState(() {
      _schemes.remove(scheme);
      if (_selectedScheme == scheme) {
        _selectedScheme = null;
      }
    });
    _saveSchemes();
  }

  void _addOperation(SyncScheme scheme) async {
    String? sourcePath = await _pickDirectory();
    if (sourcePath != null) {
      String? targetPath = await _pickDirectory();
      if (targetPath != null) {
        setState(() {
          scheme.operations
              .add(SyncOperation(source: sourcePath, target: targetPath));
        });
        _saveSchemes();
      }
    }
  }

  Future<String?> _pickDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    return selectedDirectory;
  }

  void _removeOperation(SyncScheme scheme, SyncOperation operation) {
    setState(() {
      scheme.operations.remove(operation);
    });
    _saveSchemes();
  }

  void _editSchemeName(SyncScheme scheme) {
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
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _addScheme,
                child: const Text('添加方案'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _schemes.length,
                  itemBuilder: (context, index) {
                    final scheme = _schemes[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          scheme.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedScheme = scheme;
                          });
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editSchemeName(scheme),
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () => _executeAllOperations(scheme),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeScheme(scheme),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: _selectedScheme == null
              ? const Center(child: Text('请选择一个同步方案'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '同步方案: ${_selectedScheme!.name}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _addOperation(_selectedScheme!),
                      child: const Text('添加同步操作'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _selectedScheme!.operations.length,
                        itemBuilder: (context, index) {
                          final operation = _selectedScheme!.operations[index];
                          return FutureBuilder<String?>(
                            future: _getRemoteUrl(operation.source),
                            builder: (context, sourceSnapshot) {
                              String sourceRemoteUrl =
                                  sourceSnapshot.data ?? '未知';
                              return FutureBuilder<String>(
                                future: _getRepoType(operation.source),
                                builder: (context, sourceRepoSnapshot) {
                                  String sourceRepoType =
                                      sourceRepoSnapshot.data ?? '未知类型';
                                  return FutureBuilder<String?>(
                                    future: _getRemoteUrl(operation.target),
                                    builder: (context, targetSnapshot) {
                                      String targetRemoteUrl =
                                          targetSnapshot.data ?? '未知';
                                      return FutureBuilder<String>(
                                        future: _getRepoType(operation.target),
                                        builder: (context, targetRepoSnapshot) {
                                          String targetRepoType =
                                              targetRepoSnapshot.data ?? '未知类型';
                                          return Card(
                                            margin: const EdgeInsets.all(8.0),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                _getRepoIcon(
                                                                    sourceRepoType,
                                                                    true),
                                                                const SizedBox(
                                                                    width: 8.0),
                                                                Text(
                                                                  sourceRepoType,
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .edit),
                                                                  onPressed: () =>
                                                                      _editSourcePath(
                                                                          operation),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                                '目录: ${operation.source}'),
                                                            Text(
                                                                '远程仓库: $sourceRemoteUrl'),
                                                          ],
                                                        ),
                                                      ),
                                                      const VerticalDivider(),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                _getRepoIcon(
                                                                    targetRepoType,
                                                                    false),
                                                                const SizedBox(
                                                                    width: 8.0),
                                                                Text(
                                                                  targetRepoType,
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .edit),
                                                                  onPressed: () =>
                                                                      _editTargetPath(
                                                                          operation),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                                '目录: ${operation.target}'),
                                                            Text(
                                                                '远程仓库: $targetRemoteUrl'),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Divider(),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.play_arrow),
                                                        onPressed: () =>
                                                            _executeOperation(
                                                                operation),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.delete),
                                                        onPressed: () =>
                                                            _removeOperation(
                                                                _selectedScheme!,
                                                                operation),
                                                      ),
                                                    ],
                                                  ),
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
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
