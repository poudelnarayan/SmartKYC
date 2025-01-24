import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../verification_steps/presentation/widgets/verification_progress_overlay.dart';

class UserDetailFormPage extends StatefulWidget {
  const UserDetailFormPage({super.key});

  @override
  State<UserDetailFormPage> createState() => _UserDetailFormPageState();
}

class _UserDetailFormPageState extends State<UserDetailFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  final Map<String, dynamic> _formData = {
    'licenseNumber': 'DL123456789',
    'firstName': 'Narayan',
    'lastName': 'Poudel',
    'dob': DateTime(1990, 1, 1),
    'fatherName': 'Jeevlal Poudel',
    'citizenshipNumber': 'CTZ123456',
    'phoneNumber': '+9779867513539',
    'issueDate': DateTime.now(),
    'expiryDate': DateTime.now().add(const Duration(days: 365 * 5)),
    'category': null,
  };

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _formData[field] ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              style: const TextStyle(fontSize: 20),
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormSections(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSections(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
            const SizedBox(height: 16),
            _buildDropdownField(
              label: l10n.licenseCategory,
              value: _formData['category'] ?? l10n.categoryB,
              items: [
                l10n.categoryA,
                l10n.categoryB,
                l10n.categoryC,
                l10n.categoryD,
                l10n.categoryE,
              ],
              onChanged: (value) =>
                  setState(() => _formData['category'] = value),
              prefixIcon: Icons.directions_car_outlined,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: l10n.issueDate,
                    value: _formData['issueDate'],
                    onTap: () => _selectDate(context, 'issueDate'),
                    prefixIcon: Icons.event_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    label: l10n.expiryDate,
                    value: _formData['expiryDate'],
                    onTap: () => _selectDate(context, 'expiryDate'),
                    prefixIcon: Icons.event_busy_outlined,
                  ),
                ),
              ],
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
            _buildDateField(
              label: l10n.dateOfBirth,
              value: _formData['dob'],
              onTap: () => _selectDate(context, 'dob'),
              prefixIcon: Icons.cake_outlined,
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
              label: l10n.phoneNumber,
              value: _formData['phoneNumber'],
              onChanged: (value) => _formData['phoneNumber'] = value,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.invalidPhoneNumber;
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
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
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: _getInputDecoration(label, prefixIcon),
      validator: validator ?? _getDefaultValidator(label),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
    required IconData prefixIcon,
  }) {
    return TextFormField(
      readOnly: true,
      onTap: onTap,
      decoration: _getInputDecoration(
        label,
        prefixIcon,
        suffixIcon: Icons.calendar_today_outlined,
      ),
      controller: TextEditingController(
        text: _dateFormat.format(value),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData prefixIcon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: _getInputDecoration(label, prefixIcon),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.requiredField;
        }
        return null;
      },
    );
  }

  InputDecoration _getInputDecoration(
    String label,
    IconData prefixIcon, {
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  String? Function(String?) _getDefaultValidator(String fieldName) {
    return (value) {
      if (value == null || value.isEmpty) {
        return AppLocalizations.of(context)!.pleaseEnter(fieldName);
      }
      return null;
    };
  }

  Widget _buildBottomBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: FilledButton.icon(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (context, _, __) => VerificationProgressOverlay(
                    completedStep: 1,
                    nextRoute: '/selfie-start',
                  ),
                ),
              );
            }
          },
          icon: const Icon(Icons.check_circle_outline),
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
