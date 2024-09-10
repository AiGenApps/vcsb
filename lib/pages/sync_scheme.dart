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
      decoration: BoxDecoration(
        color: isSourceValid && isTargetValid ? Colors.grey[200] : Colors.red,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[500]!,
            offset: Offset(4, 4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // ... 现有代码 ...
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: isSourceValid && isTargetValid
                    ? () {
                        // 同步操作代码
                      }
                    : null,
                child: const Text('同步操作'),
              ),
              if (!isSourceValid || !isTargetValid)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '源仓库或目标仓库类型不正确！',
                    style: TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          // ... 现有代码 ...
        ],
      ),
    );
  }
}
