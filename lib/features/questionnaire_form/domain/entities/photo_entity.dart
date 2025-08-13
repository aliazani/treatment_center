import 'package:equatable/equatable.dart';

enum PhotoSource { camera, gallery }

class PhotoEntity extends Equatable {
  final String id;
  final String fileName;
  final String filePath;
  final PhotoSource source;
  final int fileSizeBytes;
  final DateTime? capturedAt;
  final String? description;

  const PhotoEntity({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.source,
    required this.fileSizeBytes,
    required this.capturedAt,
    this.description,
  });

  PhotoEntity copyWith({
    String? id,
    String? fileName,
    String? filePath,
    PhotoSource? source,
    int? fileSizeBytes,
    DateTime? capturedAt,
    String? description,
  }) {
    return PhotoEntity(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      source: source ?? this.source,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      capturedAt: capturedAt ?? this.capturedAt,
      description: description ?? this.description,
    );
  }

  String get fileSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  @override
  List<Object?> get props => [
    id,
    fileName,
    filePath,
    source,
    fileSizeBytes,
    capturedAt,
    description,
  ];
}
