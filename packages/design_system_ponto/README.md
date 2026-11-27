# Design System Ponto

Design system em Flutter com tokens de cor, espaçamento, raio e tipografia, tema claro e escuro, e componentes prontos para montar telas.

## Visão geral

- **Tokens** centralizados em classes estáticas: `DsColors`, `DsSpacing`, `DsRadius`, `DsSizes`, `DsMotion` e `DsTypography`.
- **Tema** Material 3 completo (`DsTheme.light()` e `DsTheme.dark()`), com botões, campos, cards, chips e barra de navegação já configurados.
- **Papéis semânticos** (`DsSemanticColors`): os componentes usam nomes como `accent`, `surface` e `danger`, nunca a cor primitiva. Trocar de tema não exige mudar componente.
- **Componentes** organizados em pastas, cada um com seu estado (view model), desenho (component) e atalhos (factory) quando faz sentido.

## Paleta

| Papel | Claro | Escuro |
|---|---|---|
| Fundo | `#FBF8F3` | `#0E1A2B` |
| Superfície | `#FFFFFF` | `#15233A` |
| Acento | `#0B7F76` | `#1FB5A8` |
| Destaque | `#FF6B4A` | `#FF6B4A` |

As cores primitivas são: tinta `#0E1A2B`, maré `#1FB5A8`, areia `#F4EBDD`, coral `#FF6B4A` e âmbar `#F2B33D`.

## Como usar

```dart
import 'package:design_system_ponto/design_system.dart';

MaterialApp(
  theme: DsTheme.light(),
  darkTheme: DsTheme.dark(),
  themeMode: ThemeMode.system,
  home: Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(DsSpacing.md),
      child: DsCard(
        title: 'Saldo do mês',
        subtitle: 'Atualizado agora',
        child: Column(
          children: [
            DsStatusPill(label: 'Em dia', tone: context.ds.success),
            const SizedBox(height: DsSpacing.md),
            DsButtonFactory.primary(label: 'Ver extrato', onPressed: () {}),
          ],
        ),
      ),
    ),
  ),
);
```

Use `context.ds` para acessar os papéis de cor dentro de qualquer widget.

## Componentes

| Componente | Uso |
|---|---|
| `DsButtonFactory` / `DsButtonComponent` | Botões primário, secundário e ghost, com estado de carregamento e desabilitado |
| `DsCard` | Cartão com título, subtítulo, ícone à esquerda e destaque de borda |
| `DsStatusPill` | Indicador compacto de estado, com cor e ícone opcionais |
| `DsTextField` | Campo com rótulo acima, dica, ícone e mensagem de erro |
| `DsNavigationBar` | Barra de navegação inferior, com `DsNavItem` para cada destino |

## Vitrine

`DsSampleScreen` é uma tela de exemplo com três abas (Início, Extrato e Perfil) que mostra todos os componentes. Ela serve como referência visual e para testar claro e escuro.

Para rodar a vitrine no navegador:

```bash
cd example
flutter run -d chrome
```

## Estrutura

```
lib/
  design_system.dart          # barrel: único import necessário
  tokens/                     # cores, espaçamento/raio/tamanho, tipografia
  theme/ds_theme.dart         # ThemeData claro/escuro e context.ds
  components/
    ds_button/
    ds_card/
    ds_navigation_bar/
    ds_status_pill/
    ds_text_field/
  screens/ds_sample_screen.dart
test/ds_widgets_test.dart     # testes de widget nos dois temas
example/                      # app mínimo que exibe a vitrine
```

## Testes

```bash
flutter analyze
flutter test
```

## Próximos passos

- Golden tests para claro e escuro.
- Mais componentes: seletor de chips, avatar, lista de itens e feedback de estado vazio.
