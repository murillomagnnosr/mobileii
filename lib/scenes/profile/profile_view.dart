import 'package:design_system_ponto/design_system.dart';
import 'package:flutter/material.dart';

import 'profile_view_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({required this.viewModel, super.key});

  final ProfileViewModel viewModel;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Preenche o campo quando o perfil chega.
    widget.viewModel.load().then((_) {
      if (mounted) _name.text = widget.viewModel.name;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  static const _themes = <ChipOption<ThemeMode>>[
    (value: ThemeMode.light, label: 'Claro'),
    (value: ThemeMode.dark, label: 'Escuro'),
    (value: ThemeMode.system, label: 'Sistema'),
  ];

  Future<void> _confirmLogout() async {
    // Sair é reversível: diálogo neutro, com confirmação na cor primária.
    final confirmed = await showDsConfirmDialog(
      context,
      title: 'Sair da conta?',
      message: 'Você vai precisar entrar de novo.',
      confirmLabel: 'Sair',
      icon: Icons.logout_rounded,
    );
    if (confirmed) await widget.viewModel.logout();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return DsScaffold(
      title: 'Perfil',
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) return const DsStateView.loading();
          if (viewModel.errorMessage != null) {
            return DsStateView.error(
              message: viewModel.errorMessage!,
              onRetry: viewModel.load,
            );
          }
          return ListView(
            children: [
              DsProfileHeader(
                name: viewModel.name,
                email: viewModel.email,
                avatarUrl: viewModel.avatarUrl,
                caption: viewModel.memberSince,
              ),
              const DsSectionHeader(title: 'Dados'),
              DsCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DsTextField(
                      key: const Key('profile_name'),
                      label: 'Nome',
                      controller: _name,
                      icon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      errorText: viewModel.nameError,
                      helperText: viewModel.savedMessage,
                      onChanged: viewModel.onNameChanged,
                      onSubmitted: (_) => viewModel.saveName(),
                    ),
                    const DsGap.md(),
                    DsButtonFactory.primary(
                      key: const Key('profile_save'),
                      label: 'Salvar nome',
                      isLoading: viewModel.isSaving,
                      onPressed: viewModel.saveName,
                    ),
                  ],
                ),
              ),
              const DsSectionHeader(title: 'Aparência'),
              DsChoiceChips<ThemeMode>(
                options: _themes,
                selected: viewModel.themeMode,
                onSelected: viewModel.onThemeModeChanged,
              ),
              const DsGap.xxl(),
              DsButtonFactory.secondary(
                key: const Key('profile_logout'),
                label: 'Sair da conta',
                icon: Icons.logout_rounded,
                isLoading: viewModel.isLoggingOut,
                onPressed: _confirmLogout,
              ),
              const DsGap.lg(),
              Text(
                'Carteira Digital 1.0',
                textAlign: TextAlign.center,
                style: DsTypography.bodySmall.copyWith(
                  color: context.ds.textSecondary,
                ),
              ),
              const DsGap.xl(),
            ],
          );
        },
      ),
    );
  }
}
