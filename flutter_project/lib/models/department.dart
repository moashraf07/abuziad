class Department {
  final int? id;
  final String name;
  final String storeType;
  final String? description;
  final bool isActive;
  final bool isSystem;
  final String createdAt;

  Department({
    this.id,
    required this.name,
    required this.storeType,
    this.description,
    this.isActive = true,
    this.isSystem = false,
    required this.createdAt,
  });

  factory Department.fromMap(Map<String, dynamic> m) => Department(
        id: m['id'] as int?,
        name: m['name'] as String,
        storeType: m['store_type'] as String,
        description: m['description'] as String?,
        isActive: m['is_active'] as bool? ?? true,
        isSystem: m['is_system'] as bool? ?? false,
        createdAt: m['created_at'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'store_type': storeType,
        'description': description,
        'is_active': isActive,
        'is_system': isSystem,
        'created_at': createdAt,
      };

  Department copyWith({
    int? id,
    String? name,
    String? storeType,
    String? description,
    bool? isActive,
    bool? isSystem,
    String? createdAt,
  }) =>
      Department(
        id: id ?? this.id,
        name: name ?? this.name,
        storeType: storeType ?? this.storeType,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
        isSystem: isSystem ?? this.isSystem,
        createdAt: createdAt ?? this.createdAt,
      );
}
