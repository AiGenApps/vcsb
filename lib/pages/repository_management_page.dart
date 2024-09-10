import 'package:flutter/material.dart';
import '../widgets/repository_dialog.dart';

class RepositoryManagementPage extends StatefulWidget {
  final String projectName;
  final List<Map<String, dynamic>> repositories;
  final Function(List<Map<String, dynamic>> repositories) onSave;

  const RepositoryManagementPage({
    Key? key,
    required this.projectName,
    required this.repositories,
    required this.onSave,
  }) : super(key: key);

  @override
  State<RepositoryManagementPage> createState() =>
      _RepositoryManagementPageState();
}

class _RepositoryManagementPageState extends State<RepositoryManagementPage> {
  late List<Map<String, dynamic>> _repositories;

  @override
  void initState() {
    super.initState();
    _repositories = List.from(widget.repositories);
  }

  void _addRepository(String name, String type, String path) {
    setState(() {
      _repositories.add({
        'name': name,
        'type': type,
        'path': path,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    });
    widget.onSave(_repositories);
  }

  void _editRepository(int index, String name, String type, String path) {
    setState(() {
      _repositories[index]['name'] = name;
      _repositories[index]['type'] = type;
      _repositories[index]['path'] = path;
    });
    widget.onSave(_repositories);
  }

  void _deleteRepository(int index) {
    setState(() {
      _repositories.removeAt(index);
    });
    widget.onSave(_repositories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.projectName} - 仓库管理')),
      body: ListView.builder(
        itemCount: _repositories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_repositories[index]['name']),
            subtitle: Text(
                '${_repositories[index]['type']} - ${_repositories[index]['path']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => RepositoryDialog(
                      initialName: _repositories[index]['name'],
                      initialType: _repositories[index]['type'],
                      initialPath: _repositories[index]['path'],
                      onSave: (name, type, path) =>
                          _editRepository(index, name, type, path),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteRepository(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => RepositoryDialog(
            onSave: _addRepository,
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
