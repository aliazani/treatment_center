import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:treatment_center/core/services/import_service.dart';

abstract class ImportAssessmentEvent extends Equatable {
  const ImportAssessmentEvent();

  @override
  List<Object?> get props => [];
}

class ImportAssessmentFromFileEvent extends ImportAssessmentEvent {
  final String filePath;
  final String format;
  final ImportOptions? options;
  final bool saveAfterImport;

  const ImportAssessmentFromFileEvent({
    required this.filePath,
    required this.format,
    this.options,
    this.saveAfterImport = false,
  });

  @override
  List<Object?> get props => [filePath, format, options, saveAfterImport];
}

class ImportAssessmentFromExcelEvent extends ImportAssessmentEvent {
  final String filePath;
  final bool importSectionDetails;
  final bool validateAfterImport;
  final bool saveAfterImport;

  const ImportAssessmentFromExcelEvent({
    required this.filePath,
    this.importSectionDetails = true,
    this.validateAfterImport = true,
    this.saveAfterImport = false,
  });

  @override
  List<Object?> get props => [
    filePath,
    importSectionDetails,
    validateAfterImport,
    saveAfterImport,
  ];
}

class GetImportStatisticsEvent extends ImportAssessmentEvent {
  final String filePath;
  final String format;

  const GetImportStatisticsEvent({
    required this.filePath,
    required this.format,
  });

  @override
  List<Object?> get props => [filePath, format];
}

class ResetImportStateEvent extends ImportAssessmentEvent {}

final class ImportAssessmentFromExcelBytes extends ImportAssessmentEvent {
  final Uint8List bytes;
  final String originalName;
  final bool saveAfterImport;

  const ImportAssessmentFromExcelBytes({
    required this.bytes,
    required this.originalName,
    this.saveAfterImport = true,
  });

  @override
  List<Object?> get props => [bytes, originalName, saveAfterImport];
}
