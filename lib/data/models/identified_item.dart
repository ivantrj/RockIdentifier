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

  // Snake-specific getters based on the new API response
  /// Get common name from details
  String? get commonName => details['commonName'] as String?;

  /// Get scientific name from details
  String? get scientificName => details['scientificName'] as String?;

  /// Get family from details
  String? get family => details['family'] as String?;

  /// Get genus from details
  String? get genus => details['genus'] as String?;

  /// Get venomous status from details
  String? get venomousStatus => details['venomousStatus'] as String?;

  /// Get habitat from details
  String? get habitat => details['habitat'] as String?;

  /// Get geographic range from details
  String? get geographicRange => details['geographicRange'] as String?;

  /// Get average length from details
  String? get averageLength => details['averageLength'] as String?;

  /// Get average weight from details
  String? get averageWeight => details['averageWeight'] as String?;

  /// Get behavior from details
  String? get behavior => details['behavior'] as String?;

  /// Get diet from details
  String? get diet => details['diet'] as String?;

  /// Get conservation status from details
  String? get conservationStatus => details['conservationStatus'] as String?;

  /// Get safety information from details
  String? get safetyInformation => details['safetyInformation'] as String?;

  /// Get similar species from details
  String? get similarSpecies => details['similarSpecies'] as String?;

  /// Get interesting facts from details
  String? get interestingFacts => details['interestingFacts'] as String?;

  /// Get wiki link from details
  String? get wikiLink => details['wikiLink'] as String?;

  /// Get danger level from details (alias for venomousStatus)
  String? get dangerLevel => venomousStatus;

  /// Get species from details (alias for commonName)
  String? get species => commonName;

  // Legacy getters for backward compatibility (mapped to snake properties)
  String? get coinType => family; // Snake family
  String? get denomination => commonName; // Snake common name
  String? get mintYear => conservationStatus; // Conservation status
  String? get country => geographicRange; // Geographic range
  String? get mintMark => genus; // Snake genus
  String? get metalComposition => diet; // Snake diet
  String? get weight => averageWeight; // Snake weight
  String? get diameter => averageLength; // Snake length
  String? get condition => venomousStatus; // Venomous status
  String? get authenticity => safetyInformation; // Safety information
  String? get rarity => conservationStatus; // Conservation status
  String? get estimatedValue => interestingFacts; // Interesting facts
  String? get historicalContext => interestingFacts; // Interesting facts
  String? get designDescription => behavior; // Snake behavior
  String? get edgeType => habitat; // Snake habitat
  String? get designer => scientificName; // Scientific name
  String? get mintage => averageLength; // Snake length
  String? get marketDemand => conservationStatus; // Conservation status
  String? get investmentPotential => interestingFacts; // Interesting facts
  String? get storageRecommendations => safetyInformation; // Safety information
  String? get cleaningInstructions => safetyInformation; // Safety information
  String? get similarCoins => similarSpecies; // Similar species
  String? get insuranceValue => safetyInformation; // Safety information
  String? get era => conservationStatus; // Conservation status
  String? get coinCategory => family; // Snake family
  String? get order => behavior; // Snake behavior
}
