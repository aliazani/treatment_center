import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/providers/save_path_resolver.dart';

import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'export_service.dart';

class ExcelExportService extends BaseExportService {
  final GetSavePath getSavePath;

  ExcelExportService({
    required super.fileProvider,
    this.getSavePath = defaultSavePath,
  });

  @override
  String get fileExtension => 'xlsx';

  @override
  String get formatName => 'Microsoft Excel';

  @override
  String get mimeType =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  @override
  Future<ExportResult> exportAssessment(
    AssessmentFormModel assessment, {
    String? outputPath,
    ExportOptions? options,
  }) async {
    try {
      // Validate assessment before export
      validateForExport(assessment);

      final exportOptions = options ?? const ExportOptions();
      final fileName = getDefaultFileName(assessment); // we still need it

      // Create Excel workbook
      final excel = Excel.createExcel();

      // Build the workbook content
      await _buildExcelWorkbook(excel, assessment, exportOptions);

      // Save the workbook
      final List<int>? bytes = excel.save();
      if (bytes == null) {
        throw ExcelExportException(
          message: 'Failed to generate Excel file bytes',
        );
      }

      // new
      final bytesUint8List = Uint8List.fromList(bytes);

      final resolvedPath =
          outputPath ??
          await getSavePath(
            fileName: fileName,
            mimeType: mimeType,
            bytes: kIsWeb ? Uint8List.fromList(bytes) : null,
          );

      if (!kIsWeb) {
        final file = await fileProvider.getFile(resolvedPath);
        await fileProvider.writeAsBytes(file, bytes);
      }
      if (!kIsWeb) {
        await validateExportedFile(resolvedPath, minSizeBytes: 1_000);
      }

      return ExportResult(
        filePath: resolvedPath,
        fileName: fileName,
        format: formatName,
        fileSizeBytes: bytes.length,
        createdAt: DateTime.now(),
        // new
        bytes: kIsWeb ? bytesUint8List : null, // Include bytes on web

        metadata: {
          'sheets': _getSheetCount(exportOptions, assessment),
          'includeAnalysis': exportOptions.includeAnalysis,
          'includeSectionDetails': exportOptions.includeSectionDetails,
          'photoCount': assessment.photos.length,
        },
      );
    } catch (e) {
      if (e is ExportException ||
          e is ValidationException ||
          e is FileException) {
        rethrow;
      }
      throw ExcelExportException(
        message: 'Failed to export Excel file: ${e.toString()}',
      );
    }
  }

  /// Build the complete Excel workbook
  Future<void> _buildExcelWorkbook(
    Excel excel,
    AssessmentFormModel assessment,
    ExportOptions options,
  ) async {
    // Create main summary sheet
    final mainSheet = excel['Assessment Summary'];
    await _buildSummarySheet(mainSheet, assessment);

    // Section detail sheets
    if (options.includeSectionDetails) {
      for (int i = 0; i < assessment.sections.length; i++) {
        final section = assessment.sections[i];
        final sheetName = _sanitizeSheetName('Section ${i + 1}');
        final sectionSheet = excel[sheetName];
        await _buildSectionSheet(sectionSheet, section, assessment);
      }
    }

    // Analysis sheet
    if (options.includeAnalysis) {
      final analysisSheet = excel['Analysis'];
      await _buildAnalysisSheet(analysisSheet, assessment);
    }

    // Remove default sheet AFTER creating all other sheets
    try {
      excel.delete('Sheet1');
    } catch (e) {
      // Ignore if Sheet1 doesn't exist or can't be deleted
    }
  }

  /// Sanitize sheet name to meet Excel requirements
  String _sanitizeSheetName(String name) {
    // Excel sheet names must be <= 31 chars and cannot contain: \ / ? * [ ]
    String sanitized = name
        .replaceAll(RegExp(r'[\\\/\?\*\[\]]'), '_')
        .substring(0, name.length > 31 ? 31 : name.length);
    return sanitized.trim();
  }

  /// Build the main summary sheet - REFACTORED to use entity methods
  Future<void> _buildSummarySheet(
    Sheet sheet,
    AssessmentFormModel assessment,
  ) async {
    int currentRow = 0;

    // =======================================================================
    // ASSESSMENT STATUS & COMPLETION SUMMARY - USING ENTITY METHODS
    // =======================================================================
    _addSectionHeader(
      sheet,
      currentRow,
      'Assessment Status & Completion Summary',
    );
    currentRow += 1;

    // Use entity's calculated properties
    final statusData = [
      [
        'Assessment Status',
        assessment.status,
      ], // Using entity's status property
      [
        'Completion Rate',
        '${assessment.completionPercentage.toStringAsFixed(1)}%',
      ], // Entity method
      [
        'Submission Date',
        assessment.submissionDate?.toString().split(' ')[0] ?? 'Not submitted',
      ],
      ['Total Sections', assessment.sections.length.toString()],
      [
        'Total Assessment Items',
        assessment.totalItems.toString(),
      ], // Entity property
      [
        'Completed Items',
        assessment.completedItems.toString(),
      ], // Entity property
      [
        'Unanswered Items',
        (assessment.totalItems - assessment.completedItems).toString(),
      ], // Calculated from entity
    ];

    for (final row in statusData) {
      _setCellValue(sheet, currentRow, 0, row[0]);
      _setCellValue(sheet, currentRow, 1, row[1]);
      _styleCell(sheet, currentRow, 0, isBold: true);

      // Color code completion rate
      if (row[0] == 'Completion Rate') {
        final completionRate = assessment.completionPercentage;
        final color =
            completionRate >= 80
                ? '#C6EFCE'
                : completionRate >= 50
                ? '#FFEB9C'
                : '#FFC7CE';
        _styleCell(sheet, currentRow, 1, bgColor: color, isBold: true);
      }
      currentRow++;
    }
    currentRow += 2;

    // =======================================================================
    // RATING DISTRIBUTION OVERVIEW - USING ENTITY + HELPER METHODS
    // =======================================================================
    _addSectionHeader(sheet, currentRow, 'Rating Distribution Overview');
    currentRow += 1;

    final meetsTarget = _countRatingsByValue(assessment, 3);
    final partiallyMeets = _countRatingsByValue(assessment, 2);
    final doesNotMeet = _countRatingsByValue(assessment, 1);
    final dontKnow = _countRatingsByLabel(assessment, 'DK');
    final notApplicable = _countRatingsByLabel(assessment, 'NA');
    final unanswered =
        assessment.totalItems -
        assessment.completedItems; // Using entity calculation
    final totalItems = assessment.totalItems; // Using entity property

    final ratingDistributionData = [
      ['Meets Target (+++)', meetsTarget.toString(), '#C6EFCE'],
      ['Partially Meets (++)', partiallyMeets.toString(), '#FFEB9C'],
      ['Does Not Meet (+)', doesNotMeet.toString(), '#FFC7CE'],
      ['Don\'t Know (DK)', dontKnow.toString(), '#E6E6FA'],
      ['Not Applicable (NA)', notApplicable.toString(), '#F0F0F0'],
      ['Not Answered', unanswered.toString(), '#FFE6E6'],
      ['TOTAL ITEMS', totalItems.toString(), '#D9E2F3'],
    ];

    for (final row in ratingDistributionData) {
      _setCellValue(sheet, currentRow, 0, row[0]);
      _setCellValue(sheet, currentRow, 1, row[1]);
      _styleCell(sheet, currentRow, 0, isBold: true);
      _styleCell(sheet, currentRow, 1, bgColor: row[2], isBold: true);
      currentRow++;
    }
    currentRow += 2;

    // =======================================================================
    // SECTIONS OVERVIEW - USING SECTION ENTITY METHODS
    // =======================================================================
    _addSectionHeader(sheet, currentRow, 'Sections Overview');
    currentRow += 1;

    // Headers for sections table
    final headers = [
      'Section',
      'Title',
      'Total Items',
      'Completed',
      'Unanswered',
      'Progress %',
    ];
    for (int i = 0; i < headers.length; i++) {
      _setCellValue(sheet, currentRow, i, headers[i]);
      _styleCell(sheet, currentRow, i, isBold: true, bgColor: '#D9E2F3');
    }
    currentRow++;

    // Section data - USING ENTITY METHODS
    for (final section in assessment.sections) {
      final int totalItems;
      final int completedItems;
      final double progress;

      if (section.sectionNumber == '1') {
        final section1CompletedCount = assessment.section1CompletedItems;
        final section1TotalCount = assessment.section1TotalItems;
        totalItems = section1TotalCount;
        completedItems = section1CompletedCount;
        progress = totalItems > 0 ? (completedItems / totalItems) * 100 : 0.0;
      } else {
        // For other sections, use section entity methods
        totalItems = section.items.length;
        completedItems =
            section.completedItemsCount; // Using section entity method
        progress = totalItems > 0 ? (completedItems / totalItems) * 100 : 0.0;
      }

      final int unansweredItems = totalItems - completedItems;

      _setCellValue(sheet, currentRow, 0, section.sectionNumber);
      _setCellValue(sheet, currentRow, 1, section.title);
      _setCellValue(sheet, currentRow, 2, totalItems);
      _setCellValue(sheet, currentRow, 3, completedItems);
      _setCellValue(sheet, currentRow, 4, unansweredItems);
      _setCellValue(sheet, currentRow, 5, '${progress.toStringAsFixed(1)}%');

      // Color code progress
      final progressColor =
          progress >= 80
              ? '#C6EFCE'
              : progress >= 50
              ? '#FFEB9C'
              : '#FFC7CE';
      _styleCell(sheet, currentRow, 5, bgColor: progressColor);

      // Highlight unanswered items
      if (unansweredItems > 0) {
        _styleCell(sheet, currentRow, 4, bgColor: '#FFE6E6', isBold: true);
      }

      currentRow++;
    }
  }

  Future<void> _buildSectionSheet(
    Sheet sheet,
    dynamic section,
    AssessmentFormModel assessment,
  ) async {
    int currentRow = 0;

    // Section title
    final sectionTitle = section.title ?? 'Section ${section.sectionNumber}';
    _setCellValue(
      sheet,
      currentRow,
      0,
      'Section ${section.sectionNumber}: $sectionTitle',
    );
    _styleCell(
      sheet,
      currentRow,
      0,
      fontSize: 16,
      isBold: true,
      bgColor: '#2E75B6',
      fontColor: '#FFFFFF',
    );
    sheet.merge(
      CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 0),
      CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 6),
    );
    currentRow += 2;

    // Section description
    if (section.description != null && section.description.isNotEmpty) {
      _setCellValue(
        sheet,
        currentRow,
        0,
        'Description: ${section.description}',
      );
      _styleCell(sheet, currentRow, 0, isItalic: true);
      sheet.merge(
        CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 0),
        CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 6),
      );
      currentRow += 2;
    }

    // Section progress summary - USING ENTITY METHODS
    final int totalItems;
    final int completedItems;
    final double progress;

    if (section.sectionNumber == '1') {
      // For section 1, use the assessment entity's comprehensive calculation
      totalItems = assessment.section1TotalItems;
      completedItems = assessment.section1CompletedItems;
      progress = assessment.section1Progress;
    } else {
      // For other sections, use section entity methods
      totalItems = section.items.length;
      completedItems =
          section.completedItemsCount; // Using section entity method
      progress =
          completedItems > 0
              ? (completedItems / totalItems) * 100
              : 0.0; // Using section entity method
    }

    final int unansweredItems = totalItems - completedItems;

    _setCellValue(
      sheet,
      currentRow,
      0,
      'Progress: $completedItems/$totalItems items completed, $unansweredItems unanswered (${progress.toStringAsFixed(1)}%)',
    );
    _styleCell(sheet, currentRow, 0, isBold: true, bgColor: '#E7F3FF');
    sheet.merge(
      CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 0),
      CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 6),
    );
    currentRow += 2;

    if (section.sectionNumber == '1') {
      // =======================================================================
      // 1.1 ASSESSMENT INFORMATION
      // =======================================================================
      _addSectionHeader(sheet, currentRow, '1.1 Assessment Information');
      currentRow += 1;

      final assessmentInfoData = [
        [
          '1.1.1',
          'Date of assessment',
          assessment.assessorInfo.assessmentDate.toString().split(' ')[0],
        ],
        [
          '1.1.2',
          'Name of person conducting assessment',
          assessment.assessorInfo.name,
        ],
        ['1.1.3', 'Email', assessment.assessorInfo.email],
        ['1.1.4', 'Phone', assessment.assessorInfo.phoneNumber],
      ];

      // Add headers for assessment info table
      _setCellValue(sheet, currentRow, 0, 'Item #');
      _setCellValue(sheet, currentRow, 1, 'Description');
      _setCellValue(sheet, currentRow, 2, 'Value');
      _styleCell(sheet, currentRow, 0, isBold: true, bgColor: '#E7F3FF');
      _styleCell(sheet, currentRow, 1, isBold: true, bgColor: '#E7F3FF');
      _styleCell(sheet, currentRow, 2, isBold: true, bgColor: '#E7F3FF');
      currentRow++;

      for (final row in assessmentInfoData) {
        _setCellValue(sheet, currentRow, 0, row[0]);
        _setCellValue(sheet, currentRow, 1, row[1]);
        _setCellValue(sheet, currentRow, 2, row[2]);
        _styleCell(sheet, currentRow, 0, isBold: true);
        currentRow++;
      }
      currentRow += 2;

      // =======================================================================
      // 1.2 GEOGRAPHICAL LOCATION
      // =======================================================================
      _addSectionHeader(sheet, currentRow, '1.2 Geographical Location');
      currentRow += 1;

      final geoLocationData = [
        ['1.2.1', 'Country', assessment.geoLocation.country],
        ['1.2.2', 'Region/Province', assessment.geoLocation.regionProvince],
        ['1.2.3', 'District', assessment.geoLocation.district],
        ['1.2.4', 'City/Village', assessment.geoLocation.cityVillage],
        [
          '1.2.5',
          'Address/GPS coordinates',
          assessment.geoLocation.addressOrCoordinates,
        ],
        [
          '1.2.6',
          'Record of facility location',
          assessment.geoLocation.locationType?.name,
        ],
        [
          '1.2.7',
          'Latitude',
          assessment.geoLocation.latitude?.toString() ?? 'Not specified',
        ],
        [
          '1.2.8',
          'Longitude',
          assessment.geoLocation.longitude?.toString() ?? 'Not specified',
        ],
      ];

      _setCellValue(sheet, currentRow, 0, 'Item #');
      _setCellValue(sheet, currentRow, 1, 'Description');
      _setCellValue(sheet, currentRow, 2, 'Value');
      _styleCell(sheet, currentRow, 0, isBold: true, bgColor: '#E7F3FF');
      _styleCell(sheet, currentRow, 1, isBold: true, bgColor: '#E7F3FF');
      _styleCell(sheet, currentRow, 2, isBold: true, bgColor: '#E7F3FF');
      currentRow++;

      for (final row in geoLocationData) {
        _setCellValue(sheet, currentRow, 0, row[0]);
        _setCellValue(sheet, currentRow, 1, row[1]);
        _setCellValue(sheet, currentRow, 2, row[2]);
        _styleCell(sheet, currentRow, 0, isBold: true);
        currentRow++;
      }
      currentRow += 2;

      // =======================================================================
      // 1.3 FACILITY IDENTIFICATION
      // =======================================================================
      _addSectionHeader(sheet, currentRow, '1.3 Facility Identification');
      currentRow += 1;

      final facilityIdentificationData = [
        [
          '1.3.1',
          'Facility code',
          assessment.facilityIdentification.facilityCode,
        ],
        [
          '1.3.2',
          'Facility name',
          assessment.facilityIdentification.facilityName,
        ],
        [
          '1.3.3',
          'Managing authority',
          getManagingAuthorityText(
            assessment.facilityIdentification.managingAuthority,
          ),
        ],
        [
          '1.3.4',
          'Director/Manager name',
          assessment.facilityIdentification.directorName,
        ],
        [
          '1.3.5',
          'Director/Manager phone',
          assessment.facilityIdentification.directorPhone,
        ],
        [
          '1.3.6',
          'Director/Manager email',
          assessment.facilityIdentification.directorEmail,
        ],
        [
          '1.3.7',
          'Respondent or key informant\'s name',
          assessment.facilityIdentification.respondentName,
        ],
        [
          '1.3.8',
          'Respondent or key informant\'s position',
          assessment.facilityIdentification.respondentPosition,
        ],
        [
          '1.3.9',
          'Type of structure',
          getStructureTypeText(assessment.facilityIdentification.structureType),
        ],
        [
          '1.3.10',
          'Type of facility',
          getFacilityTypeText(assessment.facilityIdentification.facilityType),
        ],
        [
          '1.3.11',
          'Type of existing health care facility',
          assessment.facilityIdentification.existingFacilityType?.name,
        ],
      ];

      // Add headers for facility identification table
      _setCellValue(sheet, currentRow, 0, 'Item #');
      _setCellValue(sheet, currentRow, 1, 'Description');
      _setCellValue(sheet, currentRow, 2, 'Value');
      _styleCell(sheet, currentRow, 0, isBold: true, bgColor: '#E7F3FF');
      _styleCell(sheet, currentRow, 1, isBold: true, bgColor: '#E7F3FF');
      _styleCell(sheet, currentRow, 2, isBold: true, bgColor: '#E7F3FF');
      currentRow++;

      for (final row in facilityIdentificationData) {
        _setCellValue(sheet, currentRow, 0, row[0]);
        _setCellValue(sheet, currentRow, 1, row[1]);
        _setCellValue(sheet, currentRow, 2, row[2]);
        _styleCell(sheet, currentRow, 0, isBold: true);
        currentRow++;
      }
      currentRow += 2;

      // =======================================================================
      // 1.4 EXISTING HEALTH CARE FACILITY SERVICES
      // =======================================================================
      _addSectionHeader(
        sheet,
        currentRow,
        '1.4 Existing Health Care Facility Services',
      );
      currentRow += 1;

      // Build facility services data with conditional items like PDF
      final facilityServicesData = <List<String>>[
        [
          '1.4.1',
          'The facility offers outpatient services',
          _getYesNoText(assessment.facilityServices.hasOutpatientServices),
        ],
        [
          '1.4.2',
          'The facility offers inpatient services',
          _getYesNoText(assessment.facilityServices.hasInpatientServices),
        ],
      ];

      // Add conditional items only if inpatient services are available
      if (assessment.facilityServices.hasInpatientServices == true) {
        facilityServicesData.addAll([
          [
            '1.4.3',
            'Total number of overnight/inpatient beds',
            assessment.facilityServices.totalInpatientBeds?.toString() ??
                'Not specified',
          ],
          [
            '1.4.4',
            'Of the total number of inpatient beds, how many are intensive care unit (ICU) beds?',
            assessment.facilityServices.icuBeds?.toString() ?? 'Not specified',
          ],
          [
            '1.4.5',
            'The facility has dedicated 24-hour staffed emergency unit',
            _getYesNoText(assessment.facilityServices.hasEmergencyUnit),
          ],
          [
            '1.4.6',
            'The facility has intensive care or high-dependency unit',
            _getYesNoText(
              assessment.facilityServices.hasIcuOrHighDependencyUnit,
            ),
          ],
        ]);
      }

      // Add headers for facility services table
      _setCellValue(sheet, currentRow, 0, 'Item #');
      _setCellValue(sheet, currentRow, 1, 'Description');
      _setCellValue(sheet, currentRow, 2, 'Value');
      _styleCell(sheet, currentRow, 0, isBold: true, bgColor: '#E7F3FF');
      _styleCell(sheet, currentRow, 1, isBold: true, bgColor: '#E7F3FF');
      _styleCell(sheet, currentRow, 2, isBold: true, bgColor: '#E7F3FF');
      currentRow++;

      for (final row in facilityServicesData) {
        _setCellValue(sheet, currentRow, 0, row[0]);
        _setCellValue(sheet, currentRow, 1, row[1]);
        _setCellValue(sheet, currentRow, 2, row[2]);
        _styleCell(sheet, currentRow, 0, isBold: true);
        currentRow++;
      }
      currentRow += 2;

      //  1.5 PHOTO DOCUMENTATION SUMMARY
      _addSectionHeader(sheet, currentRow, '1.5 Photo Documentation Summary');
      currentRow += 1;

      final totalPhotos = assessment.photos.length;
      final cameraPhotos =
          assessment.photos
              .where((p) => p.source.toString().contains('camera'))
              .length;
      final galleryPhotos =
          assessment.photos
              .where((p) => p.source.toString().contains('gallery'))
              .length;

      final photoSummaryData = [
        ['1.5.1', 'Total photos captured', totalPhotos.toString()],
        ['1.5.2', 'Photos from camera', cameraPhotos.toString()],
        ['1.5.3', 'Photos from gallery', galleryPhotos.toString()],
      ];

      // Add headers for photo summary table
      _setCellValue(sheet, currentRow, 0, 'Item #');
      _setCellValue(sheet, currentRow, 1, 'Description');
      _setCellValue(sheet, currentRow, 2, 'Value');
      _styleCell(sheet, currentRow, 0, isBold: true, bgColor: '#E7F3FF');
      _styleCell(sheet, currentRow, 1, isBold: true, bgColor: '#E7F3FF');
      _styleCell(sheet, currentRow, 2, isBold: true, bgColor: '#E7F3FF');
      currentRow++;

      for (final row in photoSummaryData) {
        _setCellValue(sheet, currentRow, 0, row[0]);
        _setCellValue(sheet, currentRow, 1, row[1]);
        _setCellValue(sheet, currentRow, 2, row[2]);
        _styleCell(sheet, currentRow, 0, isBold: true);
        currentRow++;
      }
    }

    if (section.sectionNumber != '1') {
      // Headers
      final headers = [
        'Section #',
        'Assessment Area',
        'Rating',
        'Choice Made',
        'Status',
        'Comment',
      ];
      for (int i = 0; i < headers.length; i++) {
        _setCellValue(sheet, currentRow, i, headers[i]);
        _styleCell(sheet, currentRow, i, isBold: true, bgColor: '#D9E2F3');
      }
      currentRow++;

      // Assessment items
      for (final item in section.items) {
        // Section number (e.g., "2.1.1", "2.1.2", etc.)
        _setCellValue(sheet, currentRow, 0, item.sectionNumber ?? 'N/A');

        // Assessment area/question
        _setCellValue(
          sheet,
          currentRow,
          1,
          item.area ?? item.question ?? 'No area specified',
        );

        String ratingText = 'Not Rated';
        String choiceDetails =
            'No choice made - Assessment item not yet completed';
        String ratingColor = '#FFE6E6'; // Light red for unanswered
        String status = 'Pending';

        // Use improved detection method
        if (!_isItemUnanswered(item)) {
          // Get the rating text (+++, ++, +, DK, NA)
          ratingText = getRatingText(item.selectedRating);

          // Get detailed choice information
          choiceDetails = _getDetailedChoiceText(item.selectedRating);

          // Get rating color
          ratingColor = _getRatingColorHex(item.selectedRating);
          status = 'Completed';
        } else {
          // Double-check if there's any rating data we might have missed
          if (item.selectedRating != null) {
            ratingText = 'Partial Data';
            choiceDetails =
                'Rating data exists but appears incomplete - please review';
            ratingColor = '#FFF3CD'; // Light yellow for partial data
            status = 'Needs Review';
          }
        }

        // Rating (short form: +++, ++, +, DK, NA)
        _setCellValue(sheet, currentRow, 2, ratingText);

        // Choice Made (detailed description)
        _setCellValue(sheet, currentRow, 3, choiceDetails);

        // Status
        _setCellValue(sheet, currentRow, 4, status);

        // Comment
        _setCellValue(sheet, currentRow, 5, item.comment ?? '');

        // Style the rating cell with color
        _styleCell(sheet, currentRow, 2, bgColor: ratingColor, isBold: true);

        // Style status cell based on status
        if (status == 'Completed') {
          _styleCell(sheet, currentRow, 4, bgColor: '#C6EFCE');
        } else {
          _styleCell(sheet, currentRow, 4, bgColor: '#FFE6E6');
        }

        currentRow++;
      }
    }

    // Add comprehensive summary section
    currentRow += 1;
    _setCellValue(sheet, currentRow, 0, 'SECTION SUMMARY:');
    _styleCell(sheet, currentRow, 0, isBold: true, bgColor: '#F0F0F0');
    sheet.merge(
      CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 0),
      CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 6),
    );
    currentRow++;

    // Section statistics
    final meets = _countSectionRatingsByValue(section, 3);
    final partial = _countSectionRatingsByValue(section, 2);
    final doesNot = _countSectionRatingsByValue(section, 1);
    final dk = _countSectionRatingsByLabel(section, 'DK');
    final na = _countSectionRatingsByLabel(section, 'NA');

    final summaryData = [
      ['Total Items:', '$totalItems'],
      ['Completed:', '$completedItems'],
      ['Unanswered:', '$unansweredItems'],
      ['Meets Target (+++):', '$meets'],
      ['Partially Meets (++):', '$partial'],
      ['Does Not Meet (+):', '$doesNot'],
      ['Don\'t Know (DK):', '$dk'],
      ['Not Applicable (NA):', '$na'],
      ['Completion Rate:', '${progress.toStringAsFixed(1)}%'],
    ];

    for (final row in summaryData) {
      _setCellValue(sheet, currentRow, 0, row[0]);
      _setCellValue(sheet, currentRow, 1, row[1]);
      _styleCell(sheet, currentRow, 0, isBold: true);
      currentRow++;
    }

    if (unansweredItems > 0) {
      currentRow += 1;
      _setCellValue(sheet, currentRow, 0, '[WARNING] INCOMPLETE SECTION:');
      _styleCell(
        sheet,
        currentRow,
        0,
        isBold: true,
        bgColor: '#FFEB9C',
        fontColor: '#D68910',
      );
      sheet.merge(
        CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 0),
        CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 6),
      );
      currentRow++;

      _setCellValue(
        sheet,
        currentRow,
        0,
        '$unansweredItems items still need to be assessed for a complete evaluation. Some critical issues may be undiscovered.',
      );
      _styleCell(
        sheet,
        currentRow,
        0,
        bgColor: '#FFF3CD',
        fontColor: '#856404',
      );
      sheet.merge(
        CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 0),
        CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 6),
      );
      currentRow++;
    }

    if (doesNot > 0) {
      currentRow += 1;
      _setCellValue(
        sheet,
        currentRow,
        0,
        '[CRITICAL] URGENT ATTENTION REQUIRED:',
      );
      _styleCell(
        sheet,
        currentRow,
        0,
        isBold: true,
        bgColor: '#FFC7CE',
        fontColor: '#721C24',
      );
      sheet.merge(
        CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 0),
        CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 6),
      );
      currentRow++;

      _setCellValue(
        sheet,
        currentRow,
        0,
        '$doesNot items do not meet target requirements and need immediate attention to ensure facility safety and compliance.',
      );
      _styleCell(
        sheet,
        currentRow,
        0,
        bgColor: '#F8D7DA',
        fontColor: '#721C24',
      );
      sheet.merge(
        CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 0),
        CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 6),
      );
      currentRow++;
    }
  }

  /// Build analysis sheet - REFACTORED to use entity methods
  Future<void> _buildAnalysisSheet(
    Sheet sheet,
    AssessmentFormModel assessment,
  ) async {
    int currentRow = 0;

    // Title
    _setCellValue(sheet, currentRow, 0, 'Assessment Analysis');
    _styleCell(
      sheet,
      currentRow,
      0,
      fontSize: 16,
      isBold: true,
      bgColor: '#2E75B6',
      fontColor: '#FFFFFF',
    );
    sheet.merge(
      CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 0),
      CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 4),
    );
    currentRow += 2;

    // Overall Statistics - USING ENTITY METHODS
    _addSectionHeader(sheet, currentRow, 'Overall Statistics');
    currentRow += 1;

    final totalItems = assessment.totalItems; // Entity property
    final completedItems = assessment.completedItems; // Entity property
    final unanswered = totalItems - completedItems; // Calculated from entity

    final meetsTarget = _countRatingsByValue(assessment, 3);
    final partiallyMeets = _countRatingsByValue(assessment, 2);
    final doesNotMeet = _countRatingsByValue(assessment, 1);
    final dontKnow = _countRatingsByLabel(assessment, 'DK');
    final notApplicable = _countRatingsByLabel(assessment, 'NA');

    final statsData = [
      ['Total Assessment Items', totalItems.toString()],
      ['Completed Items', completedItems.toString()],
      ['Unanswered Items', unanswered.toString()],
      [
        'Completion Rate',
        '${assessment.completionPercentage.toStringAsFixed(1)}%',
      ], // Entity method
      ['Items Meeting Target (+++)', meetsTarget.toString()],
      ['Items Partially Meeting (++)', partiallyMeets.toString()],
      ['Items Not Meeting (+)', doesNotMeet.toString()],
      ['Don\'t Know (DK)', dontKnow.toString()],
      ['Not Applicable (NA)', notApplicable.toString()],
    ];

    for (final row in statsData) {
      _setCellValue(sheet, currentRow, 0, row[0]);
      _setCellValue(sheet, currentRow, 1, row[1]);
      _styleCell(sheet, currentRow, 0, isBold: true);
      currentRow++;
    }

    currentRow += 2;

    // Section-wise breakdown - USING ENTITY METHODS
    _addSectionHeader(sheet, currentRow, 'Section-wise Analysis');
    currentRow += 1;

    final sectionHeaders = [
      'Section',
      'Total',
      'Completed',
      'Unanswered',
      '+++',
      '++',
      '+',
      'DK',
      'NA',
    ];
    for (int i = 0; i < sectionHeaders.length; i++) {
      _setCellValue(sheet, currentRow, i, sectionHeaders[i]);
      _styleCell(sheet, currentRow, i, isBold: true, bgColor: '#D9E2F3');
    }
    currentRow++;

    // Section data - USING ENTITY METHODS
    for (final section in assessment.sections) {
      final sectionName = section.title;

      final int totalSectionItems;
      final int completedSectionItems;

      if (section.sectionNumber == '1') {
        // For section 1, use the assessment entity's comprehensive calculation
        totalSectionItems = assessment.section1TotalItems;
        completedSectionItems = assessment.section1CompletedItems;
      } else {
        // For other sections, use section entity methods
        totalSectionItems = section.items.length;
        completedSectionItems =
            section.completedItemsCount; // Using section entity method
      }

      final int unansweredSectionItems =
          totalSectionItems - completedSectionItems;

      final meets = _countSectionRatingsByValue(section, 3);
      final partial = _countSectionRatingsByValue(section, 2);
      final doesNot = _countSectionRatingsByValue(section, 1);
      final dk = _countSectionRatingsByLabel(section, 'DK');
      final na = _countSectionRatingsByLabel(section, 'NA');

      _setCellValue(sheet, currentRow, 0, sectionName);
      _setCellValue(sheet, currentRow, 1, totalSectionItems);
      _setCellValue(sheet, currentRow, 2, completedSectionItems);
      _setCellValue(sheet, currentRow, 3, unansweredSectionItems);
      _setCellValue(sheet, currentRow, 4, meets);
      _setCellValue(sheet, currentRow, 5, partial);
      _setCellValue(sheet, currentRow, 6, doesNot);
      _setCellValue(sheet, currentRow, 7, dk);
      _setCellValue(sheet, currentRow, 8, na);

      // Highlight unanswered items
      if (unansweredSectionItems > 0) {
        _styleCell(sheet, currentRow, 3, bgColor: '#FFE6E6', isBold: true);
      }

      currentRow++;
    }
  }

  /// Helper method to set cell value
  void _setCellValue(Sheet sheet, int row, int col, dynamic value) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col),
    );
    if (value is String) {
      cell.value = TextCellValue(value);
    } else if (value is int) {
      cell.value = IntCellValue(value);
    } else {
      cell.value = TextCellValue(value?.toString() ?? '');
    }
  }

  /// Helper methods for Excel formatting (adapted for excel package)
  void _addSectionHeader(Sheet sheet, int row, String title) {
    _setCellValue(sheet, row, 0, title);
    _styleCell(
      sheet,
      row,
      0,
      fontSize: 14,
      isBold: true,
      bgColor: '#4472C4',
      fontColor: '#FFFFFF',
    );
    sheet.merge(
      CellIndex.indexByColumnRow(rowIndex: row, columnIndex: 0),
      CellIndex.indexByColumnRow(rowIndex: row, columnIndex: 5),
    );
  }

  void _styleCell(
    Sheet sheet,
    int row,
    int col, {
    int fontSize = 10,
    bool isBold = false,
    bool isItalic = false,
    String? bgColor,
    String? fontColor,
  }) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col),
    );

    CellStyle? cellStyle;

    cellStyle = CellStyle(
      bold: isBold,
      italic: isItalic,
      backgroundColorHex:
          bgColor != null
              ? (ExcelColor.fromHexString(
                _convertHexColor(bgColor) ?? 'FFFFFFFF',
              ))
              : ExcelColor.fromHexString('FFFFFFFF'),
      fontColorHex:
          fontColor != null
              ? (ExcelColor.fromHexString(
                _convertHexColor(fontColor) ?? 'FF000000',
              ))
              : ExcelColor.fromHexString('FF000000'),
    );

    cell.cellStyle = cellStyle;
  }

  /// Convert hex color string to format expected by excel package
  String? _convertHexColor(String hexColor) {
    // Remove # if present and ensure proper format
    String color = hexColor.replaceAll('#', '').toUpperCase();
    if (color.length == 6) {
      return 'FF$color'; // Add alpha channel
    }
    return color;
  }

  @visibleForTesting
  String detailedChoiceText(dynamic rating) => _getDetailedChoiceText(rating);

  @visibleForTesting
  String ratingColorHex(dynamic rating) => _getRatingColorHex(rating);

  /// Get detailed choice text for display
  String _getDetailedChoiceText(dynamic rating) {
    if (rating == null) {
      return 'No choice made - Assessment item not yet completed';
    }

    // Handle different rating structures - check value first
    if (rating.value != null) {
      switch (rating.value) {
        case 3:
          return 'Meets target requirements (+++) - Fully compliant with all criteria';
        case 2:
          return 'Partially meets target (++) - Some improvements needed to reach full compliance';
        case 1:
          return 'Does not meet target (+) - Significant gaps identified, immediate action required';
        case 0:
          return 'Don\'t Know (DK) - Information not available at time of assessment';
        case -1:
          return 'Not Applicable (NA) - This criterion does not apply to this facility type';
        default:
          return 'Unknown rating value: ${rating.value} - Please review assessment data';
      }
    }
    return 'No choice made - Assessment item not yet completed';
  }

  /// Get rating color with support for all states
  String _getRatingColorHex(dynamic rating) {
    if (rating == null) return '#FFE6E6'; // Light red for not answered

    // Handle different rating structures - check value first
    if (rating.value != null) {
      switch (rating.value) {
        case 3:
          return '#C6EFCE'; // Green for meets target
        case 2:
          return '#FFEB9C'; // Yellow for partially meets
        case 1:
          return '#FFC7CE'; // Red for does not meet
        case 0:
          return '#E6E6FA'; // Light purple for Don't Know
        case -1:
          return '#F0F0F0'; // Light gray for Not Applicable
        default:
          return '#F5F5F5'; // Default gray
      }
    }
    return '#FFE6E6';
  }

  /// Helper method to convert boolean to Yes/No text
  String _getYesNoText(bool? value) {
    if (value == null) return 'Not specified';
    return value ? 'Yes' : 'No';
  }

  /// Helper method to determine if an item is unanswered
  bool _isItemUnanswered(dynamic item) {
    // Check if selectedRating is null
    if (item.selectedRating == null) {
      return true;
    }

    // Check if selectedRating exists but has no meaningful value
    final rating = item.selectedRating;

    // If both value and label are null/empty, consider it unanswered
    final hasValue = rating.value != null;
    final hasLabel =
        rating.label != null && rating.label.toString().trim().isNotEmpty;

    return !hasValue && !hasLabel;
  }

  // ===================================================================
  // KEEP THESE RATING-SPECIFIC METHODS (Excel-specific analysis)
  // ===================================================================

  /// Count ratings by value
  int _countRatingsByValue(AssessmentFormModel assessment, int value) {
    int count = 0;
    for (final section in assessment.sections) {
      count += _countSectionRatingsByValue(section, value);
    }
    return count;
  }

  /// Count ratings by label
  int _countRatingsByLabel(AssessmentFormModel assessment, String label) {
    int count = 0;
    for (final section in assessment.sections) {
      count += _countSectionRatingsByLabel(section, label);
    }
    return count;
  }

  /// Count section ratings by value
  int _countSectionRatingsByValue(dynamic section, int value) {
    if (section?.items == null) return 0;

    return section.items.where((item) {
      if (item.selectedRating == null || item.selectedRating.value == null) {
        return false;
      }

      final intValue = item.selectedRating.value;
      return intValue == value;
    }).length;
  }

  int _countSectionRatingsByLabel(dynamic section, String label) {
    if (section?.items == null) return 0;

    return section.items.where((item) {
      if (item.selectedRating == null) return false;

      // Check by label
      if (item.selectedRating.label != null &&
          item.selectedRating.label.toString().toUpperCase() ==
              label.toUpperCase()) {
        return true;
      }

      // Also check by value for DK (0) and NA (-1)
      if (item.selectedRating.value != null) {
        final intValue = item.selectedRating.value;

        if (label.toUpperCase() == 'DK' && intValue == 0) return true;
        if (label.toUpperCase() == 'NA' && intValue == -1) return true;
      }

      return false;
    }).length;
  }

  int _getSheetCount(ExportOptions options, AssessmentFormModel assessment) {
    int count = 2; // Summary + Photos sheets
    if (options.includeSectionDetails) {
      count += assessment.sections.where((s) => s.items.isNotEmpty).length;
    }
    if (options.includeAnalysis) count += 1; // Analysis sheet
    return count;
  }
}
