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

    return AppScaffold(
      showAppBar: false,
      body: Center(
        child: SingleChildScrollView(
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Entrar', style: theme.textTheme.headlineMedium),
                  const Gap.xs(),
                  Text(
                    'Acesse sua carteira digital',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Gap.xl(),
                  AppTextField(
                    key: const Key('login_email'),
                    label: 'E-mail',
                    hint: 'voce@exemplo.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.mail_outline,
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
                    Text(
                      viewModel.errorMessage!,
                      key: const Key('login_error'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const Gap.xl(),
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
      ),
    );
  }
}
