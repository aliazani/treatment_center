import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:treatment_center/core/error/exceptions.dart';

import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_section_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_item_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_rating_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessor_info_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_identification_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_services_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/geolocation_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:uuid/uuid.dart';

import 'import_service.dart';

class ExcelImportService extends BaseImportService {
  final _uuid = const Uuid();

  ExcelImportService({required super.fileProvider});

  @override
  String get supportedExtension => 'xlsx';

  @override
  String get formatName => 'Microsoft Excel';

  @override
  List<String> get supportedMimeTypes => [
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-excel',
  ];

  @override
  Future<void> validateFileForImport(String filePath) async {
    await super.validateFileForImport(filePath);

    return validateFormatSpecific(filePath);
  }

  @override
  Future<ImportedAssessmentForm> importFromBytes(
    Uint8List bytes, {
    String? originalName,
    ImportOptions? options,
  }) async {
    final excel = Excel.decodeBytes(bytes);

    final assessment = await _parseExcelData(
      excel,
      options ?? const ImportOptions(),
    );

    // Build the usual ImportedAssessmentForm – we have no path,
    // so store a synthetic one for backward-compat.
    return ImportedAssessmentForm(
      assessment: assessment,
      filePath: originalName ?? '<bytes>',
      format: formatName,
      importedAt: DateTime.now(),
      metadata: {
        'totalSheets': excel.sheets.length,
        'sheetNames': excel.sheets.keys.toList(),
        'origin': 'bytes',
        'bytesLength': bytes.length,
      },
    );
  }

  @override
  Future<ImportedAssessmentForm> importAssessment(
    String filePath, {
    ImportOptions? options,
  }) async {
    try {
      if (kIsWeb) {
        throw UnsupportedError(
          'File path import not supported on web. Use importFromBytes instead.',
        );
      }
      // Validate file before processing
      await validateFileForImport(filePath);

      final importOptions = options ?? const ImportOptions();

      // Read the Excel file
      final file = await fileProvider.getFile(filePath);
      final bytes = await fileProvider.readAsBytes(file);

      final excel = Excel.decodeBytes(bytes);

      // Debug available sheets
      _debugExcelStructure(excel);

      // Parse the Excel data
      final assessment = await _parseExcelData(excel, importOptions);

      // Validate the imported assessment
      await validateImportedAssessment(assessment);

      return ImportedAssessmentForm(
        assessment: assessment,
        filePath: filePath,
        format: formatName,
        importedAt: DateTime.now(),
        metadata: {
          'totalSheets': excel.sheets.length,
          'sheetNames': excel.sheets.keys.toList(),
          'importedSections': assessment.sections.length,
          'totalItems': assessment.totalItems,
        },
      );
    } catch (e) {
      if (e is ImportException ||
          e is ValidationException ||
          e is FileException) {
        rethrow;
      }
      throw ExcelImportException(
        message: 'Failed to import Excel file: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> validateFormatSpecific(String filePath) async {
    final lower = filePath.toLowerCase();
    if (!lower.endsWith('.xlsx') && !lower.endsWith('.xls')) {
      throw ValidationException(
        message: 'File must be an Excel file (.xlsx or .xls)',
      );
    }
  }

  /// Parse Excel data into AssessmentFormModel
  Future<AssessmentFormModel> _parseExcelData(
    Excel excel,
    ImportOptions options,
  ) async {
    final section1Sheet = _getSectionSheet(excel, '1');

    // Parse basic assessment information
    final assessmentData = _parseBasicAssessmentInfo(section1Sheet);
    final assessmentId = assessmentData['id'] ?? _uuid.v4();

    // Parse sections data
    List<AssessmentSectionModel> sections = [];

    if (options.importSectionDetails) {
      sections = await _parseSectionData(excel, options);
      final section1 = _createDefaultSections().first;
      sections.insert(0, section1);
    } else {
      // Create empty sections if not importing details
      sections = _createDefaultSections();
    }

    // Build the complete assessment model
    final assessment = AssessmentFormModel(
      id: assessmentId,
      assessorInfo: assessmentData['assessorInfo'] as AssessorInfoModel,
      geoLocation: assessmentData['geoLocation'] as GeoLocationModel,
      facilityIdentification:
          assessmentData['facilityIdentification']
              as FacilityIdentificationModel,
      facilityServices:
          assessmentData['facilityServices'] as FacilityServicesModel,
      sections: sections,
      isSubmitted: assessmentData['isSubmitted'] ?? false,
      submissionDate: assessmentData['submissionDate'],
      createdAt: assessmentData['createdAt'] ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return assessment;
  }

  /// Always grab the tab named "Section 1", or first sheet if it doesn't exist
  Sheet _getSectionSheet(Excel excel, String sectionNumber) {
    // try exact match first
    final exact = excel.sheets['Section $sectionNumber'];
    if (exact != null) return exact;

    // otherwise find any sheet that starts with "Section 1"
    final key = excel.sheets.keys.firstWhere(
      (k) => k.toLowerCase().startsWith('section $sectionNumber'),
      orElse: () => excel.sheets.keys.first,
    );
    return excel.sheets[key]!;
  }

  Map<String, dynamic> _parseBasicAssessmentInfo(Sheet sheet) {
    Map<String, dynamic> data = {};

    try {
      // Parse assessment information (section 1.1)
      final assessorInfo = _parseAssessorInfo(sheet);
      data['assessorInfo'] = assessorInfo;

      // Parse geographical location (section 1.2)
      final geoLocation = _parseGeoLocation(sheet);
      data['geoLocation'] = geoLocation;

      // Parse facility identification (section 1.3)
      final facilityIdentification = _parseFacilityIdentification(sheet);
      data['facilityIdentification'] = facilityIdentification;

      // Parse facility services (section 1.4)
      final facilityServices = _parseFacilityServices(sheet);
      data['facilityServices'] = facilityServices;

      // Parse submission status and dates
      data['isSubmitted'] =
          _findCellValue(
            sheet,
            'Assessment Status',
          )?.toString().toLowerCase().contains('submitted') ??
          false;
      data['submissionDate'] = _parseDate(
        _findCellValue(sheet, 'Submission Date'),
      );
      data['createdAt'] =
          _parseDate(_findCellValue(sheet, 'Assessment Date')) ??
          DateTime.now();
    } catch (e) {
      // Continue with defaults for missing data
    }

    return data;
  }

  /// Parse assessor information from sheet
  AssessorInfoModel _parseAssessorInfo(Sheet sheet) {
    return AssessorInfoModel(
      name:
          _findCellValue(
            sheet,
            'Name of person conducting assessment',
          )?.toString() ??
          '',
      email: _findCellValue(sheet, 'Email')?.toString() ?? '',
      phoneNumber: _findCellValue(sheet, 'Phone')?.toString() ?? '',
      assessmentDate:
          _parseDate(_findCellValue(sheet, 'Date of assessment')) ??
          DateTime.now(),
    );
  }

  /// Parse geographical location from sheet
  GeoLocationModel _parseGeoLocation(Sheet sheet) {
    return GeoLocationModel(
      country: _findCellValue(sheet, 'Country')?.toString() ?? '',
      regionProvince:
          _findCellValue(sheet, 'Region/Province')?.toString() ?? '',
      district: _findCellValue(sheet, 'District')?.toString() ?? '',
      cityVillage: _findCellValue(sheet, 'City/Village')?.toString() ?? '',
      addressOrCoordinates:
          _findCellValue(sheet, 'Address/GPS coordinates')?.toString() ?? '',
      locationType:
          _parseFacilityLocationType(
            _findCellValue(sheet, 'Record of facility location')?.toString(),
          ) ??
          FacilityLocationType.urban,
      latitude: _parseDouble(_findCellValue(sheet, 'Latitude')),
      longitude: _parseDouble(_findCellValue(sheet, 'Longitude')),
    );
  }

  /// Helper to parse FacilityLocationType from string
  FacilityLocationType? _parseFacilityLocationType(String? value) {
    if (value != null) {
      final raw = value.trim().toLowerCase();
      // Remove spaces, hyphens, underscores, etc.
      final cleaned = raw.replaceAll(RegExp(r'[^a-z0-9]'), '');

      for (var type in FacilityLocationType.values) {
        final name = type.toString().split('.').last.toLowerCase();
        if (cleaned == name) {
          return type;
        }
      }
    }
    return null;
  }

  /// Helper to parse ManagingAuthorityType from string
  ManagingAuthorityType? _parseManagingAuthorityType(String? value) {
    if (value != null) {
      final raw = value.trim().toLowerCase();
      // Remove spaces, hyphens, underscores, etc.
      final cleaned = raw.replaceAll(RegExp(r'[^a-z0-9]'), '');

      for (var type in ManagingAuthorityType.values) {
        final name = type.toString().split('.').last.toLowerCase();
        if (cleaned == name) {
          return type;
        }
      }
    }
    return null;
  }

  /// Helper to parse FacilityStructureType from string
  FacilityStructureType? _parseFacilityStructureType(String? value) {
    if (value != null) {
      final raw = value.trim().toLowerCase();
      // Remove spaces, hyphens, underscores, etc.
      final cleaned = raw.replaceAll(RegExp(r'[^a-z0-9]'), '');

      for (var type in FacilityStructureType.values) {
        final name = type.toString().split('.').last.toLowerCase();
        if (cleaned == name) {
          return type;
        }
      }
    }
    return null;
  }

  /// Helper to parse FacilityType from string
  FacilityType? _parseFacilityType(String? value) {
    if (value != null) {
      final raw = value.trim().toLowerCase();
      // Remove spaces, hyphens, underscores, etc.
      final cleaned = raw.replaceAll(RegExp(r'[^a-z0-9]'), '');

      for (var type in FacilityType.values) {
        final name = type.toString().split('.').last.toLowerCase();
        if (cleaned == name) {
          return type;
        }
      }
    }
    return null;
  }

  /// Helper to parse ExistingFacilityType from string
  ExistingFacilityType? _parseExistingFacilityType(String? value) {
    if (value != null) {
      final raw = value.trim().toLowerCase();
      // Remove spaces, hyphens, underscores, etc.
      final cleaned = raw.replaceAll(RegExp(r'[^a-z0-9]'), '');

      for (var type in ExistingFacilityType.values) {
        final name = type.toString().split('.').last.toLowerCase();
        if (cleaned == name) {
          return type;
        }
      }
    }
    return null;
  }

  /// Parse facility identification from sheet
  FacilityIdentificationModel _parseFacilityIdentification(Sheet sheet) {
    return FacilityIdentificationModel(
      facilityCode: _findCellValue(sheet, 'Facility code')?.toString() ?? '',
      facilityName: _findCellValue(sheet, 'Facility name')?.toString() ?? '',
      managingAuthority:
          _parseManagingAuthorityType(
            _findCellValue(sheet, 'Managing authority')?.toString(),
          ) ??
          ManagingAuthorityType.government,
      directorName:
          _findCellValue(sheet, 'Director/Manager name')?.toString() ?? '',
      directorPhone:
          _findCellValue(sheet, 'Director/Manager phone')?.toString() ?? '',
      directorEmail:
          _findCellValue(sheet, 'Director/Manager email')?.toString() ?? '',
      respondentName:
          _findCellValue(
            sheet,
            'Respondent or key informant\'s name',
          )?.toString() ??
          '',
      respondentPosition:
          _findCellValue(
            sheet,
            'Respondent or key informant\'s position',
          )?.toString() ??
          '',
      structureType:
          _parseFacilityStructureType(
            _findCellValue(sheet, 'Type of structure')?.toString(),
          ) ??
          FacilityStructureType.permanent,
      facilityType:
          _parseFacilityType(
            _findCellValue(sheet, 'Type of facility')?.toString(),
          ) ??
          FacilityType.screeningAndTemporaryIsolation,
      existingFacilityType: _parseExistingFacilityType(
        _findCellValue(
          sheet,
          'Type of existing health care facility',
        )?.toString(),
      ),
    );
  }

  /// Parse facility services from sheet
  FacilityServicesModel _parseFacilityServices(Sheet sheet) {
    return FacilityServicesModel(
      hasOutpatientServices:
          _parseBoolean(
            _findCellValue(sheet, 'The facility offers outpatient services'),
          ) ??
          false,
      hasInpatientServices:
          _parseBoolean(
            _findCellValue(sheet, 'The facility offers inpatient services'),
          ) ??
          false,
      totalInpatientBeds: _parseInt(
        _findCellValue(sheet, 'Total number of overnight/inpatient beds'),
      ),
      icuBeds: _parseInt(
        _findCellValue(
          sheet,
          'Of the total number of inpatient beds, how many are intensive care unit (ICU) beds?',
        ),
      ),
      hasEmergencyUnit: _parseBoolean(
        _findCellValue(
          sheet,
          'The facility has dedicated 24-hour staffed emergency unit',
        ),
      ),
      hasIcuOrHighDependencyUnit: _parseBoolean(
        _findCellValue(
          sheet,
          'The facility has intensive care or high-dependency unit',
        ),
      ),
    );
  }

  /// Parse section data from Excel sheets
  Future<List<AssessmentSectionModel>> _parseSectionData(
    Excel excel,
    ImportOptions options,
  ) async {
    List<AssessmentSectionModel> sections = [];

    // Look for section sheets (e.g., "Section 2", "Section 3", etc.)
    for (final sheetName in excel.sheets.keys) {
      if (_isSectionSheet(sheetName)) {
        try {
          final section = await _parseSectionSheet(
            excel.sheets[sheetName]!,
            sheetName,
          );
          if (section != null) {
            sections.add(section);
          }
        } catch (e) {
          // Continue processing other sections in non-strict mode
        }
      }
    }

    // Sort sections by section number
    sections.sort((a, b) => a.sectionNumber.compareTo(b.sectionNumber));

    // If no section sheets found, create default sections
    if (sections.isEmpty) {
      sections = _createDefaultSections();
    }

    return sections;
  }

  /// Check if sheet name indicates a section sheet
  bool _isSectionSheet(String sheetName) {
    final lowerName = sheetName.toLowerCase();
    return lowerName.startsWith('section ') ||
        lowerName.contains('section') && RegExp(r'\d+').hasMatch(lowerName);
  }

  /// Parse individual section sheet
  Future<AssessmentSectionModel?> _parseSectionSheet(
    Sheet sheet,
    String sheetName,
  ) async {
    // Extract section number from sheet name
    final sectionNumber = _extractSectionNumber(sheetName);
    if (sectionNumber == null) {
      return null;
    }

    // Find the header row (looking for standard headers)
    int? headerRow = _findHeaderRow(sheet);
    if (headerRow == null) {
      return null;
    }

    // Parse section title and description
    final sectionTitle =
        _extractSectionTitle(sheet) ?? 'Section $sectionNumber';

    // Parse assessment items
    final items = _parseAssessmentItems(sheet, headerRow, sectionNumber);

    return AssessmentSectionModel(
      id: _uuid.v4(), // Generate unique ID for each section
      sectionNumber: sectionNumber,
      title: sectionTitle,
      items: items,
    );
  }

  /// Extract section number from sheet name
  String? _extractSectionNumber(String sheetName) {
    final match = RegExp(r'(\d+)').firstMatch(sheetName);
    return match?.group(1);
  }

  /// Find header row in sheet
  int? _findHeaderRow(Sheet sheet) {
    const headerColumns = [
      'Section #',
      'Assessment Area',
      'Rating',
      'Choice Made',
      'Status',
    ];

    for (int row = 0; row < 20; row++) {
      // Check first 20 rows
      int foundHeaders = 0;
      for (int col = 0; col < 10; col++) {
        // Check first 10 columns
        final cellValue =
            _getCellValue(sheet, row, col)?.toString().trim() ?? '';
        if (headerColumns.any((header) => cellValue.contains(header))) {
          foundHeaders++;
        }
      }
      if (foundHeaders >= 3) {
        // Found at least 3 expected headers
        return row;
      }
    }

    return null;
  }

  /// Extract section title from sheet
  String? _extractSectionTitle(Sheet sheet) {
    // Look for title in first few rows
    for (int row = 0; row < 5; row++) {
      final cellValue = _getCellValue(sheet, row, 0)?.toString().trim();
      if (cellValue != null &&
          cellValue.isNotEmpty &&
          cellValue.contains('Section')) {
        // Extract title after "Section X:"
        final colonIndex = cellValue.indexOf(':');
        if (colonIndex != -1 && colonIndex < cellValue.length - 1) {
          return cellValue.substring(colonIndex + 1).trim();
        }
      }
    }
    return null;
  }

  /// Get column indices for parsing
  Map<String, int> _getColumnIndices(Sheet sheet, int headerRow) {
    Map<String, int> indices = {};

    for (int col = 0; col < 15; col++) {
      // Check reasonable number of columns
      final cellValue =
          _getCellValue(sheet, headerRow, col)?.toString().trim() ?? '';

      if (cellValue.contains('Section #') || cellValue.contains('Section')) {
        indices['sectionNumber'] = col;
      } else if (cellValue.contains('Assessment Area') ||
          cellValue.contains('Area')) {
        indices['area'] = col;
      } else if (cellValue.contains('Rating')) {
        indices['rating'] = col;
      } else if (cellValue.contains('Choice Made') ||
          cellValue.contains('Choice')) {
        indices['choice'] = col;
      } else if (cellValue.contains('Status')) {
        indices['status'] = col;
      } else if (cellValue.contains('Comment')) {
        indices['comment'] = col;
      }
    }

    return indices;
  }

  /// Parse individual item row
  AssessmentItemModel? _parseItemRow(
    Sheet sheet,
    int row,
    Map<String, int> columnIndices,
    String baseSectionNumber,
  ) {
    try {
      // Get section number for this item
      final itemSectionNumber =
          columnIndices.containsKey('sectionNumber')
              ? _getCellValue(
                sheet,
                row,
                columnIndices['sectionNumber']!,
              )?.toString().trim()
              : null;

      // Get assessment area
      final area =
          columnIndices.containsKey('area')
              ? _getCellValue(
                sheet,
                row,
                columnIndices['area']!,
              )?.toString().trim()
              : null;

      // Skip empty rows
      if ((itemSectionNumber == null || itemSectionNumber.isEmpty) &&
          (area == null || area.isEmpty)) {
        return null;
      }

      if (_isSummaryRow(itemSectionNumber, area)) {
        return null; // Skip these rows
      }

      if (!_isValidItemNumber(itemSectionNumber)) {
        return null; // Skip invalid item numbers
      }

      // Get rating information
      final ratingText =
          columnIndices.containsKey('rating')
              ? _getCellValue(
                sheet,
                row,
                columnIndices['rating']!,
              )?.toString().trim()
              : null;

      final choice =
          columnIndices.containsKey('choice')
              ? _getCellValue(
                sheet,
                row,
                columnIndices['choice']!,
              )?.toString().trim()
              : null;

      final status =
          columnIndices.containsKey('status')
              ? _getCellValue(
                sheet,
                row,
                columnIndices['status']!,
              )?.toString().trim()
              : null;

      final comment =
          columnIndices.containsKey('comment')
              ? _getCellValue(
                sheet,
                row,
                columnIndices['comment']!,
              )?.toString().trim()
              : null;

      // Parse rating from text
      final rating = _parseRatingFromText(ratingText, choice, status);

      // Generate item ID
      final int generatedId = row;

      return AssessmentItemModel(
        id: generatedId,

        // id is auto-incremented, so we don't set it here
        itemNumber: itemSectionNumber ?? '',
        sectionNumber: itemSectionNumber ?? '',
        area: area ?? '',
        meetsTargetDescription: 'Meets target requirements',
        partiallyMeetsDescription: 'Partially meets requirements',
        doesNotMeetDescription: 'Does not meet requirements',
        selectedRating: rating,
        comment: comment,
      );
    } catch (e) {
      return null;
    }
  }

  /// **NEW: Check if this is a summary/statistics row that should be skipped**
  bool _isSummaryRow(String? itemNumber, String? area) {
    if (itemNumber == null && area == null) return false;

    final summary = '${itemNumber ?? ''} ${area ?? ''}';
    final lowerSummary = summary.toLowerCase();

    // List of summary row patterns to skip
    final summaryPatterns = [
      'section summary',
      'total items',
      'completed',
      'unanswered',
      'meets target',
      'partially meets',
      'does not meet',
      'don\'t know',
      'not applicable',
      'completion rate',
      'warning',
      'incomplete section',
      'items still need',
      'critical issues',
      'complete evaluation',
    ];

    // Check if this row matches any summary pattern
    for (final pattern in summaryPatterns) {
      if (lowerSummary.contains(pattern)) {
        return true;
      }
    }

    // Check for specific summary row indicators
    if (itemNumber != null) {
      final itemLower = itemNumber.toLowerCase();
      if (itemLower.contains('section summary') ||
          itemLower.contains('total items') ||
          itemLower.contains('completed') ||
          itemLower.contains('unanswered') ||
          itemLower.contains('meets target') ||
          itemLower.contains('partially meets') ||
          itemLower.contains('does not meet') ||
          itemLower.contains('completion rate') ||
          itemLower.contains('warning')) {
        return true;
      }
    }

    return false;
  }

  /// **NEW: Check if item number is a valid assessment item number**
  bool _isValidItemNumber(String? itemNumber) {
    if (itemNumber == null || itemNumber.isEmpty) return false;

    // Valid item numbers should match patterns like: 2.1.1, 3.2.5, 4.3.12, etc.
    // They should start with a section number followed by subsection numbers
    final itemNumberPattern = RegExp(r'^\d+\.\d+\.\d+$');

    return itemNumberPattern.hasMatch(itemNumber.trim());
  }

  /// **UPDATED: Parse assessment items with better filtering**
  List<AssessmentItemModel> _parseAssessmentItems(
    Sheet sheet,
    int headerRow,
    String sectionNumber,
  ) {
    List<AssessmentItemModel> items = [];

    // Find column indices
    final columnIndices = _getColumnIndices(sheet, headerRow);

    // Parse each data row
    for (int row = headerRow + 1; row < sheet.maxRows; row++) {
      final itemData = _parseItemRow(sheet, row, columnIndices, sectionNumber);
      if (itemData != null) {
        items.add(itemData);
      }
    }

    return items;
  }

  /// Parse rating from various text representations
  AssessmentRatingModel? _parseRatingFromText(
    String? ratingText,
    String? choice,
    String? status,
  ) {
    // Skip if not answered
    if (status != null &&
        (status.toLowerCase().contains('pending') ||
            status.toLowerCase().contains('not answered'))) {
      return null;
    }

    // Parse from rating text
    if (ratingText != null && ratingText.isNotEmpty) {
      final rating = ratingText.trim().toUpperCase();

      if (rating.contains('+++') || rating == 'MEETS') {
        return AssessmentRatingModel.meetsTarget();
      } else if (rating.contains('++') || rating == 'PARTIAL') {
        return AssessmentRatingModel.partiallyMeetsTarget();
      } else if (rating.contains('+') || rating == 'DOES NOT') {
        return AssessmentRatingModel.doesNotMeetTarget();
      } else if (rating == 'DK' || rating.contains("DON'T KNOW")) {
        return AssessmentRatingModel.dontKnow();
      } else if (rating == 'NA' || rating.contains('NOT APPLICABLE')) {
        return AssessmentRatingModel.notApplicable();
      }
    }

    return null; // Could not determine rating
  }

  /// Helper method to find cell value by description
  dynamic _findCellValue(Sheet sheet, String description) {
    for (int row = 0; row < sheet.maxRows; row++) {
      for (int col = 0; col < 10; col++) {
        // Search in reasonable range
        final cellValue = _getCellValue(sheet, row, col)?.toString().trim();
        if (cellValue != null && cellValue.contains(description)) {
          // Look for value in next column
          final valueCell = _getCellValue(sheet, row, col + 1);
          if (valueCell != null && valueCell.toString().trim().isNotEmpty) {
            return valueCell;
          }
        }
      }
    }
    return null;
  }

  /// Helper method to get cell value safely
  dynamic _getCellValue(Sheet sheet, int row, int col) {
    try {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col),
      );
      return cell.value?.toString().trim();
    } catch (e) {
      return null;
    }
  }

  /// Parses a date from a variety of formats, but always returns
  /// a DateTime at midnight (dropping any time component).
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    final dateStr = value.toString().trim();
    if (dateStr.isEmpty || dateStr.toLowerCase() == 'not submitted') {
      return null;
    }

    try {
      // 1) ISO date, with optional time and optional fractional seconds:
      //    e.g. "2024-01-15", "2024-01-15 10:30:00", "2024-01-15T10:30:00.123"
      final isoWithTime = RegExp(
        r'^\d{4}-\d{2}-\d{2}(?:[ T]\d{2}:\d{2}:\d{2}(?:\.\d+)?)?$',
      );
      if (isoWithTime.hasMatch(dateStr)) {
        final dt = DateTime.parse(dateStr);
        // strip off any time portion
        return DateTime(dt.year, dt.month, dt.day);
      }

      // 2) US format MM/DD/YYYY or M/D/YYYY
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final m = int.tryParse(parts[0]);
        final d = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (y != null && m != null && d != null) {
          return DateTime(y, m, d);
        }
      }
    } catch (_) {
      // ignore parse errors
    }

    return null;
  }

  /// Parse boolean from text
  bool? _parseBoolean(dynamic value) {
    if (value == null) return null;

    final text = value.toString().toLowerCase().trim();
    if (text == 'yes' || text == 'true' || text == '1') {
      return true;
    } else if (text == 'no' || text == 'false' || text == '0') {
      return false;
    }

    return null;
  }

  /// Parse integer from text
  int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'not specified') return null;

    return int.tryParse(text);
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString().trim());
  }

  /// Create default sections if none found
  List<AssessmentSectionModel> _createDefaultSections() {
    return [
      // Section 1: Basic facility information (this was missing!)
      AssessmentSectionModel(
        id: _uuid.v4(), // Generate unique ID

        sectionNumber: '1',
        title: 'Facility Information Assessment',
        description:
            'Basic facility identification, assessor information, geographical location, and existing health care facility services',
        items: [],
      ),
      AssessmentSectionModel(
        id: _uuid.v4(), // Generate unique ID
        sectionNumber: '2',
        title: 'Overall Facility Assessment',
        description: 'Overall facility assessment',
        items: [],
      ),
      AssessmentSectionModel(
        id: _uuid.v4(), // Generate unique ID
        sectionNumber: '3',
        title: 'Screening with Temporary Isolation',
        description: 'Screening and isolation capabilities',
        items: [],
      ),
      AssessmentSectionModel(
        id: _uuid.v4(), // Generate unique ID
        sectionNumber: '4',
        title: 'FVD Stand-alone Treatment Centre',
        description: 'Treatment center facilities',
        items: [],
      ),
    ];
  }

  /// Debug method to understand Excel structure
  void _debugExcelStructure(Excel excel) {
    for (final sheetName in excel.sheets.keys) {
      final sheet = excel.sheets[sheetName]!;

      for (int row = 0; row < 5 && row < sheet.maxRows; row++) {
        List<String> rowData = [];
        for (int col = 0; col < 5 && col < sheet.maxColumns; col++) {
          final cellValue = _getCellValue(sheet, row, col) ?? '';
          rowData.add(
            cellValue.toString().substring(
              0,
              cellValue.toString().length > 20
                  ? 20
                  : cellValue.toString().length,
            ),
          );
        }
      }
    }
  }
}

// Only for testing purposes
extension ExcelImportServiceTestExtension on ExcelImportService {
  double? parseDoubleTest(dynamic value) {
    return _parseDouble(value);
  }

  FacilityLocationType? parseFacilityLocationTypeTest(String? value) {
    return _parseFacilityLocationType(value);
  }

  ManagingAuthorityType? parseManagingAuthorityTypeTest(String? value) {
    return _parseManagingAuthorityType(value);
  }

  FacilityStructureType? parseFacilityStructureTypeTest(String? value) {
    return _parseFacilityStructureType(value);
  }

  FacilityType? parseFacilityTypeTest(String? value) {
    return _parseFacilityType(value);
  }

  ExistingFacilityType? parseExistingFacilityTypeTest(String? value) {
    return _parseExistingFacilityType(value);
  }

  DateTime? parseDateTest(dynamic value) {
    return _parseDate(value);
  }

  bool? parseBooleanTest(dynamic value) {
    return _parseBoolean(value);
  }

  int? parseIntTest(dynamic value) {
    return _parseInt(value);
  }

  bool isSummaryRowTest(String? itemNumber, String? area) {
    return _isSummaryRow(itemNumber, area);
  }

  bool isValidItemNumberTest(String? itemNumber) {
    return _isValidItemNumber(itemNumber);
  }
}
