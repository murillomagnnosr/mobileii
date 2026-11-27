import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class InputsPage extends StatefulWidget {
  const InputsPage({super.key});

  @override
  State<InputsPage> createState() => _InputsPageState();
}

class _InputsPageState extends State<InputsPage> {
  // Pre-filled so the "R$ " prefix and the strength meter show at rest.
  final _money = TextEditingController(text: '1.234,56');
  final _password = TextEditingController(text: 'Carteira#2026');

  @override
  void dispose() {
    _money.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final moneyStyle = AppTypography.moneyInput.copyWith(color: onSurface);
    const decimal = TextInputType.numberWithOptions(decimal: true);

    return AppScaffold(
      title: 'Campos',
      actions: const [ThemeModeButton()],
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          const SectionHeader(title: 'AppTextField'),
          const AppTextField(
            label: 'E-mail',
            hint: 'voce@exemplo.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline_rounded,
          ),
          const Gap.md(),
          // Focused on open: primary border, bold floating label and hint.
          const AppTextField(
            label: 'Com foco',
            hint: 'A dica aparece com o foco',
            prefixIcon: Icons.short_text_rounded,
            autofocus: true,
          ),
          const Gap.md(),
          const AppTextField(
            label: 'Com erro',
            errorText: 'Informe um e-mail válido',
            prefixIcon: Icons.mail_outline_rounded,
          ),
          const Gap.md(),
          const AppTextField(
            label: 'Com ajuda',
            helperText: 'Opcional',
            prefixIcon: Icons.notes_rounded,
            maxLines: 3,
          ),
          const Gap.md(),
          const AppTextField(label: 'Desabilitado', enabled: false),
          const SectionHeader(title: 'Busca (pill)'),
          const AppTextField(
            label: 'Buscar',
            hint: 'Descrição do lançamento',
            prefixIcon: Icons.search_rounded,
            pill: true,
          ),
          const SectionHeader(title: 'Valor (moneyInput)'),
          AppTextField(
            label: 'Valor',
            hint: '0,00',
            prefixText: 'R\$ ',
            style: moneyStyle,
            keyboardType: decimal,
          ),
          const Gap.md(),
          AppTextField(
            label: 'Valor',
            controller: _money,
            prefixText: 'R\$ ',
            style: moneyStyle,
            keyboardType: decimal,
          ),
          const SectionHeader(title: 'PasswordField'),
          const PasswordField(),
          const Gap.md(),
          PasswordField(
            label: 'Nova senha',
            controller: _password,
            showStrength: true,
          ),
          const SectionHeader(title: 'AppErrorBanner'),
          const AppErrorBanner('Informe e-mail e senha.'),
          const SectionHeader(title: 'AppAvatar'),
          const Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppAvatar(name: 'Ana Ribeiro', size: 32),
              AppAvatar(name: 'Ana Ribeiro'),
              AppAvatar(name: 'Bruno Costa', size: 56),
              AppAvatar(
                name: 'Ana Ribeiro',
                size: 72,
                imageUrl: 'https://i.pravatar.cc/150?img=47',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
