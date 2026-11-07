import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../main.dart';

/// Filtros, seletor de tipo, linhas de detalhe, cabeçalho de perfil e os
/// diálogos de confirmação.
class FormsPage extends StatefulWidget {
  const FormsPage({super.key});

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  String _filter = 'all';
  TransactionKind _kind = TransactionKind.expense;
  String _lastAnswer = '—';

  Future<void> _confirmDelete() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Excluir lançamento?',
      message: 'Essa ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (!mounted) return;
    setState(() => _lastAnswer = ok ? 'confirmou' : 'cancelou');
  }

  Future<void> _confirmLogout() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Sair da conta?',
      message: 'Você vai precisar entrar de novo.',
      confirmLabel: 'Sair',
      icon: Icons.logout_rounded,
    );
    if (!mounted) return;
    setState(() => _lastAnswer = ok ? 'confirmou' : 'cancelou');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Filtros e detalhes',
      actions: const [ThemeModeButton()],
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          const SectionHeader(title: 'AppChoiceChips'),
          AppChoiceChips<String>(
            options: const [
              (value: 'all', label: 'Todos'),
              (value: 'income', label: 'Entradas'),
              (value: 'expense', label: 'Saídas'),
              (value: 'transfer', label: 'Transferências'),
            ],
            selected: _filter,
            onSelected: (value) => setState(() => _filter = value),
            // A página já tem recuo; no Extrato a linha vai de borda a borda.
            padding: EdgeInsets.zero,
          ),
          const SectionHeader(title: 'TransactionKindSelector'),
          TransactionKindSelector(
            selected: _kind,
            onChanged: (kind) => setState(() => _kind = kind),
          ),
          const Gap.lg(),
          Text(
            'Os três estados (fixos)',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          for (final kind in const [
            TransactionKind.expense,
            TransactionKind.income,
            TransactionKind.transfer,
          ]) ...[
            const Gap.md(),
            TransactionKindSelector(selected: kind, onChanged: (_) {}),
          ],
          const Gap.lg(),
          Text(
            'Desabilitado (enquanto o formulário salva)',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap.md(),
          TransactionKindSelector(
            selected: TransactionKind.expense,
            enabled: false,
            onChanged: (_) {},
          ),
          const SectionHeader(title: 'DetailRow'),
          // 16 de padding + 36 do ícone - 4.
          const AppPanel(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              children: [
                DetailRow(
                  label: 'Data',
                  value: '06/09/2026 14:32',
                  icon: Icons.event_outlined,
                ),
                Divider(indent: 48),
                DetailRow(
                  label: 'Conta',
                  value: 'Nubank',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                Divider(indent: 48),
                DetailRow(
                  label: 'Categoria',
                  value: 'Alimentação',
                  icon: Icons.sell_outlined,
                ),
                Divider(indent: 48),
                DetailRow(
                  label: 'Observação',
                  value:
                      'Um texto comprido que quebra em várias linhas sem '
                      'cortar.',
                  icon: Icons.notes_rounded,
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'ProfileHeader'),
          // Sem heroTag: a galeria nunca repete tags de Hero numa rota.
          const ProfileHeader(
            name: 'Ana Ribeiro',
            email: 'ana@carteira.dev',
            caption: 'Cliente desde março de 2024',
          ),
          const SectionHeader(title: 'showConfirmDialog'),
          AppButton.secondary(
            label: 'Excluir lançamento',
            icon: Icons.delete_outline_rounded,
            destructive: true,
            onPressed: _confirmDelete,
          ),
          const Gap.md(),
          AppButton.secondary(
            label: 'Sair da conta',
            icon: Icons.logout_rounded,
            onPressed: _confirmLogout,
          ),
          const Gap.md(),
          Text(
            'Última resposta: $_lastAnswer',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
