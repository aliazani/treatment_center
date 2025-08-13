import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/providers/save_path_resolver.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'export_service.dart';

class DocExportService extends BaseExportService {
  final GetSavePath getSavePath;
  static const String _templateAssetPath =
      'assets/templates/fvd_assessment_template.docx';

  DocExportService({
    required super.fileProvider,
    this.getSavePath = defaultSavePath,
  });

  @override
  String get fileExtension => 'docx';

  @override
  String get formatName => 'Microsoft Word';

  @override
  String get mimeType =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

  @override
  Future<ExportResult> exportAssessment(
    AssessmentFormModel assessment, {
    String? outputPath,
    ExportOptions? options,
  }) async {
    try {
      validateForExport(assessment);

      final exportOptions = options ?? const ExportOptions();
      final fileName = getDefaultFileName(assessment);
      final Uint8List documentBytes = await _generateDocxFromTemplate(
        assessment,
        exportOptions,
      );

      final resolvedPath =
          outputPath ??
          await getSavePath(
            fileName: fileName,
            mimeType: mimeType,
            bytes: kIsWeb ? documentBytes : null,
          );

      if (!kIsWeb) {
        final file = await fileProvider.getFile(resolvedPath);
        await fileProvider.writeAsBytes(file, documentBytes);
        await validateExportedFile(resolvedPath, minSizeBytes: 1_000);
      }

      return ExportResult(
        filePath: resolvedPath,
        fileName: fileName,
        format: formatName,
        fileSizeBytes: documentBytes.length,
        // new
        bytes: kIsWeb ? documentBytes : null, // Include bytes on web
        createdAt: DateTime.now(),
        metadata: {
          'wordCount': _estimateWordCount(assessment),
          'pageCount': _estimatePageCount(assessment),
          'sectionsIncluded': assessment.sections.length,
          'itemsIncluded': _getTotalItems(assessment),
          'method': 'template_replacement',
          'criticalItems': _countRatingsByValue(assessment, 1),
          'completionRate': _getCompletionRate(assessment),
          'questionsAnswered': _getCompletedItems(assessment),
          'totalQuestions': _getTotalItems(assessment),
          'templateVersion': 'v3.0_template',
        },
      );
    } catch (e) {
      if (e is ExportException ||
          e is ValidationException ||
          e is FileException) {
        rethrow;
      }
      throw ExportException(
        message: 'Failed to export Word document: ${e.toString()}',
        exportFormat: 'docx',
      );
    }
  }

  Future<Uint8List> _generateDocxFromTemplate(
    AssessmentFormModel assessment,
    ExportOptions options,
  ) async {
    try {
      final ByteData templateData = await rootBundle.load(_templateAssetPath);
      final Uint8List templateBytes = templateData.buffer.asUint8List();

      final archive = ZipDecoder().decodeBytes(templateBytes);
      final newArchive = Archive();

      final replacements = _getCompleteReplacementMap(assessment, options);

      for (final file in archive) {
        if (file.name.contains('document.xml') ||
            file.name.contains('header') ||
            file.name.contains('footer') ||
            file.name.endsWith('.xml')) {
          String content;
          try {
            content = utf8.decode(file.content);
          } catch (e) {
            content = String.fromCharCodes(file.content);
          }

          replacements.forEach((placeholder, value) {
            final cleanValue = _sanitizeValue(value);
            final escapedValue = _escapeXml(cleanValue);

            if (content.contains('{{$placeholder}}')) {
              content = content.replaceAll('{{$placeholder}}', escapedValue);
            }
          });

          final modifiedContent = utf8.encode(content);
          final newFile = ArchiveFile(
            file.name,
            modifiedContent.length,
            modifiedContent,
          );
          newArchive.addFile(newFile);
        } else {
          final newFile = ArchiveFile(
            file.name,
            file.content.length,
            file.content,
          );
          newArchive.addFile(newFile);
        }
      }

      final modifiedBytes = encodeArchive(newArchive);

      if (modifiedBytes == null || modifiedBytes.isEmpty) {
        throw ExportException(
          message: 'Failed to encode DOCX archive',
          exportFormat: 'docx',
        );
      }

      return Uint8List.fromList(modifiedBytes);
    } catch (e) {
      throw ExportException(
        message: 'Failed to export Word document: ${e.toString()}',
        exportFormat: 'docx',
      );
    }
  }

  Map<String, String?> _getCompleteReplacementMap(
    AssessmentFormModel assessment,
    ExportOptions options,
  ) {
    final now = DateTime.now();
    final documentDate = now.toString().split(' ')[0];

    final totalSections = _getSectionsCount(assessment);
    final totalItems = _getTotalItems(assessment);
    final completedItems = _getCompletedItems(assessment);
    final completionRate = _getCompletionRate(assessment);
    final meetsTarget = _countRatingsByValue(assessment, 3);
    final partiallyMeets = _countRatingsByValue(assessment, 2);
    final doesNotMeet = _countRatingsByValue(assessment, 1);
    final dontKnow = _countRatingsByLabel(assessment, 'DK');
    final notApplicable = _countRatingsByLabel(assessment, 'NA');
    final notRated = totalItems - completedItems;

    final baseMap = {
      // Basic information
      'FACILITY_NAME': assessment.facilityIdentification.facilityName,
      'FACILITY_CODE': assessment.facilityIdentification.facilityCode,
      'ASSESSOR_NAME': assessment.assessorInfo.name,
      'ASSESSOR_EMAIL': assessment.assessorInfo.email,
      'ASSESSOR_PHONE': assessment.assessorInfo.phoneNumber,
      'ASSESSMENT_DATE':
          assessment.assessorInfo.assessmentDate.toString().split(' ')[0],
      'DOCUMENT_GENERATED_DATE': documentDate,
      'SUBMISSION_STATUS': assessment.isSubmitted ? "Submitted" : "Draft",
      // Facility details
      'MANAGING_AUTHORITY':
          assessment.facilityIdentification.managingAuthority?.name,
      'STRUCTURE_TYPE': assessment.facilityIdentification.structureType?.name,
      'FACILITY_TYPE': assessment.facilityIdentification.facilityType?.name,
      // Location
      'COUNTRY': assessment.geoLocation.country,
      'REGION_PROVINCE': assessment.geoLocation.regionProvince,
      'DISTRICT': assessment.geoLocation.district,
      'CITY_VILLAGE': assessment.geoLocation.cityVillage,
      'ADDRESS_COORDINATES': assessment.geoLocation.addressOrCoordinates,
      "LATITUDE": assessment.geoLocation.latitude?.toString() ?? 'N/A',
      "LONGITUDE": assessment.geoLocation.longitude?.toString() ?? 'N/A',
      // Contacts
      'DIRECTOR_NAME': assessment.facilityIdentification.directorName,
      'DIRECTOR_PHONE': assessment.facilityIdentification.directorPhone,
      'DIRECTOR_EMAIL': assessment.facilityIdentification.directorEmail,
      'RESPONDENT_NAME': assessment.facilityIdentification.respondentName,
      'RESPONDENT_POSITION':
          assessment.facilityIdentification.respondentPosition,
      // Statistics
      'TOTAL_SECTIONS': totalSections.toString(),
      'TOTAL_ITEMS': totalItems.toString(),
      'COMPLETED_ITEMS': completedItems.toString(),
      'COMPLETION_RATE': completionRate.toStringAsFixed(1),
      // Rating counts
      'MEETS_TARGET_COUNT': meetsTarget.toString(),
      'PARTIALLY_MEETS_COUNT': partiallyMeets.toString(),
      'DOES_NOT_MEET_COUNT': doesNotMeet.toString(),
      'DONT_KNOW_COUNT': dontKnow.toString(),
      'NOT_APPLICABLE_COUNT': notApplicable.toString(),
      'NOT_RATED_COUNT': notRated.toString(),
      // Percentages - FIXED CALCULATION
      'MEETS_TARGET_PERCENTAGE':
          completedItems > 0
              ? ((meetsTarget / completedItems) * 100).toStringAsFixed(1)
              : "0.0",
      'PARTIALLY_MEETS_PERCENTAGE':
          completedItems > 0
              ? ((partiallyMeets / completedItems) * 100).toStringAsFixed(1)
              : "0.0",
      'DOES_NOT_MEET_PERCENTAGE':
          completedItems > 0
              ? ((doesNotMeet / completedItems) * 100).toStringAsFixed(1)
              : "0.0",
      'READINESS_SCORE': _calculateReadinessScore(
        meetsTarget,
        partiallyMeets,
        doesNotMeet,
        completedItems,
      ),
      'COMPLETION_STATUS': completionRate >= 100 ? "Complete" : "Incomplete",
      'CRITICAL_ITEMS_COUNT': doesNotMeet.toString(),
      'HAS_CRITICAL_ITEMS': doesNotMeet > 0 ? "Yes" : "No",
      'PRIORITY_ACTIONS': _generatePriorityActions(doesNotMeet, notRated),
      // Additional facility info fields
      'FACILITY_LOCATION_TYPE': assessment.geoLocation.locationType?.name,
      'EXISTING_FACILITY_TYPE':
          assessment.facilityIdentification.existingFacilityType?.name,
      'OUTPATIENT_SERVICES':
          assessment.facilityServices.hasOutpatientServices == true
              ? 'Yes'
              : 'No',
      'INPATIENT_SERVICES':
          assessment.facilityServices.hasInpatientServices == true
              ? 'Yes'
              : 'No',
      'TOTAL_BEDS': assessment.facilityServices.totalInpatientBeds.toString(),
      'ICU_BEDS': assessment.facilityServices.icuBeds.toString(),
      'EMERGENCY_UNIT':
          assessment.facilityServices.hasEmergencyUnit == true ? 'Yes' : 'No',
      'ICU_UNIT':
          assessment.facilityServices.hasIcuOrHighDependencyUnit == true
              ? 'Yes'
              : 'No',
    };

    final questionMap = _generateAllQuestionPlaceholders(assessment);
    baseMap.addAll(questionMap);

    _validateReplacementMap(baseMap);

    return baseMap;
  }

  Map<String, String> _generateAllQuestionPlaceholders(
    AssessmentFormModel assessment,
  ) {
    final questionMap = <String, String>{};

    for (final section in assessment.sections) {
      for (final item in section.items) {
        final questionKey = _generateQuestionKey(item.sectionNumber);

        questionMap['${questionKey}_RATING'] = _formatQuestionRating(
          item.selectedRating,
        );
      }
    }

    return questionMap;
  }

  String _generateQuestionKey(String? sectionNumber) {
    if (sectionNumber == null) return 'Q_UNK';
    final cleanSection = sectionNumber.replaceAll('.', '_');
    return 'Q_$cleanSection';
  }

  String _formatQuestionRating(dynamic rating) {
    if (rating == null) {
      return '⚪ Not Answered';
    }

    if (rating.value != null) {
      switch (rating.value) {
        case 3:
          return '✅ Meets Target (+++) (3)';
        case 2:
          return '🟡 Partially Meets (++) (2)';
        case 1:
          return '🔴 Does Not Meet (+) (1)';
        case 0:
          return '❓ Don\'t Know (DK)';
        case -1:
          return '➖ Not Applicable (NA)';
        default:
          return '❓ Unknown rating value: ${rating.value}';
      }
    }

    return '❓ Unknown rating format';
  }

  void _validateReplacementMap(Map<String, String?> replacements) {
    final requiredKeys = [
      'FACILITY_NAME',
      'FACILITY_CODE',
      'ASSESSOR_NAME',
      'ASSESSOR_EMAIL',
      'ASSESSOR_PHONE',
      'ASSESSMENT_DATE',
      'TOTAL_SECTIONS',
      'TOTAL_ITEMS',
      'COMPLETED_ITEMS',
      'COMPLETION_RATE',
      'MEETS_TARGET_COUNT',
      'PARTIALLY_MEETS_COUNT',
      'DOES_NOT_MEET_COUNT',
      'DONT_KNOW_COUNT',
      'NOT_APPLICABLE_COUNT',
      'NOT_RATED_COUNT',
      'MEETS_TARGET_PERCENTAGE',
      'PARTIALLY_MEETS_PERCENTAGE',
      'DOES_NOT_MEET_PERCENTAGE',
      'RISK_LEVEL',
      'READINESS_SCORE',
      'COMPLIANCE_STATUS',
      'ASSESSMENT_QUALITY',
      'OVERALL_RATING',
      'CRITICAL_ITEMS_COUNT',
    ];

    for (final key in requiredKeys) {
      if (!replacements.containsKey(key) || replacements[key] == null) {
        replacements[key] = 'N/A';
      }
    }
  }

  // =================== STATISTICAL METHODS ===================
  int _getSectionsCount(AssessmentFormModel assessment) {
    try {
      return assessment.sections.length;
    } catch (e) {
      return 0;
    }
  }

  int _getTotalItems(AssessmentFormModel assessment) {
    try {
      int total = 0;
      for (final section in assessment.sections) {
        total += section.items.length;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  int _getCompletedItems(AssessmentFormModel assessment) {
    try {
      int completed = 0;
      for (final section in assessment.sections) {
        for (final item in section.items) {
          if (item.selectedRating != null) {
            completed++;
          }
        }
      }
      return completed;
    } catch (e) {
      return 0;
    }
  }

  double _getCompletionRate(AssessmentFormModel assessment) {
    try {
      return assessment.completionPercentage;
    } catch (e) {
      return 0.0;
    }
  }

  int _countRatingsByValue(AssessmentFormModel assessment, int value) {
    try {
      int count = 0;
      for (final section in assessment.sections) {
        for (final item in section.items) {
          if (item.selectedRating?.value == value) {
            count++;
          }
        }
      }
      return count;
    } catch (e) {
      return 0;
    }
  }

  int _countRatingsByLabel(AssessmentFormModel assessment, String label) {
    try {
      int count = 0;
      for (final section in assessment.sections) {
        for (final item in section.items) {
          final ratingLabel =
              item.selectedRating?.label.toString().toUpperCase();
          if (ratingLabel != null &&
              ratingLabel.contains(label.toUpperCase())) {
            count++;
          }
        }
      }
      return count;
    } catch (e) {
      return 0;
    }
  }

  String _calculateReadinessScore(
    int meets,
    int partial,
    int doesNotMeet,
    int total,
  ) {
    if (total == 0) return '0.0';
    final score =
        ((meets * 3 + partial * 2 + doesNotMeet * 1) / (total * 3)) * 100;
    return score.toStringAsFixed(1);
  }

  String _generatePriorityActions(int critical, int unanswered) {
    final actions = <String>[];

    if (unanswered > 0) {
      actions.add(
        '${actions.length + 1}. Complete $unanswered unanswered assessment items',
      );
    }
    actions.add(
      '${actions.length + 1}. Develop comprehensive improvement plan',
    );
    actions.add('${actions.length + 1}. Schedule follow-up assessment');

    return actions.join('\n');
  }

  int _estimateWordCount(AssessmentFormModel assessment) {
    final completed = _getCompletedItems(assessment);
    final sections = _getSectionsCount(assessment);
    return 4000 + (completed * 150) + (sections * 400);
  }

  int _estimatePageCount(AssessmentFormModel assessment) {
    final words = _estimateWordCount(assessment);
    return (words / 300).ceil();
  }

  // =================== DOCX UTILITY METHODS ===================
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  String _sanitizeValue(String? value) {
    if (value == null) return '';
    return value
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
  }

  // =================== OVERRIDE METHODS ===================
  @override
  void validateFormatSpecific(AssessmentFormModel assessment) {
    final facilityName = assessment.facilityIdentification.facilityName;

    if (facilityName == 'Unknown Facility') {
      throw ValidationException(
        message: 'Facility name is required for DOCX export',
      );
    }

    final totalItems = _getTotalItems(assessment);
    if (totalItems == 0) {
      throw ValidationException(
        message: 'Assessment must have at least one item for DOCX export',
      );
    }
  }

  List<int>? encodeArchive(Archive archive) {
    return ZipEncoder().encode(archive);
  }
}
