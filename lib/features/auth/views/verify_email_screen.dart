import 'package:app_template/core/constants/app_constants.dart';
import 'package:app_template/core/extensions/context_extensions.dart';
import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/theme/app_dimensions.dart';
import 'package:app_template/core/utils/helpers.dart';
import 'package:app_template/core/utils/validators.dart';
import 'package:app_template/core/widgets/app_button.dart';
import 'package:app_template/core/widgets/app_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../controllers/auth_bloc.dart';
import '../controllers/auth_event.dart';
import '../controllers/auth_state.dart';
import 'widgets/auth_header.dart';

/// Enter the emailed code. Opened after signup, or after a login refused
/// because the email was never verified. Success signs the user in, and the
/// router's redirect then leaves this public route for home.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    // Against a local backend with AUTH_EXPOSE_DEV_CODES=true the code comes
    // back in the response; prefill it. Always null in production.
    _prefillDevCode(context.read<AuthBloc>().state);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _prefillDevCode(AuthState state) {
    final devCode = switch (state) {
      AuthVerificationRequired(:final email, :final devCode)
          when email == widget.email =>
        devCode,
      AuthVerificationCodeResent(:final email, :final devCode)
          when email == widget.email =>
        devCode,
      _ => null,
    };
    if (devCode != null) _codeController.text = devCode;
  }

  void _onVerifyPressed() {
    AppHelpers.hideKeyboard(context);
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        VerifyEmailRequested(
          email: widget.email,
          code: _codeController.text.trim(),
        ),
      );
    }
  }

  void _onResendPressed() {
    context.read<AuthBloc>().add(
      ResendVerificationRequested(email: widget.email),
    );
  }

  void _onStateChanged(BuildContext context, AuthState state) {
    if (!context.isCurrentRoute) return;
    if (state is AuthFailure) {
      context.showSnackBar(state.message, isError: true);
    } else if (state is AuthVerificationCodeResent) {
      _prefillDevCode(state);
      context.showSnackBar(context.l10n.authCodeResent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authVerifyEmailTitle)),
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
                          title: l10n.authVerifyEmailTitle,
                          subtitle: l10n.authVerifyEmailSubtitle(widget.email),
                          icon: Icons.mark_email_read_outlined,
                        ),
                        const SizedBox(height: AppDimensions.spacingXl),
                        AppTextField(
                          controller: _codeController,
                          label: l10n.authVerificationCode,
                          hint: l10n.authVerificationCodeHint,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          prefixIcon: const Icon(Icons.pin_outlined),
                          validator: (value) => Validators.lengthBetween(
                            value,
                            AppConstants.minVerificationCodeLength,
                            AppConstants.maxVerificationCodeLength,
                            requiredMessage: l10n.validationRequired,
                            message: l10n.validationLengthBetween(
                              AppConstants.minVerificationCodeLength,
                              AppConstants.maxVerificationCodeLength,
                            ),
                          ),
                          enabled: !isLoading,
                          onSubmitted: (_) => _onVerifyPressed(),
                        ),
                        const SizedBox(height: AppDimensions.spacingLg),
                        AppButton(
                          text: l10n.authVerify,
                          isLoading: isLoading,
                          onPressed: _onVerifyPressed,
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              l10n.authNoCode,
                              style: context.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: isLoading ? null : _onResendPressed,
                              child: Text(l10n.authResendCode),
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
