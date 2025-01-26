import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class EmailInput extends StatefulWidget {
  const EmailInput({super.key});

  @override
  State<EmailInput> createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isHovered = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 48),
            // Logo/Icon with animated background
            Center(
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated background circles
                    if (_isHovered)
                      ...List.generate(3, (index) {
                        return Container(
                          width: 120 + (index * 30),
                          height: 120 + (index * 30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                Colors.white.withOpacity(0.1 - (index * 0.03)),
                          ),
                        )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .scale(
                              duration: Duration(seconds: 1 + index),
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1.2, 1.2),
                            );
                      }),
                    // Main icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 48,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().scale(),
            const SizedBox(height: 32),
            // Welcome text
            Text(
              l10n.welcomeTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn().slideY(),
            const SizedBox(height: 8),
            Text(
              l10n.welcomeSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn().slideY(),
            const SizedBox(height: 48),
            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: l10n.emailLabel,
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: Colors.white.withOpacity(0.7),
                ),
                border: _getInputBorder(),
                enabledBorder: _getInputBorder(),
                focusedBorder: _getInputBorder(focused: true),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
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
            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: l10n.passwordLabel,
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white.withOpacity(0.7),
                ),
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
                border: _getInputBorder(),
                enabledBorder: _getInputBorder(),
                focusedBorder: _getInputBorder(focused: true),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
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
            // Remember me and Forgot password
            Row(
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
                        checkColor: theme.colorScheme.primary,
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
                  onPressed: () {
                    context.push('/forgot-password');
                  },
                  child: Text(
                    l10n.forgotPassword,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ).animate().fadeIn(),
            const SizedBox(height: 32),
            // Sign in button
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return FilledButton.icon(
                  onPressed: state is AuthLoading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
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
                      : const Icon(Icons.login_rounded),
                  label: Text(
                    l10n.signIn,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
            ),
            const SizedBox(height: 24),
            // Sign up link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.noAccount,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/sign-up');
                  },
                  child: Text(
                    l10n.signUp,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(),
          ],
        ),
      ),
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
