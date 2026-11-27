import 'package:design_system_ponto/design_system.dart';
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
    final muted = context.ds.textSecondary;

    return DsScaffold(
      showAppBar: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: DsSpacing.xl),
          child: ConstrainedBox(
            // Em telas largas o formulário não estica.
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: DsLogoMark()),
                const DsGap.xl(),
                Text('Entrar', style: Theme.of(context).textTheme.headlineSmall),
                const DsGap(6),
                Text(
                  'Acesse sua carteira digital',
                  style: DsTypography.body.copyWith(color: muted),
                ),
                const DsGap.xl(),
                DsCard(
                  padding: const EdgeInsets.all(DsSpacing.lg),
                  // Só o formulário depende do estado do view model.
                  child: ListenableBuilder(
                    listenable: viewModel,
                    builder: (context, _) => AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DsTextField(
                            key: const Key('login_email'),
                            label: 'E-mail',
                            hint: 'voce@exemplo.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            icon: Icons.mail_outline_rounded,
                            autofillHints: const [AutofillHints.email],
                            onChanged: viewModel.onEmailChanged,
                          ),
                          const DsGap.md(),
                          DsPasswordField(
                            key: const Key('login_password'),
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onChanged: viewModel.onPasswordChanged,
                            onSubmitted: (_) => viewModel.submit(),
                          ),
                          if (viewModel.errorMessage != null) ...[
                            const DsGap.md(),
                            DsErrorBanner(
                              viewModel.errorMessage!,
                              textKey: const Key('login_error'),
                            ),
                          ],
                          const DsGap(20),
                          DsButtonFactory.primary(
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
                const DsGap.xl(),
                Text(
                  'Carteira Digital',
                  textAlign: TextAlign.center,
                  style: DsTypography.bodySmall.copyWith(color: muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
