import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../main.dart';

/// Protótipos navegáveis das telas do app, montados só com componentes do
/// design system e dados fixos. Servem de referência para as cenas reais em
/// `lib/scenes/` e para validar o layout antes de ligar na API.
class PrototypesPage extends StatelessWidget {
  const PrototypesPage({super.key});

  static final _screens = <({String title, String route, Widget page})>[
    (title: 'Login', route: 'POST /auth/login', page: const _LoginPrototype()),
    (
      title: 'Home',
      route: 'GET /me · /summary · /transactions',
      page: const _HomePrototype(),
    ),
    (
      title: 'Extrato',
      route: 'GET /transactions?type&q&page',
      page: const _StatementPrototype(),
    ),
    (
      title: 'Detalhe do lançamento',
      route: 'GET · DELETE /transactions/:id',
      page: const _DetailPrototype(),
    ),
    (
      title: 'Novo lançamento',
      route: 'POST · PUT /transactions',
      page: const _FormPrototype(),
    ),
    (
      title: 'Perfil',
      route: 'GET · PUT /me, /auth/logout',
      page: const _ProfilePrototype(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Protótipos de telas',
      actions: const [ThemeModeButton()],
      padded: false,
      body: ListView.separated(
        itemCount: _screens.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final screen = _screens[index];
          return ListTile(
            title: Text(screen.title),
            subtitle: Text(screen.route),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => screen.page)),
          );
        },
      ),
    );
  }
}

// Dados de exemplo compartilhados pelos protótipos.
const _tiles = [
  (
    TransactionKind.expense,
    'Mercado Pão de Açúcar',
    'R\$ 306,70',
    '27/10 · Nubank',
  ),
  (TransactionKind.income, 'Salário', 'R\$ 9.526,55', '25/10 · Itaú'),
  (TransactionKind.transfer, 'Reserva', 'R\$ 500,00', '20/10 · Nubank → Itaú'),
  (TransactionKind.expense, 'Mercado', 'R\$ 89,90', '06/10 · Nubank'),
  (TransactionKind.expense, 'Aluguel', 'R\$ 4.813,44', '05/10 · Itaú'),
];

List<Widget> _tileWidgets(BuildContext context) => [
  for (final (kind, title, amount, subtitle) in _tiles)
    TransactionTile(
      kind: kind,
      title: title,
      amount: amount,
      subtitle: subtitle,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const _DetailPrototype())),
    ),
];

class _LoginPrototype extends StatelessWidget {
  const _LoginPrototype();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Protótipo: Login',
      body: Center(
        child: SingleChildScrollView(
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
              const AppTextField(
                label: 'E-mail',
                hint: 'voce@exemplo.com',
                prefixIcon: Icons.mail_outline,
              ),
              const Gap.md(),
              const PasswordField(),
              const Gap.xl(),
              AppButton(label: 'Entrar', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomePrototype extends StatelessWidget {
  const _HomePrototype();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Carteira',
      padded: false,
      actions: [
        IconButton(
          tooltip: 'Perfil',
          icon: const AppAvatar(name: 'Ana Ribeiro', size: 32),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const _ProfilePrototype()),
          ),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo lançamento',
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const _FormPrototype())),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap.md(),
                Text('Olá, Ana', style: theme.textTheme.titleLarge),
                const Gap.md(),
                const BalanceCard(
                  balance: 'R\$ 4.196,51',
                  income: 'R\$ 9.526,55',
                  expense: 'R\$ 5.330,04',
                  monthLabel: 'Outubro de 2026',
                ),
                SectionHeader(
                  title: 'Últimos lançamentos',
                  actionLabel: 'Ver todos',
                  onAction: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const _StatementPrototype(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._tileWidgets(context),
          const Gap.xxl(),
        ],
      ),
    );
  }
}

class _StatementPrototype extends StatefulWidget {
  const _StatementPrototype();

  @override
  State<_StatementPrototype> createState() => _StatementPrototypeState();
}

class _StatementPrototypeState extends State<_StatementPrototype> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Extrato',
      padded: false,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppTextField(
                  label: 'Buscar',
                  hint: 'Descrição do lançamento',
                  prefixIcon: Icons.search,
                ),
                const Gap.md(),
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
                const SectionHeader(title: 'Outubro de 2026'),
              ],
            ),
          ),
          ..._tileWidgets(context),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: AppButton.secondary(
              label: 'Carregar mais',
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPrototype extends StatelessWidget {
  const _DetailPrototype();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Lançamento',
      actions: [
        IconButton(
          tooltip: 'Editar',
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const _FormPrototype()),
          ),
        ),
      ],
      body: ListView(
        children: [
          const Gap.xl(),
          Text('Mercado Pão de Açúcar', style: theme.textTheme.titleMedium),
          const Gap.xs(),
          const MoneyText(
            'R\$ 306,70',
            tone: MoneyTone.expense,
            size: MoneySize.display,
            signed: true,
          ),
          const Gap.lg(),
          const Divider(),
          const DetailRow(
            label: 'Tipo',
            value: 'Saída',
            icon: Icons.arrow_upward_rounded,
          ),
          const DetailRow(
            label: 'Data',
            value: '27/10/2026 17:55',
            icon: Icons.event_outlined,
          ),
          const DetailRow(
            label: 'Conta',
            value: 'Nubank',
            icon: Icons.account_balance_wallet_outlined,
          ),
          const DetailRow(
            label: 'Categoria',
            value: 'Alimentação',
            icon: Icons.sell_outlined,
          ),
          const DetailRow(
            label: 'Observação',
            value: 'Dividido com a Carla',
            icon: Icons.notes_outlined,
          ),
          const Gap.xl(),
          AppButton.secondary(
            label: 'Excluir lançamento',
            icon: Icons.delete_outline,
            onPressed: () => showConfirmDialog(
              context,
              title: 'Excluir lançamento?',
              message: 'Essa ação não pode ser desfeita.',
              confirmLabel: 'Excluir',
              destructive: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormPrototype extends StatefulWidget {
  const _FormPrototype();

  @override
  State<_FormPrototype> createState() => _FormPrototypeState();
}

class _FormPrototypeState extends State<_FormPrototype> {
  TransactionKind _kind = TransactionKind.expense;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Novo lançamento',
      body: ListView(
        children: [
          const Gap.md(),
          TransactionKindSelector(
            selected: _kind,
            onChanged: (kind) => setState(() => _kind = kind),
          ),
          const Gap.lg(),
          const AppTextField(
            label: 'Valor',
            hint: '0,00',
            prefixIcon: Icons.attach_money,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const Gap.md(),
          const AppTextField(label: 'Descrição', prefixIcon: Icons.short_text),
          const Gap.md(),
          const AppTextField(
            label: 'Conta',
            hint: 'Nubank',
            prefixIcon: Icons.account_balance_wallet_outlined,
          ),
          if (_kind == TransactionKind.transfer) ...[
            const Gap.md(),
            const AppTextField(
              label: 'Conta de destino',
              hint: 'Itaú',
              prefixIcon: Icons.call_made,
            ),
          ] else ...[
            const Gap.md(),
            const AppTextField(
              label: 'Categoria (opcional)',
              prefixIcon: Icons.sell_outlined,
            ),
          ],
          const Gap.md(),
          const AppTextField(
            label: 'Data',
            hint: 'dd/mm/aaaa',
            prefixIcon: Icons.event_outlined,
          ),
          const Gap.md(),
          const AppTextField(
            label: 'Observação (opcional)',
            prefixIcon: Icons.notes_outlined,
            maxLines: 3,
          ),
          const Gap.xl(),
          AppButton(label: 'Salvar', onPressed: () {}),
          const Gap.xl(),
        ],
      ),
    );
  }
}

class _ProfilePrototype extends StatelessWidget {
  const _ProfilePrototype();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Perfil',
      body: ListView(
        children: [
          const ProfileHeader(
            name: 'Ana Ribeiro',
            email: 'ana@carteira.dev',
            caption: 'Cliente desde março de 2024',
          ),
          const AppTextField(label: 'Nome', prefixIcon: Icons.person_outline),
          const Gap.md(),
          AppButton(label: 'Salvar nome', onPressed: () {}),
          const SectionHeader(title: 'Aparência'),
          AppChoiceChips<ThemeMode>(
            options: const [
              (value: ThemeMode.light, label: 'Claro'),
              (value: ThemeMode.dark, label: 'Escuro'),
              (value: ThemeMode.system, label: 'Sistema'),
            ],
            selected: ThemeMode.light,
            onSelected: (_) {},
          ),
          const Gap.xl(),
          AppButton.secondary(
            label: 'Sair da conta',
            icon: Icons.logout,
            onPressed: () {},
          ),
          const Gap.xl(),
        ],
      ),
    );
  }
}
