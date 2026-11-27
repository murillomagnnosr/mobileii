import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_typography.dart';
import 'ds_transaction_kind.dart';

enum DsMoneySize { normal, display }

/// Valor monetário já formatado, colorido pelo tipo. O tipo vem sem sinal e o [signed] o põe.
class DsMoneyText extends StatelessWidget {
  final String text;
  final DsTransactionKind? kind;
  final DsMoneySize size;
  final bool signed;
  final Color? color;

  const DsMoneyText(
    this.text, {
    super.key,
    this.kind,
    this.size = DsMoneySize.normal,
    this.signed = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    final style = kind == null ? null : dsKindStyleOf(context, kind!);
    final base = size == DsMoneySize.display ? DsTypography.display : DsTypography.subtitle;
    final tone = color ?? style?.color ?? c.textPrimary;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        '${signed ? (style?.sign ?? '') : ''}$text',
        maxLines: 1,
        style: base.copyWith(
          color: tone,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
