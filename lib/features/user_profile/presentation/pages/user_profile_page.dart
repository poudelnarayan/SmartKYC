import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartkyc/core/theme/app_color_scheme.dart';
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
    context.read<UserProfileBloc>().add(LoadUserProfile());
  }

  Future<void> _refreshProfile() async {
    context.read<UserProfileBloc>().add(LoadUserProfile());
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          l10n.logoutConfirmation,
          style: TextStyle(
            color: isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
          ),
        ),
        content: Text(
          l10n.logoutConfirmationDesc,
          style: TextStyle(
            color: isDark
                ? AppColorScheme.darkTextSecondary
                : AppColorScheme.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: isDark
                    ? AppColorScheme.darkSecondary
                    : AppColorScheme.lightSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              context.read<UserProfileBloc>().add(LogoutUser());
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColorScheme.lightError,
              foregroundColor: Colors.white,
            ),
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
            if (mounted) {
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
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = AppColorScheme.getGradientColors(isDark);
    final l10n = AppLocalizations.of(context);

    return BlocListener<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state is UserAccountDeleted || state is UserLoggedOut) {
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
      child: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          return state is UserAccountDeleting
              ? DeleteAccountOverlay()
              : Scaffold(
                  body: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          gradientColors[0],
                          gradientColors[0],
                          gradientColors[1],
                          gradientColors[1],
                        ],
                        stops: const [0.0, 0.3, 0.3, 1.0],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          _buildAppBar(context, isDark),
                          Expanded(
                            child: RefreshIndicator(
                              key: _refreshKey,
                              onRefresh: _refreshProfile,
                              child: state is UserProfileLoading ||
                                      state is UserLoggingOut
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: isDark
                                            ? AppColorScheme.darkText
                                            : Colors.white,
                                      ),
                                    )
                                  : state is UserProfileError
                                      ? _buildErrorState(context, state, isDark)
                                      : state is UserProfileLoaded
                                          ? _buildContent(
                                              context, state, isDark)
                                          : Center(
                                              child: Text(
                                                l10n.failToLoadProfile,
                                                style: TextStyle(
                                                  color: isDark
                                                      ? AppColorScheme.darkText
                                                      : Colors.white,
                                                ),
                                              ),
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

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context).profile,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColorScheme.darkText : Colors.white,
            ),
          ),
          _buildLogoutButton(context, isDark),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? AppColorScheme.darkSurface.withOpacity(0.3)
                : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark
                  ? AppColorScheme.darkCardBorder.withOpacity(0.2)
                  : Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout_rounded,
                size: 20,
                color: isDark ? AppColorScheme.darkText : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.logout,
                style: TextStyle(
                  color: isDark ? AppColorScheme.darkText : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
  }

  Widget _buildContent(
      BuildContext context, UserProfileLoaded state, bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(context, state, isDark),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildQuickActions(context, state, isDark),
                const SizedBox(height: 24),
                _buildContactInfo(context, state, isDark),
                const SizedBox(height: 16),
                _buildPersonalInfo(context, state, isDark),
                const SizedBox(height: 16),
                _buildVerificationStatus(context, state, isDark),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, UserProfileLoaded state, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColorScheme.getCardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColorScheme.getCardBorder(isDark),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: isDark
                ? AppColorScheme.darkPrimary
                : AppColorScheme.lightPrimary,
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColorScheme.darkText
                        : AppColorScheme.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark
                              ? AppColorScheme.darkSecondary
                              : AppColorScheme.lightSecondary,
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return Text(
                        l10n.noUserSignedIn,
                        style: TextStyle(
                          color: isDark
                              ? AppColorScheme.darkTextSecondary
                              : AppColorScheme.lightTextSecondary,
                          fontSize: 14,
                        ),
                      );
                    }

                    return Text(
                      "${snapshot.data!.email}",
                      style: TextStyle(
                        color: isDark
                            ? AppColorScheme.darkTextSecondary
                            : AppColorScheme.lightTextSecondary,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildQuickActions(
      BuildContext context, UserProfileLoaded state, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorScheme.getCardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColorScheme.getCardBorder(isDark),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // 🔹 Enables horizontal scrolling
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            QuickActionButton(
              icon: Icons.edit_note,
              label: l10n.edit,
              onTap: () => _showEditContactModal(context, state),
              isDark: isDark,
            ),
            QuickActionButton(
              icon: Icons.settings_outlined,
              label: l10n.settings,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => const SettingsBottomSheet(),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
              isDark: isDark,
            ),
            QuickActionButton(
              icon: Icons.security_outlined,
              label: l10n.security,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => const SecurityBottomSheet(),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
              isDark: isDark,
            ),
            QuickActionButton(
              icon: Icons.info_outline,
              label: l10n.about,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => const AboutBottomSheet(),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
              isDark: isDark,
            ),
            // 🔹 Add more actions here if needed
          ],
        ),
      ),
    ).animate().fadeIn().slideY();
  }

  void _showEditContactModal(BuildContext context, UserProfileLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditContactBottomSheet(
        user: state.user,
        onEmailUpdated: (newEmail) {
          context.read<UserProfileBloc>().add(LoadUserProfile());
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

  Widget _buildPersonalInfo(
      BuildContext context, UserProfileLoaded state, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return ProfileSection(
      title: l10n.personalInformation,
      icon: Icons.person_outline,
      isDark: isDark,
      items: [
        ProfileItem(
          icon: Icons.badge_outlined,
          label: l10n.licenseNumber,
          value: state.user.licenseNumber,
          isDark: isDark,
        ),
        ProfileItem(
          icon: Icons.assignment_ind_outlined,
          label: l10n.citizenshipNumber,
          value: state.user.citizenshipNumber,
          isDark: isDark,
        ),
        ProfileItem(
          icon: Icons.calendar_today_outlined,
          label: l10n.dateOfBirth,
          value: state.user.dob.toString().split(' ')[0],
          isDark: isDark,
        ),
        ProfileItem(
          icon: Icons.family_restroom_outlined,
          label: l10n.fatherName,
          value: state.user.fatherName,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildContactInfo(
      BuildContext context, UserProfileLoaded state, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return ProfileSection(
      title: l10n.contactInformation,
      icon: Icons.contact_phone_outlined,
      isDark: isDark,
      items: [
        ProfileItem(
          icon: Icons.phone_outlined,
          label: l10n.phoneLabel,
          value: state.user.phoneNumber.isEmpty
              ? l10n.verificationRequired
              : state.user.phoneNumber,
          isVerified: state.user.phoneNumber.isNotEmpty,
          onVerify: state.user.phoneNumber.isEmpty
              ? () => _showPhoneVerificationModal(context)
              : null,
          isDark: isDark,
        ),
        ProfileItem(
          icon: Icons.location_on_outlined,
          label: l10n.address,
          value: state.user.address.isEmpty
              ? l10n.notProvided
              : state.user.address,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildVerificationStatus(
      BuildContext context, UserProfileLoaded state, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return ProfileSection(
      title: l10n.verificationStatus,
      icon: Icons.verified_user_outlined,
      isDark: isDark,
      items: [
        _buildVerificationItem(
          context,
          icon: Icons.document_scanner_outlined,
          label: l10n.documentVerification,
          isVerified: state.user.isDocumentVerified,
          verificationScreenPath: UploadDocumentPage.pageName,
          isDark: isDark,
        ),
        _buildVerificationItem(
          context,
          icon: Icons.face_outlined,
          label: l10n.selfieVerification,
          isVerified: state.user.isSelfieVerified,
          verificationScreenPath: SelfieStartPage.pageName,
          isDark: isDark,
        ),
        _buildVerificationItem(
          context,
          icon: Icons.security_outlined,
          label: l10n.livenessVerification,
          isVerified: state.user.isLivenessVerified,
          verificationScreenPath: LivenessDetectionStartPage.pageName,
          isDark: isDark,
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
    required bool isDark,
  }) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
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
              size: 20,
              color: isDark
                  ? AppColorScheme.darkPrimary
                  : AppColorScheme.lightPrimary,
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
                    color: isDark
                        ? AppColorScheme.darkTextSecondary
                        : AppColorScheme.lightTextSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isVerified ? l10n.verified : l10n.notVerified,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColorScheme.darkText
                        : AppColorScheme.lightText,
                  ),
                ),
              ],
            ),
          ),
          if (isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColorScheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified,
                    size: 16,
                    color: AppColorScheme.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.verified,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColorScheme.success,
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
              label: Text(l10n.verifyNowTxt),
              style: FilledButton.styleFrom(
                backgroundColor: isDark
                    ? AppColorScheme.darkPrimary
                    : AppColorScheme.lightPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, UserProfileError state, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColorScheme.lightError,
          ),
          const SizedBox(height: 16),
          Text(
            state.message,
            style: TextStyle(
              color:
                  isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              context.read<UserProfileBloc>().add(LoadUserProfile());
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
            style: FilledButton.styleFrom(
              backgroundColor: isDark
                  ? AppColorScheme.darkPrimary
                  : AppColorScheme.lightPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
