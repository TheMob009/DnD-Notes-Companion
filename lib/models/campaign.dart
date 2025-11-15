class Campaign {
  final int id;
  final String name;
  final String? edition;
  final int? iconCodePoint;
  final int createdAt;

  Campaign({
    required this.id,
    required this.name,
    this.edition,
    this.iconCodePoint,
    required this.createdAt,
  });

  factory Campaign.fromMap(Map<String, Object?> m) => Campaign(
        id: m['id'] as int,
        name: m['name'] as String,
        edition: m['edition'] as String?,
        iconCodePoint: m['icon_codepoint'] as int?,
        createdAt: m['created_at'] as int,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'edition': edition,
        'icon_codepoint': iconCodePoint,
        'created_at': createdAt,
      };

  Campaign copyWith({
    int? id,
    String? name,
    String? edition,
    int? iconCodePoint,
    int? createdAt,
  }) {
    return Campaign(
      id: id ?? this.id,
      name: name ?? this.name,
      edition: edition ?? this.edition,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
