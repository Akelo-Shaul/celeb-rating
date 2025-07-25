import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../l10n/supported_languages.dart';
import '../services/auth_service.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;
    final currentLocale = appState.locale;
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(title: 'ACCOUNT'),
          SettingsButton(
            icon: Icons.person_outline,
            label: 'Account Settings',
            onTap: () {},
          ),
          SettingsButton(
            icon: Icons.notifications_none,
            label: 'Manage Notifications',
            onTap: () {},
          ),
          SettingsButton(
            icon: Icons.history,
            label: 'History',
            onTap: () {},
          ),
          SettingsButton(
            icon: Icons.bookmark_border,
            label: 'Saved',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _SectionHeader(title: 'LANGUAGE'),
          SettingsButton(
            icon: Icons.language,
            label: 'Language Settings',
            showDownArrow: true,
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<SupportedLanguage>(
                icon: const Icon(Icons.language, color: Colors.grey),
                value: supportedLanguages.firstWhere(
                      (l) => l.code == currentLocale?.languageCode,
                  orElse: () => supportedLanguages[0],
                ),
                items: supportedLanguages.map((lang) => DropdownMenuItem(
                  value: lang,
                  child: Text('${lang.flag} ${lang.label}'),
                )).toList(),
                onChanged: (lang) {
                  if (lang != null) appState.setLocale(Locale(lang.code));
                },
              ),
            ),
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _SectionHeader(title: 'ABOUT'),
          SettingsButton(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () {},
          ),
          SettingsButton(
            icon: Icons.article_outlined,
            label: 'User Agreements',
            onTap: () {},
          ),
          SettingsButton(
            icon: Icons.info_outline,
            label: 'Acknowledgements',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _SectionHeader(title: 'SUPPORT'),
          SettingsButton(
            icon: Icons.help_outline,
            label: 'Help Center',
            onTap: () {},
          ),
          SettingsButton(
            icon: Icons.report_gmailerrorred_outlined,
            label: 'Report an Issue',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _SectionHeader(title: 'LOGOUT'),
          SettingsButton(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () async {
              await AuthService.instance.logout();
              if (context.mounted) {
                context.goNamed('auth');
              }
            },
          ),
        ],
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showDownArrow;

  const SettingsButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.showDownArrow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade200,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 24, color: Colors.black),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                ),
              ),
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: 8),
              ],
              Icon(
                  showDownArrow ? Icons.keyboard_arrow_down : Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.black
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
} 