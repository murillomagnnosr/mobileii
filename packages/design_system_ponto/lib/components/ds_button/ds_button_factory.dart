import 'package:flutter/material.dart';

import 'ds_button_component.dart';
import 'ds_button_view_model.dart';

/// Atalhos para montar o par view model + componente sem repetir código nas telas.
class DsButtonFactory {
  DsButtonFactory._();

  static DsButtonComponent primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool expanded = true,
    bool destructive = false,
  }) {
    return DsButtonComponent(
      key: key,
      viewModel: DsButtonViewModel(
        label: label,
        icon: icon,
        isLoading: isLoading,
        expanded: expanded,
        destructive: destructive,
      ),
      onPressed: onPressed,
    );
  }

  static DsButtonComponent secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool expanded = true,
    bool destructive = false,
  }) {
    return DsButtonComponent(
      key: key,
      viewModel: DsButtonViewModel(
        label: label,
        variant: DsButtonVariant.secondary,
        icon: icon,
        isLoading: isLoading,
        expanded: expanded,
        destructive: destructive,
      ),
      onPressed: onPressed,
    );
  }

  static DsButtonComponent ghost({Key? key, required String label, required VoidCallback? onPressed, IconData? icon}) {
    return DsButtonComponent(
      key: key,
      viewModel: DsButtonViewModel(label: label, variant: DsButtonVariant.ghost, icon: icon, expanded: false),
      onPressed: onPressed,
    );
  }
}
