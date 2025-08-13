import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/breakpoints.dart';

// Assessment Item Data Model for Section 4
class SectionFourAssessmentItemData {
  final String id;
  int? dbId; // ← will hold the DB autoIncrement id
  final String sectionNumber;
  final String area;
  final String meetsDescription;
  final String partialDescription;
  final String doesNotDescription;
  String? selectedRating;

  SectionFourAssessmentItemData({
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

class AssessmentSectionFourPage extends StatefulWidget {
  final AssessmentFormEntity? assessmentForm;
  final Function(AssessmentFormEntity) onUpdateForm;

  const AssessmentSectionFourPage({
    super.key,
    this.assessmentForm,
    required this.onUpdateForm,
  });

  @override
  State<AssessmentSectionFourPage> createState() =>
      _AssessmentSectionFourPageState();
}

class _AssessmentSectionFourPageState extends State<AssessmentSectionFourPage>
    with TickerProviderStateMixin {
  late List<SectionFourAssessmentItemData> _assessmentItems;
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

    // 1) Find section 4
    final section4 = form.sections.firstWhereOrNull(
      (s) => s.sectionNumber == '4',
    );
    if (section4 == null) return;

    // 3) Then populate each item's dbId + selectedRating
    for (final item in section4.items) {
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
      // 4.1 Waiting Room
      SectionFourAssessmentItemData(
        id: 'tc_4_1_1',
        sectionNumber: '4.1.1',
        area: 'Location',
        meetsDescription:
            'The waiting room is located in proximity (< 5m) to the screening and triage areas.',
        partialDescription:
            'The waiting room is located between 5m and 15m to the screening and triage areas, but the path is easy to follow',
        doesNotDescription:
            'The waiting room is located at more than 15m to the screening and triage areas, and the path is not easy to follow',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_1_2',
        sectionNumber: '4.1.2',
        area: 'Physical distance and furniture',
        meetsDescription:
            'In the waiting room the furniture (chairs, fences, ground marks) ensure there is at least 2 m between patients (1 m for IPC + 1 m for health worker movement)',
        partialDescription:
            'In the waiting room the furniture (chairs, fences, ground marks) ensure there is at least 1 m between patients',
        doesNotDescription:
            'In the waiting room the furniture (chairs, fences, ground marks) are randomly located or not present therefore there is LESS than 1 m between patients',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_1_3',
        sectionNumber: '4.1.3',
        area: 'Floor surface',
        meetsDescription: 'There is at least 4 m² per patient',
        partialDescription:
            'There is between 2.5 m² and 4 m² per patient OR there are individual booths (physical separation between patients)',
        doesNotDescription:
            'There are NO individual booths and there is LESS than 2.5 m² per patient',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_1_4',
        sectionNumber: '4.1.4',
        area: 'Surge plan',
        meetsDescription:
            'The waiting area can be extended in case of the patients accesses increase, avoiding overcrowding. It is already equipped and ready to use',
        partialDescription:
            'The waiting area can be extended in case of the patients accesses increase, avoiding overcrowding. However it is NOT equipped',
        doesNotDescription:
            'There is NO possibility to extend the waiting room',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_1_5',
        sectionNumber: '4.1.5',
        area: 'Toilet facility',
        meetsDescription:
            'There are dedicated toilets directly accessible from the waiting area, that fully meet the criteria listed in section 2.4',
        partialDescription:
            'There are dedicated toilets NOT directly accessible from the waiting area OR that fully meet the criteria listed in section 2.4',
        doesNotDescription:
            'There are no dedicated toilet OR there are dedicated toilet that do not meet the criteria listed in section 2.4',
      ),

      // 4.2 Screening and Triage
      SectionFourAssessmentItemData(
        id: 'tc_4_2_1',
        sectionNumber: '4.2.1',
        area: 'Location',
        meetsDescription:
            'A screening area is placed at the entrance of the facility. All patients pass through the screening before accessing the facility. The screening is visible, clearly labelled and proper wayfinding guides the flow of patients',
        partialDescription:
            'A screening area is placed at the entrance of the facility. All patients pass through the screening before accessing the facility. However, it is not clearly labelled AND no dedicate wayfinding is in place to guide the flow of patients',
        doesNotDescription:
            'NOT all patients pass by the screening before accessing the facility',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_2_2',
        sectionNumber: '4.2.2',
        area: 'FVD patient\'s pathway',
        meetsDescription:
            'In the screening area, there are separated exits for patient who meet the case definition (suspect cases) and patient who does not meet the case the definition (non-suspect cases) to ensure separate patients\' flows. Suspect cases access the screening facility while non-suspect cases proceed with their path',
        partialDescription:
            'In the screening area, there is only one exit for patient who meet the case definition (suspect cases) and patient who does not meet the case the definition (non-suspect cases), however the shared path is short and suspect cases access the screening facility while non-suspect cases proceed with their path',
        doesNotDescription:
            'In the screening area, there is only one exit for patient who meet the case definition (suspect cases) and patient who does not meet the case the definition (non-suspect cases). Non-suspect cases may access by accident the screening facility rather proceeding with their path',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_2_3',
        sectionNumber: '4.2.3',
        area: 'Physical distance and furniture',
        meetsDescription:
            'There is at least 1 m distance, between patients and staff when conducting screening. Physical barrier (fence or furniture) or marks on the ground support keeping the distance',
        partialDescription:
            'There is LESS than 1 m distance between patients and staff OR no marks on the ground or physical barriers helps in keeping the physical distance',
        doesNotDescription: 'There is NO distance between patients and staff',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_2_4',
        sectionNumber: '4.2.4',
        area: 'Floor surface',
        meetsDescription:
            'For each screening and triage station there is at least 14 m² of surface available',
        partialDescription:
            'For each screening and triage station, there is between 8 m² and 13.9 m² of surface available',
        doesNotDescription:
            'For each screening and triage station, there is less than 8 m² of surface available',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_2_5',
        sectionNumber: '4.2.5',
        area: 'Donning/doffing location',
        meetsDescription:
            'There are dedicated donning and doffing spaces for the screening and triage station that are strategically located between the low risk zone and the high risk zone',
        partialDescription:
            'There are NO designated spaces for donning and doffing dedicated to the screening and triage, but staff can use donning and doffing spaces, that are strategically located between the low risk zone and the high risk zone, and that are in proximity to the screening and triage station (less than 30 m)',
        doesNotDescription:
            'There are NO designated spaces for donning and doffing dedicated to the screening and triage and staff put on and take off the PPE in donning and doffing rooms far from screening and triage (more than 30 m) OR donning and doffing are not strategically located between the low risk zone and the high risk zone',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_2_6',
        sectionNumber: '4.2.6',
        area: 'Donning dimensions and furniture',
        meetsDescription:
            'The donning area is big enough to ensure space for shelves for PPE storage, bins, mirror, bench/chair, small table. The dimension of the donning and doffing areas also ensure optimal free movement of 1 staff (at least 12 m²)',
        partialDescription:
            'The donning area is big enough to ensure space for shelves for PPE storage, bins, mirror, a chair. The dimension of the donning and doffing areas also ensure free movement of 1 staff (between 9 m² and 11.9 m²)',
        doesNotDescription:
            'The donning is not big enough to ensure space for basic furniture and PPE storage AND staff has no sufficient space to properly perform donning procedure (less than 9 m²)',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_2_7',
        sectionNumber: '4.2.7',
        area: 'Doffing dimensions and furniture',
        meetsDescription:
            'The doffing area is big enough to ensure space for full rotation with open arms for 1 staff, 1 m distance with the second staff spraying, bins and handwashing station. The doffing area (1 line) is at least 10 m²',
        partialDescription:
            'The doffing area is big enough to ensure 1 m distance with the second staff spraying, bins and handwashing station. The full rotation with open arms of staff taking off the PPE is difficult. The doffing area (1 line) is between 8 m² and 9.9 m²',
        doesNotDescription:
            'The doffing area is not big enough to ensure full movement of the staff OR to ensure 1 m distance between the 2 staff OR to host bins and handwashing station. The doffing area (1 line) is less than 8 m²',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_2_8',
        sectionNumber: '4.2.8',
        area: 'Discharge location',
        meetsDescription:
            'A discharge shower is available and every non-case is passing through it before exit the screening area. It is located in proximity (< 10m) to the screening and triage areas',
        partialDescription:
            'A discharge shower is available and every non-case is passing through it before exit the facility. It is located far (> 10m) from the screening and triage areas',
        doesNotDescription:
            'A discharge shower is not available OR it is available but not every non-case pass through it before exit the facility',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_2_9',
        sectionNumber: '4.2.9',
        area: 'Discharge dimensions and furniture',
        meetsDescription:
            'The discharge shower is at least 4 m². There is space for dressing, undressing, a shower and to ensure the flow is unidirectional',
        partialDescription:
            'The discharge shower is between 2 m² and 4 m². There is space for dressing/undressing, a shower',
        doesNotDescription:
            'The discharge shower is less than 2 m². Shower and changing zone are sharing the same area',
      ),

      // 4.3 FVD Treatment Wards
      SectionFourAssessmentItemData(
        id: 'tc_4_3_1',
        sectionNumber: '4.3.1',
        area: 'FVD patient\'s pathway',
        meetsDescription:
            'The ward is clearly identified and labelled and access is controlled; A dedicated pathway lead suspect or confirmed patients from the screening/triage to the treatment ward without walking into the staff area; discharged patients have a dedicated discharge pathway',
        partialDescription:
            'The ward is clearly identified and labelled, and access is controlled; A dedicated pathway lead suspect or confirmed patients from the screening/triage to the treatment ward without walking into the staff area; there is NOT a dedicated discharge pathway',
        doesNotDescription:
            'The ward is NOT clearly identified and labelled OR access is NOT controlled; NO dedicated pathway lead suspect or confirmed patients from the triage to the treatment ward without walking into the staff area',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_3_2',
        sectionNumber: '4.3.2',
        area: 'Area distribution',
        meetsDescription:
            'There is a dedicated area for staff only (low-risk), with visibility of the patients\' rooms',
        partialDescription:
            'There is a dedicated area for staff only but there is NO visibility of the patients\' rooms',
        doesNotDescription: 'There is NOT a dedicated area for staff',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_3_3',
        sectionNumber: '4.3.3',
        area: 'Patients placement: suspect and confirmed wards',
        meetsDescription:
            'There are separated wards for suspects and confirmed cases',
        partialDescription:
            'There are no separated wards for suspect and confirmed cases, but all individuals rooms are available',
        doesNotDescription:
            'There are no separated rooms for suspect and confirmed cases and not all the rooms are individual',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_3_4',
        sectionNumber: '4.3.4',
        area: 'Suspect cases ward',
        meetsDescription:
            'Suspect cases are in individual rooms with private toilets',
        partialDescription:
            'Suspect cases are in individual room with shared toilets',
        doesNotDescription:
            'No individual room for suspect cases are available OR Shared toilets are not cleaned after each use OR suspect and confirmed patients shared the same space',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_3_5',
        sectionNumber: '4.3.5',
        area: 'Confirmed cases ward',
        meetsDescription:
            'Confirmed cases are in individual rooms OR are cohorted in shared rooms with at least 2 m between patients',
        partialDescription:
            'Confirmed cases are cohorted in shared rooms with 1 m between patients',
        doesNotDescription:
            'Confirmed cases are cohorted in shared rooms with less than 1 m between confirmed patients OR suspect and confirmed patients share the same space',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_3_6',
        sectionNumber: '4.3.6',
        area: 'Special needs rooms',
        meetsDescription:
            'Part of the rooms are equipped or easily adaptable to host patients with special needs',
        partialDescription:
            'Few rooms are equipped or easily adaptable to host patients with special needs',
        doesNotDescription:
            'NO rooms are equipped or easily adaptable to host patients with special needs',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_3_7',
        sectionNumber: '4.3.7',
        area: 'Toilet facility',
        meetsDescription:
            'Both suspect and confirmed cases have private toilet OR Suspect cases rooms have private toilets and shared toilets are available for confirmed cases rooms',
        partialDescription:
            'Confirmed cases room have shared toilets that fully meet the criteria OR not all the suspect cases room have individual toilets',
        doesNotDescription: 'Suspect and confirmed cases share toilets',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_3_8',
        sectionNumber: '4.3.8',
        area: 'Floor surface',
        meetsDescription:
            'Single bedroom/bay dimensions is 3.45 x 3.6 m, objects around the bed do not represent an obstacle for staff',
        partialDescription:
            'Single bedroom/bay dimensions is less than 3.45 x 3.6 m but more than 2.5 x 3 m OR it is 3.45 x 3.6 m with obstacles',
        doesNotDescription:
            'Single bedroom/bay dimensions is less than 2.5 x 3 m per patient',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_3_9',
        sectionNumber: '4.3.9',
        area: 'Donning/doffing location',
        meetsDescription:
            'There are dedicated donning and doffing spaces for the ward that are strategically located between the low risk zone and the high risk zone',
        partialDescription:
            'No designated spaces for the ward, but staff use nearby spaces (<30 m)',
        doesNotDescription:
            'No designated spaces or far (>30 m) OR not strategically located',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_3_10',
        sectionNumber: '4.3.10',
        area: 'Donning dimensions and furniture',
        meetsDescription:
            'The donning area is big enough for full furniture and free movement (>=12 m²)',
        partialDescription: 'Donning area 9-11.9 m² with basic furniture',
        doesNotDescription: 'Donning area <9 m² or no furniture',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_3_11',
        sectionNumber: '4.3.11',
        area: 'Doffing dimensions and furniture',
        meetsDescription:
            'Doffing area >=10 m² with rotation, bins and handwashing station',
        partialDescription: 'Doffing area 8-9.9 m² but limited rotation',
        doesNotDescription: 'Doffing area <8 m² or missing facilities',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_3_12',
        sectionNumber: '4.3.12',
        area: 'Surge plan',
        meetsDescription: 'Extra rooms are available, equipped and ready',
        partialDescription: 'Extra rooms available but not equipped',
        doesNotDescription: 'No extra rooms available',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_3_13',
        sectionNumber: '4.3.13',
        area: 'Discharge location',
        meetsDescription:
            'Discharge shower available for every ward, <10 m, unidirectional flow',
        partialDescription: 'Discharge shower available but >10 m',
        doesNotDescription: 'No discharge shower or not used by all',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_3_14',
        sectionNumber: '4.3.14',
        area: 'Discharge dimensions and furniture',
        meetsDescription:
            'Discharge shower >=4 m² with space for dressing and unidirectional flow',
        partialDescription: 'Discharge shower 2-4 m² with basics',
        doesNotDescription: 'Discharge shower <2 m², shared zones',
      ),

      // 4.4 Reprocessing Equipment
      SectionFourAssessmentItemData(
        id: 'tc_4_4_1',
        sectionNumber: '4.4.1',
        area: 'Access',
        meetsDescription:
            'A reprocessing equipment area is available. It is well-marked, clean, and easily navigable; sufficient space to prevent overcrowding',
        partialDescription: 'Available but may lack signage or space',
        doesNotDescription: 'Not available or poorly maintained',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_4_2',
        sectionNumber: '4.4.2',
        area: 'Gowning point',
        meetsDescription:
            'The reprocessing equipment area is equipped with gowning points for staff to don PPE: Fully equipped with appropriate PPE, clear signage, and ample space',
        partialDescription:
            'Basic PPE available but area may be cramped or lack instructions',
        doesNotDescription: 'No or inadequate gowning points',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_4_3',
        sectionNumber: '4.4.3',
        area: 'Dirty receiving area for used medical devices',
        meetsDescription:
            'There is a dedicated and clearly marked receiving area for the dirty used medical devices with containment measures and ventilation',
        partialDescription:
            'Area marked but lacks containment or decontamination resources',
        doesNotDescription: 'No designated area or poorly maintained',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_4_4',
        sectionNumber: '4.4.4',
        area: 'Inspection, assembly, and packing (IAP) area',
        meetsDescription:
            'There is an IAP area that is clean, organized, and equipped with necessary tools, with clear workflow',
        partialDescription: 'IAP area present but workflow unclear',
        doesNotDescription: 'No or disorganized IAP area',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_4_5',
        sectionNumber: '4.4.5',
        area: 'Sterilization area',
        meetsDescription:
            'The sterilization area is designed to minimize contamination risk with proper ventilation and monitoring',
        partialDescription: 'Area not optimally designed or missing systems',
        doesNotDescription: 'Non-functional, high contamination risk',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_4_6',
        sectionNumber: '4.4.6',
        area: 'Sterile store (cooling and short term storage)',
        meetsDescription:
            'The sterile store has sufficient surface, temp/humidity control, accessible and labelled',
        partialDescription: 'Present but insufficient surface or controls',
        doesNotDescription: 'Not available or inadequate controls',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_4_7',
        sectionNumber: '4.4.7',
        area: 'Storage for devices, chemicals, packaging',
        meetsDescription:
            'Storage is organized, segregated for raw/final products and compliant',
        partialDescription: 'Present but disorganized or minor issues',
        doesNotDescription: 'No storage or significant safety risks',
      ),

      // 4.5 Morgue
      SectionFourAssessmentItemData(
        id: 'tc_4_5_1',
        sectionNumber: '4.5.1',
        area: 'Location and access',
        meetsDescription:
            'The morgue is easily accessible but not visible; visitors can view through a window and there is a dedicated exit',
        partialDescription: 'Accessible and visible; no visitor window',
        doesNotDescription: 'Not accessible or no dedicated exit',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_5_2',
        sectionNumber: '4.5.2',
        area: 'Area distribution',
        meetsDescription:
            'There is a dedicated storage area and a separate family viewing area',
        partialDescription:
            'Storage and family area exist but lack privacy or visibility',
        doesNotDescription: 'No family viewing area',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_5_3',
        sectionNumber: '4.5.3',
        area: 'Distance/ barrier visitors',
        meetsDescription:
            'There is a barrier or transparent surface ensuring 1 m distance for visitors',
        partialDescription: 'No barrier but staff accompany visitors',
        doesNotDescription: 'Relatives cannot see the body',
      ),

      // 4.6 Other Services
      SectionFourAssessmentItemData(
        id: 'tc_4_6_1',
        sectionNumber: '4.6.1',
        area: 'Laundry',
        meetsDescription:
            'The facility has a dedicated laundry sized for the centre capacity',
        partialDescription:
            'Laundry present but undersized or external facility',
        doesNotDescription: 'No laundry service',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_6_2',
        sectionNumber: '4.6.2',
        area: 'Storage/ warehouse',
        meetsDescription:
            'There is logistic storage for consumables accessible inside and outside the TC',
        partialDescription:
            'Storage accessible only inside, forcing suppliers inside',
        doesNotDescription: 'No logistic storage',
      ),
      SectionFourAssessmentItemData(
        id: 'tc_4_6_3',
        sectionNumber: '4.6.3',
        area: 'Pharmacy',
        meetsDescription:
            'There is a pharmacy strategically located near treatment area with compliant temperature',
        partialDescription:
            'Pharmacy available but not ideal location or climate control',
        doesNotDescription: 'No pharmacy; drugs randomly stored',
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
            // 2) Now pass your "4.1.x" label
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
      (s) => s.sectionNumber == '4',
    );

    final section4 = AssessmentSectionEntity(
      id: existingSection?.id, // ←– this stays a String? UUID

      sectionNumber: "4",
      title: "FVD Stand-alone Treatment Centre",
      description:
          "This section is applicable to specialized treatment centers for FVD.",
      items: items,
    );

    final sections = List<AssessmentSectionEntity>.from(
      widget.assessmentForm!.sections,
    );
    final existingIndex = sections.indexWhere((s) => s.sectionNumber == "4");

    if (existingIndex >= 0) {
      sections[existingIndex] = section4;
    } else {
      sections.add(section4);
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
                                        'Section 4: Treatment Centre',
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
                              child: SingleChildScrollView(
                                key: const PageStorageKey(
                                  'section_four_scroll',
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
                                    _buildTreatmentWardsSection(
                                      theme,
                                      isMobile,
                                    ),
                                    SizedBox(height: isMobile ? 20 : 24),
                                    _buildReprocessingSection(theme, isMobile),
                                    SizedBox(height: isMobile ? 20 : 24),
                                    _buildMorgueSection(theme, isMobile),
                                    SizedBox(height: isMobile ? 20 : 24),
                                    _buildOtherServicesSection(theme, isMobile),
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
                Icons.local_hospital_outlined,
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
                    'Section 4: FVD Stand-alone Treatment Centre',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: isMobile ? 16 : null,
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    'Comprehensive assessment of specialized treatment facilities for viral hemorrhagic fever',
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
            .where((item) => item.sectionNumber.startsWith('4.1'))
            .toList();

    return _Section4AssessmentSection(
      title: '4.1 Waiting Room',
      icon: Icons.event_seat_outlined,
      description: 'Assessment of waiting area for treatment center patients',
      items: items,
      onRatingChanged: _updateRating,
      isMobile: isMobile,
    );
  }

  Widget _buildScreeningTriageSection(ThemeData theme, bool isMobile) {
    final items =
        _assessmentItems
            .where((item) => item.sectionNumber.startsWith('4.2'))
            .toList();

    return _Section4AssessmentSection(
      title: '4.2 Screening and Triage',
      icon: Icons.verified_user_outlined,
      description:
          'Evaluation of screening processes for treatment center admission',
      items: items,
      onRatingChanged: _updateRating,
      isMobile: isMobile,
    );
  }

  Widget _buildTreatmentWardsSection(ThemeData theme, bool isMobile) {
    final items =
        _assessmentItems
            .where((item) => item.sectionNumber.startsWith('4.3'))
            .toList();

    return _Section4AssessmentSection(
      title: '4.3 FVD Treatment Wards',
      icon: Icons.bed_outlined,
      description:
          'Assessment of patient wards, placement, and care facilities',
      items: items,
      onRatingChanged: _updateRating,
      isMobile: isMobile,
    );
  }

  Widget _buildReprocessingSection(ThemeData theme, bool isMobile) {
    final items =
        _assessmentItems
            .where((item) => item.sectionNumber.startsWith('4.4'))
            .toList();

    return _Section4AssessmentSection(
      title: '4.4 Reprocessing Equipment',
      icon: Icons.precision_manufacturing_outlined,
      description:
          'Evaluation of equipment sterilization and reprocessing facilities',
      items: items,
      onRatingChanged: _updateRating,
      isMobile: isMobile,
    );
  }

  Widget _buildMorgueSection(ThemeData theme, bool isMobile) {
    final items =
        _assessmentItems
            .where((item) => item.sectionNumber.startsWith('4.5'))
            .toList();

    return _Section4AssessmentSection(
      title: '4.5 Morgue',
      icon: Icons.location_city_outlined,
      description:
          'Assessment of morgue facilities and family viewing arrangements',
      items: items,
      onRatingChanged: _updateRating,
      isMobile: isMobile,
    );
  }

  Widget _buildOtherServicesSection(ThemeData theme, bool isMobile) {
    final items =
        _assessmentItems
            .where((item) => item.sectionNumber.startsWith('4.6'))
            .toList();

    return _Section4AssessmentSection(
      title: '4.6 Other Services',
      icon: Icons.miscellaneous_services_outlined,
      description:
          'Assessment of supporting services: laundry, storage, and pharmacy',
      items: items,
      onRatingChanged: _updateRating,
      isMobile: isMobile,
    );
  }
}

// Custom Assessment Section Widget for Section 4
class _Section4AssessmentSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final List<SectionFourAssessmentItemData> items;
  final Function(String, String?) onRatingChanged;
  final bool isMobile;

  const _Section4AssessmentSection({
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
                child: _Section4AssessmentItemCard(
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

// Custom Assessment Item Card Widget for Section 4
class _Section4AssessmentItemCard extends StatelessWidget {
  final SectionFourAssessmentItemData item;
  final Function(String, String?) onRatingChanged;
  final bool isMobile;

  const _Section4AssessmentItemCard({
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
            _Section4AssessmentRatingSelector(
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

// Custom Rating Selector Widget for Section 4
class _Section4AssessmentRatingSelector extends StatelessWidget {
  final String? selectedRating;
  final String meetsDescription;
  final String partialDescription;
  final String doesNotDescription;
  final ValueChanged<String?> onChanged;
  final bool isMobile;

  const _Section4AssessmentRatingSelector({
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
        _Section4RatingOption(
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
        _Section4RatingOption(
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
        _Section4RatingOption(
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
        _Section4CompactRatingOption(
          value: 'dk',
          selectedValue: selectedRating,
          title: "Don't Know",
          color: theme.colorScheme.onSurfaceVariant,
          icon: Icons.help_outline,
          onChanged: onChanged,
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 6 : 8),
        _Section4CompactRatingOption(
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

// Individual Rating Option Widget for Section 4
class _Section4RatingOption extends StatelessWidget {
  final String value;
  final String? selectedValue;
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final ValueChanged<String?> onChanged;
  final bool isMobile;

  const _Section4RatingOption({
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

// Compact Rating Option for Don't Know / Not Applicable for Section 4 (now full width)
class _Section4CompactRatingOption extends StatelessWidget {
  final String value;
  final String? selectedValue;
  final String title;
  final Color color;
  final IconData icon;
  final ValueChanged<String?> onChanged;
  final bool isMobile;

  const _Section4CompactRatingOption({
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
