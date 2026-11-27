import 'package:flutter/material.dart';

import '../components/ds_button/ds_button_factory.dart';
import '../components/ds_card/ds_card.dart';
import '../components/ds_navigation_bar/ds_navigation_bar.dart';
import '../components/ds_status_pill/ds_status_pill.dart';
import '../components/ds_text_field/ds_text_field.dart';
import '../theme/ds_theme.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';

/// Vitrine do design system: três telas navegáveis pela barra inferior.
/// Use como referência visual e para testar claro/escuro.
class DsSampleScreen extends StatefulWidget {
  const DsSampleScreen({super.key});

  @override
  State<DsSampleScreen> createState() => _DsSampleScreenState();
}

class _DsSampleScreenState extends State<DsSampleScreen> {
  int _tab = 0;
  final _email = TextEditingController();

  static const _titles = ['Início', 'Extrato', 'Perfil'];

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _feedback(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    final pages = [
      _HomePage(onAction: _feedback),
      _StatementPage(onAction: _feedback),
      _ProfilePage(email: _email, onAction: _feedback),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab], style: DsTypography.title.copyWith(color: c.textPrimary))),
      bottomNavigationBar: DsNavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        items: const [
          DsNavItem(label: 'Início', icon: Icons.home_outlined, selectedIcon: Icons.home),
          DsNavItem(label: 'Extrato', icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long),
          DsNavItem(label: 'Perfil', icon: Icons.person_outline, selectedIcon: Icons.person),
        ],
      ),
      body: pages[_tab],
    );
  }
}

class _HomePage extends StatelessWidget {
  final ValueChanged<String> onAction;

  const _HomePage({required this.onAction});

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    return ListView(
      padding: const EdgeInsets.all(DsSpacing.screenGutter),
      children: [
        Text('Saldo do mês', style: DsTypography.headline.copyWith(color: c.textPrimary)),
        const SizedBox(height: DsSpacing.lg),
        DsCard(
          title: 'Carteira principal',
          subtitle: 'Atualizado agora',
          highlighted: true,
          leading: Icon(Icons.account_balance_wallet, color: c.accent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('R\$ 2.340,00', style: DsTypography.display.copyWith(color: c.textPrimary)),
              const SizedBox(height: DsSpacing.sm),
              DsStatusPill(label: 'Em dia', tone: c.success, icon: Icons.check_circle),
            ],
          ),
        ),
        const SizedBox(height: DsSpacing.md),
        DsCard(
          title: 'Alertas',
          child: Wrap(
            spacing: DsSpacing.xs,
            runSpacing: DsSpacing.xs,
            children: [
              DsStatusPill(label: 'Atenção', tone: c.warning, icon: Icons.warning_amber),
              DsStatusPill(label: 'Vencido', tone: c.danger, icon: Icons.error_outline),
              DsStatusPill(label: 'Novo', tone: c.highlight),
            ],
          ),
        ),
        const SizedBox(height: DsSpacing.lg),
        DsButtonFactory.primary(
          label: 'Adicionar despesa',
          icon: Icons.add,
          onPressed: () => onAction('Despesa adicionada'),
        ),
        const SizedBox(height: DsSpacing.sm),
        DsButtonFactory.secondary(label: 'Ver extrato completo', onPressed: () => onAction('Abrindo extrato')),
      ],
    );
  }
}

class _StatementPage extends StatelessWidget {
  final ValueChanged<String> onAction;

  const _StatementPage({required this.onAction});

  static const _entries = [
    ('Mercado', 'Hoje, 10:12', '- R\$ 186,40', 'Pago', Icons.shopping_cart_outlined),
    ('Salário', 'Ontem, 08:00', '+ R\$ 5.200,00', 'Recebido', Icons.payments_outlined),
    ('Conta de luz', '12 set', '- R\$ 214,90', 'Vence em 3 dias', Icons.bolt_outlined),
    ('Assinatura', '09 set', '- R\$ 39,90', 'Vencido', Icons.subscriptions_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    return ListView(
      padding: const EdgeInsets.all(DsSpacing.screenGutter),
      children: [
        for (final e in _entries) ...[
          DsCard(
            onTap: () => onAction('${e.$1}: ${e.$3}'),
            leading: Icon(e.$5, color: c.accent),
            title: e.$1,
            subtitle: e.$2,
            child: Row(
              children: [
                Text(e.$3, style: DsTypography.label.copyWith(color: c.textPrimary)),
                const Spacer(),
                DsStatusPill(
                  label: e.$4,
                  tone: e.$4 == 'Vencido'
                      ? c.danger
                      : e.$4 == 'Vence em 3 dias'
                          ? c.warning
                          : c.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: DsSpacing.sm),
        ],
      ],
    );
  }
}

class _ProfilePage extends StatelessWidget {
  final TextEditingController email;
  final ValueChanged<String> onAction;

  const _ProfilePage({required this.email, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    return ListView(
      padding: const EdgeInsets.all(DsSpacing.screenGutter),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: c.accentSoft,
              child: Text('AS', style: DsTypography.subtitle.copyWith(color: c.accent)),
            ),
            const SizedBox(width: DsSpacing.md),
            Text('André Silva', style: DsTypography.title.copyWith(color: c.textPrimary)),
          ],
        ),
        const SizedBox(height: DsSpacing.lg),
        DsTextField(
          label: 'E-mail',
          hint: 'voce@exemplo.com',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          controller: email,
        ),
        const SizedBox(height: DsSpacing.lg),
        DsButtonFactory.primary(label: 'Salvar alterações', icon: Icons.check, onPressed: () => onAction('Perfil salvo')),
        const SizedBox(height: DsSpacing.sm),
        DsButtonFactory.primary(label: 'Carregando', isLoading: true, onPressed: () {}),
        const SizedBox(height: DsSpacing.sm),
        DsButtonFactory.primary(label: 'Desabilitado', onPressed: null),
        const SizedBox(height: DsSpacing.sm),
        DsButtonFactory.ghost(label: 'Sair', icon: Icons.logout, onPressed: () => onAction('Saindo...')),
      ],
    );
  }
}
