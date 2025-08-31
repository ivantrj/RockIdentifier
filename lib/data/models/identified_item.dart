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

  // Coin-specific getters based on the new API response
  /// Get coin type from details
  String? get coinType => details['coinType'] as String?;

  /// Get specific denomination from details
  String? get denomination => details['denomination'] as String?;

  /// Get mint year from details
  String? get mintYear => details['mintYear'] as String?;

  /// Get country of origin from details
  String? get country => details['country'] as String?;

  /// Get mint mark from details
  String? get mintMark => details['mintMark'] as String?;

  /// Get metal composition from details
  String? get metalComposition => details['metalComposition'] as String?;

  /// Get weight from details
  String? get weight => details['weight'] as String?;

  /// Get diameter from details
  String? get diameter => details['diameter'] as String?;

  /// Get condition from details
  String? get condition => details['condition'] as String?;

  /// Get authenticity from details
  String? get authenticity => details['authenticity'] as String?;

  /// Get rarity from details
  String? get rarity => details['rarity'] as String?;

  /// Get estimated value from details
  String? get estimatedValue => details['estimatedValue'] as String?;

  /// Get historical context from details
  String? get historicalContext => details['historicalContext'] as String?;

  /// Get design description from details
  String? get designDescription => details['designDescription'] as String?;

  /// Get edge type from details
  String? get edgeType => details['edgeType'] as String?;

  /// Get designer from details
  String? get designer => details['designer'] as String?;

  /// Get mintage from details
  String? get mintage => details['mintage'] as String?;

  /// Get current market demand from details
  String? get marketDemand => details['marketDemand'] as String?;

  /// Get investment potential from details
  String? get investmentPotential => details['investmentPotential'] as String?;

  /// Get storage recommendations from details
  String? get storageRecommendations => details['storageRecommendations'] as String?;

  /// Get cleaning instructions from details
  String? get cleaningInstructions => details['cleaningInstructions'] as String?;

  /// Get similar coins from details
  String? get similarCoins => details['similarCoins'] as String?;

  /// Get insurance value from details
  String? get insuranceValue => details['insuranceValue'] as String?;

  /// Get wiki link from details
  String? get wikiLink => details['wikiLink'] as String?;

  /// Get common name from details
  String? get commonName => details['commonName'] as String?;

  /// Get era/period from details (alias for mintYear)
  String? get era => mintYear;

  /// Get coin category from details (alias for coinType)
  String? get coinCategory => coinType;

  // Legacy getters for backward compatibility
  String? get species => denomination;
  String? get family => coinType;
  String? get order => designDescription;
  String? get habitat => country;
  String? get dangerLevel => condition;
}
