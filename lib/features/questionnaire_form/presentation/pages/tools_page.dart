import 'package:flutter/material.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/breakpoints.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/compare_assessments_page.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/import_assessment_page.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar:
          AdaptiveBreakpoints.isDesktop(MediaQuery.sizeOf(context).width)
              ? null
              : AppBar(title: const Text('Assessment Tools'), elevation: 0),
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
                                        'Assessment Tools',
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
                              child: ListView(
                                key: const PageStorageKey('tools_scroll'),
                                physics: const BouncingScrollPhysics(),
                                padding: AdaptiveBreakpoints.getScreenPadding(
                                  screenWidth,
                                ),
                                children: [
                                  _buildHeaderSection(theme, isMobile),
                                  SizedBox(height: isMobile ? 20 : 24),
                                  _buildDataManagementSection(theme, isMobile),
                                  SizedBox(height: isMobile ? 20 : 24),
                                  _buildAnalysisSection(theme, isMobile),
                                  SizedBox(height: isMobile ? 20 : 24),
                                ],
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
                Icons.build_outlined,
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
                    'Assessment Tools',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: isMobile ? 16 : null,
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    'Comprehensive tools for data management, analysis, and reporting',
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

  Widget _buildDataManagementSection(ThemeData theme, bool isMobile) {
    return _ToolsSection(
      title: 'Data Management',
      icon: Icons.folder_outlined,
      isMobile: isMobile,
      children: [
        _ToolCard(
          title: 'Import Assessment',
          subtitle: 'Upload existing assessment data from files',
          icon: Icons.upload_file_outlined,
          isMobile: isMobile,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ImportAssessmentPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnalysisSection(ThemeData theme, bool isMobile) {
    return _ToolsSection(
      title: 'Analysis & Comparison',
      icon: Icons.analytics_outlined,
      isMobile: isMobile,
      children: [
        _ToolCard(
          title: 'Compare Assessments',
          subtitle: 'Side-by-side comparison of facility assessments',
          icon: Icons.compare_arrows,
          isMobile: isMobile,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CompareAssessmentsPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ToolsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isMobile;
  final List<Widget> children;

  const _ToolsSection({
    required this.title,
    required this.icon,
    required this.isMobile,
    required this.children,
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
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    fontSize: isMobile ? 16 : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isMobile;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isMobile,
    required this.onTap,
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
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 4 : 8,
        ),
        leading: Container(
          padding: EdgeInsets.all(isMobile ? 8 : 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: isMobile ? 18 : 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: isMobile ? 12 : 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: isMobile ? 14 : 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}
