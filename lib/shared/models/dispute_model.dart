class DisputeModel {
  final String id;
  final String orderId;
  final String reason;
  final String description;
  final String status; // 'OPEN', 'UNDER_REVIEW', 'RESOLVED', 'REJECTED'
  final String? resolutionNotes;
  final DateTime? createdAt;

  DisputeModel({
    required this.id,
    required this.orderId,
    required this.reason,
    required this.description,
    required this.status,
    this.resolutionNotes,
    this.createdAt,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    return DisputeModel(
      id: json['_id'] ?? json['id'] ?? '',
      orderId: json['order'] is Map ? json['order']['_id'] : json['order'] ?? '',
      reason: json['reason'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'OPEN',
      resolutionNotes: json['resolutionNotes'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
