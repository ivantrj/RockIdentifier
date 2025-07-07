class IdentifiedItem {
  final String id;
  final String imagePath;
  final String result;
  final String subtitle;
  final double confidence;
  final Map<String, dynamic> details;
  final DateTime dateTime;
  final String? category;
  final String? collection;
  final List<String> tags;
  final bool isFavorite;
  final String? notes;

  IdentifiedItem({
    required this.id,
    required this.imagePath,
    required this.result,
    required this.subtitle,
    required this.confidence,
    required this.details,
    required this.dateTime,
    this.category,
    this.collection,
    this.tags = const [],
    this.isFavorite = false,
    this.notes,
  });

  factory IdentifiedItem.fromJson(Map<String, dynamic> json) => IdentifiedItem(
        id: json['id'] as String,
        imagePath: json['imagePath'] as String,
        result: json['result'] as String,
        subtitle: json['subtitle'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        details: Map<String, dynamic>.from(json['details'] as Map),
        dateTime: DateTime.parse(json['dateTime'] as String),
        category: json['category'] as String?,
        collection: json['collection'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        isFavorite: json['isFavorite'] as bool? ?? false,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'result': result,
        'subtitle': subtitle,
        'confidence': confidence,
        'details': details,
        'dateTime': dateTime.toIso8601String(),
        'category': category,
        'collection': collection,
        'tags': tags,
        'isFavorite': isFavorite,
        'notes': notes,
      };

  /// Create a copy of this item with updated fields
  IdentifiedItem copyWith({
    String? id,
    String? imagePath,
    String? result,
    String? subtitle,
    double? confidence,
    Map<String, dynamic>? details,
    DateTime? dateTime,
    String? category,
    String? collection,
    List<String>? tags,
    bool? isFavorite,
    String? notes,
  }) {
    return IdentifiedItem(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      result: result ?? this.result,
      subtitle: subtitle ?? this.subtitle,
      confidence: confidence ?? this.confidence,
      details: details ?? this.details,
      dateTime: dateTime ?? this.dateTime,
      category: category ?? this.category,
      collection: collection ?? this.collection,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      notes: notes ?? this.notes,
    );
  }

  /// Get estimated price from details
  String? get estimatedPrice => details['Estimated Price'] as String?;

  /// Get species from details
  String? get species => details['Species'] as String?;

  /// Get family from details
  String? get family => details['Family'] as String?;

  /// Get order from details
  String? get order => details['Order'] as String?;

  /// Get habitat from details
  String? get habitat => details['Habitat'] as String?;

  /// Get danger level from details
  String? get dangerLevel => details['Danger Level'] as String?;

  /// Get common name from details
  String? get commonName => details['Common Name'] as String?;

  /// Get distribution from details
  String? get distribution => details['Distribution'] as String?;

  /// Get size from details
  String? get size => details['Size'] as String?;

  /// Get color from details
  String? get color => details['Color'] as String?;

  /// Get life cycle from details
  String? get lifeCycle => details['Life Cycle'] as String?;

  /// Get feeding habits from details
  String? get feedingHabits => details['Feeding Habits'] as String?;

  /// Get conservation status from details
  String? get conservationStatus => details['Conservation Status'] as String?;

  /// Get authenticity from details
  String? get authenticity => details['Authenticity'] as String?;

  /// Get condition from details
  String? get condition => details['Condition'] as String?;
}
