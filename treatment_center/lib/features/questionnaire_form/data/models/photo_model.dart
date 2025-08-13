import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';

class PhotoModel extends PhotoEntity {
  const PhotoModel({
    required super.id,
    required super.fileName,
    required super.filePath,
    required super.source,
    required super.fileSizeBytes,
    required super.capturedAt,
    super.description,
  });

  /// Factory constructor to create PhotoModel from PhotoEntity
  /// Useful for converting domain entities to data models
  factory PhotoModel.fromEntity(PhotoEntity entity) {
    return PhotoModel(
      id: entity.id,
      fileName: entity.fileName,
      filePath: entity.filePath,
      source: entity.source,
      fileSizeBytes: entity.fileSizeBytes,
      capturedAt: entity.capturedAt,
      description: entity.description,
    );
  }

  /// Converts PhotoModel back to PhotoEntity
  /// Useful for converting data models to domain entities
  PhotoEntity toEntity() {
    return PhotoEntity(
      id: id,
      fileName: fileName,
      filePath: filePath,
      source: source,
      fileSizeBytes: fileSizeBytes,
      capturedAt: capturedAt,
      description: description,
    );
  }

  /// Factory constructor to create PhotoModel from JSON
  /// Used for deserializing data from APIs or local storage
  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      source: PhotoSource.values.firstWhere(
        (e) => e.toString() == 'PhotoSource.${json['source']}',
        orElse: () => PhotoSource.gallery, // Default fallback
      ),
      fileSizeBytes: json['fileSizeBytes'] as int,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      description: json['description'] as String?,
    );
  }

  /// Converts PhotoModel to JSON
  /// Used for serializing data to APIs or local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'source': source.toString().split('.').last,
      'fileSizeBytes': fileSizeBytes,
      'capturedAt': capturedAt?.toIso8601String(),
      'description': description,
    };
  }

  /// Returns a new PhotoModel with updated fields
  /// Maintains immutability while allowing updates
  @override
  PhotoModel copyWith({
    String? id,
    String? fileName,
    String? filePath,
    PhotoSource? source,
    int? fileSizeBytes,
    DateTime? capturedAt,
    String? description,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      source: source ?? this.source,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      capturedAt: capturedAt,
      description: description,
    );
  }
}
