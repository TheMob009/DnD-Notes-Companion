class Note {
  final int id;
  final int campaignId;
  final int? categoryId;
  final String title;
  final String description;
  final bool favorite;
  final int createdAt;
  final int updatedAt;

  // No se persiste directo en notes; se maneja en note_images
  final List<String> images;

  Note({
    required this.id,
    required this.campaignId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.favorite,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
  });

  factory Note.fromMap(Map<String, Object?> m, {List<String> images = const []}) => Note(
        id: m['id'] as int,
        campaignId: m['campaign_id'] as int,
        categoryId: m['category_id'] as int?,
        title: m['title'] as String,
        description: m['description'] as String,
        favorite: (m['favorite'] as int) == 1,
        createdAt: m['created_at'] as int,
        updatedAt: m['updated_at'] as int,
        images: images,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'campaign_id': campaignId,
        'category_id': categoryId,
        'title': title,
        'description': description,
        'favorite': favorite ? 1 : 0,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  Note copyWith({
    int? id,
    int? campaignId,
    int? categoryId,
    String? title,
    String? description,
    bool? favorite,
    int? createdAt,
    int? updatedAt,
    List<String>? images,
  }) {
    return Note(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      favorite: favorite ?? this.favorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
    );
  }
}
