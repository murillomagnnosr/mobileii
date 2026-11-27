import 'package:design_system_ponto/design_system.dart';
import 'package:flutter/material.dart';

import 'insights_view_model.dart';

class InsightsView extends StatefulWidget {
  const InsightsView({required this.viewModel, super.key});

  final InsightsViewModel viewModel;

  @override
  State<InsightsView> createState() => _InsightsViewState();
}

class _InsightsViewState extends State<InsightsView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return DsScaffold(
      title: 'Resumo',
      padded: false,
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const DsStateView.loading(message: 'Montando seus gráficos');
          }
          if (viewModel.errorMessage != null) {
            return DsStateView.error(
              message: viewModel.errorMessage!,
              onRetry: viewModel.load,
            );
          }
          return RefreshIndicator(
            onRefresh: () => viewModel.load(silent: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                DsSpacing.screenGutter,
                DsSpacing.sm,
                DsSpacing.screenGutter,
                DsSpacing.xl,
              ),
              children: [
                DsEntrance(child: _CategoriesCard(viewModel: viewModel)),
                const DsGap.md(),
                DsEntrance(index: 1, child: _MonthsCard(viewModel: viewModel)),
              ],
            ),
          );
        },
      ),
    );
  }
}

Color _colorOf(int index) =>
    DsColors.chartPalette[index % DsColors.chartPalette.length];

class _CategoriesCard extends StatelessWidget {
  const _CategoriesCard({required this.viewModel});

  final InsightsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final categories = viewModel.categories;

    return DsCard(
      title: 'Gastos por categoria',
      subtitle: viewModel.monthText,
      leading: Icon(Icons.pie_chart_rounded, color: context.ds.accent),
      child: categories.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: DsSpacing.md),
              child: DsStateView.empty(
                message: 'Nenhuma saída neste mês.',
                icon: Icons.savings_outlined,
              ),
            )
          : Column(
              children: [
                const DsGap.sm(),
                Center(
                  child: DsDonutChart(
                    segments: [
                      for (final (i, c) in categories.indexed)
                        DsChartSegment(
                          label: c.category,
                          value: c.total,
                          color: _colorOf(i),
                        ),
                    ],
                    selectedIndex: viewModel.selectedCategory,
                    onSelected: viewModel.selectCategory,
                    centerTitle: viewModel.donutTitle,
                    centerValue: viewModel.donutValue,
                  ),
                ),
                const DsGap.md(),
                for (final (i, category) in categories.indexed)
                  _LegendRow(
                    color: _colorOf(i),
                    name: category.category,
                    share: viewModel.shareOf(category),
                    amount: viewModel.amountOf(category),
                    selected: viewModel.selectedCategory == i,
                    dimmed:
                        viewModel.selectedCategory != null &&
                        viewModel.selectedCategory != i,
                    onTap: () => viewModel.selectCategory(
                      viewModel.selectedCategory == i ? null : i,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.name,
    required this.share,
    required this.amount,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final Color color;
  final String name;
  final String share;
  final String amount;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DsRadius.sm),
      child: AnimatedOpacity(
        duration: DsMotion.fast,
        opacity: dimmed ? 0.45 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: DsSpacing.xs,
            horizontal: DsSpacing.xxs,
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: DsSpacing.sm),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (selected ? DsTypography.subtitle : DsTypography.body)
                      .copyWith(color: c.textPrimary),
                ),
              ),
              Text(
                share,
                style: DsTypography.caption.copyWith(color: c.textSecondary),
              ),
              const SizedBox(width: DsSpacing.sm),
              SizedBox(
                width: 104,
                child: Text(
                  amount,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  style: DsTypography.label.copyWith(color: c.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthsCard extends StatelessWidget {
  const _MonthsCard({required this.viewModel});

  final InsightsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    final months = viewModel.months;
    final selected = viewModel.selectedMonthSummary;

    return DsCard(
      title: 'Últimos ${months.length} meses',
      subtitle: 'Toque numa barra para ver o mês',
      leading: Icon(Icons.bar_chart_rounded, color: c.accent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DsGap.sm(),
          Row(
            children: [
              _Dot(color: c.success, label: 'Entradas'),
              const SizedBox(width: DsSpacing.md),
              _Dot(color: c.danger, label: 'Saídas'),
            ],
          ),
          const DsGap.md(),
          DsBarChart(
            groups: [
              for (final month in months)
                DsBarGroup(
                  label: viewModel.shortMonthOf(month),
                  values: [month.income, month.expense],
                ),
            ],
            seriesColors: [c.success, c.danger],
            selectedIndex: viewModel.selectedMonth,
            onSelected: viewModel.selectMonth,
          ),
          AnimatedSize(
            duration: DsMotion.normal,
            curve: DsCurves.emphasized,
            alignment: Alignment.topCenter,
            child: selected == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: DsSpacing.md),
                    child: _MonthDetail(
                      title: viewModel.selectedMonthTitle!,
                      income: viewModel.format(selected.income),
                      expense: viewModel.format(selected.expense),
                      balance: viewModel.format(selected.balance),
                      positive: selected.balance >= 0,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: DsSpacing.xxs + 2),
        Text(
          label,
          style: DsTypography.caption.copyWith(color: context.ds.textSecondary),
        ),
      ],
    );
  }
}

class _MonthDetail extends StatelessWidget {
  const _MonthDetail({
    required this.title,
    required this.income,
    required this.expense,
    required this.balance,
    required this.positive,
  });

  final String title;
  final String income;
  final String expense;
  final String balance;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DsSpacing.sm),
      decoration: BoxDecoration(
        color: c.surfaceVariant,
        borderRadius: BorderRadius.circular(DsRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: DsTypography.subtitle.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: DsSpacing.xxs),
          _DetailLine(label: 'Entradas', value: income, color: c.success),
          _DetailLine(label: 'Saídas', value: expense, color: c.danger),
          _DetailLine(
            label: 'Saldo',
            value: balance,
            color: positive ? c.success : c.danger,
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
    required this.color,
    this.strong = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: DsTypography.bodySmall.copyWith(
                color: context.ds.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: (strong ? DsTypography.label : DsTypography.bodySmall)
                .copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
