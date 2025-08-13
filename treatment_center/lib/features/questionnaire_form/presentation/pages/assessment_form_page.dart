import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_cities_by_region.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_countries.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_regions_by_country.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/geographic_cascade/geographic_cascade_bloc.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/assessment_dashboard_page.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/assessment_scoring_page.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/assessment_section_four_page.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/assessment_section_one_page.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/assessment_section_three_page.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/assessment_section_two_page.dart';

// BLoC imports
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_form/assessment_form_bloc.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_form/assessment_form_event.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_form/assessment_form_state.dart';

// Dependency Injection
import 'package:treatment_center/injection_container.dart' as di;

// Core imports
import 'package:treatment_center/core/services/export_service.dart';

// Presentation imports

class AssessmentFormPage extends StatelessWidget {
  final String? assessmentId; // Null for new assessment, populated for editing

  const AssessmentFormPage({super.key, this.assessmentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              di.sl<AssessmentFormBloc>()
                ..add(InitializeAssessmentForm(assessmentId: assessmentId)),
      child: const AssessmentFormView(),
    );
  }
}

class AssessmentFormView extends StatefulWidget {
  const AssessmentFormView({super.key});

  @override
  State<AssessmentFormView> createState() => _AssessmentFormViewState();
}

class _AssessmentFormViewState extends State<AssessmentFormView>
    with TickerProviderStateMixin {
  bool _exportSuccessDialogShownForCurrentResult = false;
  ExportResult? _lastShownExportResult;
  bool _saveResultShownForCurrentMessage = false;
  String? _lastShownSaveResult;
  bool _submissionResultShownForCurrentMessage = false;
  String? _lastShownSubmissionResult;
  bool _validationErrorShownForCurrentMessage = false;
  String? _lastShownValidationError;

  late final PageController _pageController;
  late final AnimationController _progressAnimationController;
  late final Animation<double> _progressAnimation;
  late final ScrollController _sidebarScrollController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _sidebarScrollController = ScrollController(initialScrollOffset: 0);

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sidebarScrollController.dispose();

    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssessmentFormBloc, AssessmentFormState>(
      listener: (context, state) {
        _handleStateChange(context, state);
      },
      builder: (context, state) {
        if (state is AssessmentFormInitial) {
          return const _LoadingScreen();
        } else if (state is AssessmentFormInitializationError) {
          return _ErrorScreen(message: state.message);
        } else if (state is AssessmentFormLoaded) {
          return _buildLoadedForm(context, state);
        }

        return const _LoadingScreen();
      },
    );
  }

  void _handleStateChange(BuildContext context, AssessmentFormState state) {
    if (state is AssessmentFormLoaded) {
      // Handle page navigation
      if (_pageController.hasClients &&
          _pageController.page?.round() != state.currentStep - 1) {
        _pageController.animateToPage(
          state.currentStep - 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_sidebarScrollController.hasClients) return;

        final itemHeight = 36.0;
        final targetOffset = (state.currentStep - 1) * itemHeight;

        final pos = _sidebarScrollController.position;
        final viewport = pos.viewportDimension;
        final totalContent = state.totalSteps * itemHeight;

        if (totalContent > viewport) {
          final isAbove = targetOffset < pos.pixels;
          final isBelow = targetOffset + itemHeight > pos.pixels + viewport;

          if (isAbove || isBelow) {
            _sidebarScrollController.animateTo(
              targetOffset,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      });

      final bloc = context.read<AssessmentFormBloc>();

      // Handle one-shot dialog markers
      if (state.lastSaveResult == 'show_export_dialog') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showExportDialog(context, state);
        });
        bloc.add(const HideExportDialog());
        return;
      }

      if (state.lastSaveResult == 'show_completion_dialog') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCompletionDialog(context, state);
        });
        bloc.add(const HideCompletionDialog());
        return;
      }

      // UPDATED: Handle save results with one-time showing
      if (state.lastSaveResult != null &&
          !state.lastSaveResult!.startsWith('show_')) {
        final result = state.lastSaveResult!;
        final alreadyShown = _lastShownSaveResult == result;

        if (!_saveResultShownForCurrentMessage || !alreadyShown) {
          _saveResultShownForCurrentMessage = true;
          _lastShownSaveResult = result;

          _showSnackBar(
            context,
            result,
            result.contains('success') ? Colors.green : Colors.red,
          );

          if (result.contains('success')) {
            // give the snackbar a tick to render
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.of(context).pop();
            });
          }
        }
      } else {
        // Reset tracking when no save result in state
        _saveResultShownForCurrentMessage = false;
        _lastShownSaveResult = null;
      }

      // UPDATED: Handle submission results with one-time showing
      if (state.lastSubmissionResult != null) {
        final result = state.lastSubmissionResult!;
        final alreadyShown = _lastShownSubmissionResult == result;

        if (!_submissionResultShownForCurrentMessage || !alreadyShown) {
          _submissionResultShownForCurrentMessage = true;
          _lastShownSubmissionResult = result;

          _showSnackBar(
            context,
            result,
            result.contains('success') ? Colors.green : Colors.red,
          );

          // Navigate back if successfully submitted
          if (result.contains('success')) {
            Navigator.of(context).pop();
          }
        }
      } else {
        // Reset tracking when no submission result in state
        _submissionResultShownForCurrentMessage = false;
        _lastShownSubmissionResult = null;
      }

      // Export success dialog (keep existing logic)
      if (state.lastExportResult != null) {
        final result = state.lastExportResult!;
        final alreadyShown =
            _lastShownExportResult != null &&
            _lastShownExportResult!.filePath == result.filePath;
        if (!_exportSuccessDialogShownForCurrentResult || !alreadyShown) {
          _exportSuccessDialogShownForCurrentResult = true;
          _lastShownExportResult = result;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _showExportSuccessDialog(context, result);
          });
        }
      } else {
        _exportSuccessDialogShownForCurrentResult = false;
      }

      // UPDATED: Handle validation errors with one-time showing
      if (state.validationError != null) {
        final error = state.validationError!;
        final alreadyShown = _lastShownValidationError == error;

        if (!_validationErrorShownForCurrentMessage || !alreadyShown) {
          _validationErrorShownForCurrentMessage = true;
          _lastShownValidationError = error;

          _showSnackBar(context, error, Colors.orange);
        }
      } else {
        // Reset tracking when no validation error in state
        _validationErrorShownForCurrentMessage = false;
        _lastShownValidationError = null;
      }
    }
  }

  Widget _buildLoadedForm(BuildContext context, AssessmentFormLoaded state) {
    final theme = Theme.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // 1) The PageView, taking 85% of space in landscape
    final pageView = Expanded(
      flex: isLandscape ? 3 : 4, // 85% in landscape (17/20)
      child: Container(
        margin:
            isLandscape
                ? const EdgeInsets.fromLTRB(16, 16, 8, 16)
                : EdgeInsets.zero,
        decoration:
            isLandscape
                ? BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
                : null,
        child: ClipRRect(
          borderRadius:
              isLandscape ? BorderRadius.circular(12) : BorderRadius.zero,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              if (index + 1 != state.currentStep) {
                context.read<AssessmentFormBloc>().add(
                  NavigateToStep(step: index + 1),
                );
              }
            },
            children: [
              BlocProvider(
                create:
                    (_) => GeographicCascadeBloc(
                      di.sl<GetCountries>(),
                      di.sl<GetRegionsByCountry>(),
                      di.sl<GetCitiesByRegion>(),
                    ),
                child: AssessmentSectionOnePage(
                  assessmentForm: state.assessmentForm,
                  onUpdateForm: (updatedForm) {
                    context.read<AssessmentFormBloc>().add(
                      UpdateAssessmentForm(updatedForm: updatedForm),
                    );
                  },
                ),
              ),

              AssessmentSectionTwoPage(
                assessmentForm: state.assessmentForm,
                onUpdateForm: (updatedForm) {
                  context.read<AssessmentFormBloc>().add(
                    UpdateAssessmentForm(updatedForm: updatedForm),
                  );
                },
              ),
              AssessmentSectionThreePage(
                assessmentForm: state.assessmentForm,
                onUpdateForm: (updatedForm) {
                  context.read<AssessmentFormBloc>().add(
                    UpdateAssessmentForm(updatedForm: updatedForm),
                  );
                },
              ),
              AssessmentSectionFourPage(
                assessmentForm: state.assessmentForm,
                onUpdateForm: (updatedForm) {
                  context.read<AssessmentFormBloc>().add(
                    UpdateAssessmentForm(updatedForm: updatedForm),
                  );
                },
              ),
              AssessmentDashboardPage(
                assessmentForm: state.assessmentForm,
                onUpdateForm: (updatedForm) {
                  context.read<AssessmentFormBloc>().add(
                    UpdateAssessmentForm(updatedForm: updatedForm),
                  );
                },
              ),
              AssessmentScoringPage(
                assessmentForm: state.assessmentForm,
                onUpdateForm: (updatedForm) {
                  context.read<AssessmentFormBloc>().add(
                    UpdateAssessmentForm(updatedForm: updatedForm),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

    // 2) Compact sidebar for landscape mode - only 15%
    final compactSidebar = Expanded(
      flex: 1, // 15% in landscape (3/20)
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 16, 16, 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Compact header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${state.currentStep}',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step ${state.currentStep}/${state.totalSteps}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          '${((state.currentStep / state.totalSteps) * 100).toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: theme.colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Compact progress indicator
            Container(
              padding: const EdgeInsets.all(8),
              child: LinearProgressIndicator(
                value: state.currentStep / state.totalSteps,
                backgroundColor: theme.colorScheme.outline.withValues(
                  alpha: 0.2,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Compact step indicators - scrollable
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                  controller: _sidebarScrollController,
                  itemCount: state.totalSteps,
                  itemBuilder: (context, index) {
                    final stepNumber = index + 1;
                    final isActive = stepNumber == state.currentStep;
                    final isCompleted = stepNumber < state.currentStep;

                    return Container(
                      height: 32,
                      margin: const EdgeInsets.only(bottom: 4),
                      child: Material(
                        color:
                            isActive
                                ? theme.colorScheme.primaryContainer.withValues(
                                  alpha: 0.5,
                                )
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            if (stepNumber <= state.currentStep ||
                                isCompleted) {
                              context.read<AssessmentFormBloc>().add(
                                NavigateToStep(step: stepNumber),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color:
                                        isCompleted
                                            ? theme.colorScheme.primary
                                            : isActive
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.outline
                                                .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child:
                                        isCompleted
                                            ? Icon(
                                              Icons.check,
                                              size: 12,
                                              color:
                                                  theme.colorScheme.onPrimary,
                                            )
                                            : Text(
                                              '$stepNumber',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    isActive
                                                        ? theme
                                                            .colorScheme
                                                            .onPrimary
                                                        : theme
                                                            .colorScheme
                                                            .outline,
                                              ),
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getCompactStepTitle(stepNumber),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color:
                                          isActive
                                              ? theme.colorScheme.primary
                                              : theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                      fontWeight:
                                          isActive
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Compact navigation buttons
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Previous/Next row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: OutlinedButton(
                            onPressed:
                                state.canGoToPreviousStep && !state.isLoading
                                    ? () => context
                                        .read<AssessmentFormBloc>()
                                        .add(const NavigateToPreviousStep())
                                    : null,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Icon(Icons.arrow_back, size: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: FilledButton(
                            onPressed:
                                state.isLoading
                                    ? null
                                    : state.isOnLastStep
                                    ? () => context
                                        .read<AssessmentFormBloc>()
                                        .add(const CompleteAssessment())
                                    : () => context
                                        .read<AssessmentFormBloc>()
                                        .add(const NavigateToNextStep()),
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child:
                                state.isLoading
                                    ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Icon(
                                      state.isOnLastStep
                                          ? Icons.check
                                          : Icons.arrow_forward,
                                      size: 16,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Action buttons row
                  Row(
                    children: [
                      // Save
                      Expanded(
                        child: SizedBox(
                          height: 28,
                          child: OutlinedButton(
                            onPressed:
                                state.canSave && !state.isSaving
                                    ? () => context
                                        .read<AssessmentFormBloc>()
                                        .add(const SaveAssessmentForm())
                                    : null,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child:
                                state.isSaving
                                    ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.save, size: 14),
                          ),
                        ),
                      ),

                      if (state.currentStep <= 4) ...[
                        const SizedBox(width: 6),
                        // Export
                        Expanded(
                          child: SizedBox(
                            height: 28,
                            child: OutlinedButton(
                              onPressed:
                                  state.canExport
                                      ? () => context
                                          .read<AssessmentFormBloc>()
                                          .add(const ShowExportDialog())
                                      : null,
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Icon(Icons.file_download, size: 14),
                            ),
                          ),
                        ),
                      ],

                      if (state.exportHistory.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        // Files
                        SizedBox(
                          width: 42,
                          height: 28,
                          child: OutlinedButton(
                            onPressed:
                                () => _showExportedFilesDialog(context, state),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            // overlay badge + icon with a Stack
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // 1) the folder icon, centered
                                Center(child: Icon(Icons.folder, size: 14)),
                                // 2) the badge, positioned top‐right
                                Positioned(
                                  top: 1,
                                  right: 2,

                                  child: Badge(
                                    // use padding to shrink the dot
                                    padding: const EdgeInsets.all(1),
                                    backgroundColor: theme.colorScheme.error,
                                    label: Text(
                                      '${state.exportHistory.length}',
                                      style: const TextStyle(
                                        fontSize: 8,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // 3) Wrap both portrait & landscape in same Scaffold with AppBar
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop(context, state);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor:
            isLandscape ? theme.colorScheme.surfaceContainerLowest : null,
        appBar: _buildAppBar(context, state),
        body:
            isLandscape
                ? Row(children: [pageView, compactSidebar])
                : Column(
                  children: [
                    _ProgressIndicator(
                      currentStep: state.currentStep,
                      totalSteps: state.totalSteps,
                      animation: _progressAnimation,
                    ),
                    pageView,
                    _NavigationBar(state: state),
                  ],
                ),
      ),
    );
  }

  // Helper method for compact step titles
  String _getCompactStepTitle(int step) {
    switch (step) {
      case 1:
        return 'Info';
      case 2:
        return 'Infrastructure';
      case 3:
        return 'Operations';
      case 4:
        return 'Specialized';
      case 5:
        return 'Dashboard';
      case 6:
        return 'Results';
      default:
        return 'Step $step';
    }
  }

  // Enhanced AppBar for landscape mode
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AssessmentFormLoaded state,
  ) {
    final theme = Theme.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Dynamic title based on current step
    String getStepTitle() {
      if (isLandscape) {
        // Shorter title for landscape to save space
        return state.isEditMode ? 'Edit Assessment' : 'New Assessment';
      }

      switch (state.currentStep) {
        case 1:
          return 'Section 1: General Information';
        case 2:
          return 'Section 2: Infrastructure Assessment';
        case 3:
          return 'Section 3: Operational Assessment';
        case 4:
          return 'Section 4: Specialized Assessment';
        case 5:
          return 'Dashboard: Assessment Statistics';
        case 6:
          return 'Score: Assessment Results';
        default:
          return state.isEditMode ? 'Edit Assessment' : 'New Assessment';
      }
    }

    return AppBar(
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      scrolledUnderElevation: 1,
      automaticallyImplyLeading: false,
      toolbarHeight: isLandscape ? 56 : 72, // Shorter in landscape
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        iconSize: 24,
        onPressed: () async {
          final shouldPop = await _onWillPop(context, state);
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        tooltip: 'Back to Landing Page',
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            getStepTitle(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (state
                      .assessmentForm
                      ?.facilityIdentification
                      .facilityName
                      .isNotEmpty ==
                  true &&
              !isLandscape) // Hide subtitle in landscape to save space
            Text(
              state.assessmentForm!.facilityIdentification.facilityName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions:
          isLandscape
              ? [
                // In landscape, minimal actions since sidebar has controls
                const SizedBox(width: 8),
              ]
              : [
                // Portrait mode - show all actions
                if (state.exportHistory.isNotEmpty)
                  IconButton(
                    icon: Badge(
                      label: Text(
                        '${state.exportHistory.length}',
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: theme.colorScheme.error,
                      textColor: theme.colorScheme.onError,
                      child: Icon(
                        Icons.folder_outlined,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    iconSize: 24,
                    tooltip:
                        'View exported files (${state.exportHistory.length})',
                    onPressed: () => _showExportedFilesDialog(context, state),
                  ),

                IconButton(
                  icon: Icon(
                    Icons.file_download_outlined,
                    color:
                        state.canExport
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                  ),
                  iconSize: 24,
                  tooltip: 'Export assessment',
                  onPressed:
                      state.canExport
                          ? () => context.read<AssessmentFormBloc>().add(
                            const ShowExportDialog(),
                          )
                          : null,
                ),

                state.isSaving
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    )
                    : IconButton(
                      icon: Icon(
                        Icons.save_outlined,
                        color: theme.colorScheme.onSurface,
                      ),
                      iconSize: 24,
                      tooltip: 'Save assessment',
                      onPressed:
                          state.canSave && !state.isSaving
                              ? () => context.read<AssessmentFormBloc>().add(
                                const SaveAssessmentForm(),
                              )
                              : null,
                    ),
                const SizedBox(width: 8),
              ],
    );
  }

  Future<bool> _onWillPop(
    BuildContext context,
    AssessmentFormLoaded state,
  ) async {
    if (!state.hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                SizedBox(width: 8),
                Text('Discard changes?'),
              ],
            ),
            content: const Text(
              'You have unsaved changes. Are you sure you want to discard them?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('DISCARD'),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                color == Colors.red
                    ? Icons.error_outline
                    : color == Colors.green
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showExportDialog(BuildContext context, AssessmentFormLoaded state) {
    final bloc = context.read<AssessmentFormBloc>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: !state.isExporting,
      enableDrag: !state.isExporting,
      builder:
          (bottomSheetContext) => BlocProvider.value(
            value: bloc,
            child: BlocListener<AssessmentFormBloc, AssessmentFormState>(
              listener: (context, state) {
                if (state is AssessmentFormLoaded) {
                  // Close dialog when export completes
                  if (state.lastExportResult != null && !state.isExporting) {
                    Navigator.of(bottomSheetContext).pop();
                    // Do NOT emit HideExportDialog here; already handled.
                  }
                }
              },
              child: _ExportDialog(
                state: state,
                onExport: (format, options) {
                  bloc.add(ExportAssessment(format: format, options: options));
                },
              ),
            ),
          ),
    );
  }

  void _showCompletionDialog(BuildContext context, AssessmentFormLoaded state) {
    final bloc = context.read<AssessmentFormBloc>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => BlocProvider.value(
            value: bloc,
            child: _CompletionDialog(
              state: state,
              onEmailSubmit: (email, formats, subject, body, photoFilePaths) {
                bloc.add(
                  SubmitAssessmentViaEmail(
                    recipientEmail: email,
                    exportFormats: formats,
                    customSubject: subject,
                    customBody: body,
                    photoFilePaths: photoFilePaths,
                  ),
                );
                Navigator.of(dialogContext).pop();
                bloc.add(const HideCompletionDialog());
              },
              onCompleteOnly: () {
                bloc.add(const CompleteAssessmentOnly());
                Navigator.of(dialogContext).pop();
                bloc.add(const HideCompletionDialog());
              },
            ),
          ),
    );
  }

  void _showExportSuccessDialog(BuildContext context, ExportResult result) {
    final bloc = context.read<AssessmentFormBloc>();

    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: bloc,
            child: _ExportSuccessDialog(
              result: result,
              onShare: () {
                bloc.add(ShareExportedFile(file: result));
                Navigator.of(dialogContext).pop();
              },
              onViewFiles: () {
                Navigator.of(dialogContext).pop();
                _showExportedFilesDialog(
                  context,
                  bloc.state as AssessmentFormLoaded,
                );
              },
            ),
          ),
    );
  }

  void _showExportedFilesDialog(
    BuildContext context,
    AssessmentFormLoaded state,
  ) {
    final bloc = context.read<AssessmentFormBloc>();

    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: bloc,
            child: _ExportedFilesDialog(
              exportedFiles: state.exportHistory,
              onShare: (file) {
                bloc.add(ShareExportedFile(file: file));
                Navigator.of(dialogContext).pop();
              },
              onDelete: (file, index) {
                bloc.add(DeleteExportedFile(file: file, index: index));
                Navigator.of(dialogContext).pop();
              },
              onShowLocation: () {
                Navigator.of(dialogContext).pop();
                _showSnackBar(
                  context,
                  'Files saved to app documents folder',
                  Colors.blue,
                );
              },
            ),
          ),
    );
  }
}

// Navigation Bar Widget
class _NavigationBar extends StatelessWidget {
  final AssessmentFormLoaded state;

  const _NavigationBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (state.canGoToPreviousStep)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      state.isLoading
                          ? null
                          : () => context.read<AssessmentFormBloc>().add(
                            const NavigateToPreviousStep(),
                          ),
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else
              const Expanded(child: SizedBox()),

            const SizedBox(width: 16),

            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed:
                    state.isLoading
                        ? null
                        : state.isOnLastStep
                        ? () => context.read<AssessmentFormBloc>().add(
                          const CompleteAssessment(),
                        )
                        : () => context.read<AssessmentFormBloc>().add(
                          const NavigateToNextStep(),
                        ),
                icon:
                    state.isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Icon(
                          state.isOnLastStep
                              ? Icons.check_circle_outline
                              : Icons.arrow_forward_ios,
                          size: 16,
                        ),
                label: Text(
                  state.isLoading
                      ? 'Processing...'
                      : state.isOnLastStep
                      ? 'Complete Assessment'
                      : 'Next',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Progress Indicator Widget - Non-sticky
class _ProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Animation<double> animation;

  const _ProgressIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stepTitles = ['Info', 'Eval', 'Scrn', 'Trt', 'Stats', 'Score'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step $currentStep of $totalSteps',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                '${((currentStep / totalSteps) * 100).toInt()}% Complete',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: (currentStep / totalSteps) * animation.value,
                backgroundColor: theme.colorScheme.outline.withValues(
                  alpha: 0.2,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(totalSteps, (index) {
              final stepNumber = index + 1;
              final isActive = stepNumber == currentStep;
              final isCompleted = stepNumber < currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color:
                                  isCompleted
                                      ? theme.colorScheme.primary
                                      : isActive
                                      ? theme.colorScheme.primaryContainer
                                      : theme.colorScheme.outline.withValues(
                                        alpha: 0.2,
                                      ),
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  isActive
                                      ? Border.all(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      )
                                      : null,
                            ),
                            child: Icon(
                              isCompleted ? Icons.check : Icons.circle,
                              size: 16,
                              color:
                                  isCompleted
                                      ? theme.colorScheme.onPrimary
                                      : isActive
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stepTitles[index],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  isActive
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                              fontWeight:
                                  isActive
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    if (index < totalSteps - 1)
                      Container(
                        width: 24,
                        height: 2,
                        color:
                            stepNumber < currentStep
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Loading Screen Widget
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading assessment...'),
          ],
        ),
      ),
    );
  }
}

// Error Screen Widget
class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $message'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportDialog extends StatefulWidget {
  final AssessmentFormLoaded state;
  final Function(String format, ExportOptions options) onExport;

  const _ExportDialog({required this.state, required this.onExport});

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  String _selectedFormat = 'pdf';
  bool _includeAnalysis = true;
  bool _includeSectionDetails = true;
  bool _includeSignaturePage = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormatSelection(theme),
                  const SizedBox(height: 24),
                  _buildExportOptions(theme),
                ],
              ),
            ),
          ),
          _buildExportButton(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.file_download,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export Assessment',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Choose format and options',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed:
                widget.state.isExporting
                    ? null
                    : () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Format',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        // Debug indicator
        if (kDebugMode)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Selected: $_selectedFormat',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: _FormatCard(
                format: 'pdf',
                icon: Icons.picture_as_pdf,
                title: 'PDF',
                description: 'Professional report',
                color: Colors.red,
                isSelected: _selectedFormat == 'pdf',
                enabled: !widget.state.isExporting,
                onTap: () {
                  if (!widget.state.isExporting) {
                    setState(() => _selectedFormat = 'pdf');
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FormatCard(
                format: 'excel',
                icon: Icons.table_chart,
                title: 'Excel',
                description: 'Data analysis',
                color: Colors.green,
                isSelected: _selectedFormat == 'excel',
                enabled: !widget.state.isExporting,
                onTap: () {
                  if (!widget.state.isExporting) {
                    setState(() => _selectedFormat = 'excel');
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FormatCard(
                format: 'docx',
                icon: Icons.description,
                title: 'Word',
                description: 'Text document',
                color: Colors.blue,
                isSelected: _selectedFormat == 'docx',
                enabled: !widget.state.isExporting,
                onTap: () {
                  if (!widget.state.isExporting) {
                    setState(() => _selectedFormat = 'docx');
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExportOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Options',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _OptionTile(
          title: 'Include Analysis',
          subtitle: 'Statistical analysis and charts',
          value: _includeAnalysis,
          enabled: !widget.state.isExporting,
          onChanged:
              (value) => setState(() => _includeAnalysis = value ?? true),
        ),
        _OptionTile(
          title: 'Include Section Details',
          subtitle: 'Detailed breakdown of each section',
          value: _includeSectionDetails,
          enabled: !widget.state.isExporting,
          onChanged:
              (value) => setState(() => _includeSectionDetails = value ?? true),
        ),
        if (_selectedFormat != 'excel')
          _OptionTile(
            title: 'Include Signature Page',
            subtitle: 'Page for assessor signatures',
            value: _includeSignaturePage,
            enabled: !widget.state.isExporting,
            onChanged:
                (value) =>
                    setState(() => _includeSignaturePage = value ?? true),
          ),
      ],
    );
  }

  Widget _buildExportButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed:
              widget.state.isExporting
                  ? null
                  : () {
                    // fire your export
                    widget.onExport(
                      _selectedFormat,
                      ExportOptions(
                        includeAnalysis: _includeAnalysis,
                        includeSectionDetails: _includeSectionDetails,
                        includeSignaturePage: _includeSignaturePage,
                      ),
                    );
                  },
          icon:
              widget.state.isExporting
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Icon(
                    Icons.file_download_outlined,
                    color: theme.colorScheme.onPrimary,
                  ),
          label: Text(
            widget.state.isExporting ? 'Exporting…' : 'Export',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

// // Enhanced Completion Dialog with better UX and three-state logic
// class _CompletionDialog extends StatefulWidget {
//   final AssessmentFormLoaded state;
//   final Function(
//     String email,
//     List<String> formats,
//     String? subject,
//     String? body,
//     List<String> photoFilePaths,
//   )
//   onEmailSubmit;
//   final VoidCallback onCompleteOnly;

//   const _CompletionDialog({
//     required this.state,
//     required this.onEmailSubmit,
//     required this.onCompleteOnly,
//   });

//   @override
//   State<_CompletionDialog> createState() => _CompletionDialogState();
// }

// class _CompletionDialogState extends State<_CompletionDialog> {
//   final _emailController = TextEditingController();
//   final _subjectController = TextEditingController();
//   final _bodyController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   bool _attachPhotos = true;
//   final List<String> _selectedFormats = ['pdf'];
//   bool _sendEmail = false;

//   @override
//   void initState() {
//     super.initState();
//     // Pre-fill email if available
//     if (widget.state.assessmentForm?.assessorInfo.email.isNotEmpty == true) {
//       _emailController.text = widget.state.assessmentForm!.assessorInfo.email;
//     }

//     // Pre-fill subject
//     _subjectController.text =
//         'FVD Assessment Report - ${widget.state.assessmentForm?.facilityIdentification.facilityName ?? "Assessment"}';

//     // Pre-fill body
//     _bodyController.text = '''Please find attached the FVD Assessment Report.

// Assessment Details:
// • Facility: ${widget.state.assessmentForm?.facilityIdentification.facilityName ?? "N/A"}
// • Code: ${widget.state.assessmentForm?.facilityIdentification.facilityCode ?? "N/A"}
// • Assessor: ${widget.state.assessmentForm?.assessorInfo.name ?? "N/A"}
// • Date: ${widget.state.assessmentForm?.assessorInfo.assessmentDate.toString().split(' ')[0] ?? "N/A"}

// Best regards,
// FVD Assessment System''';
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _subjectController.dispose();
//     _bodyController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Theme.of(context);
//     final mediaQuery = MediaQuery.of(context);
//     final screenHeight = mediaQuery.size.height;
//     final maxDialogHeight = screenHeight * 0.85;

//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: const Row(
//         children: [
//           Icon(Icons.check_circle, color: Colors.green, size: 28),
//           SizedBox(width: 12),
//           Flexible(child: Text('Complete Assessment')),
//         ],
//       ),
//       content: ConstrainedBox(
//         constraints: BoxConstraints(
//           maxWidth: double.maxFinite,
//           maxHeight: maxDialogHeight,
//         ),
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Information container
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.blue.shade200),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.info_outline, color: Colors.blue.shade700),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'Choose how to proceed:',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue.shade700,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         '• Complete Only: Mark as completed and ready for submission\n• Send Email: Submit assessment via email (marks as submitted)',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.blue.shade700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // Email option checkbox
//                 CheckboxListTile(
//                   title: Row(
//                     children: [
//                       Flexible(child: const Text('Submit via Email')),
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 6,
//                           vertical: 2,
//                         ),
//                       ),
//                     ],
//                   ),
//                   subtitle: const Text(
//                     'Email assessment and mark as submitted',
//                   ),
//                   value: _sendEmail,
//                   onChanged:
//                       widget.state.isSubmittingEmail
//                           ? null
//                           : (value) =>
//                               setState(() => _sendEmail = value ?? false),
//                   contentPadding: EdgeInsets.all(12),
//                 ),

//                 if (_sendEmail) ...[
//                   const SizedBox(height: 16),

//                   SwitchListTile.adaptive(
//                     title: const Text('Attach photos'),
//                     subtitle: const Text(
//                       'Include captured photos as email attachments',
//                     ),
//                     value: _attachPhotos,
//                     onChanged:
//                         widget.state.isSubmittingEmail
//                             ? null
//                             : (v) => setState(() => _attachPhotos = v),
//                     contentPadding: EdgeInsets.all(12),
//                   ),
//                   const SizedBox(height: 8),

//                   // Email address
//                   TextFormField(
//                     controller: _emailController,
//                     enabled: !widget.state.isSubmittingEmail,
//                     decoration: const InputDecoration(
//                       labelText: 'Recipient Email',
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.email),
//                     ),
//                     validator: (value) {
//                       if (value?.isEmpty ?? true) return 'Email required';
//                       if (!RegExp(
//                         r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                       ).hasMatch(value!)) {
//                         return 'Invalid email format';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // Export formats
//                   const Text(
//                     'Export Formats:',
//                     style: TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 8,
//                     children: [
//                       FilterChip(
//                         label: const Text('PDF'),
//                         selected: _selectedFormats.contains('pdf'),
//                         onSelected:
//                             widget.state.isSubmittingEmail
//                                 ? null
//                                 : (selected) {
//                                   setState(() {
//                                     if (selected) {
//                                       _selectedFormats.add('pdf');
//                                     } else {
//                                       _selectedFormats.remove('pdf');
//                                     }
//                                   });
//                                 },
//                       ),
//                       FilterChip(
//                         label: const Text('Excel'),
//                         selected: _selectedFormats.contains('excel'),
//                         onSelected:
//                             widget.state.isSubmittingEmail
//                                 ? null
//                                 : (selected) {
//                                   setState(() {
//                                     if (selected) {
//                                       _selectedFormats.add('excel');
//                                     } else {
//                                       _selectedFormats.remove('excel');
//                                     }
//                                   });
//                                 },
//                       ),
//                       FilterChip(
//                         label: const Text('Word'),
//                         selected: _selectedFormats.contains('docx'),
//                         onSelected:
//                             widget.state.isSubmittingEmail
//                                 ? null
//                                 : (selected) {
//                                   setState(() {
//                                     if (selected) {
//                                       _selectedFormats.add('docx');
//                                     } else {
//                                       _selectedFormats.remove('docx');
//                                     }
//                                   });
//                                 },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   // Subject
//                   TextFormField(
//                     controller: _subjectController,
//                     enabled: !widget.state.isSubmittingEmail,
//                     decoration: const InputDecoration(
//                       labelText: 'Subject',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // Body
//                   SizedBox(
//                     height: 120,
//                     child: TextFormField(
//                       controller: _bodyController,
//                       enabled: !widget.state.isSubmittingEmail,
//                       decoration: const InputDecoration(
//                         labelText: 'Message',
//                         border: OutlineInputBorder(),
//                         alignLabelWithHint: true,
//                       ),
//                       maxLines: null,
//                       expands: true,
//                       textAlignVertical: TextAlignVertical.top,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed:
//               widget.state.isSubmittingEmail
//                   ? null
//                   : () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),

//         if (!_sendEmail)
//           FilledButton.icon(
//             onPressed:
//                 widget.state.isSubmittingEmail ? null : widget.onCompleteOnly,
//             icon:
//                 widget.state.isSubmittingEmail
//                     ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     )
//                     : const Icon(Icons.check),
//             label: Text(
//               widget.state.isSubmittingEmail
//                   ? 'Completing...'
//                   : 'Complete Only',
//             ),
//             style: FilledButton.styleFrom(backgroundColor: Colors.blue),
//           ),

//         if (_sendEmail)
//           FilledButton.icon(
//             onPressed:
//                 widget.state.isSubmittingEmail
//                     ? null
//                     : () {
//                       if (_formKey.currentState?.validate() ?? false) {
//                         if (_selectedFormats.isEmpty) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text(
//                                 'Please select at least one export format',
//                               ),
//                             ),
//                           );
//                           return;
//                         }

//                         final photoPaths =
//                             _attachPhotos
//                                 ? _extractPhotoPaths(widget.state)
//                                 : <String>[];
//                         widget.onEmailSubmit(
//                           _emailController.text.trim(),
//                           _selectedFormats,
//                           _subjectController.text.trim().isNotEmpty
//                               ? _subjectController.text.trim()
//                               : null,
//                           _bodyController.text.trim().isNotEmpty
//                               ? _bodyController.text.trim()
//                               : null,
//                           photoPaths,
//                         );
//                       }
//                     },
//             icon:
//                 widget.state.isSubmittingEmail
//                     ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     )
//                     : const Icon(Icons.send),
//             label: Text(
//               widget.state.isSubmittingEmail
//                   ? 'Submitting...'
//                   : 'Submit via Email',
//             ),
//             style: FilledButton.styleFrom(backgroundColor: Colors.green),
//           ),
//       ],
//     );
//   }

//   List<String> _extractPhotoPaths(AssessmentFormLoaded s) {
//     final form = s.assessmentForm;
//     if (form == null) return const [];
//     final photos = form.photos;
//     // Try common fields: localPath, path, filePath, uri
//     return photos
//         .map((p) {
//           try {
//             // dynamic access to avoid tight coupling
//             final dynamic dp = p;
//             return (dp.localPath ??
//                     dp.filePath ??
//                     dp.path ??
//                     (dp.uri is String ? dp.uri : null))
//                 as String?;
//           } catch (_) {
//             return null;
//           }
//         })
//         .whereType<String>()
//         .where((p) => p.trim().isNotEmpty)
//         .toList(growable: false);
//   }
// }

// Replace the _CompletionDialog class in your AssessmentFormView

class _CompletionDialog extends StatefulWidget {
  final AssessmentFormLoaded state;
  final Function(
    String email,
    List<String> formats,
    String? subject,
    String? body,
    List<String> photoFilePaths,
  )
  onEmailSubmit;
  final VoidCallback onCompleteOnly;

  const _CompletionDialog({
    required this.state,
    required this.onEmailSubmit,
    required this.onCompleteOnly,
  });

  @override
  State<_CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<_CompletionDialog> {
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _attachPhotos = true;
  final List<String> _selectedFormats = ['pdf'];
  bool _sendEmail = false;

  // Add validation state
  bool get _canSubmitViaEmail {
    final form = widget.state.assessmentForm;
    if (form == null) return false;

    // Must be 100% complete
    if (form.completionPercentage < 100.0) return false;

    // Required fields must be filled
    return form.assessorInfo.name.trim().isNotEmpty &&
        form.assessorInfo.email.trim().isNotEmpty &&
        _isValidEmail(form.assessorInfo.email) &&
        form.assessorInfo.assessmentDate != null &&
        form.facilityIdentification.facilityCode.trim().isNotEmpty &&
        form.facilityIdentification.facilityName.trim().isNotEmpty &&
        form.facilityIdentification.directorName.trim().isNotEmpty &&
        form.facilityIdentification.respondentName.trim().isNotEmpty;
  }

  String? get _completionBlockerMessage {
    final form = widget.state.assessmentForm;
    if (form == null) return 'Assessment form not available';

    final completion = form.completionPercentage;
    if (completion < 100.0) {
      return 'Assessment is ${completion.toStringAsFixed(1)}% complete. Email submission requires 100% completion.';
    }

    // Check required fields
    final missingFields = <String>[];
    if (form.assessorInfo.name.trim().isEmpty) {
      missingFields.add('Assessor name');
    }
    if (form.assessorInfo.email.trim().isEmpty) {
      missingFields.add('Assessor email');
    } else if (!_isValidEmail(form.assessorInfo.email)) {
      missingFields.add('Valid assessor email');
    }
    if (form.assessorInfo.assessmentDate == null) {
      missingFields.add('Assessment date');
    }
    if (form.facilityIdentification.facilityCode.trim().isEmpty) {
      missingFields.add('Facility code');
    }
    if (form.facilityIdentification.facilityName.trim().isEmpty) {
      missingFields.add('Facility name');
    }
    if (form.facilityIdentification.directorName.trim().isEmpty) {
      missingFields.add('Director name');
    }
    if (form.facilityIdentification.respondentName.trim().isEmpty) {
      missingFields.add('Respondent name');
    }

    if (missingFields.isNotEmpty) {
      return 'Missing required fields: ${missingFields.join(', ')}';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill email if available and valid
    if (widget.state.assessmentForm?.assessorInfo.email.isNotEmpty == true) {
      final email = widget.state.assessmentForm!.assessorInfo.email;
      if (_isValidEmail(email)) {
        _emailController.text = email;
      }
    }

    // Pre-fill subject
    _subjectController.text =
        'FVD Assessment Report - ${widget.state.assessmentForm?.facilityIdentification.facilityName ?? "Assessment"}';

    // Pre-fill body
    _bodyController.text = '''Please find attached the FVD Assessment Report.

Assessment Details:
• Facility: ${widget.state.assessmentForm?.facilityIdentification.facilityName ?? "N/A"}
• Code: ${widget.state.assessmentForm?.facilityIdentification.facilityCode ?? "N/A"}
• Assessor: ${widget.state.assessmentForm?.assessorInfo.name ?? "N/A"}
• Date: ${widget.state.assessmentForm?.assessorInfo.assessmentDate.toString().split(' ')[0] ?? "N/A"}
• Completion: ${widget.state.assessmentForm?.completionPercentage.toStringAsFixed(1) ?? "0.0"}%

Best regards,
FVD Assessment System''';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final maxDialogHeight = screenHeight * 0.85;
    final completion = widget.state.assessmentForm?.completionPercentage ?? 0.0;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            completion >= 100.0 ? Icons.check_circle : Icons.warning,
            color: completion >= 100.0 ? Colors.green : Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Complete Assessment'),
                Text(
                  '${completion.toStringAsFixed(1)}% Complete',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: completion >= 100.0 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: double.maxFinite,
          maxHeight: maxDialogHeight,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        completion >= 100.0
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          completion >= 100.0
                              ? Colors.green.shade200
                              : Colors.orange.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            completion >= 100.0
                                ? Icons.check_circle
                                : Icons.info_outline,
                            color:
                                completion >= 100.0
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              completion >= 100.0
                                  ? 'Ready for submission!'
                                  : 'Completion required',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    completion >= 100.0
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: completion / 100.0,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completion >= 100.0 ? Colors.green : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (completion < 100.0) ...[
                        Text(
                          _completionBlockerMessage ??
                              'Please complete all sections before email submission.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '• Complete Only: Mark as completed and ready for submission\n• Send Email: Submit assessment via email (marks as submitted)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Email option checkbox
                CheckboxListTile(
                  title: Row(
                    children: [
                      const Flexible(child: Text('Submit via Email')),
                      const SizedBox(width: 8),
                      if (!_canSubmitViaEmail)
                        Icon(Icons.lock, size: 16, color: Colors.grey.shade600),
                    ],
                  ),
                  subtitle: Text(
                    _canSubmitViaEmail
                        ? 'Email assessment and mark as submitted'
                        : 'Complete assessment to enable email submission',
                  ),
                  value: _sendEmail && _canSubmitViaEmail,
                  onChanged:
                      _canSubmitViaEmail && !widget.state.isSubmittingEmail
                          ? (value) =>
                              setState(() => _sendEmail = value ?? false)
                          : null,
                  contentPadding: const EdgeInsets.all(12),
                ),

                if (_sendEmail && _canSubmitViaEmail) ...[
                  const SizedBox(height: 16),

                  SwitchListTile.adaptive(
                    title: const Text('Attach photos'),
                    subtitle: const Text(
                      'Include captured photos as email attachments',
                    ),
                    value: _attachPhotos,
                    onChanged:
                        widget.state.isSubmittingEmail
                            ? null
                            : (v) => setState(() => _attachPhotos = v),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  const SizedBox(height: 8),

                  // Email address with improved validation
                  TextFormField(
                    controller: _emailController,
                    enabled: !widget.state.isSubmittingEmail,
                    decoration: const InputDecoration(
                      labelText: 'Recipient Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                      helperText: 'Enter a valid email address',
                    ),
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Email required';
                      }
                      if (!_isValidEmail(value!)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Export formats
                  const Text(
                    'Export Formats:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('PDF'),
                        selected: _selectedFormats.contains('pdf'),
                        onSelected:
                            widget.state.isSubmittingEmail
                                ? null
                                : (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedFormats.add('pdf');
                                    } else {
                                      _selectedFormats.remove('pdf');
                                    }
                                  });
                                },
                      ),
                      FilterChip(
                        label: const Text('Excel'),
                        selected: _selectedFormats.contains('excel'),
                        onSelected:
                            widget.state.isSubmittingEmail
                                ? null
                                : (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedFormats.add('excel');
                                    } else {
                                      _selectedFormats.remove('excel');
                                    }
                                  });
                                },
                      ),
                      FilterChip(
                        label: const Text('Word'),
                        selected: _selectedFormats.contains('docx'),
                        onSelected:
                            widget.state.isSubmittingEmail
                                ? null
                                : (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedFormats.add('docx');
                                    } else {
                                      _selectedFormats.remove('docx');
                                    }
                                  });
                                },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Subject
                  TextFormField(
                    controller: _subjectController,
                    enabled: !widget.state.isSubmittingEmail,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Body
                  SizedBox(
                    height: 120,
                    child: TextFormField(
                      controller: _bodyController,
                      enabled: !widget.state.isSubmittingEmail,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              widget.state.isSubmittingEmail
                  ? null
                  : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),

        if (!_sendEmail || !_canSubmitViaEmail)
          FilledButton.icon(
            onPressed:
                widget.state.isSubmittingEmail ? null : widget.onCompleteOnly,
            icon:
                widget.state.isSubmittingEmail
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.check),
            label: Text(
              widget.state.isSubmittingEmail
                  ? 'Completing...'
                  : 'Complete Only',
            ),
            style: FilledButton.styleFrom(backgroundColor: Colors.blue),
          ),

        if (_sendEmail && _canSubmitViaEmail)
          FilledButton.icon(
            onPressed:
                widget.state.isSubmittingEmail
                    ? null
                    : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (_selectedFormats.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select at least one export format',
                              ),
                            ),
                          );
                          return;
                        }

                        final photoPaths =
                            _attachPhotos
                                ? _extractPhotoPaths(widget.state)
                                : <String>[];
                        widget.onEmailSubmit(
                          _emailController.text.trim(),
                          _selectedFormats,
                          _subjectController.text.trim().isNotEmpty
                              ? _subjectController.text.trim()
                              : null,
                          _bodyController.text.trim().isNotEmpty
                              ? _bodyController.text.trim()
                              : null,
                          photoPaths,
                        );
                      }
                    },
            icon:
                widget.state.isSubmittingEmail
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.send),
            label: Text(
              widget.state.isSubmittingEmail
                  ? 'Submitting...'
                  : 'Submit via Email',
            ),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
          ),
      ],
    );
  }

  List<String> _extractPhotoPaths(AssessmentFormLoaded s) {
    final form = s.assessmentForm;
    if (form == null) return const [];
    final photos = form.photos;
    return photos
        .map((p) {
          try {
            final dynamic dp = p;
            return (dp.localPath ??
                    dp.filePath ??
                    dp.path ??
                    (dp.uri is String ? dp.uri : null))
                as String?;
          } catch (_) {
            return null;
          }
        })
        .whereType<String>()
        .where((p) => p.trim().isNotEmpty)
        .toList(growable: false);
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email.trim());
  }
}

class _FormatCard extends StatelessWidget {
  final String format;
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _FormatCard({
    required this.format,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
          border: Border.all(
            color:
                isSelected
                    ? color
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool?> onChanged;

  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.value,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: enabled ? onChanged : null,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

// Export Success Dialog
class _ExportSuccessDialog extends StatelessWidget {
  final ExportResult result;
  final VoidCallback onShare;
  final VoidCallback onViewFiles;

  const _ExportSuccessDialog({
    required this.result,
    required this.onShare,
    required this.onViewFiles,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 28),
          SizedBox(width: 12),
          Text('Export Successful'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('File: ${result.fileName}'),
          Text('Format: ${result.format}'),
          Text('Size: ${result.fileSizeFormatted}'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'File saved to app documents. Use Share to save to your preferred location.',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        TextButton.icon(
          onPressed: onViewFiles,
          icon: const Icon(Icons.folder_open),
          label: const Text('View Files'),
        ),
        FilledButton.icon(
          onPressed: onShare,
          icon: const Icon(Icons.share),
          label: const Text('Share'),
        ),
      ],
    );
  }
}

// Exported Files Dialog
class _ExportedFilesDialog extends StatelessWidget {
  final List<ExportResult> exportedFiles;
  final Function(ExportResult) onShare;
  final Function(ExportResult, int) onDelete;
  final VoidCallback onShowLocation;

  const _ExportedFilesDialog({
    required this.exportedFiles,
    required this.onShare,
    required this.onDelete,
    required this.onShowLocation,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.folder_open),
          SizedBox(width: 8),
          Text('Exported Files'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child:
            exportedFiles.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.file_present, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No exported files yet'),
                      Text('Export an assessment to see files here'),
                    ],
                  ),
                )
                : ListView.builder(
                  itemCount: exportedFiles.length,
                  itemBuilder: (context, index) {
                    final file = exportedFiles[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(_getFileIcon(file.format)),
                        title: Text(file.fileName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${file.fileSizeFormatted} • ${file.format}'),
                            Text(
                              'Created: ${file.createdAt.toString().split(' ')[0]}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'share',
                                  child: Row(
                                    children: [
                                      Icon(Icons.share, size: 18),
                                      SizedBox(width: 8),
                                      Text('Share'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                          onSelected: (value) {
                            switch (value) {
                              case 'share':
                                onShare(file);
                                break;
                              case 'delete':
                                onDelete(file, index);
                                break;
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
      ),
      actions: [
        if (exportedFiles.isNotEmpty)
          TextButton.icon(
            onPressed: onShowLocation,
            icon: const Icon(Icons.folder),
            label: const Text('Show Location'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  IconData _getFileIcon(String format) {
    switch (format.toLowerCase()) {
      case 'pdf':
      case 'adobe pdf':
        return Icons.picture_as_pdf;
      case 'excel':
      case 'microsoft excel':
        return Icons.table_chart;
      case 'word':
      case 'microsoft word':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}
