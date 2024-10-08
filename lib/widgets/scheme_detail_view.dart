import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../models/sync_scheme.dart';
import '../models/sync_operation.dart';
import 'operation_card.dart';

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
  Future<String> _syncRepo(String repoPath, String? branch) async {
    try {
      if (Directory(path.join(repoPath, '.git')).existsSync()) {
        // Git 仓库同步
        List<String> commands = [];
        String output = "";

        // 1. 切换到指定分支
        if (branch != null && branch.isNotEmpty) {
          commands.add('git checkout $branch');
        }

        // 2. 获取远程更新
        commands.add('git fetch origin');

        // 3. 强制重置到远程分支
        String targetBranch = branch ?? 'HEAD';
        commands.add('git reset --hard origin/$targetBranch');

        // 4. 强制清理工作目录
        commands.add('git clean -fd');

        // 执行命令
        for (String cmd in commands) {
          var parts = cmd.split(' ');
          var result = await Process.run(
            parts[0],
            parts.sublist(1),
            workingDirectory: repoPath,
            stdoutEncoding: const SystemEncoding(),
            stderrEncoding: const SystemEncoding(),
          );
          output += "执行命令: $cmd\n执行结果:\n${result.stdout}${result.stderr}\n\n";
        }

        return output;
      } else if (Directory(path.join(repoPath, '.svn')).existsSync()) {
        // SVN 仓库同步（保持不变）
        List<String> command = ['svn', 'update'];
        String commandStr = command.join(' ');
        var result = await Process.run(
          command[0],
          command.sublist(1),
          workingDirectory: repoPath,
          stdoutEncoding: const SystemEncoding(),
          stderrEncoding: const SystemEncoding(),
        );
        return "执行命令: $commandStr\n\n执行结果:\n${result.stdout}\n${result.stderr}";
      } else {
        return "未知仓库类型";
      }
    } catch (e) {
      return "同步过程中发生错误: $e";
    }
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
              );
            },
          ),
        ),
      ],
    );
  }
}
