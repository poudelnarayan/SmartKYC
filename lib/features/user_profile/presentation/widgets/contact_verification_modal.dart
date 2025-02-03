import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class ContactVerificationModal extends StatefulWidget {
  final String type; // 'email' or 'phone'
  final String currentValue;
  final Function(String) onVerified;

  const ContactVerificationModal({
    super.key,
    required this.type,
    required this.currentValue,
    required this.onVerified,
  });

  @override
  State<ContactVerificationModal> createState() =>
      _ContactVerificationModalState();
}

class _ContactVerificationModalState extends State<ContactVerificationModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId;
  int? _resendToken;
  bool _isVerifyingOTP = false;
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.type == 'email') {
        await _verifyEmail();
      } else {
        await _verifyPhone();
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyEmail() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    try {
      await user.verifyBeforeUpdateEmail(_controller.text);
    } catch (e) {
      print(e.toString());
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification email sent to ${_controller.text}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _verifyPhone() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _controller.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _updatePhoneNumber(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _errorMessage = e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isVerifyingOTP = true;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() => _verificationId = verificationId);
      },
      forceResendingToken: _resendToken,
    );
  }

  Future<void> _verifyOTP() async {
    if (_verificationId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );

      await _updatePhoneNumber(credential);
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP';
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePhoneNumber(PhoneAuthCredential credential) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      await user.updatePhoneNumber(credential);

      if (mounted) {
        widget.onVerified(_controller.text);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isVerifyingOTP
                      ? 'Enter Verification Code'
                      : widget.type == 'email'
                          ? l10n.updateEmail
                          : l10n.updatePhone,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isVerifyingOTP
                      ? 'Enter the code sent to ${_controller.text}'
                      : widget.type == 'email'
                          ? l10n.updateEmailDesc
                          : l10n.updatePhoneDesc,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                if (_isVerifyingOTP)
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the verification code';
                      }
                      return null;
                    },
                  )
                else
                  TextFormField(
                    controller: _controller,
                    keyboardType: widget.type == 'email'
                        ? TextInputType.emailAddress
                        : TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: widget.type == 'email'
                          ? l10n.emailLabel
                          : l10n.phoneLabel,
                      prefixIcon: Icon(
                        widget.type == 'email'
                            ? Icons.email_outlined
                            : Icons.phone_outlined,
                      ),
                      errorText: _errorMessage,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.fieldRequired;
                      }
                      if (widget.type == 'email') {
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return l10n.invalidEmail;
                        }
                      } else {
                        if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value)) {
                          return l10n.invalidPhone;
                        }
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading
                        ? null
                        : _isVerifyingOTP
                            ? _verifyOTP
                            : _verifyContact,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_isVerifyingOTP ? 'Verify Code' : l10n.update),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
