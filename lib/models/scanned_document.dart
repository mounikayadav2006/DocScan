/// Represents a single scanned document record stored in the local database.
class ScannedDocument {
  final int? id;
  final String title;
  final String imagePath;
  final String extractedText;
  final String createdAt; // ISO-8601 string, easy to store & sort in SQLite

  ScannedDocument({
    this.id,
    required this.title,
    required this.imagePath,
    required this.extractedText,
    required this.createdAt,
  });

  /// Converts this object into a Map for SQLite insert/update operations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imagePath': imagePath,
      'extractedText': extractedText,
      'createdAt': createdAt,
    };
  }

  /// Builds a ScannedDocument from a SQLite row.
  factory ScannedDocument.fromMap(Map<String, dynamic> map) {
    return ScannedDocument(
      id: map['id'] as int?,
      title: map['title'] as String,
      imagePath: map['imagePath'] as String,
      extractedText: map['extractedText'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

  ScannedDocument copyWith({
    int? id,
    String? title,
    String? imagePath,
    String? extractedText,
    String? createdAt,
  }) {
    return ScannedDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      extractedText: extractedText ?? this.extractedText,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
