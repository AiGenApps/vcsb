class SyncOperation {
  String source;
  String target;
  String? sourceBranch; // 新增
  String? targetBranch; // 新增
  String name; // 新增

  SyncOperation({
    required this.source,
    required this.target,
    this.sourceBranch, // 新增
    this.targetBranch, // 新增
    required this.name, // 新增
  });

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      source: json['source'],
      target: json['target'],
      sourceBranch: json['sourceBranch'],
      targetBranch: json['targetBranch'],
      name: json['name'] ?? '未命名操作', // 新增，提供默认值
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'target': target,
      'sourceBranch': sourceBranch,
      'targetBranch': targetBranch,
      'name': name, // 新增
    };
  }
}
