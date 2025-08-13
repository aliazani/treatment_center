import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/delete_all_assessments_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/get_all_assessments_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/delete_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/breakpoints.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/assessment_form_page.dart';
import 'package:treatment_center/injection_container.dart' as di;

enum AssessmentFilter { all, draft, completed, submitted }

class AssessmentListPage extends StatefulWidget {
  const AssessmentListPage({super.key});

  @override
  State<AssessmentListPage> createState() => _AssessmentListPageState();
}

class _AssessmentListPageState extends State<AssessmentListPage>
    with TickerProviderStateMixin {
  // Use cases
  late final GetAllAssessmentsUsecase _getAllAssessments;
  late final DeleteAssessmentUsecase _deleteAssessment;
  late final DeleteAllAssessmentsUsecase _deleteAllAssessments;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State
  List<AssessmentFormEntity> _allAssessments = [];
  List<AssessmentFormEntity> _filteredAssessments = [];
  AssessmentFilter _currentFilter = AssessmentFilter.all;
  bool _isLoading = true;
  bool _isDeletingAll = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getAllAssessments = di.get<GetAllAssessmentsUsecase>();
    _deleteAssessment = di.get<DeleteAssessmentUsecase>();
    _deleteAllAssessments = di.get<DeleteAllAssessmentsUsecase>();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _loadAssessments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadAssessments() async {
    setState(() => _isLoading = true);

    try {
      final result = await _getAllAssessments.call(const NoParams());

      result.fold(
        (failure) {
          _showErrorSnackBar('Failed to load assessments: ${failure.message}');
          setState(() {
            _allAssessments = [];
            _filteredAssessments = [];
            _isLoading = false;
          });
        },
        (assessments) {
          setState(() {
            _allAssessments = assessments;
            _applyFilters();
            _isLoading = false;
          });

          // Start animations
          _fadeController.forward();
          _slideController.forward();
        },
      );
    } catch (e) {
      _showErrorSnackBar('Unexpected error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAssessmentHandler(
    String assessmentId,
    String facilityName,
  ) async {
    final confirmed = await _showDeleteConfirmationDialog(facilityName);
    if (!confirmed) return;

    try {
      final result = await _deleteAssessment.call(
        DeleteAssessmentParams(id: assessmentId),
      );

      result.fold(
        (failure) {
          _showErrorSnackBar('Failed to delete assessment: ${failure.message}');
        },
        (_) {
          _showSuccessSnackBar('Assessment deleted successfully');
          _loadAssessments(); // Reload the list
        },
      );
    } catch (e) {
      _showErrorSnackBar('Unexpected error: $e');
    }
  }

  Future<void> _deleteAllAssessmentsHandler() async {
    final confirmed = await _showDeleteAllConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isDeletingAll = true);

    try {
      AssessmentFilterType? filterType;
      switch (_currentFilter) {
        case AssessmentFilter.draft:
          filterType = AssessmentFilterType.draft;
          break;
        case AssessmentFilter.completed:
          filterType = AssessmentFilterType.completed;
          break;
        case AssessmentFilter.submitted:
          filterType = AssessmentFilterType.submitted;
          break;
        case AssessmentFilter.all:
          filterType = AssessmentFilterType.all;
          break;
      }

      final result = await _deleteAllAssessments.call(
        DeleteAllAssessmentsParams(
          confirmationText: 'DELETE ALL',
          filter: filterType,
        ),
      );

      result.fold(
        (failure) {
          _showErrorSnackBar(
            'Failed to delete assessments: ${failure.message}',
          );
        },
        (success) {
          if (success) {
            final filterName =
                _currentFilter == AssessmentFilter.all
                    ? 'all assessments'
                    : '${_currentFilter.name} assessments';
            _showSuccessSnackBar('Successfully deleted $filterName');
            _loadAssessments(); // Reload the list
          } else {
            _showErrorSnackBar('Failed to delete assessments');
          }
        },
      );
    } catch (e) {
      _showErrorSnackBar('Unexpected error: $e');
    } finally {
      setState(() => _isDeletingAll = false);
    }
  }

  Future<bool> _showDeleteConfirmationDialog(String facilityName) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            final theme = Theme.of(context);
            final isMobile = AdaptiveBreakpoints.isMobile(
              MediaQuery.of(context).size.width,
            );
            final isLandscape =
                MediaQuery.of(context).orientation == Orientation.landscape;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isLandscape ? 6 : 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: isLandscape ? 18 : (isMobile ? 20 : 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Delete Assessment',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isLandscape ? 14 : (isMobile ? 16 : null),
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure you want to delete the assessment for:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: isLandscape ? 12 : (isMobile ? 14 : null),
                      ),
                    ),
                    SizedBox(height: isLandscape ? 6 : 8),
                    Container(
                      padding: EdgeInsets.all(isLandscape ? 8 : 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        facilityName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isLandscape ? 12 : (isMobile ? 14 : null),
                        ),
                      ),
                    ),
                    SizedBox(height: isLandscape ? 8 : 12),
                    Text(
                      'This action cannot be undone.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                        fontSize: isLandscape ? 11 : (isMobile ? 12 : null),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: isLandscape ? 12 : (isMobile ? 14 : null),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: isLandscape ? 12 : (isMobile ? 14 : null),
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _showDeleteAllConfirmationDialog() async {
    final TextEditingController confirmationController =
        TextEditingController();
    final ValueNotifier<bool> isValidConfirmation = ValueNotifier<bool>(false);

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            final theme = Theme.of(context);
            final isMobile = AdaptiveBreakpoints.isMobile(
              MediaQuery.of(context).size.width,
            );
            final count = _filteredAssessments.length;
            final filterName =
                _currentFilter == AssessmentFilter.all
                    ? 'all $count assessments'
                    : '$count ${_currentFilter.name} assessments';

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_sweep,
                      color: Colors.red,
                      size: isMobile ? 20 : 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Delete All Assessments',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: isMobile ? 16 : null,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: Colors.red,
                                size: isMobile ? 16 : 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'DANGER ZONE',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 12 : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You are about to permanently delete $filterName.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                              fontSize: isMobile ? 13 : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This action cannot be undone.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.red.shade600,
                              fontStyle: FontStyle.italic,
                              fontSize: isMobile ? 11 : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),
                    Text(
                      'To confirm, type "DELETE ALL" in the field below:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: isMobile ? 14 : null,
                      ),
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                    TextField(
                      controller: confirmationController,
                      decoration: InputDecoration(
                        hintText: 'Type DELETE ALL to confirm',
                        hintStyle: TextStyle(fontSize: isMobile ? 14 : null),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.red.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.warning,
                          color: Colors.red,
                          size: isMobile ? 20 : 24,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: isMobile ? 12 : 16,
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(fontSize: isMobile ? 14 : null),
                      onChanged: (value) {
                        isValidConfirmation.value =
                            value.trim() == 'DELETE ALL';
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: isMobile ? 14 : null,
                    ),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: isValidConfirmation,
                  builder: (context, isValid, child) {
                    return FilledButton(
                      onPressed:
                          isValid
                              ? () => Navigator.of(context).pop(true)
                              : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: isValid ? Colors.red : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_sweep, size: isMobile ? 16 : 18),
                          const SizedBox(width: 8),
                          Text(
                            'Delete $count Assessments',
                            style: TextStyle(fontSize: isMobile ? 14 : null),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _applyFilters() {
    List<AssessmentFormEntity> filtered = List.from(_allAssessments);

    // Apply status filter
    switch (_currentFilter) {
      case AssessmentFilter.draft:
        filtered =
            filtered
                .where(
                  (assessment) =>
                      !assessment.isComplete && !assessment.isSubmitted,
                )
                .toList();
        break;
      case AssessmentFilter.completed:
        filtered =
            filtered
                .where(
                  (assessment) =>
                      assessment.isComplete && !assessment.isSubmitted,
                )
                .toList();
        break;
      case AssessmentFilter.submitted:
        filtered =
            filtered.where((assessment) => assessment.isSubmitted).toList();
        break;
      case AssessmentFilter.all:
        break;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((assessment) {
            final query = _searchQuery.toLowerCase();
            return assessment.facilityIdentification.facilityName
                    .toLowerCase()
                    .contains(query) ||
                assessment.facilityIdentification.facilityCode
                    .toLowerCase()
                    .contains(query) ||
                assessment.assessorInfo.name.toLowerCase().contains(query);
          }).toList();
    }

    // Sort by most recent first
    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    setState(() => _filteredAssessments = filtered);
  }

  void _onFilterChanged(AssessmentFilter filter) {
    setState(() => _currentFilter = filter);
    _applyFilters();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _applyFilters();
  }

  void _editAssessment(AssessmentFormEntity assessment) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                AssessmentFormPage(assessmentId: assessment.id),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) => _loadAssessments());
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _loadAssessments,
          ),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar:
          AdaptiveBreakpoints.isDesktop(MediaQuery.sizeOf(context).width) ||
                  isLandscape
              ? null
              : AppBar(
                title: const Text('Saved Assessments'),
                elevation: 0,
                actions: [
                  // Clear All Button
                  if (_filteredAssessments.isNotEmpty)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder:
                          (context) => [
                            PopupMenuItem<String>(
                              value: 'clear_all',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete_sweep,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Clear All${_currentFilter != AssessmentFilter.all ? ' ${_currentFilter.name.toUpperCase()}' : ''}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                      onSelected: (value) {
                        if (value == 'clear_all') {
                          HapticFeedback.heavyImpact();
                          _deleteAllAssessmentsHandler();
                        }
                      },
                    ),
                  // Refresh Button
                  IconButton(
                    icon: const Icon(Icons.refresh_outlined),
                    onPressed:
                        _isLoading || _isDeletingAll ? null : _loadAssessments,
                    tooltip: 'Refresh',
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const AssessmentFormPage(assessmentId: null),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      ).then((_) => _loadAssessments());
                    },
                    tooltip: 'New Assessment',
                  ),
                ],
              ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final contentWidth = AdaptiveBreakpoints.getContentWidth(screenWidth);
          final isMobile = AdaptiveBreakpoints.isMobile(screenWidth);

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child:
                    _isLoading
                        ? const _LoadingScreen()
                        : Stack(
                          children: [
                            isLandscape
                                ? _buildLandscapeLayout(screenWidth, isMobile)
                                : _buildPortraitLayout(screenWidth, isMobile),
                            // Loading overlay for delete all operation
                            if (_isDeletingAll)
                              Container(
                                color: Colors.black.withValues(alpha: 0.5),
                                child: Center(
                                  child: Card(
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        isMobile ? 20 : 24,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const CircularProgressIndicator(
                                            color: Colors.red,
                                          ),
                                          SizedBox(height: isMobile ? 12 : 16),
                                          Text(
                                            'Deleting assessments...',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              fontSize: isMobile ? 14 : null,
                                            ),
                                          ),
                                          SizedBox(height: isMobile ? 6 : 8),
                                          Text(
                                            'Please wait, this may take a moment.',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.copyWith(
                                              color:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                              fontSize: isMobile ? 12 : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortraitLayout(double screenWidth, bool isMobile) {
    return Column(
      children: [
        if (AdaptiveBreakpoints.isDesktop(screenWidth))
          _buildDesktopHeader(screenWidth),
        _FilterHeader(
          searchController: _searchController,
          searchQuery: _searchQuery,
          onSearchChanged: _onSearchChanged,
          currentFilter: _currentFilter,
          allAssessments: _allAssessments,
          onFilterChanged: _onFilterChanged,
          isMobile: isMobile,
          isLandscape: false,
        ),
        Expanded(
          child: _buildAssessmentContent(
            isMobile: isMobile,
            screenWidth: screenWidth,
            isLandscape: false,
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(double screenWidth, bool isMobile) {
    return Row(
      children: [
        // Side panel with filters
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildLandscapeHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: _FilterHeader(
                    searchController: _searchController,
                    searchQuery: _searchQuery,
                    onSearchChanged: _onSearchChanged,
                    currentFilter: _currentFilter,
                    allAssessments: _allAssessments,
                    onFilterChanged: _onFilterChanged,
                    isMobile: isMobile,
                    isLandscape: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Main content area
        Expanded(
          child: _buildAssessmentContent(
            isMobile: isMobile,
            screenWidth: screenWidth,
            isLandscape: true,
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Assessments',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (_filteredAssessments.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, size: 20),
              onPressed: _deleteAllAssessmentsHandler,
              tooltip: 'Clear All',
              color: Colors.red,
            ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            onPressed: _isLoading || _isDeletingAll ? null : _loadAssessments,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          const AssessmentFormPage(assessmentId: null),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              ).then((_) => _loadAssessments());
            },
            tooltip: 'New Assessment',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Saved Assessments',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          if (_filteredAssessments.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder:
                  (context) => [
                    PopupMenuItem<String>(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_sweep,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Clear All${_currentFilter != AssessmentFilter.all ? ' ${_currentFilter.name.toUpperCase()}' : ''}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
              onSelected: (value) {
                if (value == 'clear_all') {
                  HapticFeedback.heavyImpact();
                  _deleteAllAssessmentsHandler();
                }
              },
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _isLoading || _isDeletingAll ? null : _loadAssessments,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          const AssessmentFormPage(assessmentId: null),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              ).then((_) => _loadAssessments());
            },
            tooltip: 'New Assessment',
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentContent({
    required bool isMobile,
    required double screenWidth,
    required bool isLandscape,
  }) {
    if (_filteredAssessments.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: _EmptyState(
          allAssessments: _allAssessments,
          currentFilter: _currentFilter,
          searchQuery: _searchQuery,
          isMobile: isMobile,
          onCreateNew: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const AssessmentFormPage(assessmentId: null),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            ).then((_) => _loadAssessments());
          },
        ),
      );
    }

    return _AssessmentsList(
      assessments: _filteredAssessments,
      onRefresh: _loadAssessments,
      onEdit: _editAssessment,
      onDelete: _deleteAssessmentHandler,
      fadeAnimation: _fadeAnimation,
      slideAnimation: _slideAnimation,
      isMobile: isMobile,
      screenWidth: screenWidth,
      isLandscape: isLandscape,
    );
  }
}

class _FilterHeader extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final AssessmentFilter currentFilter;
  final List<AssessmentFormEntity> allAssessments;
  final ValueChanged<AssessmentFilter> onFilterChanged;
  final bool isMobile;
  final bool isLandscape;

  const _FilterHeader({
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.currentFilter,
    required this.allAssessments,
    required this.onFilterChanged,
    required this.isMobile,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLandscape) {
      // Vertical layout for landscape side panel
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assessment count info
            if (allAssessments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${_filteredAssessments.length} of ${allAssessments.length} assessments',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.7,
                    ),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  suffixIcon:
                      searchQuery.isNotEmpty
                          ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 18,
                            ),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 20),

            // Filter Section
            Row(
              children: [
                Icon(
                  Icons.filter_list_outlined,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filter by status',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Filter Chips - Vertical layout for landscape
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FilterChip(
                  label: 'All',
                  count: allAssessments.length,
                  isSelected: currentFilter == AssessmentFilter.all,
                  onSelected: () => onFilterChanged(AssessmentFilter.all),
                  isMobile: true,
                  isLandscape: true,
                ),
                const SizedBox(height: 8),
                _FilterChip(
                  label: 'Draft',
                  count:
                      allAssessments
                          .where((a) => !a.isComplete && !a.isSubmitted)
                          .length,
                  isSelected: currentFilter == AssessmentFilter.draft,
                  onSelected: () => onFilterChanged(AssessmentFilter.draft),
                  isMobile: true,
                  isLandscape: true,
                ),
                const SizedBox(height: 8),
                _FilterChip(
                  label: 'Completed',
                  count:
                      allAssessments
                          .where((a) => a.isComplete && !a.isSubmitted)
                          .length,
                  isSelected: currentFilter == AssessmentFilter.completed,
                  onSelected: () => onFilterChanged(AssessmentFilter.completed),
                  isMobile: true,
                  isLandscape: true,
                ),
                const SizedBox(height: 8),
                _FilterChip(
                  label: 'Submitted',
                  count: allAssessments.where((a) => a.isSubmitted).length,
                  isSelected: currentFilter == AssessmentFilter.submitted,
                  onSelected: () => onFilterChanged(AssessmentFilter.submitted),
                  isMobile: true,
                  isLandscape: true,
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Original portrait layout
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assessment count info
            if (allAssessments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '${_filteredAssessments.length} of ${allAssessments.length} assessments',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: isMobile ? 12 : null,
                  ),
                ),
              ),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search by facility name, code, or assessor...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.7,
                    ),
                    fontSize: isMobile ? 14 : null,
                  ),
                  prefixIcon: Icon(
                    Icons.search_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: isMobile ? 20 : 24,
                  ),
                  suffixIcon:
                      searchQuery.isNotEmpty
                          ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: isMobile ? 20 : 24,
                            ),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isMobile ? 12 : 16,
                  ),
                ),
                style: TextStyle(fontSize: isMobile ? 14 : null),
              ),
            ),

            SizedBox(height: isMobile ? 16 : 20),

            // Filter Section
            Row(
              children: [
                Icon(
                  Icons.filter_list_outlined,
                  size: isMobile ? 18 : 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filter by status',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    fontSize: isMobile ? 13 : null,
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 8 : 12),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    count: allAssessments.length,
                    isSelected: currentFilter == AssessmentFilter.all,
                    onSelected: () => onFilterChanged(AssessmentFilter.all),
                    isMobile: isMobile,
                    isLandscape: false,
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  _FilterChip(
                    label: 'Draft',
                    count:
                        allAssessments
                            .where((a) => !a.isComplete && !a.isSubmitted)
                            .length,
                    isSelected: currentFilter == AssessmentFilter.draft,
                    onSelected: () => onFilterChanged(AssessmentFilter.draft),
                    isMobile: isMobile,
                    isLandscape: false,
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  _FilterChip(
                    label: 'Completed',
                    count:
                        allAssessments
                            .where((a) => a.isComplete && !a.isSubmitted)
                            .length,
                    isSelected: currentFilter == AssessmentFilter.completed,
                    onSelected:
                        () => onFilterChanged(AssessmentFilter.completed),
                    isMobile: isMobile,
                    isLandscape: false,
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  _FilterChip(
                    label: 'Submitted',
                    count: allAssessments.where((a) => a.isSubmitted).length,
                    isSelected: currentFilter == AssessmentFilter.submitted,
                    onSelected:
                        () => onFilterChanged(AssessmentFilter.submitted),
                    isMobile: isMobile,
                    isLandscape: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AssessmentFormEntity> get _filteredAssessments {
    List<AssessmentFormEntity> filtered = List.from(allAssessments);

    // Apply status filter
    switch (currentFilter) {
      case AssessmentFilter.draft:
        filtered =
            filtered
                .where(
                  (assessment) =>
                      !assessment.isComplete && !assessment.isSubmitted,
                )
                .toList();
        break;
      case AssessmentFilter.completed:
        filtered =
            filtered
                .where(
                  (assessment) =>
                      assessment.isComplete && !assessment.isSubmitted,
                )
                .toList();
        break;
      case AssessmentFilter.submitted:
        filtered =
            filtered.where((assessment) => assessment.isSubmitted).toList();
        break;
      case AssessmentFilter.all:
        break;
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered.where((assessment) {
            final query = searchQuery.toLowerCase();
            return assessment.facilityIdentification.facilityName
                    .toLowerCase()
                    .contains(query) ||
                assessment.facilityIdentification.facilityCode
                    .toLowerCase()
                    .contains(query) ||
                assessment.assessorInfo.name.toLowerCase().contains(query);
          }).toList();
    }

    return filtered;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onSelected;
  final bool isMobile;
  final bool isLandscape;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onSelected,
    required this.isMobile,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isLandscape ? 12 : (isMobile ? 12 : 16),
          vertical: isLandscape ? 8 : (isMobile ? 8 : 12),
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: isLandscape ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment:
              isLandscape
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: isLandscape ? 13 : (isMobile ? 13 : null),
              ),
            ),
            SizedBox(width: isLandscape ? 8 : (isMobile ? 6 : 8)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 6 : (isMobile ? 6 : 8),
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.2)
                        : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: isLandscape ? 10 : (isMobile ? 10 : 12),
                  fontWeight: FontWeight.bold,
                  color:
                      isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final List<AssessmentFormEntity> allAssessments;
  final AssessmentFilter currentFilter;
  final String searchQuery;
  final bool isMobile;
  final VoidCallback onCreateNew;

  const _EmptyState({
    required this.allAssessments,
    required this.currentFilter,
    required this.searchQuery,
    required this.isMobile,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    String message;
    IconData icon;
    String? actionText;

    if (allAssessments.isEmpty) {
      message =
          'No assessments found.\nCreate your first assessment to get started.';
      icon = Icons.assignment_outlined;
      actionText = 'Create New Assessment';
    } else if (searchQuery.isNotEmpty) {
      message =
          'No assessments match your search.\nTry adjusting your search terms.';
      icon = Icons.search_off_outlined;
    } else {
      switch (currentFilter) {
        case AssessmentFilter.draft:
          message =
              'No draft assessments found.\nAll assessments have been completed.';
          icon = Icons.drafts_outlined;
          break;
        case AssessmentFilter.completed:
          message =
              'No completed assessments found.\nCompleted assessments appear here before submission.';
          icon = Icons.check_circle_outline;
          break;
        case AssessmentFilter.submitted:
          message =
              'No submitted assessments found.\nSubmit completed assessments to see them here.';
          icon = Icons.cloud_upload_outlined;
          break;
        case AssessmentFilter.all:
          message = 'No assessments found.';
          icon = Icons.assessment_outlined;
          break;
      }
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height * (isLandscape ? 0.5 : 0.6),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(isLandscape ? 24 : (isMobile ? 32 : 48)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(
                    isLandscape ? 16 : (isMobile ? 20 : 24),
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: isLandscape ? 40 : (isMobile ? 48 : 64),
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: isLandscape ? 12 : (isMobile ? 16 : 24)),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                    fontSize: isLandscape ? 13 : (isMobile ? 14 : null),
                  ),
                ),
                if (actionText != null) ...[
                  SizedBox(height: isLandscape ? 16 : (isMobile ? 24 : 32)),
                  SizedBox(
                    height: isLandscape ? 40 : (isMobile ? 48 : 56),
                    child: FilledButton.icon(
                      onPressed: onCreateNew,
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: isLandscape ? 18 : (isMobile ? 20 : 24),
                      ),
                      label: Text(
                        actionText,
                        style: TextStyle(
                          fontSize: isLandscape ? 13 : (isMobile ? 14 : 16),
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLandscape ? 16 : (isMobile ? 20 : 24),
                          vertical: isLandscape ? 8 : (isMobile ? 12 : 16),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssessmentsList extends StatelessWidget {
  final List<AssessmentFormEntity> assessments;
  final Future<void> Function() onRefresh;
  final Function(AssessmentFormEntity) onEdit;
  final Function(String, String) onDelete;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final bool isMobile;
  final double screenWidth;
  final bool isLandscape;

  const _AssessmentsList({
    required this.assessments,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.isMobile,
    required this.screenWidth,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: ListView.builder(
            key:
                isLandscape
                    ? const PageStorageKey('assessments_landscape_scroll')
                    : const PageStorageKey('assessments_list_scroll'),
            padding:
                isLandscape
                    ? const EdgeInsets.all(16)
                    : AdaptiveBreakpoints.getScreenPadding(screenWidth),
            itemCount: assessments.length,
            itemBuilder: (context, index) {
              final assessment = assessments[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: isLandscape ? 8 : (isMobile ? 12 : 16),
                ),
                child: _AssessmentCard(
                  assessment: assessment,
                  onTap: () => onEdit(assessment),
                  onDelete:
                      () => onDelete(
                        assessment.id,
                        assessment.facilityIdentification.facilityName,
                      ),
                  isMobile: isMobile,
                  isLandscape: isLandscape,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  final AssessmentFormEntity assessment;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isMobile;
  final bool isLandscape;

  const _AssessmentCard({
    required this.assessment,
    required this.onTap,
    required this.onDelete,
    required this.isMobile,
    required this.isLandscape,
  });

  void _showOptionsMenu(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 20),
                Text(
                  assessment.facilityIdentification.facilityName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 20 : 24),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 4 : 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: isMobile ? 18 : 20,
                    ),
                  ),
                  title: Text(
                    'Edit Assessment',
                    style: TextStyle(fontSize: isMobile ? 14 : null),
                  ),
                  subtitle: Text(
                    'Continue working on this assessment',
                    style: TextStyle(fontSize: isMobile ? 12 : null),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onTap();
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 4 : 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: isMobile ? 18 : 20,
                    ),
                  ),
                  title: Text(
                    'Delete Assessment',
                    style: TextStyle(fontSize: isMobile ? 14 : null),
                  ),
                  subtitle: Text(
                    'This action cannot be undone',
                    style: TextStyle(fontSize: isMobile ? 12 : null),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
                SizedBox(height: isMobile ? 20 : 24),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completion = assessment.completionPercentage;

    if (isLandscape) {
      // Horizontal card layout for landscape mode - one per row
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          onLongPress: () => _showOptionsMenu(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Facility Info
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assessment.facilityIdentification.facilityName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_2_outlined,
                            size: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              assessment.facilityIdentification.facilityCode,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Assessor Info & Date Combined
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assessment.assessorInfo.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(assessment.updatedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress Bar
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${completion.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color:
                                assessment.isSubmitted
                                    ? Colors.green
                                    : theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: completion / 100,
                          backgroundColor: theme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            assessment.isSubmitted
                                ? Colors.green
                                : theme.colorScheme.primary,
                          ),
                          minHeight: 3,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Status Badge (Compact)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(assessment).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(assessment),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusLabel(assessment),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(assessment),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // More Options
                IconButton(
                  onPressed: () => _showOptionsMenu(context),
                  icon: const Icon(Icons.more_vert, size: 16),
                  tooltip: 'More options',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Original portrait card
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showOptionsMenu(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with More Options
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assessment.facilityIdentification.facilityName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            fontSize: isMobile ? 14 : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isMobile ? 4 : 6),
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code_2_outlined,
                              size: isMobile ? 14 : 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              assessment.facilityIdentification.facilityCode,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                                fontSize: isMobile ? 12 : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      _StatusBadge(assessment: assessment, isMobile: isMobile),
                      SizedBox(width: isMobile ? 6 : 8),
                      IconButton(
                        onPressed: () => _showOptionsMenu(context),
                        icon: Icon(Icons.more_vert, size: isMobile ? 18 : 20),
                        tooltip: 'More options',
                        style: IconButton.styleFrom(
                          backgroundColor: theme
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          foregroundColor: theme.colorScheme.onSurfaceVariant,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(
                            isMobile ? 32 : 40,
                            isMobile ? 32 : 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 16 : 20),

              // Progress Section
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Assessment Progress',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                            fontSize: isMobile ? 12 : null,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 6 : 8,
                            vertical: isMobile ? 2 : 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                assessment.isSubmitted
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${completion.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  assessment.isSubmitted
                                      ? Colors.green
                                      : theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                    LinearProgressIndicator(
                      value: completion / 100,
                      backgroundColor: theme.colorScheme.outline.withValues(
                        alpha: 0.2,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        assessment.isSubmitted
                            ? Colors.green
                            : theme.colorScheme.primary,
                      ),
                      minHeight: isMobile ? 6 : 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 16 : 20),

              // Footer Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person_outlined,
                      size: isMobile ? 14 : 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assessment.assessorInfo.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                            fontSize: isMobile ? 13 : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              size: isMobile ? 10 : 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(assessment.updatedAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: isMobile ? 10 : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: isMobile ? 12 : 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getStatusColor(AssessmentFormEntity assessment) {
    if (assessment.isSubmitted) {
      return Colors.green;
    } else if (assessment.isComplete) {
      return Colors.blue;
    } else {
      return Colors.orange;
    }
  }

  String _getStatusLabel(AssessmentFormEntity assessment) {
    if (assessment.isSubmitted) {
      return 'Submitted';
    } else if (assessment.isComplete) {
      return 'Completed';
    } else {
      return 'Draft';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final AssessmentFormEntity assessment;
  final bool isMobile;

  const _StatusBadge({required this.assessment, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    // Determine status
    String label;
    Color color;
    IconData icon;

    if (assessment.isSubmitted) {
      label = 'Submitted';
      color = Colors.green;
      icon = Icons.cloud_done;
    } else if (assessment.isComplete) {
      label = 'Completed';
      color = Colors.blue;
      icon = Icons.check_circle;
    } else {
      label = 'Draft';
      color = Colors.orange;
      icon = Icons.edit;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: isMobile ? 10 : 12, color: Colors.white),
          ),
          SizedBox(width: isMobile ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading assessments...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
