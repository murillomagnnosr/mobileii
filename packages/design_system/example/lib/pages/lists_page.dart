import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  static const _tiles = [
    (TransactionKind.expense, 'Mercado', 'Alimentação · Nubank', 'R\$ 89,90'),
    (TransactionKind.income, 'Salário', 'Salário · Itaú', 'R\$ 8.500,00'),
    (
      TransactionKind.transfer,
      'Reserva de emergência',
      'Nubank → Itaú',
      'R\$ 1.000,00',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Listas',
      actions: const [ThemeModeButton()],
      padded: false,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          AppSpacing.xxl,
        ),
        children: [
          const SectionHeader(title: 'BalanceCard'),
          const BalanceCard(
            balance: 'R\$ 5.289,55',
            income: 'R\$ 8.500,00',
            expense: 'R\$ 3.210,45',
            monthLabel: 'Setembro 2026',
          ),
          const SectionHeader(title: 'MoneyText'),
          const Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              MoneyText('R\$ 12,50', size: MoneySize.small),
              MoneyText('R\$ 12,50', tone: MoneyTone.income, signed: true),
              MoneyText(
                'R\$ 12,50',
                tone: MoneyTone.expense,
                size: MoneySize.large,
                signed: true,
              ),
            ],
          ),
          // Home: floating capsules with the staggered entrance.
          const SectionHeader(title: 'Cápsulas'),
          for (final (index, (kind, title, subtitle, amount))
              in _tiles.indexed) ...[
            if (index > 0) const Gap.sm(),
            TransactionTile(
              kind: kind,
              title: title,
              subtitle: subtitle,
              amount: amount,
              capsule: true,
              entranceIndex: index,
              onTap: () {},
            ),
          ],
          // Extrato: one glass panel with inset dividers.
          const SectionHeader(title: 'Painel com divisores'),
          AppPanel(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              children: [
                for (final (kind, title, subtitle, amount) in _tiles) ...[
                  TransactionTile(
                    kind: kind,
                    title: title,
                    subtitle: subtitle,
                    amount: amount,
                    onTap: () {},
                  ),
                  // 16 tile padding + 44 orb + 16 gap.
                  const Divider(indent: 76, endIndent: 16),
                ],
                const TransactionTile(
                  kind: TransactionKind.expense,
                  title:
                      'Um título comprido o bastante para ser cortado com '
                      'reticências',
                  subtitle: 'Sem categoria',
                  amount: 'R\$ 1.234.567,89',
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'CategoryBar'),
          const AppPanel(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.panel,
              vertical: 10,
            ),
            child: Column(
              children: [
                CategoryBar(
                  label: 'Alimentação',
                  amount: 'R\$ 702,20',
                  share: 0.38,
                ),
                CategoryBar(label: 'Moradia', amount: 'R\$ 1.850,00', share: 1),
                CategoryBar(
                  label: 'Uma categoria com nome comprido demais',
                  amount: 'R\$ 12,00',
                  share: 0.02,
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'EmptyDivider'),
          const EmptyDivider(),
          SectionHeader(
            title: 'Hoje',
            actionLabel: 'Ver todos',
            onAction: () {},
          ),
        ],
      ),
    );
  }
}
