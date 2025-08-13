import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/breakpoints.dart';

// Assessment Item Data Model for Section 3
class AssessmentSectionThreeItemData {
  final String id;
  int? dbId; // ← will hold the DB autoIncrement id
  final String sectionNumber;
  final String area;
  final String meetsDescription;
  final String partialDescription;
  final String doesNotDescription;
  String? selectedRating;

  AssessmentSectionThreeItemData({
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

class AssessmentSectionThreePage extends StatefulWidget {
  final AssessmentFormEntity? assessmentForm;
  final Function(AssessmentFormEntity) onUpdateForm;

  const AssessmentSectionThreePage({
    super.key,
    this.assessmentForm,
    required this.onUpdateForm,
  });

  @override
  State<AssessmentSectionThreePage> createState() =>
      _AssessmentSectionThreePageState();
}

class _AssessmentSectionThreePageState extends State<AssessmentSectionThreePage>
    with TickerProviderStateMixin {
  late List<AssessmentSectionThreeItemData> _assessmentItems;
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

  void _loadExistingRatings() {
    final form = widget.assessmentForm;
    if (form == null) return;

    // 1) Find section 3
    final section3 = form.sections.firstWhereOrNull(
      (s) => s.sectionNumber == '3',
    );
    if (section3 == null) return;

    // 3) Then populate each item's dbId + selectedRating
    for (final item in section3.items) {
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

  void _initializeAssessmentItems() {
    _assessmentItems = [
      // 3.1 Waiting room
      AssessmentSectionThreeItemData(
        id: 'waiting_location',
        sectionNumber: '3.1.1',
        area: 'Location',
        meetsDescription:
            'The waiting room is located in proximity (< 5m) to the screening and triage areas.',
        partialDescription:
            'The waiting room is located between 5m and 15m to the screening and triage areas, but the path is easy to follow',
        doesNotDescription:
            'The waiting room is located at more than 15m to the screening and triage areas, and the path is not easy to follow.',
      ),
      AssessmentSectionThreeItemData(
        id: 'waiting_physical_distance',
        sectionNumber: '3.1.2',
        area: 'Physical distance and furniture',
        meetsDescription:
            'In the waiting room the furniture (chairs, fences, ground marks) ensure there is at least 2 m between patients (1 m for IPC + 1 m for health worker movement)',
        partialDescription:
            'In the waiting room the furniture (chairs, fences, ground marks) ensure there is at least 1 m between patients',
        doesNotDescription:
            'In the waiting room the furniture (chairs, fences, ground marks) are randomly located or not present therefore there is LESS than 1 m between patients',
      ),
      AssessmentSectionThreeItemData(
        id: 'waiting_floor_surface',
        sectionNumber: '3.1.3',
        area: 'Floor surface',
        meetsDescription: 'There is at least 4 m² per patient',
        partialDescription:
            'There is between 2.5 m² and 4 m² per patient OR there are individual booths (physical separation between patients)',
        doesNotDescription:
            'There are NO individual booths and there is LESS than 2.5 m² per patient',
      ),
      AssessmentSectionThreeItemData(
        id: 'waiting_surge_plan',
        sectionNumber: '3.1.4',
        area: 'Surge plan',
        meetsDescription:
            'The waiting area can be extended in case of the patients accesses increase, avoiding overcrowding. It is already equipped and ready to use',
        partialDescription:
            'The waiting area can be extended in case of the patients accesses increase, avoiding overcrowding. However it is NOT equipped',
        doesNotDescription:
            'There is NO possibility to extend the waiting room',
      ),
      AssessmentSectionThreeItemData(
        id: 'waiting_toilet',
        sectionNumber: '3.1.5',
        area: 'Toilet facility',
        meetsDescription:
            'There are dedicated toilets directly accessible from the waiting area, that fully meet the criteria listed in section 2.4.5',
        partialDescription:
            'There are dedicated toilets NOT directly accessible from the waiting area OR that fully meet the criteria listed in section 2.4.5',
        doesNotDescription:
            'There are no dedicated toilet OR there are dedicated toilet that do not meet the criteria listed in section 2.4.5',
      ),

      // 3.2 Screening and triage
      AssessmentSectionThreeItemData(
        id: 'screening_location',
        sectionNumber: '3.2.1',
        area: 'Location',
        meetsDescription:
            'A screening area is placed at the entrance of the facility. All patients pass through the screening before accessing the facility. The screening is visible, clearly labelled and proper wayfinding guides the flow of patients.',
        partialDescription:
            'A screening area is placed at the entrance of the facility. All patients pass through the screening before accessing the facility. However, it is not clearly labelled AND no dedicate wayfinding is in place to guide the flow of patients.',
        doesNotDescription:
            'NOT all patients pass by the screening before accessing the facility',
      ),
      AssessmentSectionThreeItemData(
        id: 'screening_patient_pathway',
        sectionNumber: '3.2.2',
        area: 'FVD patient\'s pathway',
        meetsDescription:
            'In the screening area, there are separated exits for patient who meet the case definition (suspect cases) and patient who does not meet the case the definition (non-suspect cases) to ensure separate patients\' flows. Suspect cases access the screening facility while non-suspect cases proceed with their path.',
        partialDescription:
            'In the screening area, there is only one exit for patient who meet the case definition (suspect cases) and patient who does not meet the case the definition (non-suspect cases), however the shared path is short and suspect cases access the screening facility while non-suspect cases proceed with their path.',
        doesNotDescription:
            'In the screening area, there is only one exit for patient who meet the case definition (suspect cases) and patient who does not meet the case the definition (non-suspect cases). Non-suspect cases may access by accident the screening facility rather proceeding with their path.',
      ),
      AssessmentSectionThreeItemData(
        id: 'screening_physical_distance',
        sectionNumber: '3.2.3',
        area: 'Physical distance and furniture',
        meetsDescription:
            'There is at least 1 m distance, between patients and staff when conducting screening. Physical barrier (fence or furniture) or marks on the ground support keeping the distance',
        partialDescription:
            'There is LESS than 1 m distance between patients and staff OR no marks on the ground or physical barriers helps in keeping the physical distance',
        doesNotDescription: 'There is NO distance between patients and staff',
      ),
      AssessmentSectionThreeItemData(
        id: 'screening_floor_surface',
        sectionNumber: '3.2.4',
        area: 'Floor surface',
        meetsDescription:
            'For each screening and triage station there is at least 14 m² of surface available',
        partialDescription:
            'For each screening and triage station, there is between 8 m² and 13.9 m² of surface available',
        doesNotDescription:
            'For each screening and triage station, there is less than 8 m² of surface available',
      ),
      AssessmentSectionThreeItemData(
        id: 'screening_donning_location',
        sectionNumber: '3.2.5',
        area: 'Donning/doffing location',
        meetsDescription:
            'There are dedicated donning and doffing spaces for the screening and triage station that are strategically located between the low risk zone and the high risk zone',
        partialDescription:
            'There are NO designated spaces for donning and doffing dedicated to the screening and triage, but staff can use donning and doffing spaces, that are strategically located between the low risk zone and the high risk zone, and that are in proximity to the screening and triage station (less than 30 m).',
        doesNotDescription:
            'There are NO designated spaces for donning and doffing dedicated to the screening and triage and staff put on and take off the PPE in donning and doffing rooms far from screening and triage ( more than 30 m) OR donning and doffing are not strategically located between the low risk zone and the high risk zone',
      ),
      AssessmentSectionThreeItemData(
        id: 'screening_donning_dimensions',
        sectionNumber: '3.2.6',
        area: 'Donning dimensions and furniture',
        meetsDescription:
            'The donning area is big enough to ensure space for shelves for PPE storage, bins, mirror, bench/chair, small table. The dimension of the donning and doffing areas also ensure optimal free movement of 1 staff (at least 12 m²)',
        partialDescription:
            'The donning area is big enough to ensure space for shelves for PPE storage, bins, mirror, a chair. The dimension of the donning and doffing areas also ensure free movement of 1 staff (between 9 m² and 11.9 m²)',
        doesNotDescription:
            'The donning is not big enough to ensure space for basic furniture and PPE storage AND staff has no sufficient space to properly perform donning procedure (less than 9 m²).',
      ),
      AssessmentSectionThreeItemData(
        id: 'screening_doffing_dimensions',
        sectionNumber: '3.2.7',
        area: 'Doffing dimensions and furniture',
        meetsDescription:
            'The doffing area is big enough to ensure space for full rotation with open arms for 1 staff, 1 m distance with the second staff spraying, bins and handwashing station. The doffing area (1 line) is at least 10 m²',
        partialDescription:
            'The doffing area is big enough to ensure 1 m distance with the second staff spraying, bins and handwashing station. The full rotation with open arms of staff taking off the PPE is difficult. The doffing area (1 line) is between 8 m² and 9.9 m²',
        doesNotDescription:
            'The doffing area is not big enough to ensure full movement of the staff OR to ensure 1 m distance between the 2 staff OR to host bins and handwashing station. The doffing area ( 1 line) is less than 8 m²',
      ),
      AssessmentSectionThreeItemData(
        id: 'screening_discharge_location',
        sectionNumber: '3.2.8',
        area: 'Discharge shower location',
        meetsDescription:
            'A discharge shower is available and every non-case is passing through it before exit the screening area. It is located in proximity (< 10m) to the screening and triage areas',
        partialDescription:
            'A discharge shower is available and every non-case is passing through it before exit the facility. It is located far ( > 10m) from the screening and triage areas',
        doesNotDescription:
            'A discharge shower is not available OR it is available but not every non-case pass through it before exit the facility.',
      ),
      AssessmentSectionThreeItemData(
        id: 'screening_discharge_dimensions',
        sectionNumber: '3.2.9',
        area: 'Discharge shower dimensions and furniture',
        meetsDescription:
            'The discharge shower is at least 4 m². There is space for dressing, undressing, a shower and to ensure the flow is unidirectional',
        partialDescription:
            'The discharge shower is between 2 m² and 4 m². There is space for dressing/undressing, a shower.',
        doesNotDescription:
            'The discharge shower is less than 2 m². Shower and changing zone are sharing the same area.',
      ),

      // 3.3 Temporary isolation rooms
      AssessmentSectionThreeItemData(
        id: 'isolation_location',
        sectionNumber: '3.3.1',
        area: 'Location and access',
        meetsDescription:
            'The isolation room is a single room, clearly identified and labelled, and access is controlled. A dedicated pathway leads suspect patients from the screening/triage to the isolation room without walking into the staff area. Individual toilets are available. Suspect cases wait here for the referral to the suitable health facility, a dedicated exit toward the ambulance bay is available.',
        partialDescription:
            'The isolation room is a single room, clearly identified and labelled, and access is controlled. A dedicated pathway leads suspect patients from the screening/ triage to the isolation room without walking into the staff area. Individual toilets are available. Suspect cases wait here for the referral to the suitable health facility, but there is NO dedicated exit toward the ambulance bay.',
        doesNotDescription:
            'The isolation room is NOT a single room, OR NOT clearly identified and labelled OR access is NOT controlled. NO dedicated pathway leads suspect patients from the screening/triage to the isolation room without walking into the staff area, NO dedicated exit toward the ambulance bay is available.',
      ),
      AssessmentSectionThreeItemData(
        id: 'isolation_donning_location',
        sectionNumber: '3.3.2',
        area: 'Donning/doffing location',
        meetsDescription:
            'There are dedicated donning and doffing spaces for the isolation room that are strategically located between the low risk zone and the high risk zone',
        partialDescription:
            'There are NO designated spaces for donning and doffing dedicated to the isolation room, but staff can use donning and doffing spaces, that are strategically located between the low risk zone and the high risk zone, and that are in proximity to the isolation room ( less than 30 m).',
        doesNotDescription:
            'There are NO designated spaces for donning and doffing dedicated to the isolation room and staff put on and take off the PPE in donning and doffing rooms far the isolation room ( more than 30 m) OR donning and doffing are not strategically located between the low risk zone and the high risk zone',
      ),
      AssessmentSectionThreeItemData(
        id: 'isolation_donning_dimensions',
        sectionNumber: '3.3.3',
        area: 'Donning dimensions and furniture',
        meetsDescription:
            'The donning area is big enough to ensure space for shelves for PPE storage, bins, mirror, bench/chair, small table. The dimension of the donning and doffing areas also ensure optimal free movement of 1 staff (at least 12 m²)',
        partialDescription:
            'The donning area is big enough to ensure space for shelves for PPE storage, bins, mirror, a chair. The dimension of the donning and doffing areas also ensure free movement of 1 staff (between 9 m² and 11.9 m²)',
        doesNotDescription:
            'The donning is not big enough to ensure space for basic furniture and PPE storage AND staff has no sufficient space to properly perform donning procedure (less than 9 m²).',
      ),
      AssessmentSectionThreeItemData(
        id: 'isolation_doffing_dimensions',
        sectionNumber: '3.3.4',
        area: 'Doffing dimensions and furniture',
        meetsDescription:
            'The doffing area is big enough to ensure space for full rotation with open arms for 1 staff, 1 m distance with the second staff spraying, bins and handwashing station. The doffing area (1 line) is at least 10 m²',
        partialDescription:
            'The doffing area is big enough to ensure 1 m distance with the second staff spraying, bins and handwashing station. The full rotation with open arms of staff taking off the PPE is difficult. The doffing area (1 line) is between 8 m² and 9.9 m²',
        doesNotDescription:
            'The doffing area is not big enough to ensure full movement of the staff OR to ensure 1 m distance between the 2 staff OR to host bins and handwashing station. The doffing area ( 1 line) is less than 8 m²',
      ),
      AssessmentSectionThreeItemData(
        id: 'isolation_patient_placement',
        sectionNumber: '3.3.5',
        area: 'Patients\' placement',
        meetsDescription:
            'Suspect cases are in individual rooms with private toilets. (further criteria for toilets in section 2.4.5)',
        partialDescription:
            'Suspect cases are in individual room with shared toilets. (further criteria for toilets in section 2.4.5)',
        doesNotDescription:
            'No individual room for suspect cases is available OR Shared toilets are not cleaned after each use. (further criteria for toilets in section 2.4.5)',
      ),
      AssessmentSectionThreeItemData(
        id: 'isolation_floor_surface',
        sectionNumber: '3.3.6',
        area: 'Floor surface',
        meetsDescription:
            'The individual room for suspect cases is at least 8 m². Private toilet is available',
        partialDescription:
            'The surface of the individual room for suspect cases is between 8 m² and 6 m².',
        doesNotDescription: 'The isolation room is less than 6 m²',
      ),
      AssessmentSectionThreeItemData(
        id: 'isolation_surge_plan',
        sectionNumber: '3.3.7',
        area: 'Surge plan',
        meetsDescription:
            'Extra rooms are available in case the beds demand increase; it is equipped and ready at any time',
        partialDescription:
            'Extra rooms are available in case the beds demand increase, but it is NOT equipped',
        doesNotDescription:
            'There is NO extra rooms are available in case the beds demand increase',
      ),
    ];
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
            // 2) Now pass your "3.1.x" label
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
      (s) => s.sectionNumber == '3',
    );

    final section3 = AssessmentSectionEntity(
      id: existingSection?.id, // ←– this stays a String? UUID

      sectionNumber: "3",
      title: "Screening with Temporary Isolation",
      description:
          "Assessment of waiting areas, screening processes, and temporary isolation facilities",
      items: items,
    );

    final sections = List<AssessmentSectionEntity>.from(
      widget.assessmentForm!.sections,
    );
    final existingIndex = sections.indexWhere((s) => s.sectionNumber == "3");

    if (existingIndex >= 0) {
      sections[existingIndex] = section3;
    } else {
      sections.add(section3);
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
                                        'Section 3: Screening & Isolation',
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
                              child: SingleChildScrollView(
                                key: const PageStorageKey(
                                  'section_three_scroll',
                                ),
                                physics: const BouncingScrollPhysics(),
                                padding: AdaptiveBreakpoints.getScreenPadding(
                                  screenWidth,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeaderSection(theme, isMobile),
                                    SizedBox(height: isMobile ? 20 : 24),
                                    _buildWaitingRoomSection(theme, isMobile),
                                    SizedBox(height: isMobile ? 20 : 24),
                                    _buildScreeningTriageSection(
                                      theme,
                                      isMobile,
                                    ),
                                    SizedBox(height: isMobile ? 20 : 24),
                                    _buildIsolationRoomsSection(
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
                Icons.health_and_safety_outlined,
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
                    'Section 3: Screening with Temporary Isolation',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: isMobile ? 16 : null,
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    'Assessment of waiting areas, screening processes, and temporary isolation facilities',
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

  Widget _buildWaitingRoomSection(ThemeData theme, bool isMobile) {
    final items =
        _assessmentItems
            .where((item) => item.sectionNumber.startsWith('3.1'))
            .toList();

    return _Section3AssessmentSection(
      title: '3.1 Waiting Room',
      icon: Icons.event_seat_outlined,
      description:
          'Assessment of waiting area location, spacing, furniture, and facilities',
      items: items,
      onRatingChanged: _updateRating,
      isMobile: isMobile,
    );
  }

  Widget _buildScreeningTriageSection(ThemeData theme, bool isMobile) {
    final items =
        _assessmentItems
            .where((item) => item.sectionNumber.startsWith('3.2'))
            .toList();

    return _Section3AssessmentSection(
      title: '3.2 Screening and Triage',
      icon: Icons.verified_user_outlined,
      description:
          'Evaluation of screening processes, patient pathways, and PPE procedures',
      items: items,
      onRatingChanged: _updateRating,
      isMobile: isMobile,
    );
  }

  Widget _buildIsolationRoomsSection(ThemeData theme, bool isMobile) {
    final items =
        _assessmentItems
            .where((item) => item.sectionNumber.startsWith('3.3'))
            .toList();

    return _Section3AssessmentSection(
      title: '3.3 Temporary Isolation Rooms',
      icon: Icons.meeting_room_outlined,
      description:
          'Assessment of isolation room facilities, access controls, and patient placement',
      items: items,
      onRatingChanged: _updateRating,
      isMobile: isMobile,
    );
  }
}

// Custom Assessment Section Widget for Section 3
class _Section3AssessmentSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final List<AssessmentSectionThreeItemData> items;
  final Function(String, String?) onRatingChanged;
  final bool isMobile;

  const _Section3AssessmentSection({
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
                child: _Section3AssessmentItemCard(
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

// Custom Assessment Item Card Widget for Section 3
class _Section3AssessmentItemCard extends StatelessWidget {
  final AssessmentSectionThreeItemData item;
  final Function(String, String?) onRatingChanged;
  final bool isMobile;

  const _Section3AssessmentItemCard({
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
            _Section3AssessmentRatingSelector(
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

// Custom Rating Selector Widget for Section 3
class _Section3AssessmentRatingSelector extends StatelessWidget {
  final String? selectedRating;
  final String meetsDescription;
  final String partialDescription;
  final String doesNotDescription;
  final ValueChanged<String?> onChanged;
  final bool isMobile;

  const _Section3AssessmentRatingSelector({
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
        _SectionThreeRatingOption(
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
        _SectionThreeRatingOption(
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
        _SectionThreeRatingOption(
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
        _Section3CompactRatingOption(
          value: 'dk',
          selectedValue: selectedRating,
          title: "Don't Know",
          color: theme.colorScheme.onSurfaceVariant,
          icon: Icons.help_outline,
          onChanged: onChanged,
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 6 : 8),
        _Section3CompactRatingOption(
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

// Individual Rating Option Widget for Section 3
class _SectionThreeRatingOption extends StatelessWidget {
  final String value;
  final String? selectedValue;
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final ValueChanged<String?> onChanged;
  final bool isMobile;

  const _SectionThreeRatingOption({
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
              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
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

// Compact Rating Option for Don't Know / Not Applicable for Section 3 (now full width)
class _Section3CompactRatingOption extends StatelessWidget {
  final String value;
  final String? selectedValue;
  final String title;
  final Color color;
  final IconData icon;
  final ValueChanged<String?> onChanged;
  final bool isMobile;

  const _Section3CompactRatingOption({
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
