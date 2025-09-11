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

  // Rock-specific getters based on the new API response
  /// Get common name from details
  String? get commonName => details['commonName'] as String?;

  /// Get scientific name from details
  String? get scientificName => details['scientificName'] as String?;

  /// Get rock type from details
  String? get rockType => details['rockType'] as String?;

  /// Get mineral composition from details
  String? get mineralComposition => details['mineralComposition'] as String?;

  /// Get hardness from details
  String? get hardness => details['hardness'] as String?;

  /// Get formation from details
  String? get formation => details['formation'] as String?;

  /// Get geographic location from details
  String? get geographicLocation => details['geographicLocation'] as String?;

  /// Get age from details
  String? get age => details['age'] as String?;

  /// Get density from details
  String? get density => details['density'] as String?;

  /// Get crystal structure from details
  String? get crystalStructure => details['crystalStructure'] as String?;

  /// Get color variations from details
  String? get colorVariations => details['colorVariations'] as String?;

  /// Get economic value from details
  String? get economicValue => details['economicValue'] as String?;

  /// Get estimated price range from details
  String? get estimatedPrice => details['estimatedPrice'] ?? details['priceRange'] as String?;

  /// Get market value from details
  String? get marketValue => details['marketValue'] ?? economicValue;

  /// Get usage information from details
  String? get usageInformation => details['usageInformation'] as String?;

  /// Get similar rocks from details
  String? get similarRocks => details['similarRocks'] as String?;

  /// Get interesting facts from details
  String? get interestingFacts => details['interestingFacts'] as String?;

  /// Get wiki link from details
  String? get wikiLink => details['wikiLink'] as String?;

  /// Get authenticity status from details
  String? get authenticity => details['authenticity'] ?? details['isReal'] as String?;

  /// Get quality grade from details
  String? get qualityGrade => details['qualityGrade'] as String?;

  /// Get clarity rating from details
  String? get clarity => details['clarity'] as String?;

  /// Get cleavage pattern from details
  String? get cleavage => details['cleavage'] as String?;

  /// Get luster from details
  String? get luster => details['luster'] as String?;

  /// Get streak color from details
  String? get streak => details['streak'] as String?;

  /// Get fracture pattern from details
  String? get fracture => details['fracture'] as String?;

  /// Get specific gravity from details
  String? get specificGravity => details['specificGravity'] as String?;

  /// Get refractive index from details
  String? get refractiveIndex => details['refractiveIndex'] as String?;

  /// Get pleochroism from details
  String? get pleochroism => details['pleochroism'] as String?;

  /// Get rarity level from details (alias for economicValue)
  String? get rarityLevel => economicValue;

  /// Get rock type from details (alias for commonName)
  String? get rock => commonName;

  // Legacy getters for backward compatibility (mapped to rock properties)
  String? get coinType => rockType; // Rock type
  String? get denomination => commonName; // Rock common name
  String? get mintYear => age; // Rock age
  String? get country => geographicLocation; // Geographic location
  String? get mintMark => mineralComposition; // Mineral composition
  String? get metalComposition => mineralComposition; // Mineral composition
  String? get weight => density; // Rock density
  String? get diameter => hardness; // Rock hardness
  String? get condition => crystalStructure; // Crystal structure
  String? get rarity => economicValue; // Economic value
  String? get estimatedValue => interestingFacts; // Interesting facts
  String? get historicalContext => formation; // Geological formation
  String? get designDescription => crystalStructure; // Crystal structure
  String? get edgeType => formation; // Geological formation
  String? get designer => scientificName; // Scientific name
  String? get mintage => age; // Rock age
  String? get marketDemand => economicValue; // Economic value
  String? get investmentPotential => interestingFacts; // Interesting facts
  String? get storageRecommendations => usageInformation; // Usage information
  String? get cleaningInstructions => usageInformation; // Usage information
  String? get similarCoins => similarRocks; // Similar rocks
  String? get insuranceValue => usageInformation; // Usage information
  String? get era => age; // Rock age
  String? get coinCategory => rockType; // Rock type
  String? get order => crystalStructure; // Crystal structure
}
