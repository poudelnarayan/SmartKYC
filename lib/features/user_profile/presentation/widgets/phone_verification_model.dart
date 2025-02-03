import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';

class PhoneVerificationModal extends StatefulWidget {
  final Function(String) onVerificationComplete;

  const PhoneVerificationModal({
    super.key,
    required this.onVerificationComplete,
  });

  @override
  State<PhoneVerificationModal> createState() => _PhoneVerificationModalState();
}

class _PhoneVerificationModalState extends State<PhoneVerificationModal> {
  final _phoneController = TextEditingController();
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

    if (phoneNumber.length < 13) {
      // +977 + 9 digits
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
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification completed (rare on Android, never on iOS)
          _verifyWithCredential(credential);
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

  Future<void> _verifyWithCredential(PhoneAuthCredential credential) async {
    try {
      // // Only verify the phone number without signing in
      // await _auth.signInWithCredential(credential);
      // await _auth.signOut(); // Immediately sign out

      if (mounted) {
        widget
            .onVerificationComplete(_formatPhoneNumber(_phoneController.text));
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed: ${e.toString()}';
        _isLoading = false;
      });
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
      await _verifyWithCredential(credential);
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (!_isVerifyingOTP) _buildPhoneInput() else _buildOTPInput(),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ).animate().fadeIn().shake(),
            const SizedBox(height: 24),
            FilledButton(
              onPressed:
                  _isLoading ? null : (_isVerifyingOTP ? _verifyOTP : _sendOTP),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                      ? Colors.grey
                      : Theme.of(context).colorScheme.primary,
                ),
                label: Text(
                  _resendCountdown > 0
                      ? 'Resend OTP in ${_resendCountdown}s'
                      : 'Resend OTP',
                  style: TextStyle(
                    color: _resendCountdown > 0
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verify Phone Number',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your phone number to verify',
          style: TextStyle(
            color: Colors.grey[600],
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
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '98XXXXXXXX',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_outlined),
                      const SizedBox(width: 8),
                      Text(
                        '+977',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.grey[300],
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
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn().slideY();
  }

  Widget _buildOTPInput() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter OTP',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the verification code sent to ${_phoneController.text}',
          style: TextStyle(
            color: Colors.grey[600],
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
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
