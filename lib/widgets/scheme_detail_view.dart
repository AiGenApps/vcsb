import 'package:flutter/material.dart';
import '../models/sync_scheme.dart';
import '../models/sync_operation.dart';
import 'operation_card.dart';

class SchemeDetailView extends StatelessWidget {
  final SyncSchemeModel scheme;
  final Function(SyncSchemeModel) onAddOperation;
  final Function(SyncSchemeModel, SyncOperation) onRemoveOperation;
  final Function(SyncOperation, {String? source, String? target})
      onUpdateOperation;
  final Function(SyncOperation) onExecuteOperation;

  const SchemeDetailView({
    Key? key,
    required this.scheme,
    required this.onAddOperation,
    required this.onRemoveOperation,
    required this.onUpdateOperation,
    required this.onExecuteOperation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('同步方案: ${scheme.name}',
            style: Theme.of(context).textTheme.titleLarge),
        ElevatedButton(
          onPressed: () => onAddOperation(scheme),
          child: const Text('添加同步操作'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: scheme.operations.length,
            itemBuilder: (context, index) {
              final operation = scheme.operations[index];
              return OperationCard(
                operation: operation,
                onRemove: () => onRemoveOperation(scheme, operation),
                onUpdate: (source, target) => onUpdateOperation(operation,
                    source: source, target: target),
                onExecute: () => onExecuteOperation(operation),
              );
            },
          ),
        ),
      ],
    );
  }
}
