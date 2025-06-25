class IdentifiedItem {
  final String id;
  final String imagePath;
  final String result;
  final String subtitle;
  final double confidence;
  final Map<String, dynamic> details;
  final DateTime dateTime;

  IdentifiedItem({
    required this.id,
    required this.imagePath,
    required this.result,
    required this.subtitle,
    required this.confidence,
    required this.details,
    required this.dateTime,
  });

  factory IdentifiedItem.fromJson(Map<String, dynamic> json) => IdentifiedItem(
        id: json['id'] as String,
        imagePath: json['imagePath'] as String,
        result: json['result'] as String,
        subtitle: json['subtitle'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        details: Map<String, dynamic>.from(json['details'] as Map),
        dateTime: DateTime.parse(json['dateTime'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'result': result,
        'subtitle': subtitle,
        'confidence': confidence,
        'details': details,
        'dateTime': dateTime.toIso8601String(),
      };
}
