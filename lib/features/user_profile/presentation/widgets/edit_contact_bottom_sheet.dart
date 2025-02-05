import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartkyc/core/theme/app_color_scheme.dart';
import 'package:smartkyc/features/user_profile/presentation/widgets/phone_verification_model.dart';
import '../../../../domain/entities/user.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/user_profile_bloc.dart';
import '../bloc/user_profile_event.dart';
import '../bloc/user_profile_state.dart';
import 'contact_verification_modal.dart';
import 'password_change_modal.dart';

class EditContactBottomSheet extends StatelessWidget {
  final User user;
  final Function(String) onEmailUpdated;
  final Function(String) onPhoneUpdated;

  const EditContactBottomSheet({
    super.key,
    required this.user,
    required this.onEmailUpdated,
    required this.onPhoneUpdated,
  });

  void _showVerificationModal(
    BuildContext context, {
    required String type,
    required String currentValue,
    required Function(String) onVerified,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ContactVerificationModal(
          type: type,
          currentValue: currentValue,
          onVerified: onVerified,
        ),
      ),
    );
  }

  void _showPhoneNumberChangeModal(
    BuildContext context,
    String previousNumber,
  ) {
    final numberWithoutCountryCode = previousNumber.substring(4);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PhoneVerificationModal(
          previousNumber: numberWithoutCountryCode,
          isEditing: true,
          onVerificationComplete: (phoneNumber) {
            final currentState = context.read<UserProfileBloc>().state;
            if (currentState is UserProfileLoaded) {
              final updatedUser = currentState.user.copyWith(
                phoneNumber: phoneNumber,
              );
              context.read<UserProfileBloc>().add(
                    UpdateUserProfile(updatedUser),
                  );
            }
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showPasswordChangeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const PasswordChangeModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
          Text(
            l10n.editProfile,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
            ),
          ),
          const SizedBox(height: 24),
          _buildContactOption(
            context,
            icon: Icons.email_outlined,
            title: 'Email',
            value: auth.FirebaseAuth.instance.currentUser!.email!,
            onEdit: () {
              Navigator.pop(context);
              _showVerificationModal(
                context,
                type: 'email',
                currentValue: auth.FirebaseAuth.instance.currentUser!.email!,
                onVerified: onEmailUpdated,
              );
            },
            isDark: isDark,
          ),
          Divider(
            height: 32,
            color: isDark
                ? AppColorScheme.darkCardBorder
                : AppColorScheme.lightCardBorder,
          ),
          _buildPasswordSection(context, isDark),
          Divider(
            height: 32,
            color: isDark
                ? AppColorScheme.darkCardBorder
                : AppColorScheme.lightCardBorder,
          ),
          _buildContactOption(
            context,
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: user.phoneNumber.isEmpty ? 'Not provided' : user.phoneNumber,
            onEdit: () {
              Navigator.pop(context);
              _showPhoneNumberChangeModal(context, user.phoneNumber);
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColorScheme.darkBackground
            : AppColorScheme.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColorScheme.darkCardBorder
              : AppColorScheme.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: isDark
                    ? AppColorScheme.darkPrimary
                    : AppColorScheme.lightPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'Password',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColorScheme.darkText
                      : AppColorScheme.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _showPasswordChangeModal(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColorScheme.darkSurface
                    : AppColorScheme.lightSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? AppColorScheme.darkCardBorder
                      : AppColorScheme.lightCardBorder,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '••••••••',
                      style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 2,
                        color: isDark
                            ? AppColorScheme.darkTextSecondary
                            : AppColorScheme.lightTextSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: isDark
                        ? AppColorScheme.darkPrimary
                        : AppColorScheme.lightPrimary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }
}

Widget _buildContactOption(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String value,
  required VoidCallback onEdit,
  required bool isDark,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColorScheme.darkPrimary.withOpacity(0.1)
                    : AppColorScheme.lightPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDark
                    ? AppColorScheme.darkPrimary
                    : AppColorScheme.lightPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: isDark
                          ? AppColorScheme.darkText
                          : AppColorScheme.lightText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: isDark
                          ? AppColorScheme.darkTextSecondary
                          : AppColorScheme.lightTextSecondary,
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColorScheme.darkPrimary.withOpacity(0.1)
                    : AppColorScheme.lightPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: isDark
                        ? AppColorScheme.darkPrimary
                        : AppColorScheme.lightPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColorScheme.darkPrimary
                          : AppColorScheme.lightPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ).animate().fadeIn().slideX();
}
