import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartkyc/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:smartkyc/features/auth/presentation/pages/singin_page.dart';
import 'package:smartkyc/features/liveliness_detection/presentation/pages/liveness_detection_start_page.dart';
import 'package:smartkyc/features/selfie_capture/presentation/pages/selfie_start_page.dart';
import 'package:smartkyc/features/upload_document/presentation/pages/upload_document_page.dart';
import '../bloc/user_profile_bloc.dart';
import '../bloc/user_profile_event.dart';
import '../bloc/user_profile_state.dart';
import '../widgets/delete_account_overlay.dart';
import '../widgets/edit_contact_bottom_sheet.dart';
import '../widgets/phone_verification_model.dart';
import '../widgets/profile_section.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/about_bottom_sheet.dart';
import '../widgets/security_bottom_sheet.dart';
import '../widgets/settings_bottom_sheet.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  static const pageName = '/userProfilePage';

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    // Load user profile when page initializes
    context.read<UserProfileBloc>().add(LoadUserProfile());
  }

  // void _toggleLanguage(BuildContext context) {
  //   final currentLocale = Localizations.localeOf(context);
  //   final newLocale = currentLocale.languageCode == 'en'
  //       ? const Locale('ne')
  //       : const Locale('en');
  //   context.read<LanguageBloc>().add(ChangeLanguage(newLocale));
  // }

  Future<void> _refreshProfile() async {
    context.read<UserProfileBloc>().add(LoadUserProfile());
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirmation),
        content: Text(l10n.logoutConfirmationDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<UserProfileBloc>().add(LogoutUser());
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  void _showPhoneVerificationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PhoneVerificationModal(
          onVerificationComplete: (phoneNumber) {
            // Handle phone verification completion
            if (mounted) {
              final currentState = context.read<UserProfileBloc>().state;
              if (currentState is UserProfileLoaded) {
                final updatedUser = currentState.user.copyWith(
                  phoneNumber: phoneNumber,
                );
                context.read<UserProfileBloc>().add(
                      UpdateUserProfile(updatedUser), // Updated event name
                    );
              }
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state is UserAccountDeleted || state is UserLoggedOut) {
          context.pushReplacement(SinginPage.pageName);
        } else if (state is UserProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          return state is UserAccountDeleting
              ? DeleteAccountOverlay()
              : Scaffold(
                  backgroundColor: Colors.grey[100],
                  appBar: AppBar(
                    title: Text(
                      l10n.profile,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () => _showLogoutDialog(context),
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                  body: RefreshIndicator(
                    key: _refreshKey,
                    onRefresh: _refreshProfile,
                    child: state is UserProfileLoading ||
                            state is UserLoggingOut
                        ? const Center(child: CircularProgressIndicator())
                        : state is UserProfileError
                            ? _buildErrorState(context, state)
                            : state is UserProfileLoaded
                                ? SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      children: [
                                        _buildHeader(context, state),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            children: [
                                              _buildQuickActions(
                                                  context, state),
                                              const SizedBox(height: 24),
                                              _buildContactInfo(context, state),
                                              const SizedBox(height: 16),
                                              _buildPersonalInfo(
                                                  context, state),
                                              const SizedBox(height: 16),
                                              _buildVerificationStatus(
                                                  context, state),
                                              const SizedBox(height: 32),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const Center(
                                    child: Text('Failed to load profile'),
                                  ),
                  ),
                );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, UserProfileLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        QuickActionButton(
          icon: Icons.edit_note,
          label: 'Edit',
          onTap: () => _showEditContactModal(context, state),
        ),
        QuickActionButton(
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => const SettingsBottomSheet(),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          },
        ),
        QuickActionButton(
          icon: Icons.security_outlined,
          label: 'Security',
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => const SecurityBottomSheet(),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          },
        ),
        QuickActionButton(
          icon: Icons.info_outline,
          label: 'About',
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => const AboutBottomSheet(),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          },
        ),
      ],
    ).animate().fadeIn().slideY();
  }

// Add this new method
  void _showEditContactModal(BuildContext context, UserProfileLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditContactBottomSheet(
        user: state.user,
        onEmailUpdated: (newEmail) {
          // TODO
          // context.read<UserProfileBloc>().add(
          //       UpdateUserProfile(
          //         state.user.copyWith(email: newEmail),
          //       ),
          //     );
        },
        onPhoneUpdated: (newPhone) {
          context.read<UserProfileBloc>().add(
                UpdateUserProfile(
                  state.user.copyWith(phoneNumber: newPhone),
                ),
              );
        },
      ),
    );
  }

  Widget _buildPersonalInfo(BuildContext context, UserProfileLoaded state) {
    return ProfileSection(
      title: 'Personal Information',
      icon: Icons.person_outline,
      items: [
        ProfileItem(
          icon: Icons.badge_outlined,
          label: 'License Number',
          value: state.user.licenseNumber,
        ),
        ProfileItem(
          icon: Icons.assignment_ind_outlined,
          label: 'Citizenship Number',
          value: state.user.citizenshipNumber,
        ),
        ProfileItem(
          icon: Icons.calendar_today_outlined,
          label: 'Date of Birth',
          value: state.user.dob.toString().split(' ')[0],
        ),
        ProfileItem(
          icon: Icons.family_restroom_outlined,
          label: "Father's Name",
          value: state.user.fatherName,
        ),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context, UserProfileLoaded state) {
    return ProfileSection(
      title: 'Contact Information',
      icon: Icons.contact_phone_outlined,
      items: [
        ProfileItem(
          icon: Icons.phone_outlined,
          label: 'Phone Number',
          value: state.user.phoneNumber.isEmpty
              ? 'Verification Required'
              : state.user.phoneNumber,
          isVerified: state.user.phoneNumber.isNotEmpty,
          onVerify: state.user.phoneNumber.isEmpty
              ? () => _showPhoneVerificationModal(context)
              : null,
        ),
        ProfileItem(
          icon: Icons.location_on_outlined,
          label: 'Address',
          value:
              state.user.address.isEmpty ? 'Not provided' : state.user.address,
        ),
      ],
    );
  }

  Widget _buildVerificationStatus(
      BuildContext context, UserProfileLoaded state) {
    return ProfileSection(
      title: 'Verification Status',
      icon: Icons.verified_user_outlined,
      items: [
        _buildVerificationItem(
          context,
          icon: Icons.document_scanner_outlined,
          label: 'Document Verification',
          isVerified: state.user.isDocumentVerified,
          verificationScreenPath: UploadDocumentPage.pageName,
        ),
        _buildVerificationItem(
          context,
          icon: Icons.face_outlined,
          label: 'Selfie Verification',
          isVerified: state.user.isSelfieVerified,
          verificationScreenPath: SelfieStartPage.pageName,
        ),
        _buildVerificationItem(
          context,
          icon: Icons.security_outlined,
          label: 'Liveness Check',
          isVerified: state.user.isLivenessVerified,
          verificationScreenPath: LivenessDetectionStartPage.pageName,
        ),
      ],
    );
  }

  Widget _buildVerificationItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isVerified,
    required String verificationScreenPath,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isVerified ? 'Verified' : 'Not Verified',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          if (isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified,
                    size: 16,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Verified',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            FilledButton.icon(
              onPressed: () {
                context.push(
                  verificationScreenPath,
                  extra: {'returnToProfile': true},
                );
              },
              icon: const Icon(Icons.verified_user_outlined, size: 16),
              label: const Text('Verify Now'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfileLoaded state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              state.user.initials,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.user.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  FirebaseAuth.instance.currentUser!.email!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildErrorState(BuildContext context, UserProfileError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(state.message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<UserProfileBloc>().add(LoadUserProfile());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
