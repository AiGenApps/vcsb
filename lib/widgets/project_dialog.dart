import 'package:flutter/material.dart';
import 'dart:io';

class ProjectDialog extends StatefulWidget {
  final String? initialName;
  final String? initialPath;
  final Function(String name, String path) onSave;

  const ProjectDialog({
    Key? key,
    this.initialName,
    this.initialPath,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<ProjectDialog> {
  late TextEditingController _nameController;
  late TextEditingController _pathController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _pathController = TextEditingController(text: widget.initialPath);
  }

  Future<void> _selectDirectory() async {
    // 使用简单的方式选择目录
    Directory? selectedDirectory = await showDialog<Directory>(
      context: context,
      builder: (context) => DirectoryPickerDialog(),
    );
    if (selectedDirectory != null) {
      setState(() {
        _pathController.text = selectedDirectory.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? '添加项目' : '编辑项目'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '项目名称'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pathController,
                  decoration: const InputDecoration(labelText: '项目路径'),
                  readOnly: true,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.folder_open),
                onPressed: _selectDirectory,
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(_nameController.text, _pathController.text);
            Navigator.pop(context);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}

class DirectoryPickerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择目录'),
      content: const Text('请手动输入目录路径'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            // 这里可以实现手动输入目录路径的逻辑
            Navigator.pop(context, Directory('/path/to/directory'));
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
