import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../main.dart';

/// Filtros, seletor de tipo, linhas de detalhe, cabeçalho de perfil e o
/// diálogo de confirmação.
class FormsPage extends StatefulWidget {
  const FormsPage({super.key});

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  String _filter = 'all';
  TransactionKind _kind = TransactionKind.expense;
  String _lastAnswer = '—';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Filtros e detalhes',
      actions: const [ThemeModeButton()],
      body: ListView(
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
          ),
          const SectionHeader(title: 'TransactionKindSelector'),
          TransactionKindSelector(
            selected: _kind,
            onChanged: (kind) => setState(() => _kind = kind),
          ),
          const SectionHeader(title: 'DetailRow'),
          const DetailRow(
            label: 'Data',
            value: '06/09/2026 14:32',
            icon: Icons.event_outlined,
          ),
          const DetailRow(
            label: 'Conta',
            value: 'Nubank',
            icon: Icons.account_balance_wallet_outlined,
          ),
          const DetailRow(
            label: 'Observação',
            value: 'Um texto comprido que quebra em várias linhas sem cortar.',
            icon: Icons.notes_outlined,
          ),
          const SectionHeader(title: 'ProfileHeader'),
          const ProfileHeader(
            name: 'Ana Ribeiro',
            email: 'ana@carteira.dev',
            caption: 'Cliente desde março de 2024',
          ),
          const SectionHeader(title: 'showConfirmDialog'),
          AppButton.secondary(
            label: 'Excluir lançamento',
            icon: Icons.delete_outline,
            onPressed: () async {
              final ok = await showConfirmDialog(
                context,
                title: 'Excluir lançamento?',
                message: 'Essa ação não pode ser desfeita.',
                confirmLabel: 'Excluir',
                destructive: true,
              );
              setState(() => _lastAnswer = ok ? 'confirmou' : 'cancelou');
            },
          ),
          const Gap.sm(),
          Text('Última resposta: $_lastAnswer'),
          const Gap.xl(),
        ],
      ),
    );
  }
}
