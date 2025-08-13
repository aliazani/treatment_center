import 'package:flutter/material.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/breakpoints.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;

  const SettingsPage({super.key, this.onThemeChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
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
              : AppBar(title: const Text('Settings'), elevation: 0),
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
                                        'Settings',
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
                              child: ListView(
                                key: const PageStorageKey('settings_scroll'),
                                physics: const BouncingScrollPhysics(),
                                padding: AdaptiveBreakpoints.getScreenPadding(
                                  screenWidth,
                                ),
                                children: [
                                  // Application Settings
                                  _buildApplicationSection(theme, isMobile),
                                  SizedBox(height: isMobile ? 20 : 24),

                                  // About Section
                                  _buildAboutSection(theme, isMobile),
                                  SizedBox(height: isMobile ? 20 : 24),

                                  // WHO Branding
                                  _buildWHOBrandingSection(theme, isMobile),
                                  SizedBox(height: isMobile ? 24 : 40),
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

  Widget _buildApplicationSection(ThemeData theme, bool isMobile) {
    return _SettingsSection(
      title: 'Application',
      icon: Icons.smartphone,
      isMobile: isMobile,
      children: [
        // Theme Selection
        if (widget.onThemeChanged != null)
          _ThemeSettingsTile(
            onThemeChanged: widget.onThemeChanged!,
            isMobile: isMobile,
          ),
        SizedBox(height: isMobile ? 8 : 12),
        _SettingsTile(
          title: 'Language',
          subtitle: 'English',
          icon: Icons.language,
          isMobile: isMobile,
          onTap: () {
            _showLanguageDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(ThemeData theme, bool isMobile) {
    return _SettingsSection(
      title: 'About',
      icon: Icons.info_outline,
      isMobile: isMobile,
      children: [
        _SettingsTile(
          title: 'Version',
          subtitle: '1.0.0 (Build 1)',
          icon: Icons.apps,
          isMobile: isMobile,
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'FVD Assessment Tool',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2025 World Health Organization',
              children: [
                const SizedBox(height: 16),
                Text(
                  'A comprehensive assessment tool for Filovirus Disease (FVD) treatment center compliance with WHO guidelines.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            );
          },
        ),
        SizedBox(height: isMobile ? 8 : 12),
        _SettingsTile(
          title: 'WHO Guidelines',
          subtitle: 'View compliance information',
          icon: Icons.public,
          isMobile: isMobile,
          onTap: () {
            _launchGuidelines();
          },
        ),
        SizedBox(height: isMobile ? 8 : 12),
        _SettingsTile(
          title: 'Privacy Policy',
          subtitle: 'Review data handling policies',
          icon: Icons.privacy_tip_outlined,
          isMobile: isMobile,
          onTap: () {
            _showPrivacyPolicy(context);
          },
        ),
        SizedBox(height: isMobile ? 8 : 12),
        _SettingsTile(
          title: 'Support',
          subtitle: 'Get help and contact support',
          icon: Icons.support_outlined,
          isMobile: isMobile,
          onTap: () {
            _showSupportDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildWHOBrandingSection(ThemeData theme, bool isMobile) {
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
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
              ),
              child: Icon(
                Icons.public,
                color: theme.colorScheme.onPrimary,
                size: isMobile ? 24 : 32,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'World Health Organization',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 16 : null,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 4 : 8),
            Text(
              'FVD Treatment Center Assessment Tool',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.8,
                ),
                fontSize: isMobile ? 13 : null,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              'Supporting global health security through standardized facility assessments',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.7,
                ),
                fontSize: isMobile ? 11 : null,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('English'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Language set to English')),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Privacy Policy'),
            content: const SingleChildScrollView(
              child: Text(
                'This application collects and processes assessment data in accordance with WHO data protection policies. '
                'All data is stored locally on your device and is not transmitted without explicit user action.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Support'),
            content: const Text(
              'For technical support or questions about the FVD Assessment Tool, '
              'please contact your WHO regional office or visit the WHO website.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _launchSupport();
                },
                child: const Text('Visit WHO'),
              ),
            ],
          ),
    );
  }

  Future<void> _launchGuidelines() async {
    final url = Uri.parse('https://www.who.int/publications/b/73031');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WHO guidelines')),
        );
      }
    }
  }

  Future<void> _launchSupport() async {
    final url = Uri.parse('https://www.who.int/europe/about-us/contact-us');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WHO support page')),
        );
      }
    }
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isMobile;
  final List<Widget> children;

  const _SettingsSection({
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

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isMobile;
  final VoidCallback onTap;

  const _SettingsTile({
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
        leading: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: isMobile ? 20 : 24,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w500,
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

class _ThemeSettingsTile extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;
  final bool isMobile;

  const _ThemeSettingsTile({
    required this.onThemeChanged,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTheme = theme.brightness;
    String themeText = 'System default';

    // Determine current theme text
    if (MediaQuery.of(context).platformBrightness == Brightness.dark &&
        currentTheme == Brightness.dark) {
      themeText = 'Dark mode';
    } else if (MediaQuery.of(context).platformBrightness == Brightness.light &&
        currentTheme == Brightness.light) {
      themeText = 'Light mode';
    }

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
        leading: Icon(
          Icons.palette_outlined,
          color: theme.colorScheme.primary,
          size: isMobile ? 20 : 24,
        ),
        title: Text(
          'Theme',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          themeText,
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
        onTap: () {
          _showThemeDialog(context);
        },
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text('System default'),
                onTap: () {
                  onThemeChanged(ThemeMode.system);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Light mode'),
                onTap: () {
                  onThemeChanged(ThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark mode'),
                onTap: () {
                  onThemeChanged(ThemeMode.dark);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
