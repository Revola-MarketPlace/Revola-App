class MaterialTypeModel {
  final String id;
  final String name;
  final String? description;

  MaterialTypeModel({required this.id, required this.name, this.description});

  factory MaterialTypeModel.fromJson(Map<String, dynamic> json) {
    return MaterialTypeModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
  };
}
