class AudioFile {
  final String id;
  final String name;
  final String filename;
  final String type;
  final String description;

  const AudioFile({
    required this.id,
    required this.name,
    required this.filename,
    required this.type,
    required this.description,
  });

  factory AudioFile.fromJson(Map<String, dynamic> json) {
    return AudioFile(
      id: json['id'] as String,
      name: json['name'] as String,
      filename: json['filename'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filename': filename,
      'type': type,
      'description': description,
    };
  }
}
