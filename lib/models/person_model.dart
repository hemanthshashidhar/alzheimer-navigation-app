class Person {
  final String id;
  final String name;
  final String relationship;
  final String? imageUrl; // Network URL
  final String? imagePath; // Local file path
  final String phoneNumber;
  final String notes;

  Person({
    required this.id,
    required this.name,
    required this.relationship,
    this.imageUrl,
    this.imagePath,
    required this.phoneNumber,
    this.notes = '',
  });

  bool get hasImage => imageUrl != null || imagePath != null;

  Person copyWith({
    String? id,
    String? name,
    String? relationship,
    String? imageUrl,
    String? imagePath,
    String? phoneNumber,
    String? notes,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notes: notes ?? this.notes,
    );
  }
}