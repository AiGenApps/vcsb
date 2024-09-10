class SyncOperation {
  String source;
  String target;

  SyncOperation({required this.source, required this.target});

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      source: json['source'],
      target: json['target'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'target': target,
    };
  }
}
