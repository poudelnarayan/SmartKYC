import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class UserDetailFormPage extends StatefulWidget {
  const UserDetailFormPage({super.key});

  @override
  State<UserDetailFormPage> createState() => _UserDetailFormPageState();
}

class _UserDetailFormPageState extends State<UserDetailFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  // Pre-populated dummy data
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
    'category': 'B - Light Vehicles',
  };

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _formData[field] ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        _formData[field] = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('License Details'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              ..._buildFormFields(context),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    context.go('/selfie-start');
                  }
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ).animate().fadeIn().slideY(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_ind,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Driver\'s License Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please verify your information below',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  List<Widget> _buildFormFields(BuildContext context) {
    return [
      _buildTextField(
        label: 'License Number',
        value: _formData['licenseNumber'],
        onChanged: (value) => _formData['licenseNumber'] = value,
      ),
      _buildTextField(
        label: 'First Name',
        value: _formData['firstName'],
        onChanged: (value) => _formData['firstName'] = value,
      ),
      _buildTextField(
        label: 'Last Name',
        value: _formData['lastName'],
        onChanged: (value) => _formData['lastName'] = value,
      ),
      _buildDateField(
        label: 'Date of Birth',
        value: _formData['dob'],
        onTap: () => _selectDate(context, 'dob'),
      ),
      _buildTextField(
        label: 'Father\'s Name',
        value: _formData['fatherName'],
        onChanged: (value) => _formData['fatherName'] = value,
      ),
      _buildTextField(
        label: 'Citizenship Number',
        value: _formData['citizenshipNumber'],
        onChanged: (value) => _formData['citizenshipNumber'] = value,
      ),
      _buildTextField(
        label: 'Phone Number',
        value: _formData['phoneNumber'],
        onChanged: (value) => _formData['phoneNumber'] = value,
        keyboardType: TextInputType.phone,
      ),
      _buildDateField(
        label: 'Date of Issue',
        value: _formData['issueDate'],
        onTap: () => _selectDate(context, 'issueDate'),
      ),
      _buildDateField(
        label: 'Date of Expiry',
        value: _formData['expiryDate'],
        onTap: () => _selectDate(context, 'expiryDate'),
      ),
      _buildDropdownField(
        label: 'License Category',
        value: _formData['category'],
        items: const [
          'A - Motorcycles',
          'B - Light Vehicles',
          'C - Heavy Vehicles',
          'D - Public Transport',
          'E - Heavy Trailers',
        ],
        onChanged: (value) => setState(() => _formData['category'] = value),
      ),
    ].animate(interval: const Duration(milliseconds: 100)).fadeIn().slideX();
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        controller: TextEditingController(
          text: _dateFormat.format(value),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}
