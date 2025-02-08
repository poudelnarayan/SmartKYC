import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';
import 'package:smartkyc/core/theme/app_color_scheme.dart';

class PhoneVerificationModal extends StatefulWidget {
  final Function(String) onVerificationComplete;
  final bool isEditing;
  final String? previousNumber;

  const PhoneVerificationModal({
    super.key,
    required this.onVerificationComplete,
    this.isEditing = false,
    this.previousNumber = '',
  });

  @override
  State<PhoneVerificationModal> createState() => _PhoneVerificationModalState();
}

class _PhoneVerificationModalState extends State<PhoneVerificationModal> {
  late TextEditingController _phoneController;
  final _auth = FirebaseAuth.instance;
  String? _verificationId;
  bool _isLoading = false;
  bool _isVerifyingOTP = false;
  String? _errorMessage;
  String? _otpCode;

  Timer? _resendTimer;
  int _resendCountdown = 0;
  static const int _resendDelay = 60; // 60 seconds delay

  @override
  void initState() {
    _phoneController = TextEditingController(
      text: widget.previousNumber ?? "",
    );
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = _resendDelay;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _resendTimer?.cancel();
        }
      });
    });
  }

  String _formatPhoneNumber(String number) {
    final cleanNumber = number.trim().replaceAll(' ', '');
    return '+977$cleanNumber';
  }

  Future<void> _sendOTP() async {
    final phoneNumber = _formatPhoneNumber(_phoneController.text);

    if (phoneNumber.length != 14) {
      setState(() => _errorMessage = 'Please enter a valid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (widget.isEditing) {
            await _updatePhoneNumber(credential); // ✅ Directly update
          } else {
            await _linkPhoneNumber(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _errorMessage = e.message ?? 'Verification failed';
            _isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
            _isVerifyingOTP = true;
          });
          _startResendTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePhoneNumber(PhoneAuthCredential credential) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePhoneNumber(credential); // ✅ Firebase Auth update
        await _updateUserData(_formatPhoneNumber(
            _phoneController.text)); // ✅ Update Firestore data
        if (mounted) {
          widget.onVerificationComplete(
              _formatPhoneNumber(_phoneController.text));
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getFirebaseErrorMessage(e.code);
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData(String phoneNumber) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'phoneNumber': phoneNumber, // ✅ Updating Firestore data
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error updating Firestore: $e");
    }
  }

  Future<void> _linkPhoneNumber(PhoneAuthCredential credential) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.linkWithCredential(credential);
        if (mounted) {
          widget.onVerificationComplete(
              _formatPhoneNumber(_phoneController.text));
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getFirebaseErrorMessage(e.code);
        _isLoading = false;
      });
    }
  }

  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-verification-code':
        return 'Invalid OTP code';
      case 'invalid-verification-id':
        return 'Verification failed, please try again';
      case 'credential-already-in-use':
        return 'Phone number already linked to another account';
      case 'too-many-requests':
        return 'Too many attempts, please try again later';
      default:
        return 'Verification failed, please try again';
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpCode == null || _otpCode!.length != 6) {
      setState(() => _errorMessage = 'Please enter a valid OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpCode!,
      );

      if (widget.isEditing) {
        await _updatePhoneNumber(credential); // ✅ Update phone
      } else {
        await _linkPhoneNumber(
            credential); // ✅ Link phone for first-time verification
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: AppColorScheme.getCardBackground(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
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
            if (!_isVerifyingOTP)
              _buildPhoneInput(isDark)
            else
              _buildOTPInput(isDark),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: AppColorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ).animate().fadeIn().shake(),
            const SizedBox(height: 24),
            FilledButton(
              onPressed:
                  _isLoading ? null : (_isVerifyingOTP ? _verifyOTP : _sendOTP),
              style: FilledButton.styleFrom(
                backgroundColor: isDark
                    ? AppColorScheme.darkPrimary
                    : AppColorScheme.lightPrimary,
                foregroundColor:
                    isDark ? AppColorScheme.darkSurface : Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColorScheme.darkSurface : Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      _isVerifyingOTP ? 'Verify OTP' : 'Send OTP',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            if (_isVerifyingOTP)
              TextButton.icon(
                onPressed: _resendCountdown > 0 || _isLoading ? null : _sendOTP,
                icon: Icon(
                  Icons.refresh,
                  size: 18,
                  color: _resendCountdown > 0
                      ? isDark
                          ? AppColorScheme.darkTextSecondary
                          : AppColorScheme.lightTextSecondary
                      : isDark
                          ? AppColorScheme.darkPrimary
                          : AppColorScheme.lightPrimary,
                ),
                label: Text(
                  _resendCountdown > 0
                      ? 'Resend OTP in ${_resendCountdown}s'
                      : 'Resend OTP',
                  style: TextStyle(
                    color: _resendCountdown > 0
                        ? isDark
                            ? AppColorScheme.darkTextSecondary
                            : AppColorScheme.lightTextSecondary
                        : isDark
                            ? AppColorScheme.darkPrimary
                            : AppColorScheme.lightPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isEditing ? 'Edit your number' : 'Verify Phone Number',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.isEditing
              ? 'Enter your phone number to edit'
              : 'Enter your phone number to verify',
          style: TextStyle(
            color: isDark
                ? AppColorScheme.darkTextSecondary
                : AppColorScheme.lightTextSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        Stack(
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              enabled: !_isLoading,
              style: TextStyle(
                color:
                    isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
              ),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(
                  color: isDark
                      ? AppColorScheme.darkTextSecondary
                      : AppColorScheme.lightTextSecondary,
                ),
                hintText: '98XXXXXXXX',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColorScheme.darkTextSecondary.withOpacity(0.5)
                      : AppColorScheme.lightTextSecondary.withOpacity(0.5),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        color: isDark
                            ? AppColorScheme.darkTextSecondary
                            : AppColorScheme.lightTextSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+977',
                        style: TextStyle(
                          color: isDark
                              ? AppColorScheme.darkPrimary
                              : AppColorScheme.lightPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: isDark
                            ? AppColorScheme.darkCardBorder
                            : AppColorScheme.lightCardBorder,
                      ),
                    ],
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColorScheme.darkCardBorder
                        : AppColorScheme.lightCardBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColorScheme.darkCardBorder
                        : AppColorScheme.lightCardBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColorScheme.darkPrimary
                        : AppColorScheme.lightPrimary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: isDark
                    ? AppColorScheme.darkSurface
                    : AppColorScheme.lightSurface,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn().slideY();
  }

  Widget _buildOTPInput(bool isDark) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
      ),
      decoration: BoxDecoration(
        color:
            isDark ? AppColorScheme.darkSurface : AppColorScheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColorScheme.darkCardBorder
              : AppColorScheme.lightCardBorder,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter OTP',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the verification code sent to ${_phoneController.text}',
          style: TextStyle(
            color: isDark
                ? AppColorScheme.darkTextSecondary
                : AppColorScheme.lightTextSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Pinput(
            length: 6,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyWith(
              decoration: defaultPinTheme.decoration!.copyWith(
                border: Border.all(
                  color: isDark
                      ? AppColorScheme.darkPrimary
                      : AppColorScheme.lightPrimary,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark
                            ? AppColorScheme.darkPrimary
                            : AppColorScheme.lightPrimary)
                        .withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            onChanged: (value) => _otpCode = value,
            onCompleted: (value) {
              _otpCode = value;
              _verifyOTP();
            },
          ),
        ),
      ],
    ).animate().fadeIn().slideY();
  }
}
