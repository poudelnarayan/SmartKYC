import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/language_bloc.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        final isEnglish = state.currentLocale.languageCode == 'en';

        return GestureDetector(
          onTap: () {
            context.read<LanguageBloc>().add(
                  ChangeLanguage(
                    isEnglish ? const Locale('ne') : const Locale('en'),
                  ),
                );
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLanguageOption(
                    context,
                    'EN',
                    isSelected: isEnglish,
                  ),
                  const SizedBox(width: 8),
                  _buildLanguageOption(
                    context,
                    'ने',
                    isSelected: !isEnglish,
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn().scale(duration: const Duration(milliseconds: 200));
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String text, {
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ).animate().fadeIn().scale(duration: const Duration(milliseconds: 200));
  }
}
