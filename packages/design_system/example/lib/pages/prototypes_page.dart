import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/menu_panel.dart';

/// Protótipos navegáveis das telas do app, montados só com componentes do
/// design system e dados fixos. Espelham as cenas reais em `lib/scenes/`
/// (mesmos componentes e parâmetros) e servem para validar o layout antes de
/// ligar na API.
///
/// Diferença proposital: nenhum avatar recebe `heroTag`, para a galeria nunca
/// ter duas tags de Hero iguais na mesma rota.
class PrototypesPage extends StatelessWidget {
  const PrototypesPage({super.key});

  /// Título e nome da rota: o "Sair da conta" do Perfil volta até aqui.
  static const title = 'Protótipos de telas';

  static final _screens = <GalleryEntry>[
    const GalleryEntry(
      title: 'Login',
      subtitle: 'POST /auth/login',
      icon: Icons.login_rounded,
      page: _LoginPrototype(),
    ),
    const GalleryEntry(
      title: 'Home',
      subtitle: 'GET /me · /summary · /transactions',
      icon: Icons.home_rounded,
      page: _HomePrototype(),
    ),
    const GalleryEntry(
      title: 'Extrato',
      subtitle: 'GET /transactions?type&q&page',
      icon: Icons.receipt_long_rounded,
      page: _StatementPrototype(),
    ),
    GalleryEntry(
      title: 'Detalhe do lançamento',
      subtitle: 'GET · DELETE /transactions/:id',
      icon: Icons.info_outline_rounded,
      page: _DetailPrototype(sample: _samples.first),
    ),
    const GalleryEntry(
      title: 'Novo lançamento',
      subtitle: 'POST · PUT /transactions',
      icon: Icons.add_rounded,
      page: _FormPrototype(),
    ),
    const GalleryEntry(
      title: 'Perfil',
      subtitle: 'GET · PUT /me, /auth/logout',
      icon: Icons.person_outline_rounded,
      page: _ProfilePrototype(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: title,
      actions: const [ThemeModeButton()],
      padded: false,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(
            'O Login leva à Home, e a Home abre o Extrato, o Detalhe, o '
            'formulário e o Perfil.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap.lg(),
          MenuPanel(entries: _screens),
        ],
      ),
    );
  }
}

void _open(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

String _two(int n) => n.toString().padLeft(2, '0');

/// Um lançamento de exemplo, com os textos que os ViewModels formatam.
class _Sample {
  const _Sample({
    required this.kind,
    required this.title,
    required this.amount,
    required this.date,
    required this.account,
    this.toAccount,
    this.category,
    this.note,
  });

  final TransactionKind kind;
  final String title;

  /// Já formatado e sem sinal: o tile e o MoneyText põem o sinal.
  final String amount;
  final DateTime date;
  final String account;
  final String? toAccount;
  final String? category;
  final String? note;

  String get accountText =>
      toAccount == null ? account : '$account → $toAccount';

  String get subtitle => '${_two(date.day)}/${_two(date.month)} · $accountText';

  String get dateText =>
      '${_two(date.day)}/${_two(date.month)}/${date.year} '
      '${_two(date.hour)}:${_two(date.minute)}';

  String get typeText => switch (kind) {
    TransactionKind.income => 'Entrada',
    TransactionKind.expense => 'Saída',
    TransactionKind.transfer => 'Transferência',
  };

  /// Valor como o usuário digita no campo (sem o "R$ ").
  String get amountInput => amount.replaceFirst('R\$ ', '');
}

// Dados de exemplo compartilhados pelos protótipos.
final _samples = [
  _Sample(
    kind: TransactionKind.expense,
    title: 'Mercado Pão de Açúcar',
    amount: 'R\$ 306,70',
    date: DateTime(2026, 10, 27, 17, 55),
    account: 'Nubank',
    category: 'Alimentação',
    note: 'Dividido com a Carla',
  ),
  _Sample(
    kind: TransactionKind.income,
    title: 'Salário',
    amount: 'R\$ 9.526,55',
    date: DateTime(2026, 10, 25, 8),
    account: 'Itaú',
    category: 'Salário',
  ),
  _Sample(
    kind: TransactionKind.transfer,
    title: 'Reserva',
    amount: 'R\$ 500,00',
    date: DateTime(2026, 10, 20, 12, 10),
    account: 'Nubank',
    toAccount: 'Itaú',
  ),
  _Sample(
    kind: TransactionKind.expense,
    title: 'Mercado',
    amount: 'R\$ 89,90',
    date: DateTime(2026, 10, 6, 19, 30),
    account: 'Nubank',
    category: 'Alimentação',
  ),
  _Sample(
    kind: TransactionKind.expense,
    title: 'Aluguel',
    amount: 'R\$ 4.813,44',
    date: DateTime(2026, 10, 5, 9),
    account: 'Itaú',
    category: 'Moradia',
  ),
];

// ---------------------------------------------------------------------------
// 11.1 Login

class _LoginPrototype extends StatefulWidget {
  const _LoginPrototype();

  @override
  State<_LoginPrototype> createState() => _LoginPrototypeState();
}

class _LoginPrototypeState extends State<_LoginPrototype> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Mesma regra do LoginViewModel; com os campos preenchidos, simula a
  /// chamada e segue para a Home.
  Future<void> _submit() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Informe e-mail e senha.');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const _HomePrototype()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return AppScaffold(
      showAppBar: false,
      spotlight: true,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // O ponto lima do logotipo é a faísca do Login.
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: 'E-mail',
                        hint: 'voce@exemplo.com',
                        controller: _email,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const Gap.md(),
                      PasswordField(
                        controller: _password,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _submit(),
                      ),
                      if (_error != null) ...[
                        const Gap.md(),
                        AppErrorBanner(_error!),
                      ],
                      const Gap(20),
                      AppButton(
                        label: 'Entrar',
                        isLoading: _loading,
                        onPressed: _submit,
                      ),
                    ],
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

// ---------------------------------------------------------------------------
// 11.2 Home

class _HomePrototype extends StatelessWidget {
  const _HomePrototype();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Carteira',
      brand: true,
      padded: false,
      actions: [
        IconButton(
          tooltip: 'Perfil',
          // Não é botão de chrome: sem fundo nem borda em volta do anel.
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            side: BorderSide.none,
            padding: EdgeInsets.zero,
            fixedSize: const Size.square(44),
          ),
          icon: const AppAvatar(name: 'Ana Ribeiro', size: 36),
          onPressed: () => _open(context, const _ProfilePrototype()),
        ),
      ],
      floatingActionButton: AppFab(
        tooltip: 'Novo lançamento',
        onPressed: () => _open(context, const _FormPrototype()),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.fabClearance + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Text('Olá, Ana', style: theme.textTheme.titleLarge),
          const Gap.lg(),
          const BalanceCard(
            balance: 'R\$ 4.196,51',
            income: 'R\$ 9.526,55',
            expense: 'R\$ 5.330,04',
            monthLabel: 'Outubro de 2026',
          ),
          SectionHeader(
            title: 'Últimos lançamentos',
            actionLabel: 'Ver todos',
            onAction: () => _open(context, const _StatementPrototype()),
          ),
          for (final (index, sample) in _samples.indexed) ...[
            if (index > 0) const Gap.sm(),
            // O tile põe o sinal conforme o tipo; o valor vai sem sinal.
            TransactionTile(
              capsule: true,
              entranceIndex: index,
              kind: sample.kind,
              title: sample.title,
              amount: sample.amount,
              subtitle: sample.subtitle,
              onTap: () => _open(context, _DetailPrototype(sample: sample)),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 11.3 Extrato

class _StatementPrototype extends StatefulWidget {
  const _StatementPrototype();

  @override
  State<_StatementPrototype> createState() => _StatementPrototypeState();
}

class _StatementPrototypeState extends State<_StatementPrototype> {
  static const _filters = <ChipOption<TransactionKind?>>[
    (value: null, label: 'Todos'),
    (value: TransactionKind.income, label: 'Entradas'),
    (value: TransactionKind.expense, label: 'Saídas'),
    (value: TransactionKind.transfer, label: 'Transferências'),
  ];

  TransactionKind? _filter;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final items = [
      for (final sample in _samples)
        if ((_filter == null || sample.kind == _filter) &&
            sample.title.toLowerCase().contains(query))
          sample,
    ];

    return AppScaffold(
      title: 'Extrato',
      padded: false,
      floatingActionButton: AppFab(
        tooltip: 'Novo lançamento',
        onPressed: () => _open(context, const _FormPrototype()),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          bottom:
              AppSpacing.fabClearance + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.md,
            ),
            child: AppTextField(
              label: 'Buscar',
              hint: 'Descrição do lançamento',
              prefixIcon: Icons.search_rounded,
              pill: true,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          // Linha de chips de borda a borda; o recuo vai dentro da rolagem.
          AppChoiceChips<TransactionKind?>(
            options: _filters,
            selected: _filter,
            onSelected: (value) => setState(() => _filter = value),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          ),
          const Gap.lg(),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
              child: StateView.empty(
                message: 'Nenhum lançamento encontrado.',
                icon: Icons.search_off_rounded,
                actionLabel: 'Adicionar',
                onAction: () => _open(context, const _FormPrototype()),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
              child: AppPanel(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  children: [
                    for (final (index, sample) in items.indexed) ...[
                      // 16 de padding + 44 do orb + 16 de espaço.
                      if (index > 0) const Divider(indent: 76, endIndent: 16),
                      TransactionTile(
                        kind: sample.kind,
                        title: sample.title,
                        amount: sample.amount,
                        subtitle: sample.subtitle,
                        onTap: () =>
                            _open(context, _DetailPrototype(sample: sample)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: AppButton.secondary(
                label: 'Carregar mais',
                onPressed: () {},
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 11.4 Detalhe

class _DetailPrototype extends StatelessWidget {
  const _DetailPrototype({required this.sample});

  final _Sample sample;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Excluir lançamento?',
      message: 'Essa ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (confirmed && context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kind = kindStyleOf(context, sample.kind);
    return AppScaffold(
      title: 'Lançamento',
      actions: [
        IconButton(
          tooltip: 'Editar',
          icon: const Icon(Icons.edit_rounded),
          onPressed: () => _open(context, _FormPrototype(initial: sample)),
        ),
      ],
      body: ListView(
        children: [
          const Gap.sm(),
          AppPanel(
            radius: AppRadius.xl,
            padding: const EdgeInsets.all(AppSpacing.hero),
            glow: kind.color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    KindOrb(kind: sample.kind, size: 52),
                    const Gap.md(),
                    // A pílula de tipo substitui a linha "Tipo".
                    DecoratedBox(
                      decoration: ShapeDecoration(
                        color: kind.container,
                        shape: const StadiumBorder(),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 6,
                        ),
                        child: Text(
                          sample.typeText,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: kind.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap.lg(),
                Text(sample.title, style: theme.textTheme.titleMedium),
                const Gap.xs(),
                MoneyText(
                  sample.amount,
                  tone: kind.tone,
                  size: MoneySize.display,
                  signed: true,
                ),
              ],
            ),
          ),
          const Gap.lg(),
          AppPanel(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              children: [
                DetailRow(
                  label: 'Data',
                  value: sample.dateText,
                  icon: Icons.event_outlined,
                ),
                const Divider(indent: 48),
                DetailRow(
                  label: 'Conta',
                  value: sample.accountText,
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const Divider(indent: 48),
                DetailRow(
                  label: 'Categoria',
                  value: sample.category ?? 'Sem categoria',
                  icon: Icons.sell_outlined,
                ),
                if (sample.note != null) ...[
                  const Divider(indent: 48),
                  DetailRow(
                    label: 'Observação',
                    value: sample.note!,
                    icon: Icons.notes_rounded,
                  ),
                ],
              ],
            ),
          ),
          const Gap.xl(),
          AppButton.secondary(
            label: 'Excluir lançamento',
            icon: Icons.delete_outline_rounded,
            destructive: true,
            onPressed: () => _delete(context),
          ),
          const Gap.xl(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 11.5 Novo / Editar lançamento

class _FormPrototype extends StatefulWidget {
  const _FormPrototype({this.initial});

  /// Preenchido quando aberto pelo "Editar" do Detalhe.
  final _Sample? initial;

  @override
  State<_FormPrototype> createState() => _FormPrototypeState();
}

class _FormPrototypeState extends State<_FormPrototype> {
  late TransactionKind _kind = widget.initial?.kind ?? TransactionKind.expense;
  late final _amount = TextEditingController(text: widget.initial?.amountInput);
  late final _description = TextEditingController(text: widget.initial?.title);
  late final _account = TextEditingController(text: widget.initial?.account);
  late final _toAccount = TextEditingController(
    text: widget.initial?.toAccount,
  );
  late final _category = TextEditingController(text: widget.initial?.category);
  late final _note = TextEditingController(text: widget.initial?.note);
  late DateTime _date = widget.initial?.date ?? DateTime.now();
  String? _amountError;
  String? _errorMessage;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [
      _amount,
      _description,
      _account,
      _toAccount,
      _category,
      _note,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _dateText =>
      '${_two(_date.day)}/${_two(_date.month)}/${_date.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  /// Valida só o valor (o bastante para mostrar o erro do campo e o banner)
  /// e simula o salvamento.
  Future<void> _submit() async {
    final amountError = _amount.text.trim().isEmpty
        ? 'Informe um valor numérico.'
        : null;
    setState(() {
      _amountError = amountError;
      _errorMessage = amountError == null
          ? null
          : 'Revise os campos destacados.';
      _saving = amountError == null;
    });
    if (amountError != null) return;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isTransfer = _kind == TransactionKind.transfer;
    return AppScaffold(
      title: widget.initial == null ? 'Novo lançamento' : 'Editar lançamento',
      body: ListView(
        children: [
          const Gap.sm(),
          TransactionKindSelector(
            selected: _kind,
            enabled: !_saving,
            onChanged: (kind) => setState(() => _kind = kind),
          ),
          const Gap(20),
          // O valor é o foco do formulário: Space Grotesk 28 com "R$ ".
          AppTextField(
            label: 'Valor',
            hint: '0,00',
            controller: _amount,
            prefixText: 'R\$ ',
            style: AppTypography.moneyInput.copyWith(color: onSurface),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            errorText: _amountError,
          ),
          const Gap.md(),
          AppTextField(
            label: 'Descrição',
            controller: _description,
            prefixIcon: Icons.short_text_rounded,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
          ),
          const Gap.md(),
          AppTextField(
            label: isTransfer ? 'Conta de origem' : 'Conta',
            hint: 'Nubank',
            controller: _account,
            prefixIcon: Icons.account_balance_wallet_outlined,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const Gap.md(),
          if (isTransfer)
            AppTextField(
              label: 'Conta de destino',
              hint: 'Itaú',
              controller: _toAccount,
              prefixIcon: Icons.call_made_rounded,
              textCapitalization: TextCapitalization.words,
            )
          else
            AppTextField(
              label: 'Categoria (opcional)',
              hint: 'Alimentação',
              controller: _category,
              prefixIcon: Icons.sell_outlined,
              textCapitalization: TextCapitalization.sentences,
            ),
          const Gap.md(),
          InkWell(
            onTap: _saving ? null : _pickDate,
            borderRadius: AppRadius.mdAll,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data',
                prefixIcon: Icon(Icons.event_outlined, size: 22),
              ),
              child: Text(_dateText),
            ),
          ),
          const Gap.md(),
          AppTextField(
            label: 'Observação (opcional)',
            controller: _note,
            prefixIcon: Icons.notes_rounded,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          if (_errorMessage != null) ...[
            const Gap.md(),
            AppErrorBanner(_errorMessage!),
          ],
          const Gap(28),
          AppButton(label: 'Salvar', isLoading: _saving, onPressed: _submit),
          const Gap.xl(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 11.6 Perfil

class _ProfilePrototype extends StatefulWidget {
  const _ProfilePrototype();

  @override
  State<_ProfilePrototype> createState() => _ProfilePrototypeState();
}

class _ProfilePrototypeState extends State<_ProfilePrototype> {
  static const _themes = <ChipOption<ThemeMode>>[
    (value: ThemeMode.light, label: 'Claro'),
    (value: ThemeMode.dark, label: 'Escuro'),
    (value: ThemeMode.system, label: 'Sistema'),
  ];

  final _name = TextEditingController(text: 'Ana Ribeiro');
  String? _savedMessage;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _savedMessage = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _saving = false;
      _savedMessage = 'Nome atualizado.';
    });
  }

  /// Sair não é destrutivo (dá para entrar de novo): confirmação primária.
  /// Confirmado, volta ao Login por cima da lista de protótipos.
  Future<void> _logout() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sair da conta?',
      message: 'Você vai precisar entrar de novo.',
      confirmLabel: 'Sair',
      icon: Icons.logout_rounded,
    );
    if (!confirmed || !mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const _LoginPrototype()),
      ModalRoute.withName(PrototypesPage.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Perfil',
      body: ListView(
        children: [
          // Sem avatarHeroTag (veja a documentação de PrototypesPage).
          const ProfileHeader(
            name: 'Ana Ribeiro',
            email: 'ana@carteira.dev',
            caption: 'Cliente desde março de 2024',
          ),
          const SectionHeader(title: 'Dados'),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Nome',
                  controller: _name,
                  prefixIcon: Icons.person_outline_rounded,
                  helperText: _savedMessage,
                  textCapitalization: TextCapitalization.words,
                ),
                const Gap.md(),
                AppButton(
                  label: 'Salvar nome',
                  isLoading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Aparência'),
          // Ligado ao tema da galeria, como o ThemeController no app.
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeMode,
            builder: (context, mode, _) => AppChoiceChips<ThemeMode>(
              options: _themes,
              selected: mode,
              onSelected: (value) => themeMode.value = value,
            ),
          ),
          const Gap.xxl(),
          AppButton.secondary(
            label: 'Sair da conta',
            icon: Icons.logout_rounded,
            onPressed: _logout,
          ),
          const Gap.lg(),
          Text(
            'Carteira Digital 1.0',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap.xl(),
        ],
      ),
    );
  }
}
