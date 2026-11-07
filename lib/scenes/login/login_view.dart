import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'login_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({required this.viewModel, super.key});

  final LoginViewModel viewModel;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return AppScaffold(
      showAppBar: false,
      // Brilho aqua atrás do logo.
      spotlight: true,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: ConstrainedBox(
            // Em telas largas o formulário não estica.
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AppLogoMark(spark: true)),
                const Gap.xl(),
                Text('Entrar', style: theme.textTheme.headlineMedium),
                const Gap(6),
                Text(
                  'Acesse sua carteira digital',
                  style: theme.textTheme.bodyLarge?.copyWith(color: muted),
                ),
                const Gap.xl(),
                AppPanel(
                  radius: AppRadius.xl,
                  padding: const EdgeInsets.all(AppSpacing.panel),
                  // Só o formulário depende do estado do view model.
                  child: ListenableBuilder(
                    listenable: viewModel,
                    builder: (context, _) => AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            key: const Key('login_email'),
                            label: 'E-mail',
                            hint: 'voce@exemplo.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.mail_outline_rounded,
                            autofillHints: const [AutofillHints.email],
                            onChanged: viewModel.onEmailChanged,
                          ),
                          const Gap.md(),
                          PasswordField(
                            key: const Key('login_password'),
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onChanged: viewModel.onPasswordChanged,
                            onSubmitted: (_) => viewModel.submit(),
                          ),
                          if (viewModel.errorMessage != null) ...[
                            const Gap.md(),
                            AppErrorBanner(
                              viewModel.errorMessage!,
                              textKey: const Key('login_error'),
                            ),
                          ],
                          const Gap(20),
                          AppButton(
                            key: const Key('login_submit'),
                            label: 'Entrar',
                            isLoading: viewModel.isLoading,
                            onPressed: viewModel.submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap.xl(),
                Text(
                  'Carteira Digital',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
