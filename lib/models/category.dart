class Category {
  final int id;
  final int campaignId;
  final String name;
  final int? iconCodePoint;
  final bool isBuiltin;

  Category({
    required this.id,
    required this.campaignId,
    required this.name,
    this.iconCodePoint,
    required this.isBuiltin,
  });

  factory Category.fromMap(Map<String, Object?> m) => Category(
        id: m['id'] as int,
        campaignId: m['campaign_id'] as int,
        name: m['name'] as String,
        iconCodePoint: m['icon_codepoint'] as int?,
        isBuiltin: (m['is_builtin'] as int) == 1,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'campaign_id': campaignId,
        'name': name,
        'icon_codepoint': iconCodePoint,
        'is_builtin': isBuiltin ? 1 : 0,
      };

  Category copyWith({
    int? id,
    int? campaignId,
    String? name,
    int? iconCodePoint,
    bool? isBuiltin,
  }) {
    return Category(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isBuiltin: isBuiltin ?? this.isBuiltin,
    );
  }
}
