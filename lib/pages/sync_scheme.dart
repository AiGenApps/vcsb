import 'sync_operation.dart';
import 'package:flutter/material.dart';

class SyncSchemeModel {
  String name;
  final List<SyncOperation> operations;

  SyncSchemeModel({required this.name, required this.operations});

  factory SyncSchemeModel.fromJson(Map<String, dynamic> json) {
    return SyncSchemeModel(
      name: json['name'],
      operations: (json['operations'] as List)
          .map((e) => SyncOperation.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'operations': operations.map((e) => e.toJson()).toList(),
    };
  }
}

class SyncScheme extends StatelessWidget {
  final String sourceRepoType;
  final String targetRepoType;

  const SyncScheme({
    Key? key,
    required this.sourceRepoType,
    required this.targetRepoType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isValidRepoType(String repoType) {
      return repoType == 'git' || repoType == 'svn';
    }

    bool isSourceValid = isValidRepoType(sourceRepoType);
    bool isTargetValid = isValidRepoType(targetRepoType);

    return Container(
      color: isSourceValid && isTargetValid ? Colors.white : Colors.red,
      child: Column(
        children: [
          // ... 现有代码 ...
          ElevatedButton(
            onPressed: isSourceValid && isTargetValid
                ? () {
                    // 同步操作代码
                  }
                : null,
            child: const Text('同步操作'),
          ),
          // ... 现有代码 ...
        ],
      ),
    );
  }
}
