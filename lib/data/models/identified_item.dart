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

  // Antique-specific getters based on the new API response
  /// Get item type from details
  String? get itemType => details['itemType'] as String?;

  /// Get specific category from details
  String? get specificCategory => details['specificCategory'] as String?;

  /// Get estimated age from details
  String? get estimatedAge => details['estimatedAge'] as String?;

  /// Get origin from details
  String? get origin => details['origin'] as String?;

  /// Get maker or manufacturer from details
  String? get makerOrManufacturer => details['makerOrManufacturer'] as String?;

  /// Get materials from details
  String? get materials => details['materials'] as String?;

  /// Get construction techniques from details
  String? get constructionTechniques => details['constructionTechniques'] as String?;

  /// Get style from details
  String? get style => details['style'] as String?;

  /// Get condition from details
  String? get condition => details['condition'] as String?;

  /// Get authenticity from details
  String? get authenticity => details['authenticity'] as String?;

  /// Get rarity from details
  String? get rarity => details['rarity'] as String?;

  /// Get estimated value from details
  String? get estimatedValue => details['estimatedValue'] as String?;

  /// Get provenance from details
  String? get provenance => details['provenance'] as String?;

  /// Get markings or signatures from details
  String? get markingsOrSignatures => details['markingsOrSignatures'] as String?;

  /// Get historical context from details
  String? get historicalContext => details['historicalContext'] as String?;

  /// Get care instructions from details
  String? get careInstructions => details['careInstructions'] as String?;

  /// Get restoration notes from details
  String? get restorationNotes => details['restorationNotes'] as String?;

  /// Get similar examples from details
  String? get similarExamples => details['similarExamples'] as String?;

  /// Get market demand from details
  String? get marketDemand => details['marketDemand'] as String?;

  /// Get investment potential from details
  String? get investmentPotential => details['investmentPotential'] as String?;

  /// Get conservation status from details
  String? get conservationStatus => details['conservationStatus'] as String?;

  /// Get display recommendations from details
  String? get displayRecommendations => details['displayRecommendations'] as String?;

  /// Get insurance value from details
  String? get insuranceValue => details['insuranceValue'] as String?;

  /// Get wiki link from details
  String? get wikiLink => details['wikiLink'] as String?;

  /// Get common name from details
  String? get commonName => details['commonName'] as String?;

  /// Get period/era from details (alias for estimatedAge)
  String? get period => estimatedAge;

  /// Get antique category from details (alias for itemType)
  String? get antiqueCategory => itemType;

  // Legacy getters for backward compatibility
  String? get species => specificCategory;
  String? get family => itemType;
  String? get order => style;
  String? get habitat => origin;
  String? get dangerLevel => condition;
}
