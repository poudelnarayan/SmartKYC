import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartkyc/domain/usecases/get_user.dart';
import '../../../../domain/entities/user.dart';
import '../../../../l10n/app_localizations.dart';
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
      builder: (context) => ContactVerificationModal(
        type: type,
        currentValue: currentValue,
        onVerified: onVerified,
      ),
    );
  }

  void _showPasswordChangeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PasswordChangeModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final getUser = GetUser();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Text(
            l10n.editProfile,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Email Option
          _buildContactOption(
            context,
            icon: Icons.email_outlined,
            title: 'Email',
            value: getUser.userEmail!,
            onEdit: () {
              Navigator.pop(context);
              _showVerificationModal(
                context,
                type: 'email',
                currentValue: getUser.userEmail!,
                onVerified: onEmailUpdated,
              );
            },
          ),

          const Divider(height: 32),
          _buildPasswordSection(context),
          const Divider(height: 32),

          // Phone Option
          _buildContactOption(
            context,
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: user.phoneNumber.isEmpty ? 'Not provided' : user.phoneNumber,
            onEdit: () {
              Navigator.pop(context);
              _showVerificationModal(
                context,
                type: 'phone',
                currentValue: user.phoneNumber,
                onVerified: onPhoneUpdated,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Password',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '••••••••',
                      style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 2,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
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
