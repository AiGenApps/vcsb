import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../models/sync_scheme.dart';
import '../models/sync_operation.dart';
import 'operation_card.dart';
import 'dart:async';

class SchemeDetailView extends StatefulWidget {
  final SyncSchemeModel scheme;
  final Function(SyncSchemeModel) onAddOperation;
  final Function(SyncSchemeModel, SyncOperation) onRemoveOperation;
  final Function(SyncOperation, {String? source, String? target})
      onUpdateOperation;
  final Function(SyncOperation) onExecuteOperation;
  final Function(SyncSchemeModel, SyncOperation) onCopyOperation;

  const SchemeDetailView({
    Key? key,
    required this.scheme,
    required this.onAddOperation,
    required this.onRemoveOperation,
    required this.onUpdateOperation,
    required this.onExecuteOperation,
    required this.onCopyOperation,
  }) : super(key: key);

  @override
  _SchemeDetailViewState createState() => _SchemeDetailViewState();
}

class _SchemeDetailViewState extends State<SchemeDetailView> {
  StreamController<String> _syncStreamController =
      StreamController<String>.broadcast();

  Future<String> _syncRepo(String repoPath, String? branch) async {
    print("_syncRepo called for $repoPath"); // 添加这行
    String output = "";
    _syncStreamController.add("开始同步仓库: $repoPath\n");
    try {
      if (Directory(path.join(repoPath, '.git')).existsSync()) {
        // Git 仓库同步
        List<String> commands = [];

        // 1. 获取所有远程分支信息
        commands.add('git fetch --all');

        // 2. 切换到指定分支
        if (branch != null && branch.isNotEmpty) {
          commands.add('git checkout $branch');
          // 3. 拉取远程分支最新代码
          commands.add('git pull origin $branch');
        } else {
          // 如果没有指定分支，则使用当前分支
          commands.add('git rev-parse --abbrev-ref HEAD');
          var result = await Process.run(
            'git',
            ['rev-parse', '--abbrev-ref', 'HEAD'],
            workingDirectory: repoPath,
            stdoutEncoding: const SystemEncoding(),
            stderrEncoding: const SystemEncoding(),
          );
          String currentBranch = result.stdout.trim();
          commands.add('git pull origin $currentBranch');
        }

        // 4. 强制重置到远程分支（确保本地与远程完全一致）
        String targetBranch = branch ?? 'HEAD';
        commands.add('git reset --hard origin/$targetBranch');

        // 5. 强制清理工作目录
        commands.add('git clean -fd');

        // 执行命令
        for (String cmd in commands) {
          _syncStreamController.add("> $cmd\n");
          var parts = cmd.split(' ');
          var result = await Process.run(
            parts[0],
            parts.sublist(1),
            workingDirectory: repoPath,
            stdoutEncoding: const SystemEncoding(),
            stderrEncoding: const SystemEncoding(),
          );
          String cmdOutput = "执行结果:\n${result.stdout}${result.stderr}\n";
          output += cmdOutput;
          _syncStreamController.add(cmdOutput);
        }
      } else if (Directory(path.join(repoPath, '.svn')).existsSync()) {
        // SVN 仓库同步
        List<String> command = ['svn', 'update'];
        String commandStr = command.join(' ');
        _syncStreamController.add("> $commandStr\n"); // 添加这行来打印执行的命令
        var result = await Process.run(
          command[0],
          command.sublist(1),
          workingDirectory: repoPath,
          stdoutEncoding: const SystemEncoding(),
          stderrEncoding: const SystemEncoding(),
        );
        String cmdOutput = "执行结果:\n${result.stdout}${result.stderr}\n";
        output += cmdOutput;
        _syncStreamController.add(cmdOutput);
      } else {
        String errorMsg = "未知仓库类型\n";
        output += errorMsg;
        _syncStreamController.add(errorMsg);
      }
    } catch (e) {
      String errorMsg = "同步过程中发生错误: $e\n";
      output += errorMsg;
      _syncStreamController.add(errorMsg);
    }
    _syncStreamController.add("仓库同步完成: $repoPath\n");
    return output;
  }

  Future<String> _fullSync(String sourcePath, String targetPath) async {
    print("_fullSync called"); // 添加这行
    String output = "";

    // 步骤 1: 更新源仓库
    _syncStreamController.add("步骤 1: 更新源仓库\n");
    _syncStreamController.add("====================\n");
    output += await _syncRepo(sourcePath, null);
    _syncStreamController.add("\n步骤 1 完成\n\n");

    // 步骤 2: 更新目标仓库
    _syncStreamController.add("步骤 2: 更新目标仓库\n");
    _syncStreamController.add("====================\n");
    output += await _syncRepo(targetPath, null);
    _syncStreamController.add("\n步骤 2 完成\n\n");

    // 步骤 3: 同步仓库
    _syncStreamController.add("步骤 3: 同步仓库\n");
    _syncStreamController.add("====================\n");
    try {
      _syncStreamController.add("开始删除目标仓库中的非版本控制文件...\n");
      await _deleteNonVersionControlFiles(targetPath);
      _syncStreamController.add("删除完成\n");

      _syncStreamController.add("\n开始复制源仓库文件到目标仓库...\n");
      await _copyFiles(sourcePath, targetPath);
      _syncStreamController.add("复制完成\n");

      String completeMsg = "\n步骤 3 完成\n";
      output += completeMsg;
      _syncStreamController.add(completeMsg);
    } catch (e) {
      String errorMsg = "\n同步过程中发生错误: $e\n";
      output += errorMsg;
      _syncStreamController.add(errorMsg);
    }

    _syncStreamController.add("\n全部同步操作完成。\n");

    return output;
  }

  Future<void> _showCopyConfirmDialog(SyncOperation operation) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认复制'),
          content: Text('您确定要复制这个同步操作吗？'),
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
      final newOperation = SyncOperation(
        name: '${operation.name} 副本',
        source: operation.source,
        target: operation.target,
        sourceBranch: operation.sourceBranch,
        targetBranch: operation.targetBranch,
      );
      widget.onCopyOperation(widget.scheme, newOperation);
    }
  }

  void _duplicateOperation(SyncOperation operation) {
    _showCopyConfirmDialog(operation);
  }

  Future<void> _deleteNonVersionControlFiles(String repoPath) async {
    var dir = Directory(repoPath);
    await for (var entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        var relativePath = path.relative(entity.path, from: repoPath);
        if (!relativePath.startsWith('.git') &&
            !relativePath.startsWith('.svn')) {
          await entity.delete();
        }
      }
    }
  }

  Future<void> _copyFiles(String sourcePath, String targetPath) async {
    var sourceDir = Directory(sourcePath);
    await for (var entity
        in sourceDir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        var relativePath = path.relative(entity.path, from: sourcePath);
        if (!relativePath.startsWith('.git') &&
            !relativePath.startsWith('.svn')) {
          var targetFile = File(path.join(targetPath, relativePath));
          await targetFile.create(recursive: true);
          await entity.copy(targetFile.path);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('同步方案: ${widget.scheme.name}',
            style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => widget.onAddOperation(widget.scheme),
          icon: Icon(Icons.add, size: 24),
          label: Text('添加同步操作', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: widget.scheme.operations.length,
            itemBuilder: (context, index) {
              final operation = widget.scheme.operations[index];
              return OperationCard(
                operation: operation,
                onRemove: () =>
                    widget.onRemoveOperation(widget.scheme, operation),
                onUpdate: (source, target) => widget.onUpdateOperation(
                    operation,
                    source: source,
                    target: target),
                onExecute: () => widget.onExecuteOperation(operation),
                onSync: (path, branch) => _syncRepo(path, branch),
                onDuplicate: (newOperation) => _duplicateOperation(operation),
                onFullSync: _fullSync,
                syncStream: _syncStreamController.stream,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _syncStreamController.close();
    super.dispose();
  }
}
