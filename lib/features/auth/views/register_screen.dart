import 'package:app_template/core/constants/app_constants.dart';
import 'package:app_template/core/extensions/context_extensions.dart';
import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/routes/route_names.dart';
import 'package:app_template/core/theme/app_dimensions.dart';
import 'package:app_template/core/utils/helpers.dart';
import 'package:app_template/core/utils/validators.dart';
import 'package:app_template/core/widgets/app_button.dart';
import 'package:app_template/core/widgets/app_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../controllers/auth_bloc.dart';
import '../controllers/auth_event.dart';
import '../controllers/auth_state.dart';
import '../models/account_type.dart';
import 'widgets/account_type_selector.dart';
import 'widgets/auth_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _organisationController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  AccountType _accountType = AccountType.influencer;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _organisationController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _organisationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    AppHelpers.hideKeyboard(context);
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        RegisterRequested(
          accountType: _accountType,
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          organisation: _organisationController.text.trim(),
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
      context.push(RouteNames.verifyEmailPath(state.email));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBrand = _accountType == AccountType.organization;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authCreateAccount)),
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
                          title: l10n.authGetStarted,
                          subtitle: l10n.authRegisterSubtitle,
                          icon: Icons.person_add_outlined,
                        ),
                        const SizedBox(height: AppDimensions.spacingXl),
                        AccountTypeSelector(
                          selected: _accountType,
                          enabled: !isLoading,
                          onChanged: (type) =>
                              setState(() => _accountType = type),
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        AppTextField(
                          controller: _nameController,
                          label: l10n.authFullName,
                          hint: l10n.authFullNameHint,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (value) => Validators.lengthBetween(
                            value,
                            AppConstants.minFullNameLength,
                            AppConstants.maxFullNameLength,
                            requiredMessage: l10n.validationRequired,
                            message: l10n.validationLengthBetween(
                              AppConstants.minFullNameLength,
                              AppConstants.maxFullNameLength,
                            ),
                          ),
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
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
                        // One backend field, two meanings: the business name
                        // for a brand, the social handle for a creator.
                        AppTextField(
                          controller: _organisationController,
                          label: isBrand
                              ? l10n.authOrganizationName
                              : l10n.authSocialHandle,
                          hint: isBrand
                              ? l10n.authOrganizationNameHint
                              : l10n.authSocialHandleHint,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icon(
                            isBrand
                                ? Icons.business_outlined
                                : Icons.alternate_email,
                          ),
                          validator: (value) => Validators.lengthBetween(
                            value,
                            AppConstants.minOrganisationLength,
                            AppConstants.maxOrganisationLength,
                            requiredMessage: l10n.validationRequired,
                            message: l10n.validationLengthBetween(
                              AppConstants.minOrganisationLength,
                              AppConstants.maxOrganisationLength,
                            ),
                          ),
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        AppTextField(
                          controller: _passwordController,
                          label: l10n.commonPassword,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
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
                          validator: (value) => Validators.strongPassword(
                            value,
                            requiredMessage: l10n.validationPasswordRequired,
                            tooShortMessage: l10n.validationPasswordTooShort(
                              AppConstants.minPasswordLength,
                            ),
                            tooLongMessage: l10n.validationPasswordTooLong(
                              AppConstants.maxPasswordLength,
                            ),
                            weakMessage: l10n.validationPasswordWeak,
                          ),
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        AppTextField(
                          controller: _confirmPasswordController,
                          label: l10n.authConfirmPassword,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.lock_clock_outlined),
                          validator: (value) => Validators.confirmPassword(
                            value,
                            _passwordController.text,
                            requiredMessage:
                                l10n.validationConfirmPasswordRequired,
                            message: l10n.validationPasswordsDoNotMatch,
                          ),
                          enabled: !isLoading,
                          onSubmitted: (_) => _onRegisterPressed(),
                        ),
                        const SizedBox(height: AppDimensions.spacingLg),
                        AppButton(
                          text: l10n.authSignUp,
                          isLoading: isLoading,
                          onPressed: _onRegisterPressed,
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.authHaveAccount,
                              style: context.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: isLoading ? null : () => context.pop(),
                              child: Text(l10n.authSignIn),
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
