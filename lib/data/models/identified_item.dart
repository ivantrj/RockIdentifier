class IdentifiedItem {
  final String id;
  final String imagePath;
  final String name;
  final String commonName;
  final String confidence;
  final Classification classification;
  final Characteristics characteristics;
  final String composition;
  final String formation;
  final String age;
  final String location;
  final String uses;
  final Value value;
  final String careAndStorage;
  final String safety;
  final String interestingFacts;
  final String? wikiLink;
  final DateTime dateTime;
  final String? collection;
  final List<String> tags;
  final bool isFavorite;
  final String? notes;

  IdentifiedItem({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.commonName,
    required this.confidence,
    required this.classification,
    required this.characteristics,
    required this.composition,
    required this.formation,
    required this.age,
    required this.location,
    required this.uses,
    required this.value,
    required this.careAndStorage,
    required this.safety,
    required this.interestingFacts,
    this.wikiLink,
    required this.dateTime,
    this.collection,
    this.tags = const [],
    this.isFavorite = false,
    this.notes,
  });

  factory IdentifiedItem.fromJson(Map<String, dynamic> json) => IdentifiedItem(
        id: json['id'] as String,
        imagePath: json['imagePath'] as String,
        name: json['name'] as String,
        commonName: json['commonName'] as String,
        confidence: json['confidence'] as String,
        classification: Classification.fromJson(json['classification'] as Map<String, dynamic>),
        characteristics: Characteristics.fromJson(json['characteristics'] as Map<String, dynamic>),
        composition: json['composition'] as String,
        formation: json['formation'] as String,
        age: json['age'] as String,
        location: json['location'] as String,
        uses: json['uses'] as String,
        value: Value.fromJson(json['value'] as Map<String, dynamic>),
        careAndStorage: json['careAndStorage'] as String,
        safety: json['safety'] as String,
        interestingFacts: json['interestingFacts'] as String,
        wikiLink: json['wikiLink'] as String?,
        dateTime: DateTime.parse(json['dateTime'] as String),
        collection: json['collection'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        isFavorite: json['isFavorite'] as bool? ?? false,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'name': name,
        'commonName': commonName,
        'confidence': confidence,
        'classification': classification.toJson(),
        'characteristics': characteristics.toJson(),
        'composition': composition,
        'formation': formation,
        'age': age,
        'location': location,
        'uses': uses,
        'value': value.toJson(),
        'careAndStorage': careAndStorage,
        'safety': safety,
        'interestingFacts': interestingFacts,
        'wikiLink': wikiLink,
        'dateTime': dateTime.toIso8601String(),
        'collection': collection,
        'tags': tags,
        'isFavorite': isFavorite,
        'notes': notes,
      };

  IdentifiedItem copyWith({
    String? id,
    String? imagePath,
    String? name,
    String? commonName,
    String? confidence,
    Classification? classification,
    Characteristics? characteristics,
    String? composition,
    String? formation,
    String? age,
    String? location,
    String? uses,
    Value? value,
    String? careAndStorage,
    String? safety,
    String? interestingFacts,
    String? wikiLink,
    DateTime? dateTime,
    String? collection,
    List<String>? tags,
    bool? isFavorite,
    String? notes,
  }) {
    return IdentifiedItem(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      name: name ?? this.name,
      commonName: commonName ?? this.commonName,
      confidence: confidence ?? this.confidence,
      classification: classification ?? this.classification,
      characteristics: characteristics ?? this.characteristics,
      composition: composition ?? this.composition,
      formation: formation ?? this.formation,
      age: age ?? this.age,
      location: location ?? this.location,
      uses: uses ?? this.uses,
      value: value ?? this.value,
      careAndStorage: careAndStorage ?? this.careAndStorage,
      safety: safety ?? this.safety,
      interestingFacts: interestingFacts ?? this.interestingFacts,
      wikiLink: wikiLink ?? this.wikiLink,
      dateTime: dateTime ?? this.dateTime,
      collection: collection ?? this.collection,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      notes: notes ?? this.notes,
    );
  }
}

class Classification {
  final String type;
  final String category;
  final String group;

  Classification({
    required this.type,
    required this.category,
    required this.group,
  });

  factory Classification.fromJson(Map<String, dynamic> json) => Classification(
        type: json['type'] as String,
        category: json['category'] as String,
        group: json['group'] as String,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'category': category,
        'group': group,
      };
}

class Characteristics {
  final String color;
  final String texture;
  final String hardness;
  final String luster;
  final String transparency;
  final String crystalForm;

  Characteristics({
    required this.color,
    required this.texture,
    required this.hardness,
    required this.luster,
    required this.transparency,
    required this.crystalForm,
  });

  factory Characteristics.fromJson(Map<String, dynamic> json) => Characteristics(
        color: json['color'] as String,
        texture: json['texture'] as String,
        hardness: json['hardness'] as String,
        luster: json['luster'] as String,
        transparency: json['transparency'] as String,
        crystalForm: json['crystalForm'] as String,
      );

  Map<String, dynamic> toJson() => {
        'color': color,
        'texture': texture,
        'hardness': hardness,
        'luster': luster,
        'transparency': transparency,
        'crystalForm': crystalForm,
      };
}

class Value {
  final String estimatedValue;
  final String rarity;
  final String factors;

  Value({
    required this.estimatedValue,
    required this.rarity,
    required this.factors,
  });

  factory Value.fromJson(Map<String, dynamic> json) => Value(
        estimatedValue: json['estimatedValue'] as String,
        rarity: json['rarity'] as String,
        factors: json['factors'] as String,
      );

  Map<String, dynamic> toJson() => {
        'estimatedValue': estimatedValue,
        'rarity': rarity,
        'factors': factors,
      };
}
