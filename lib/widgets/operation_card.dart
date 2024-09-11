import 'package:flutter/material.dart';
import '../models/sync_operation.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class OperationCard extends StatelessWidget {
  final SyncOperation operation;
  final VoidCallback onRemove;
  final Function(String?, String?) onUpdate;
  final VoidCallback onExecute;

  const OperationCard({
    Key? key,
    required this.operation,
    required this.onRemove,
    required this.onUpdate,
    required this.onExecute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.blue[50], // 添加淡蓝色背景
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildRepoInfo(context, '源仓库', operation.source, true),
                ),
                const SizedBox(width: 16),
                Container(
                  height: 120,
                  width: 1,
                  color: Colors.grey[300],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child:
                      _buildRepoInfo(context, '目标仓库', operation.target, false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: onExecute,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('执行同步'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // 改为蓝色，与卡片背景协调
                    foregroundColor: Colors.white, // 设置文字颜色为白色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepoInfo(
      BuildContext context, String title, String path, bool isSource) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                  isSource ? Icons.folder_open : Icons.drive_folder_upload),
              onPressed: () => _editPath(context, isSource),
              color: Colors.blue,
            ),
            if (isSource) ...[
              _buildRepoTypeIcon(path),
              Expanded(child: _buildRemoteUrl(path)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            path,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRepoTypeIcon(String repoPath) {
    String iconPath = _getRepoTypeIconPath(repoPath);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
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
      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
    return Directory(path.join(repoPath, '.git')).existsSync();
  }

  bool _isSvnRepo(String repoPath) {
    return Directory(path.join(repoPath, '.svn')).existsSync();
  }

  void _editPath(BuildContext context, bool isSource) async {
    // 这里可以实现选择路径的逻辑，例如使用 FilePicker
    // 暂时用一个简单的对话框代替
    String? newPath = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isSource ? '编辑源路径' : '编辑目标路径'),
          content: TextField(
            decoration: InputDecoration(hintText: "输入新路径"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () =>
                  Navigator.of(context).pop('新路径'), // 这里应该返回实际输入的路径
            ),
          ],
        );
      },
    );

    if (newPath != null) {
      onUpdate(isSource ? newPath : null, isSource ? null : newPath);
    }
  }

  String _getRepoTypeIconPath(String repoPath) {
    if (_isGitRepo(repoPath)) {
      return 'assets/images/git.png';
    } else if (_isSvnRepo(repoPath)) {
      return 'assets/images/svn.png';
    } else {
      return 'assets/images/unknown.png'; // 你可能需要添加一个未知类型的图标
    }
  }
}
