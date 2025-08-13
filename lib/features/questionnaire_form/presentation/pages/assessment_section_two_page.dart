import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/breakpoints.dart';

// Assessment Item Data Model
class AssessmentSectionTwoItemData {
  final String id;
  int? dbId; // ← will hold the DB autoIncrement id
  final String sectionNumber;
  final String area;
  final String meetsDescription;
  final String partialDescription;
  final String doesNotDescription;
  String? selectedRating;

  AssessmentSectionTwoItemData({
    required this.id,
    this.dbId,
    required this.sectionNumber,
    required this.area,
    required this.meetsDescription,
    required this.partialDescription,
    required this.doesNotDescription,
    this.selectedRating,
  });
}

// Rating Type Enum
enum AssessmentRating { meets, partial, doesNot, dontKnow, notApplicable }

class AssessmentSectionTwoPage extends StatefulWidget {
  final AssessmentFormEntity? assessmentForm;
  final Function(AssessmentFormEntity) onUpdateForm;

  const AssessmentSectionTwoPage({
    super.key,
    this.assessmentForm,
    required this.onUpdateForm,
  });

  @override
  State<AssessmentSectionTwoPage> createState() =>
      _AssessmentSectionTwoPageState();
}

class _AssessmentSectionTwoPageState extends State<AssessmentSectionTwoPage>
    with TickerProviderStateMixin {
  late List<AssessmentSectionTwoItemData> _assessmentItems;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _initializeAssessmentItems();
    _loadExistingRatings();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAssessmentItems() {
    _assessmentItems = [
      // 2.1 Facility accesses and flows
      AssessmentSectionTwoItemData(
        id: 'facility_entrances',
        sectionNumber: '2.1.1',
        area: 'Health care facility entrances',
        meetsDescription:
            'Patients and staff have dedicated entrances clearly labelled',
        partialDescription:
            'There are separate entrances for patients and staff but not properly labelled or not always used',
        doesNotDescription:
            'There is only one common entrance for both staff and patients',
      ),
      AssessmentSectionTwoItemData(
        id: 'area_distribution',
        sectionNumber: '2.1.2',
        area: 'Area distribution',
        meetsDescription:
            'High-risk and low-risk zones are clearly divided and identified',
        partialDescription: 'Zones are divided but not clearly identified',
        doesNotDescription:
            'No clear division between high-risk and low-risk areas',
      ),
      AssessmentSectionTwoItemData(
        id: 'patient_flow',
        sectionNumber: '2.1.3',
        area: 'Patient flow',
        meetsDescription:
            'Patient flow is logical, labeled, and supports one-way movement',
        partialDescription: 'Flow is logical but not labeled or easy to follow',
        doesNotDescription: 'Patient flow is unclear or not logical',
      ),
      AssessmentSectionTwoItemData(
        id: 'staff_flow',
        sectionNumber: '2.1.4',
        area: 'Staff flow',
        meetsDescription:
            'Staff follow a clear, labeled path through screening, donning, risk zone, and doffing',
        partialDescription:
            'Staff path is logical but not labeled or fully controlled',
        doesNotDescription: 'No proper staff flow exists',
      ),
      AssessmentSectionTwoItemData(
        id: 'visitor_area',
        sectionNumber: '2.1.5',
        area: 'Visitor area',
        meetsDescription:
            'There is a dedicated visitor area with physical separation from wards',
        partialDescription: 'Visitor area exists but offers limited separation',
        doesNotDescription:
            'No visitor area or no protocols for visitor access',
      ),
      AssessmentSectionTwoItemData(
        id: 'facility_delimitation',
        sectionNumber: '2.1.6',
        area: 'Facility delimitation',
        meetsDescription:
            'Facility compound is fully fenced and all entrances are controlled',
        partialDescription:
            'Compound is fenced but not all entrances are controlled',
        doesNotDescription:
            'No continuous fence or uncontrolled compound access',
      ),

      // 2.2 Facility systems and finishing
      AssessmentSectionTwoItemData(
        id: 'electricity',
        sectionNumber: '2.2.1',
        area: 'Electricity',
        meetsDescription:
            'Electrical system meets regulations and has back-up power',
        partialDescription:
            'System meets regulations but critical loads lack back-up',
        doesNotDescription:
            'Electrical system fails regulations or has no back-up',
      ),
      AssessmentSectionTwoItemData(
        id: 'fire_safety',
        sectionNumber: '2.2.2',
        area: 'Fire safety',
        meetsDescription:
            'Fire safety system meets regulations and has an evacuation plan',
        partialDescription:
            'System meets regulations but no formal evacuation plan',
        doesNotDescription: 'No compliant fire safety system',
      ),
      AssessmentSectionTwoItemData(
        id: 'ventilation_airflow',
        sectionNumber: '2.2.3',
        area: 'Ventilation, airflow rate',
        meetsDescription: 'All areas have at least 10 L/s/person ventilation',
        partialDescription: 'Areas are ventilated but airflow not measured',
        doesNotDescription: 'Areas lack adequate ventilation',
      ),
      AssessmentSectionTwoItemData(
        id: 'ventilation_maintenance',
        sectionNumber: '2.2.4',
        area: 'Ventilation system maintenance (if mechanical)',
        meetsDescription:
            'Mechanical ventilation is well maintained per guidelines',
        partialDescription: 'System works but maintenance is irregular',
        doesNotDescription: 'System is not functioning or not maintained',
      ),
      AssessmentSectionTwoItemData(
        id: 'finishing_materials',
        sectionNumber: '2.2.5',
        area: 'Finishing materials and furniture',
        meetsDescription:
            'Materials and furniture are smooth, non-porous, and easy to clean',
        partialDescription:
            'Materials are non-porous but hard to clean or repair',
        doesNotDescription: 'Materials are porous or not easy to maintain',
      ),

      // 2.3 Waste management
      AssessmentSectionTwoItemData(
        id: 'waste_area',
        sectionNumber: '2.3.1',
        area: 'Waste area',
        meetsDescription:
            'Dedicated waste area is fenced, with capacity and running water',
        partialDescription:
            'Waste area exists but lacks fence or cleaning facilities',
        doesNotDescription: 'No dedicated waste storage area',
      ),
      AssessmentSectionTwoItemData(
        id: 'waste_segregation',
        sectionNumber: '2.3.2',
        area: 'Waste segregation',
        meetsDescription:
            'Three-bin segregation system is in place and used properly',
        partialDescription:
            'System exists but not used properly or in all locations',
        doesNotDescription: 'No waste segregation bins',
      ),
      AssessmentSectionTwoItemData(
        id: 'hazardous_waste',
        sectionNumber: '2.3.3',
        area: 'Hazardous waste',
        meetsDescription: 'Hazardous waste is treated or disposed safely',
        partialDescription:
            'On-site or off-site treatment exists but is irregular',
        doesNotDescription: 'Hazardous waste is mixed with general waste',
      ),

      // 2.4 Water and sanitation
      AssessmentSectionTwoItemData(
        id: 'water_availability',
        sectionNumber: '2.4.1',
        area: 'Water availability',
        meetsDescription:
            'Safe water is available on premises in sufficient quantity',
        partialDescription:
            'Water is from an improved source but not on site or insufficient',
        doesNotDescription: 'Water is not available or unsafe',
      ),
      AssessmentSectionTwoItemData(
        id: 'water_storage',
        sectionNumber: '2.4.2',
        area: 'Water storage',
        meetsDescription: 'Protected storage lasts at least two days',
        partialDescription: 'Storage exists but is unprotected or insufficient',
        doesNotDescription: 'No water storage',
      ),
      AssessmentSectionTwoItemData(
        id: 'water_quality',
        sectionNumber: '2.4.3',
        area: 'Water quality',
        meetsDescription: 'Water quality meets national standards',
        partialDescription: 'Standards met but monitoring is irregular',
        doesNotDescription: 'Water fails quality standards',
      ),
      AssessmentSectionTwoItemData(
        id: 'waste_water',
        sectionNumber: '2.4.4',
        area: 'Waste water',
        meetsDescription:
            'Waste water is safely managed with no environmental discharge',
        partialDescription: 'Some leakage or partial safety controls',
        doesNotDescription: 'Waste water discharged into environment',
      ),
      AssessmentSectionTwoItemData(
        id: 'hand_washing',
        sectionNumber: '2.4.5',
        area: 'Hand washing',
        meetsDescription:
            'All toilets have functional handwashing stations within 5 m',
        partialDescription:
            'At least half of toilets have handwashing stations',
        doesNotDescription: 'Fewer than half have functional stations',
      ),
      AssessmentSectionTwoItemData(
        id: 'mhm_toilet',
        sectionNumber: '2.4.6',
        area: 'Improved toilet for menstrual hygiene management (MHM)',
        meetsDescription:
            'At least one usable toilet meets menstrual hygiene needs',
        partialDescription: 'Toilet present but missing key features',
        doesNotDescription: 'No usable MHM toilet',
      ),
      AssessmentSectionTwoItemData(
        id: 'reduced_mobility_toilet',
        sectionNumber: '2.4.7',
        area: 'Toilet for people with reduce mobility',
        meetsDescription: 'Accessible toilet available for reduced mobility',
        partialDescription: 'Toilet exists but only partially accessible',
        doesNotDescription: 'No accessible toilet',
      ),
    ];
  }

  void _loadExistingRatings() {
    final form = widget.assessmentForm;
    if (form == null) return;

    // 1) Find section 2
    final section2 = form.sections.firstWhereOrNull(
      (s) => s.sectionNumber == '2',
    );
    if (section2 == null) return;

    // 3) Then populate each item's dbId + selectedRating
    for (final item in section2.items) {
      final ai = _assessmentItems.firstWhereOrNull(
        (x) => x.sectionNumber == item.sectionNumber,
      );
      if (ai != null) {
        ai.dbId = item.id;
        if (item.selectedRating != null) {
          ai.selectedRating = _getRatingValue(item.selectedRating!.value);
        }
      }
    }
  }

  String? _getRatingValue(int ratingId) {
    switch (ratingId) {
      case 3:
        return 'meets';
      case 2:
        return 'partial';
      case 1:
        return 'does_not';
      case 0:
        return 'dk';
      case -1:
        return 'na';
      default:
        return null;
    }
  }

  AssessmentRatingEntity? _createRating(String? value) {
    if (value == null) return null;

    switch (value) {
      case 'meets':
        return AssessmentRatingEntity.meetsTarget();
      case 'partial':
        return AssessmentRatingEntity.partiallyMeetsTarget();
      case 'does_not':
        return AssessmentRatingEntity.doesNotMeetTarget();
      case 'dk':
        return AssessmentRatingEntity.dontKnow();
      case 'na':
        return AssessmentRatingEntity.notApplicable();
      default:
        return null;
    }
  }

  void _updateRating(String itemId, String? value) {
    setState(() {
      final item = _assessmentItems.firstWhere((item) => item.id == itemId);
      item.selectedRating = value;
    });

    _updateForm();
  }

  void _updateForm() {
    if (widget.assessmentForm == null) {
      return;
    }

    final items =
        _assessmentItems.asMap().entries.map((entry) {
          final data = entry.value;
          final rating = _createRating(data.selectedRating);

          return AssessmentItemEntity(
            // 1) Always > 0
            id: data.dbId, // ←– the real item PK (or null for a brand‑new one)
            // 2) Now pass your "2.1.x" label
            itemNumber: data.sectionNumber,

            sectionNumber: data.sectionNumber,
            area: data.area,
            meetsTargetDescription: data.meetsDescription,
            partiallyMeetsDescription: data.partialDescription,
            doesNotMeetDescription: data.doesNotDescription,
            selectedRating: rating,
            comment: data.selectedRating,
          );
        }).toList();

    final existingSection = widget.assessmentForm!.sections.firstWhereOrNull(
      (s) => s.sectionNumber == '2',
    );

    final section2 = AssessmentSectionEntity(
      id: existingSection?.id, // ←– this stays a String? UUID

      sectionNumber: "2",
      title: "Overall Facility Assessment",
      description:
          "This section is applicable to all the health facilities addressed in this document.",
      items: items,
    );

    final sections = List<AssessmentSectionEntity>.from(
      widget.assessmentForm!.sections,
    );
    final existingIndex = sections.indexWhere((s) => s.sectionNumber == "2");

    if (existingIndex >= 0) {
      sections[existingIndex] = section2;
    } else {
      sections.add(section2);
    }

    final updatedForm = widget.assessmentForm!.copyWith(sections: sections);

    widget.onUpdateForm(updatedForm);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final contentWidth = AdaptiveBreakpoints.getContentWidth(screenWidth);
          final isMobile = AdaptiveBreakpoints.isMobile(screenWidth);

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Column(
                          children: [
                            if (AdaptiveBreakpoints.isDesktop(screenWidth))
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 24,
                                  bottom: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Section 2: Facility Assessment',
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
                              child: SingleChildScrollView(
                                key: const PageStorageKey('section_two_scroll'),
                                physics: const BouncingScrollPhysics(),
                                padding: AdaptiveBreakpoints.getScreenPadding(
                                  screenWidth,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeaderSection(theme, isMobile),
                                    SizedBox(height: isMobile ? 20 : 24),
                                    _buildFacilityAccessSection(
                                      theme,
                                      isMobile,
                                    ),
                                    SizedBox(height: isMobile ? 20 : 24),
                                    _buildFacilitySystemsSection(
                                      theme,
                                      isMobile,
                                    ),
                                    SizedBox(height: isMobile ? 20 : 24),
                                    _buildWasteManagementSection(
                                      theme,
                                      isMobile,
                                    ),
                                    SizedBox(height: isMobile ? 20 : 24),
                                    _buildWaterSanitationSection(
                                      theme,
                                      isMobile,
                                    ),
                                    SizedBox(height: isMobile ? 24 : 40),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme, bool isMobile) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
              ),
              child: Icon(
                Icons.assignment_outlined,
                color: theme.colorScheme.onPrimary,
                size: isMobile ? 20 : 24,
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Section 2: Overall Facility Assessment',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: isMobile ? 16 : null,
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    'Evaluate facility infrastructure, systems, and basic services',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.8,
                      ),
                      fontSize: isMobile ? 13 : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityAccessSection(ThemeData theme, bool isMobile) {
    final items =
        _assessmentItems
            .where((item) => item.sectionNumber.startsWith('2.1'))
            .toList();

    return _AssessmentSection(
      title: '2.1 Facility Accesses and Flows',
      icon: Icons.input_outlined,
      description:
          'Evaluation of entrances, area distribution, and patient/staff flow patterns',
      items: items,
      onRatingChanged: _updateRating,
      isMobile: isMobile,
    );
  }

  Widget _buildFacilitySystemsSection(ThemeData theme, bool isMobile) {
    final items =
        _assessmentItems
            .where((item) => item.sectionNumber.startsWith('2.2'))
            .toList();

    return _AssessmentSection(
      title: '2.2 Facility Systems and Finishing',
      icon: Icons.settings_outlined,
      description:
          'Assessment of electrical, fire safety, ventilation, and finishing materials',
      items: items,
      onRatingChanged: _updateRating,
      isMobile: isMobile,
    );
  }

  Widget _buildWasteManagementSection(ThemeData theme, bool isMobile) {
    final items =
        _assessmentItems
            .where((item) => item.sectionNumber.startsWith('2.3'))
            .toList();

    return _AssessmentSection(
      title: '2.3 Waste Management',
      icon: Icons.delete_outline,
      description:
          'Evaluation of waste storage, segregation, and disposal systems',
      items: items,
      onRatingChanged: _updateRating,
      isMobile: isMobile,
    );
  }

  Widget _buildWaterSanitationSection(ThemeData theme, bool isMobile) {
    final items =
        _assessmentItems
            .where((item) => item.sectionNumber.startsWith('2.4'))
            .toList();

    return _AssessmentSection(
      title: '2.4 Water and Sanitation',
      icon: Icons.water_drop_outlined,
      description:
          'Assessment of water availability, quality, storage, and sanitation facilities',
      items: items,
      onRatingChanged: _updateRating,
      isMobile: isMobile,
    );
  }
}

// Custom Assessment Section Widget
class _AssessmentSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final List<AssessmentSectionTwoItemData> items;
  final Function(String, String?) onRatingChanged;
  final bool isMobile;

  const _AssessmentSection({
    required this.title,
    required this.icon,
    required this.description,
    required this.items,
    required this.onRatingChanged,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 6 : 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: isMobile ? 18 : 20,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          fontSize: isMobile ? 16 : null,
                        ),
                      ),
                      SizedBox(height: isMobile ? 1 : 2),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: isMobile ? 11 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),
            ...items.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: isMobile ? 16 : 20),
                child: _AssessmentItemCard(
                  item: item,
                  onRatingChanged: onRatingChanged,
                  isMobile: isMobile,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Assessment Item Card Widget
class _AssessmentItemCard extends StatelessWidget {
  final AssessmentSectionTwoItemData item;
  final Function(String, String?) onRatingChanged;
  final bool isMobile;

  const _AssessmentItemCard({
    required this.item,
    required this.onRatingChanged,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 6 : 8,
                    vertical: isMobile ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.sectionNumber,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                      fontSize: isMobile ? 10 : null,
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    item.area,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      fontSize: isMobile ? 14 : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            _AssessmentRatingSelector(
              selectedRating: item.selectedRating,
              meetsDescription: item.meetsDescription,
              partialDescription: item.partialDescription,
              doesNotDescription: item.doesNotDescription,
              onChanged: (value) => onRatingChanged(item.id, value),
              isMobile: isMobile,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Rating Selector Widget
class _AssessmentRatingSelector extends StatelessWidget {
  final String? selectedRating;
  final String meetsDescription;
  final String partialDescription;
  final String doesNotDescription;
  final ValueChanged<String?> onChanged;
  final bool isMobile;

  const _AssessmentRatingSelector({
    required this.selectedRating,
    required this.meetsDescription,
    required this.partialDescription,
    required this.doesNotDescription,
    required this.onChanged,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _RatingOption(
          value: 'meets',
          selectedValue: selectedRating,
          title: 'Meets Target',
          description: meetsDescription,
          color: const Color(0xFF2E7D32), // WHO Green
          icon: Icons.check_circle_outline,
          onChanged: onChanged,
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 6 : 8),
        _RatingOption(
          value: 'partial',
          selectedValue: selectedRating,
          title: 'Partially Meets',
          description: partialDescription,
          color: const Color(0xFFFF8F00), // WHO Orange
          icon: Icons.adjust_outlined,
          onChanged: onChanged,
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 6 : 8),
        _RatingOption(
          value: 'does_not',
          selectedValue: selectedRating,
          title: 'Does Not Meet',
          description: doesNotDescription,
          color: const Color(0xFFD32F2F), // Error Red
          icon: Icons.cancel_outlined,
          onChanged: onChanged,
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 8 : 12),
        // Separate rows for Don't Know and Not Applicable
        _CompactRatingOption(
          value: 'dk',
          selectedValue: selectedRating,
          title: "Don't Know",
          color: theme.colorScheme.onSurfaceVariant,
          icon: Icons.help_outline,
          onChanged: onChanged,
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 6 : 8),
        _CompactRatingOption(
          value: 'na',
          selectedValue: selectedRating,
          title: 'Not Applicable',
          color: theme.colorScheme.secondary,
          icon: Icons.not_interested,
          onChanged: onChanged,
          isMobile: isMobile,
        ),
      ],
    );
  }
}

// Individual Rating Option Widget
class _RatingOption extends StatelessWidget {
  final String value;
  final String? selectedValue;
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final ValueChanged<String?> onChanged;
  final bool isMobile;

  const _RatingOption({
    required this.value,
    required this.selectedValue,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.onChanged,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: () => onChanged(isSelected ? null : value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? color
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
              size: isMobile ? 18 : 20,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Icon(
              icon,
              color: isSelected ? color : theme.colorScheme.onSurface,
              size: isMobile ? 16 : 18,
            ),
            SizedBox(width: isMobile ? 6 : 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : theme.colorScheme.onSurface,
                      fontSize: isMobile ? 13 : null,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            isSelected
                                ? color.withValues(alpha: 0.8)
                                : theme.colorScheme.onSurfaceVariant,
                        fontSize: isMobile ? 11 : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactRatingOption extends StatelessWidget {
  final String value;
  final String? selectedValue;
  final String title;
  final Color color;
  final IconData icon;
  final ValueChanged<String?> onChanged;
  final bool isMobile;

  const _CompactRatingOption({
    required this.value,
    required this.selectedValue,
    required this.title,
    required this.color,
    required this.icon,
    required this.onChanged,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: () => onChanged(isSelected ? null : value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity, // Full width
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                isSelected
                    ? color
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? color : theme.colorScheme.onSurface,
              size: isMobile ? 16 : 18,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Icon(
              icon,
              color: isSelected ? color : theme.colorScheme.onSurface,
              size: isMobile ? 14 : 16,
            ),
            SizedBox(width: isMobile ? 6 : 8),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : theme.colorScheme.onSurface,
                  fontSize: isMobile ? 12 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
