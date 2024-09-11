import 'package:flutter/material.dart';
import '../models/sync_scheme.dart';

class SchemeListView extends StatelessWidget {
  final List<SyncSchemeModel> schemes;
  final Function(String) onAddScheme;
  final Function(SyncSchemeModel) onSelectScheme;
  final Function(SyncSchemeModel, String) onEditSchemeName;
  final Function(SyncSchemeModel) onRemoveScheme;

  const SchemeListView({
    Key? key,
    required this.schemes,
    required this.onAddScheme,
    required this.onSelectScheme,
    required this.onEditSchemeName,
    required this.onRemoveScheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showAddSchemeDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('添加方案'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: schemes.length,
            itemBuilder: (context, index) {
              final scheme = schemes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      scheme.name[0].toUpperCase(),
                      style: TextStyle(
                          color: Colors.blue[800], fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    scheme.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('操作数量: ${scheme.operations.length}'),
                  onTap: () => onSelectScheme(scheme),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditSchemeDialog(context, scheme),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _showDeleteConfirmDialog(context, scheme),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddSchemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newSchemeName = '';
        return AlertDialog(
          title: const Text('添加新方案'),
          content: TextField(
            onChanged: (value) => newSchemeName = value,
            decoration: const InputDecoration(hintText: "输入方案名称"),
          ),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('添加'),
              onPressed: () {
                if (newSchemeName.isNotEmpty) {
                  onAddScheme(newSchemeName);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditSchemeDialog(BuildContext context, SyncSchemeModel scheme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName = scheme.name;
        return AlertDialog(
          title: const Text('编辑方案名称'),
          content: TextField(
            onChanged: (value) => newName = value,
            decoration: InputDecoration(hintText: scheme.name),
          ),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('保存'),
              onPressed: () {
                if (newName.isNotEmpty) {
                  onEditSchemeName(scheme, newName);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, SyncSchemeModel scheme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('您确定要删除方案 "${scheme.name}" 吗？'),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('删除'),
              onPressed: () {
                onRemoveScheme(scheme);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
