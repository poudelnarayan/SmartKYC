import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smartkyc/core/services/biometric_services.dart';
import 'package:smartkyc/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:smartkyc/features/auth/presentation/pages/sign_up_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'biometric_login_text.dart';

class LoginForm extends StatefulWidget {
  final Function(String, String)? onValuesChanged;

  const LoginForm({super.key, this.onValuesChanged});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: _getInputDecoration(
              label: l10n.emailLabel,
              icon: Icons.email_outlined,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.emailRequired;
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return l10n.invalidEmail;
              }
              return null;
            },
          ).animate().fadeIn().slideX(),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: const TextStyle(color: Colors.white),
            decoration: _getInputDecoration(
              label: l10n.passwordLabel,
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white.withOpacity(0.7),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.passwordRequired;
              }
              if (value.length < 8) {
                return l10n.passwordTooShort;
              }
              return null;
            },
          ).animate().fadeIn().slideX(),
          const SizedBox(height: 16),
          _buildRememberMeAndForgotPassword(context, l10n),
          const SizedBox(height: 10),
          const BiometricLoginText(),
          const SizedBox(height: 20),
          _buildLoginButton(context, l10n, theme),
          const SizedBox(height: 24),
          _buildSignUpLink(context, l10n),
        ],
      ),
    );
  }

  Widget _buildRememberMeAndForgotPassword(
      BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                fillColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.white;
                    }
                    return Colors.white.withOpacity(0.3);
                  },
                ),
                checkColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.rememberMe,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => context.push(ForgotPasswordPage.pageName),
          child: Text(
            l10n.forgotPassword,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildLoginButton(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return FilledButton.icon(
          onPressed: state is AuthLoading
              ? null
              : () async {
                  final String? email = await BiometricService.email;
                  if (email != null && email != _emailController.text) {
                    BiometricService.disableBiometric();
                  }

                  widget.onValuesChanged!(
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (_formKey.currentState?.validate() ?? false) {
                    FocusScope.of(context).unfocus();
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    context.read<AuthBloc>().add(
                          SignInWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          ),
                        );
                  }
                },
          icon: state is AuthLoading
              ? Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(2),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Icon(
                  Icons.person_rounded,
                  color: Colors.blue,
                ),
          label: Text(
            state is AuthLoading ? l10n.signingIn : l10n.signIn,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: state is AuthLoading ? Colors.grey : Colors.blue,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: theme.colorScheme.primary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ).animate().fadeIn().scale();
      },
    );
  }

  Widget _buildSignUpLink(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.noAccount,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        TextButton(
          onPressed: () => context.push(SignUpPage.pageName),
          child: Text(
            l10n.signUp,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  InputDecoration _getInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      prefixIcon: Icon(
        icon,
        color: Colors.white.withOpacity(0.7),
      ),
      errorStyle: const TextStyle(color: Colors.white),
      suffixIcon: suffixIcon,
      border: _getInputBorder(),
      enabledBorder: _getInputBorder(),
      focusedBorder: _getInputBorder(focused: true),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
    );
  }

  InputBorder _getInputBorder({bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: focused ? Colors.white : Colors.white.withOpacity(0.3),
      ),
    );
  }
}
