import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartkyc/core/theme/app_color_scheme.dart';
import '../../../language/presentation/bloc/language_bloc.dart';
import '../../../theme/presentation/bloc/theme_bloc.dart';
import '../../../theme/presentation/bloc/theme_event.dart';
import '../../../theme/presentation/bloc/theme_state.dart';

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColorScheme.getCardBackground(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColorScheme.darkCardBorder
                  : AppColorScheme.lightCardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          CircleAvatar(
            radius: 40,
            backgroundColor: isDark
                ? AppColorScheme.darkPrimary
                : AppColorScheme.lightPrimary,
            child: Icon(
              Icons.settings_outlined,
              size: 40,
              color: AppColorScheme.getCardBackground(isDark),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColorScheme.darkText
                      : AppColorScheme.lightText,
                ),
          ),
          const SizedBox(height: 32),
          _buildThemeSection(context, isDark),
          Divider(
            height: 32,
            color: isDark
                ? AppColorScheme.darkCardBorder
                : AppColorScheme.lightCardBorder,
          ),
          _buildLanguageSection(context, isDark),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.palette_outlined,
          title: 'Theme',
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildThemeOptions(context, isDark),
      ],
    );
  }

  Widget _buildLanguageSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.language_outlined,
          title: 'Language',
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildLanguageOptions(context, isDark),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColorScheme.darkPrimary.withOpacity(0.1)
                : AppColorScheme.lightPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDark
                ? AppColorScheme.darkPrimary
                : AppColorScheme.lightPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOptions(BuildContext context, bool isDark) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? AppColorScheme.darkBackground
                : AppColorScheme.lightBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  context,
                  icon: Icons.light_mode_outlined,
                  label: 'Light',
                  isSelected: state.themeMode == ThemeMode.light,
                  onTap: () {
                    context.read<ThemeBloc>().add(ChangeTheme(ThemeMode.light));
                  },
                  isDark: isDark,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: _buildThemeOption(
                  context,
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark',
                  isSelected: state.themeMode == ThemeMode.dark,
                  onTap: () {
                    context.read<ThemeBloc>().add(ChangeTheme(ThemeMode.dark));
                  },
                  isDark: isDark,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: _buildThemeOption(
                  context,
                  icon: Icons.brightness_auto_outlined,
                  label: 'System',
                  isSelected: state.themeMode == ThemeMode.system,
                  onTap: () {
                    context
                        .read<ThemeBloc>()
                        .add(ChangeTheme(ThemeMode.system));
                  },
                  isDark: isDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOptions(BuildContext context, bool isDark) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        final currentLocale = state.currentLocale.languageCode;

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? AppColorScheme.darkBackground
                : AppColorScheme.lightBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildLanguageOption(
                  context,
                  label: 'English',
                  locale: const Locale('en'),
                  isSelected: currentLocale == 'en',
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildLanguageOption(
                  context,
                  label: 'नेपाली',
                  locale: const Locale('ne'),
                  isSelected: currentLocale == 'ne',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? isDark
                  ? AppColorScheme.darkPrimary.withOpacity(0.1)
                  : AppColorScheme.lightPrimary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? isDark
                    ? AppColorScheme.darkPrimary
                    : AppColorScheme.lightPrimary
                : isDark
                    ? AppColorScheme.darkCardBorder
                    : AppColorScheme.lightCardBorder,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? isDark
                      ? AppColorScheme.darkPrimary
                      : AppColorScheme.lightPrimary
                  : isDark
                      ? AppColorScheme.darkTextSecondary
                      : AppColorScheme.lightTextSecondary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? isDark
                        ? AppColorScheme.darkPrimary
                        : AppColorScheme.lightPrimary
                    : isDark
                        ? AppColorScheme.darkTextSecondary
                        : AppColorScheme.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String label,
    required Locale locale,
    required bool isSelected,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<LanguageBloc>().add(ChangeLanguage(locale));
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColorScheme.getCardBackground(isDark)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? isDark
                      ? AppColorScheme.darkPrimary
                      : AppColorScheme.lightPrimary
                  : isDark
                      ? AppColorScheme.darkTextSecondary
                      : AppColorScheme.lightTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
