import 'sync_operation.dart';

class SyncScheme {
  String name;
  final List<SyncOperation> operations;

  SyncScheme({required this.name, required this.operations});

  factory SyncScheme.fromJson(Map<String, dynamic> json) {
    return SyncScheme(
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
