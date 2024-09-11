import 'sync_operation.dart';

class SyncSchemeModel {
  String name;
  List<SyncOperation> operations;

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
