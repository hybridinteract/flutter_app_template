import 'package:app_template/core/extensions/context_extensions.dart';
import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/routes/route_names.dart';
import 'package:app_template/core/theme/app_dimensions.dart';
import 'package:app_template/core/utils/helpers.dart';
import 'package:app_template/core/utils/validators.dart';
import 'package:app_template/core/widgets/app_button.dart';
import 'package:app_template/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_bloc.dart';
import '../controllers/auth_event.dart';
import '../controllers/auth_state.dart';
import 'widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    AppHelpers.hideKeyboard(context);
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _onStateChanged(BuildContext context, AuthState state) {
    if (!context.isCurrentRoute) return;
    if (state is AuthFailure) {
      context.showSnackBar(state.message, isError: true);
    } else if (state is AuthVerificationRequired) {
      // Signed up but never verified: a fresh code was just sent.
      if (state.message != null) context.showSnackBar(state.message!);
      context.push(RouteNames.verifyEmailPath(state.email));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: _onStateChanged,
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AuthHeader(
                          title: l10n.authWelcomeBack,
                          subtitle: l10n.authSignInSubtitle,
                          icon: Icons.lock_outline_rounded,
                        ),
                        const SizedBox(height: AppDimensions.spacingXl),
                        AppTextField(
                          controller: _emailController,
                          label: l10n.commonEmail,
                          hint: l10n.commonEmailHint,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (value) => Validators.email(
                            value,
                            requiredMessage: l10n.validationEmailRequired,
                            message: l10n.validationEmailInvalid,
                          ),
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        AppTextField(
                          controller: _passwordController,
                          label: l10n.commonPassword,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) => Validators.required(
                            value,
                            message: l10n.validationPasswordRequired,
                          ),
                          enabled: !isLoading,
                          onSubmitted: (_) => _onLoginPressed(),
                        ),
                        const SizedBox(height: AppDimensions.spacingLg),
                        AppButton(
                          text: l10n.authSignIn,
                          isLoading: isLoading,
                          onPressed: _onLoginPressed,
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.authNoAccount,
                              style: context.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context.push(RouteNames.register),
                              child: Text(l10n.authSignUp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
