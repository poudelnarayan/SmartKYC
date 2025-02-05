import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartkyc/core/theme/app_color_scheme.dart';
import 'package:smartkyc/features/auth/presentation/pages/singin_page.dart';
import '../../../../core/services/biometric_services.dart';
import '../../../auth/presentation/widgets/biometric_prompt_dialog.dart';
import '../bloc/user_profile_bloc.dart';
import '../bloc/user_profile_event.dart';
import '../bloc/user_profile_state.dart';

class SecurityBottomSheet extends StatefulWidget {
  const SecurityBottomSheet({super.key});

  @override
  State<SecurityBottomSheet> createState() => _SecurityBottomSheetState();
}

class _SecurityBottomSheetState extends State<SecurityBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state is UserAccountDeleted) {
          context.pushReplacement(SigninPage.pageName);
        } else if (state is UserProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColorScheme.lightError,
            ),
          );
        }
      },
      child: Container(
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
              'Security Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColorScheme.darkText
                        : AppColorScheme.lightText,
                  ),
            ),
            const SizedBox(height: 24),
            _buildBiometricOption(context, isDark),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: AppColorScheme.darkError,
              ),
              title: Text(
                'Delete Account',
                style: TextStyle(color: AppColorScheme.lightError),
              ),
              onTap: () => _showDeleteConfirmation(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColorScheme.getCardBackground(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColorScheme.getCardBorder(isDark),
          ),
        ),
        title: Text(
          'Delete Account',
          style: TextStyle(
            color: isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete your account? ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'This action:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
              ),
            ),
            const SizedBox(height: 16),
            _buildBulletPoint('Cannot be undone', isDark),
            _buildBulletPoint('Will delete all your data', isDark),
            _buildBulletPoint('Will remove your verification status', isDark),
            _buildBulletPoint('Will terminate your account access', isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? AppColorScheme.darkSecondary
                  : AppColorScheme.lightSecondary,
            ),
            child: const Text('Cancel'),
          ),
          _buildBiometricOption(context, isDark),
          const Divider(height: 1),
          FilledButton(
            onPressed: () {
              // Dispatch delete account event
              context.read<UserProfileBloc>().add(DeleteUserAccount());

              // Close dialog and bottom sheet
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColorScheme.lightError,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricOption(BuildContext context, bool isDark) {
    return FutureBuilder<bool>(
      future: BiometricService.isBiometricEnabled(),
      builder: (context, snapshot) {
        final isEnabled = snapshot.data ?? false;

        return SwitchListTile(
          title: Text(
            'Biometric Login',
            style: TextStyle(
              color:
                  isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
            ),
          ),
          subtitle: Text(
            isEnabled ? 'Enabled' : 'Disabled',
            style: TextStyle(
              color: isDark
                  ? AppColorScheme.darkTextSecondary
                  : AppColorScheme.lightTextSecondary,
            ),
          ),
          secondary: Icon(
            Icons.fingerprint,
            color: isEnabled
                ? isDark
                    ? AppColorScheme.darkPrimary
                    : AppColorScheme.lightPrimary
                : isDark
                    ? AppColorScheme.darkTextSecondary
                    : AppColorScheme.lightTextSecondary,
          ),
          value: isEnabled,
          onChanged: (value) async {
            if (value) {
              final isAvailable =
                  await BiometricService.isBiometricsAvailable();
              if (!isAvailable) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Biometric login not available on this device'),
                    ),
                  );
                }
                return;
              }

              // Re-authenticate to enable biometrics
              if (context.mounted) {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => BiometricPromptDialog(
                    email: FirebaseAuth.instance.currentUser!.email!,
                    password: '', // You'll need to get this securely
                  ),
                );

                if (result ?? false) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Biometric login enabled'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              }
            } else {
              await BiometricService.disableBiometric();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Biometric login disabled'),
                  ),
                );
              }
            }

            // Refresh the UI
            if (context.mounted) {
              setState(() {});
            }
          },
          activeColor:
              isDark ? AppColorScheme.darkPrimary : AppColorScheme.lightPrimary,
        );
      },
    );
  }

  Widget _buildBulletPoint(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '• ',
            style: TextStyle(
              color:
                  isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              color:
                  isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
            ),
          ),
        ],
      ),
    );
  }
}
