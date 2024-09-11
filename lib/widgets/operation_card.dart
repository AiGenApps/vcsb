import 'package:flutter/material.dart';
import '../models/sync_operation.dart';

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
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
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
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _editPath(context, isSource),
          icon: Icon(isSource ? Icons.folder_open : Icons.drive_folder_upload),
          label: Text(isSource ? '选择源路径' : '选择目标路径'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue, // 设置文字和图标颜色
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
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
}
