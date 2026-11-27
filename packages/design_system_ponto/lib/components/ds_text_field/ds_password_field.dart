import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import 'ds_text_field.dart';

/// Campo de senha com botão para mostrar e esconder o texto.
class DsPasswordField extends StatefulWidget {
  final String label;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const DsPasswordField({
    super.key,
    this.label = 'Senha',
    this.textInputAction,
    this.autofillHints,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<DsPasswordField> createState() => _DsPasswordFieldState();
}

class _DsPasswordFieldState extends State<DsPasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    return DsTextField(
      label: widget.label,
      hint: '••••••••',
      icon: Icons.lock_outline_rounded,
      obscureText: _hidden,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      errorText: widget.errorText,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      suffix: IconButton(
        tooltip: _hidden ? 'Mostrar senha' : 'Esconder senha',
        icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: c.textSecondary),
        onPressed: () => setState(() => _hidden = !_hidden),
      ),
    );
  }
}
