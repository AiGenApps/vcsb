import 'package:flutter/material.dart';

class RepositoryDialog extends StatefulWidget {
  final String? initialName;
  final String? initialType;
  final String? initialPath;
  final Function(String name, String type, String path) onSave;

  const RepositoryDialog({
    Key? key,
    this.initialName,
    this.initialType,
    this.initialPath,
    required this.onSave,
  }) : super(key: key);

  @override
  State<RepositoryDialog> createState() => _RepositoryDialogState();
}

class _RepositoryDialogState extends State<RepositoryDialog> {
  late TextEditingController _nameController;
  late TextEditingController _pathController;
  String _selectedType = 'Git';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _pathController = TextEditingController(text: widget.initialPath);
    _selectedType = widget.initialType ?? 'Git';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? '添加仓库' : '编辑仓库'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '仓库名称'),
          ),
          DropdownButtonFormField<String>(
            value: _selectedType,
            items: ['Git', 'SVN'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedType = newValue!;
              });
            },
            decoration: const InputDecoration(labelText: '仓库类型'),
          ),
          TextField(
            controller: _pathController,
            decoration: const InputDecoration(labelText: '仓库本地路径'),
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
            widget.onSave(
                _nameController.text, _selectedType, _pathController.text);
            Navigator.pop(context);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
