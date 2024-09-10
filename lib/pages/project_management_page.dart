import 'package:flutter/material.dart';
import '../widgets/project_dialog.dart';
import 'repository_management_page.dart';
import 'dart:io';

class ProjectManagementPage extends StatefulWidget {
  const ProjectManagementPage({super.key});

  @override
  State<ProjectManagementPage> createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {
  List<Map<String, dynamic>> projects = [];

  String _getDefaultProjectPath(String projectName) {
    final userDir = Directory.current.path;
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '')
        .replaceAll('.', '');
    return '$userDir/.vcsb/$projectName-$timestamp';
  }

  void _addProject(String name, String selectedPath) {
    final projectPath =
        selectedPath.isNotEmpty ? selectedPath : _getDefaultProjectPath(name);

    setState(() {
      projects.add({
        'name': name,
        'path': projectPath,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'repositories': <Map<String, dynamic>>[], // 确保类型正确
      });
    });
  }

  void _editProject(int index, String name, String path) {
    setState(() {
      projects[index]['name'] = name;
      projects[index]['path'] = path;
    });
  }

  void _deleteProject(int index) {
    setState(() {
      projects.removeAt(index);
    });
  }

  void _manageRepositories(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RepositoryManagementPage(
          projectName: projects[index]['name'],
          repositories: List<Map<String, dynamic>>.from(
              projects[index]['repositories']), // 确保类型正确
          onSave: (repositories) {
            setState(() {
              projects[index]['repositories'] = repositories;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('项目管理')),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(projects[index]['name']),
            subtitle: Text(projects[index]['path']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.storage),
                  onPressed: () => _manageRepositories(index),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => ProjectDialog(
                      initialName: projects[index]['name'],
                      initialPath: projects[index]['path'],
                      onSave: (name, path) => _editProject(index, name, path),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteProject(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => ProjectDialog(
            onSave: _addProject,
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
