import 'package:flutter/material.dart';
import '../models/sync_operation.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class OperationCard extends StatefulWidget {
  final SyncOperation operation;
  final VoidCallback onRemove;
  final Function(String?, String?) onUpdate;
  final VoidCallback onExecute;
  final Future<String> Function(String, String?) onSync;
  final Function(SyncOperation) onDuplicate;
  final Future<String> Function(String, String) onFullSync; // 新增全同步功能
  final ValueNotifier<List<String>> syncLogNotifier;

  const OperationCard({
    Key? key,
    required this.operation,
    required this.onRemove,
    required this.onUpdate,
    required this.onExecute,
    required this.onSync,
    required this.onDuplicate,
    required this.onFullSync,
    required this.syncLogNotifier,
  }) : super(key: key);

  @override
  _OperationCardState createState() => _OperationCardState();
}

class _OperationCardState extends State<OperationCard> {
  late TextEditingController sourceController;
  late TextEditingController targetController;
  late TextEditingController nameController;
  List<String> _logLines = [];
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    sourceController =
        TextEditingController(text: widget.operation.sourceBranch ?? '');
    targetController =
        TextEditingController(text: widget.operation.targetBranch ?? '');
    nameController = TextEditingController(text: widget.operation.name);

    // 添加焦点监听器
    sourceController.addListener(() => _onBranchChanged(true));
    targetController.addListener(() => _onBranchChanged(false));
    nameController.addListener(_onNameChanged);
  }

  void _onBranchChanged(bool isSource) {
    // 不在这里立即更新，而是在失去焦点时更新
  }

  void _onNameChanged() {
    // 不在这里立即更新，而是在失去焦点时更新
  }

  @override
  void didUpdateWidget(OperationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.operation.sourceBranch != widget.operation.sourceBranch) {
      sourceController.text = widget.operation.sourceBranch ?? '';
    }
    if (oldWidget.operation.targetBranch != widget.operation.targetBranch) {
      targetController.text = widget.operation.targetBranch ?? '';
    }
    if (oldWidget.operation.name != widget.operation.name) {
      nameController.text = widget.operation.name;
    }
  }

  @override
  void dispose() {
    sourceController.dispose();
    targetController.dispose();
    nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool canFullSync = widget.operation.source.isNotEmpty &&
        widget.operation.target.isNotEmpty;

    return Card(
      elevation: 4,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildNameField(),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child:
                        _buildRepoInfo(context, widget.operation.source, true),
                  ),
                  SizedBox(width: 8),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.grey[300],
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child:
                        _buildRepoInfo(context, widget.operation.target, false),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.sync, color: Colors.green, size: 24),
                  onPressed: canFullSync ? _fullSync : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: canFullSync ? '全同步' : '请选择源仓库和目标仓库',
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.content_copy,
                      color: Colors.blue, size: 24),
                  onPressed: _duplicateOperation,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: '复制操作',
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                  onPressed: widget.onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: '删除操作',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: nameController,
        decoration: InputDecoration(
          labelText: '操作名称',
          border: OutlineInputBorder(),
        ),
        onEditingComplete: () {
          // 在编辑完成时更新操作名称
          widget.onUpdate(null, null);
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }

  Widget _buildRepoInfo(BuildContext context, String path, bool isSource) {
    bool isGitRepo = path.isNotEmpty && _isGitRepo(path);
    bool isSvnRepo = path.isNotEmpty && _isSvnRepo(path);
    bool isValidRepo = isGitRepo || isSvnRepo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildRepoTypeIcon(path),
            SizedBox(width: 4),
            if (isValidRepo)
              Expanded(child: _buildRemoteUrl(path))
            else
              Expanded(
                child: Text(
                  '请选择仓库目录',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            if (isGitRepo) ...[
              SizedBox(width: 4),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: isSource ? sourceController : targetController,
                  decoration: InputDecoration(
                    hintText: '分支',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: 14),
                  onEditingComplete: () {
                    // 在编辑完成时更新分支
                    if (isSource) {
                      widget.operation.sourceBranch = sourceController.text;
                    } else {
                      widget.operation.targetBranch = targetController.text;
                    }
                    widget.onUpdate(null, null);
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            ],
            SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.sync, size: 24),
              onPressed: isValidRepo ? () => _syncRepo(path, isSource) : null,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            IconButton(
              icon: Icon(Icons.folder_open, size: 24),
              onPressed: () => _editPath(context, isSource),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          path.isEmpty ? '未选择目录' : path,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: path.isEmpty ? Colors.red : Colors.black87,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildRepoTypeIcon(String repoPath) {
    String iconPath = _getRepoTypeIconPath(repoPath);
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Image.asset(
        iconPath,
        width: 24,
        height: 24,
      ),
    );
  }

  Widget _buildRemoteUrl(String repoPath) {
    String remoteUrl = _getRemoteUrl(repoPath);
    return Text(
      remoteUrl,
      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _getRemoteUrl(String repoPath) {
    if (_isGitRepo(repoPath)) {
      return _getGitRemoteUrl(repoPath);
    } else if (_isSvnRepo(repoPath)) {
      return _getSvnRemoteUrl(repoPath);
    }
    return '未知远程地址';
  }

  String _getGitRemoteUrl(String repoPath) {
    try {
      var result = Process.runSync(
          'git', ['config', '--get', 'remote.origin.url'],
          workingDirectory: repoPath);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      print('获取 Git 远程地址时出错: $e');
    }
    return 'Git 远程地址未知';
  }

  String _getSvnRemoteUrl(String repoPath) {
    try {
      var result = Process.runSync('svn', ['info', '--show-item', 'url'],
          workingDirectory: repoPath);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      print('获取 SVN 远程地址时出错: $e');
    }
    return 'SVN 远程地址未知';
  }

  bool _isGitRepo(String repoPath) {
    return repoPath.isNotEmpty &&
        Directory(path.join(repoPath, '.git')).existsSync();
  }

  bool _isSvnRepo(String repoPath) {
    return repoPath.isNotEmpty &&
        Directory(path.join(repoPath, '.svn')).existsSync();
  }

  void _syncRepo(String repoPath, bool isSource) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('警告'),
          content: Text('此操作将强制覆盖本地更改。您确定要继续吗？'),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('确定'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _logLines.clear(); // 清除之前的日志
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('同步进度'),
            content: Container(
              width: double.maxFinite,
              height: 300,
              child: ValueListenableBuilder<List<String>>(
                valueListenable: widget.syncLogNotifier,
                builder: (context, logLines, child) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController
                          .jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: logLines.length,
                    itemBuilder: (context, index) {
                      return Text(
                        logLines[index],
                        style: TextStyle(fontFamily: 'Courier'),
                      );
                    },
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('关闭'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      if (_isGitRepo(repoPath)) {
        await widget.onSync(
            repoPath,
            isSource
                ? widget.operation.sourceBranch
                : widget.operation.targetBranch);
      } else if (_isSvnRepo(repoPath)) {
        await widget.onSync(repoPath, null);
      } else {
        await widget.onSync(repoPath, null);
      }
    }
  }

  void _editPath(BuildContext context, bool isSource) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: isSource ? '选择源路径' : '选择目标路径',
    );

    if (selectedDirectory != null) {
      widget.onUpdate(isSource ? selectedDirectory : null,
          isSource ? null : selectedDirectory);
    }
  }

  String _getRepoTypeIconPath(String repoPath) {
    if (repoPath.isEmpty) {
      return 'assets/images/unknown.png';
    } else if (_isGitRepo(repoPath)) {
      return 'assets/images/git.png';
    } else if (_isSvnRepo(repoPath)) {
      return 'assets/images/svn.png';
    } else {
      return 'assets/images/unknown.png';
    }
  }

  void _duplicateOperation() {
    final newOperation = SyncOperation(
      name: '${widget.operation.name} 副本',
      source: widget.operation.source,
      target: widget.operation.target,
      sourceBranch: widget.operation.sourceBranch,
      targetBranch: widget.operation.targetBranch,
    );
    widget.onDuplicate(newOperation); // 调用新的回调函数
  }

  void _fullSync() async {
    if (!widget.operation.source.isNotEmpty ||
        !widget.operation.target.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请确保已选择源仓库和目标仓库')),
      );
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认全同步'),
          content: Text('此操作将同步源仓库和目标仓库，并覆盖目标仓库中的文件。您确定要继续吗？'),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('确定'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _logLines.clear(); // 清除之前的日志
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('全同步进度'),
            content: Container(
              width: double.maxFinite,
              height: 300,
              child: ValueListenableBuilder<List<String>>(
                valueListenable: widget.syncLogNotifier,
                builder: (context, logLines, child) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController
                          .jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: logLines.length,
                    itemBuilder: (context, index) {
                      return Text(
                        logLines[index],
                        style: TextStyle(fontFamily: 'Courier'),
                      );
                    },
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('关闭'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      await widget.onFullSync(widget.operation.source, widget.operation.target);
    }
  }
}
