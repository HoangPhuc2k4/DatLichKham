class Doctor {
  final int? id;
  final String name;
  final String specialty;
  final List<String> specializations;
  final int experience;
  final String description;
  final String image;

  Doctor({
    this.id,
    required this.name,
    required this.specialty,
    this.specializations = const [],
    required this.experience,
    required this.description,
    required this.image,
  });

  factory Doctor.fromMap(Map<String, dynamic> map) {
    final rawSpecs = (map['specializations'] as String?) ?? '';
    final specs = rawSpecs
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    return Doctor(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      specialty: map['specialty'] as String? ?? '',
      specializations: specs,
      experience: (map['experience'] as int?) ?? 0,
      description: map['description'] as String? ?? '',
      image: map['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'specializations': specializations.join('|'),
      'experience': experience,
      'description': description,
      'image': image,
    };
  }
}

