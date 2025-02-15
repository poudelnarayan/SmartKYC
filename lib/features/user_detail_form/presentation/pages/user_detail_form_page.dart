import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smartkyc/l10n/app_localizations.dart';

import 'package:smartkyc/core/extensions/string_extension.dart';
import 'package:smartkyc/core/presentation/widgets/upload_overlay.dart';
import 'package:smartkyc/domain/usecases/get_user.dart';
import 'package:smartkyc/features/selfie_capture/presentation/pages/selfie_start_page.dart';
import 'package:smartkyc/features/user_profile/presentation/pages/user_profile_page.dart';
import '../../../../domain/entities/user.dart';
import '../../../verification_steps/presentation/widgets/verification_progress_overlay.dart';
import '../bloc/user_detail_form_bloc.dart';
import '../bloc/user_detail_form_event.dart';
import '../bloc/user_detail_form_state.dart';

class UserDetailFormPage extends StatefulWidget {
  const UserDetailFormPage({super.key});

  static const pageName = "/userDetailForm";

  @override
  State<UserDetailFormPage> createState() => _UserDetailFormPageState();
}

class _UserDetailFormPageState extends State<UserDetailFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  Map<String, dynamic> _formData = {
    'licenseNumber': 'DL123456789',
    'firstName': 'Narayan',
    'lastName': 'Poudel',
    'dob': '1990-1-1',
    'fatherName': 'Jeevlal Poudel',
    'citizenshipNumber': 'CTZ123456',
    'address': 'Suddhodhan-5 Butwal',
    'gender': 'Male'
  };

  Future<void> _selectDate(BuildContext context, String field) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _formData['dob'] != 'Not found'
          ? DateFormat("dd-MM-yyyy").parse(_formData['dob'])
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Colors.white,
                  surface: isDark ? Colors.grey[850] : Colors.white,
                  onSurface: isDark ? Colors.white : Colors.black,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _formData[field] = picked;
      });
    }
  }

  bool isSelfieVerified = false;
  bool isLivenessVerified = false;

  Future<void> fetchUserData() async {
    final getUser = GetUser();

    try {
      User user = await getUser();

      if (mounted) {
        setState(() {
          isSelfieVerified = user.isSelfieVerified;
          isLivenessVerified = user.isLivenessVerified;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSelfieVerified = false;
          isLivenessVerified = false;
        });
      }
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final extraData = GoRouterState.of(context).extra as Map<String, dynamic>;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Background color
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    setState(() {
      _formData = extraData['userData'];
    });

    return BlocConsumer<UserBloc, UserAndFileState>(
      listener: (context, state) {
        if (state is UserUpdateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state is UserUpdated) {
          final returnToProfile = extraData['returnToProfile'] ?? false;

          if (returnToProfile) {
            context.go(UserProfilePage.pageName);
          }

          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, _, __) =>
                  const VerificationProgressOverlay(
                completedStep: 1,
                nextRoute: SelfieStartPage.pageName,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return state is UserUpdating || state is FileUploading
            ? UploadOverlay(
                title: "Uploading Details",
                message: 'Please wait while we process your details...',
                lottieUrl:
                    'https://lottie.host/7a5f681f-48d9-4af3-9413-a0c09368d996/s3byanoCZ1.json',
                onCancel: () {
                  UploadOverlay.hide(context);
                },
              )
            : SafeArea(
                child: Scaffold(
                  backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
                  appBar: AppBar(
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.assignment_ind,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.licenseDetails,
                          style: TextStyle(
                            fontSize: 20,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    centerTitle: false,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  body: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: FocusScope.of(context).unfocus,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildFormSections(context),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildBottomBar(context, extraData['file']),
                      ],
                    ),
                  ),
                ),
              );
      },
    );
  }

  Widget _buildFormSections(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          context,
          title: l10n.licenseInformation,
          icon: Icons.badge_outlined,
          children: [
            _buildTextField(
              label: l10n.licenseNumber,
              value: _formData['licenseNumber'],
              onChanged: (value) => _formData['licenseNumber'] = value,
              prefixIcon: Icons.credit_card_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.invalidLicenseNumber;
                }
                return null;
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          context,
          title: l10n.personalInformation,
          icon: Icons.person_outline,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: l10n.firstName,
                    value: _formData['firstName'],
                    onChanged: (value) => _formData['firstName'] = value,
                    prefixIcon: Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: l10n.lastName,
                    value: _formData['lastName'],
                    onChanged: (value) => _formData['lastName'] = value,
                    prefixIcon: Icons.person_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildDateField(
                    label: l10n.dateOfBirth,
                    value: _formData['dob'] != 'Not found'
                        ? DateFormat("dd-MM-yyyy").parse(_formData['dob'])
                        : DateTime(0000, 01, 01),
                    onTap: () => _selectDate(context, 'dob'),
                    prefixIcon: Icons.cake_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isDark ? Colors.grey[800] : Colors.grey[50],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _formData['gender'],
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      decoration: InputDecoration(
                        labelText: "Gender",
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[300] : null,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: "Male",
                          child: Row(
                            children: [
                              Icon(
                                Icons.male_rounded,
                                color: isDark ? Colors.grey[400] : Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Male",
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Female",
                          child: Row(
                            children: [
                              Icon(
                                Icons.female_rounded,
                                color: isDark ? Colors.grey[400] : Colors.pink,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Female",
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Other",
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                color:
                                    isDark ? Colors.grey[400] : Colors.purple,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Other",
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _formData['gender'] = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select your gender";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: l10n.fatherName,
              value: _formData['fatherName'],
              onChanged: (value) => _formData['fatherName'] = value,
              prefixIcon: Icons.family_restroom_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: l10n.citizenshipNumber,
              value: _formData['citizenshipNumber'],
              onChanged: (value) => _formData['citizenshipNumber'] = value,
              prefixIcon: Icons.badge_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.invalidCitizenshipNumber;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: "Address".hardcoded,
              value: _formData['address'],
              onChanged: (value) => _formData['address'] = value,
              prefixIcon: Icons.location_city,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Invalid Address".hardcoded;
                }
                return null;
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : null,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.grey[700] : null,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    required IconData prefixIcon,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: _getInputDecoration(label, prefixIcon),
      validator: validator ?? _getDefaultValidator(label),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
    IconData? prefixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      readOnly: true,
      onTap: onTap,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: _getInputDecoration(
        label,
        prefixIcon,
      ),
      controller: TextEditingController(
        text: _dateFormat.format(value),
      ),
    );
  }

  InputDecoration _getInputDecoration(
    String label,
    IconData? prefixIcon, {
    IconData? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[300] : null,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            )
          : null,
      suffixIcon: suffixIcon != null
          ? Icon(
              suffixIcon,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  String? Function(String?) _getDefaultValidator(String fieldName) {
    return (value) {
      if (value == null || value.isEmpty) {
        return AppLocalizations.of(context).pleaseEnter(fieldName);
      }
      return null;
    };
  }

  Widget _buildBottomBar(BuildContext context, file) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: FilledButton.icon(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              final User user = User(
                licenseNumber: _formData['licenseNumber'],
                citizenshipNumber: _formData['citizenshipNumber'],
                dob: _formData['dob'] != 'Not found'
                    ? DateFormat("dd-MM-yyyy").parse(_formData['dob'])
                    : DateTime(0000, 01, 01),
                email: auth.FirebaseAuth.instance.currentUser!.email!,
                fatherName: _formData['fatherName'],
                firstName: _formData['firstName'],
                lastName: _formData['lastName'],
                address: _formData['address'],
                gender: _formData['gender'],
                uid: auth.FirebaseAuth.instance.currentUser!.uid,
                isDocumentVerified: true,
                isEmailVerified:
                    auth.FirebaseAuth.instance.currentUser!.emailVerified,
                isLivenessVerified: isLivenessVerified,
                isSelfieVerified: isSelfieVerified,
              );
              context.read<UserBloc>().add(UpdateUserEvent(user));
              context.read<UserBloc>().add(UpploadFileEvent(file));
            }
          },
          icon: const Icon(
            Icons.check_circle_outline,
          ),
          label: Text(
            l10n.submit,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY();
  }
}
