import 'package:flutter/material.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/breakpoints.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/compare_assessments_page.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/import_assessment_page.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/assessment_form_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar:
          AdaptiveBreakpoints.isDesktop(MediaQuery.sizeOf(context).width)
              ? null
              : AppBar(title: const Text('Dashboard'), elevation: 0),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final contentWidth = AdaptiveBreakpoints.getContentWidth(screenWidth);
          final isMobile = AdaptiveBreakpoints.isMobile(screenWidth);

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: Column(
                  children: [
                    if (AdaptiveBreakpoints.isDesktop(screenWidth))
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Dashboard',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        key: const PageStorageKey('dashboard_scroll'),
                        padding: AdaptiveBreakpoints.getScreenPadding(
                          screenWidth,
                        ),
                        child: Column(
                          children: [
                            if (!AdaptiveBreakpoints.isDesktop(screenWidth))
                              _ResponsiveWHOHeader(isMobile: isMobile),

                            SizedBox(height: isMobile ? 16 : 24),

                            _ResponsiveQuickActions(isMobile: isMobile),

                            SizedBox(height: isMobile ? 20 : 32),

                            _ResponsiveAssessmentOverview(isMobile: isMobile),

                            SizedBox(height: isMobile ? 20 : 32),

                            _ResponsiveRecentActivity(isMobile: isMobile),
                          ],
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
}

// Responsive WHO header
class _ResponsiveWHOHeader extends StatelessWidget {
  final bool isMobile;

  const _ResponsiveWHOHeader({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: isMobile ? 50 : 60,
                  height: isMobile ? 50 : 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.public,
                    color: Colors.white,
                    size: isMobile ? 25 : 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WHO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'World Health Organization',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 10 : 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),
            Text(
              'FVD Treatment Center\nAssessment Tool',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            SizedBox(height: isMobile ? 6 : 8),
            Text(
              'Rapid assessment for filovirus disease treatment facilities',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: isMobile ? 12 : 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponsiveQuickActions extends StatelessWidget {
  final bool isMobile;

  const _ResponsiveQuickActions({required this.isMobile});

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
                Icon(
                  Icons.flash_on,
                  color: theme.colorScheme.primary,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),

            // Primary action
            SizedBox(
              width: double.infinity,
              height: isMobile ? 48 : 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const AssessmentFormPage(assessmentId: null),
                    ),
                  );
                },
                icon: Icon(Icons.add_circle_outline, size: isMobile ? 20 : 24),
                label: Text(
                  'Start New Assessment',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // Secondary actions
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 400) {
                  // Stack buttons vertically on very small screens
                  return Column(
                    children: [
                      _SecondaryActionButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const ImportAssessmentPage(),
                              ),
                            ),
                        icon: Icons.upload_file,
                        label: 'Import Assessment',
                        isCompact: isMobile,
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      _SecondaryActionButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const CompareAssessmentsPage(),
                              ),
                            ),
                        icon: Icons.compare_arrows,
                        label: 'Compare Assessments',
                        isCompact: isMobile,
                      ),
                    ],
                  );
                } else {
                  // Side by side buttons
                  return Row(
                    children: [
                      Expanded(
                        child: _SecondaryActionButton(
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const ImportAssessmentPage(),
                                ),
                              ),
                          icon: Icons.upload_file,
                          label: 'Import Assessment',
                          isCompact: isMobile,
                        ),
                      ),
                      SizedBox(width: isMobile ? 8 : 12),
                      Expanded(
                        child: _SecondaryActionButton(
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const CompareAssessmentsPage(),
                                ),
                              ),
                          icon: Icons.compare_arrows,
                          label: 'Compare Assessments',
                          isCompact: isMobile,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Secondary action button
class _SecondaryActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isCompact;

  const _SecondaryActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: isCompact ? 44 : 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: isCompact ? 18 : 20),
        label: Text(
          label,
          style: TextStyle(
            fontSize: isCompact ? 12 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

// Responsive assessment overview
class _ResponsiveAssessmentOverview extends StatelessWidget {
  final bool isMobile;

  const _ResponsiveAssessmentOverview({required this.isMobile});

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
                Icon(
                  Icons.assessment_outlined,
                  color: theme.colorScheme.primary,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Text(
                  'Assessment Coverage',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),

            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid based on available width
                final crossAxisCount =
                    constraints.maxWidth < 300
                        ? 1
                        : constraints.maxWidth < 600
                        ? 2
                        : 3;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: isMobile ? 8 : 12,
                  crossAxisSpacing: isMobile ? 8 : 12,
                  childAspectRatio: crossAxisCount == 1 ? 4 : 1.2,
                  children: [
                    _StatCard(
                      icon: Icons.checklist_outlined,
                      value: '35+',
                      label: 'Assessment Criteria',
                      color: theme.colorScheme.primary,
                      isCompact: isMobile,
                    ),
                    _StatCard(
                      icon: Icons.layers_outlined,
                      value: '5',
                      label: 'Major Sections',
                      color: theme.colorScheme.secondary,
                      isCompact: isMobile,
                    ),
                    _StatCard(
                      icon: Icons.business_outlined,
                      value: '2',
                      label: 'Facility Types',
                      color: theme.colorScheme.tertiary,
                      isCompact: isMobile,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Responsive recent activity
class _ResponsiveRecentActivity extends StatelessWidget {
  final bool isMobile;

  const _ResponsiveRecentActivity({required this.isMobile});

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
                Icon(
                  Icons.verified_user,
                  color: theme.colorScheme.primary,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    'WHO Guidelines Compliance',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),

            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This assessment tool follows WHO guidelines for FVD treatment centers, developed in consultation with IPC, WASH, and Case Management experts.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: isMobile ? 13 : 14,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: isMobile ? 8 : 12),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user,
                        color: theme.colorScheme.primary,
                        size: isMobile ? 14 : 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'WHO-aligned assessment criteria',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Responsive stat card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isCompact;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 6 : 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: isCompact ? 20 : 24),
          Text(
            value,
            style: TextStyle(
              fontSize: isCompact ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isCompact ? 10 : 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
