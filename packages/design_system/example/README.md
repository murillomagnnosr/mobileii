# Galeria do design system

App de demonstração do pacote `carteira_design_system` (direção visual
"Neon noturno+"). Mostra cada token e cada componente nos temas claro e
escuro, com os mesmos valores que o app usa: nada aqui é copiado à mão, tudo
é lido dos tokens e do tema.

## Como rodar

```sh
cd packages/design_system/example
flutter pub get
flutter run            # emulador, aparelho ou desktop
flutter run -d chrome  # no navegador
```

O botão da app bar alterna entre claro, escuro e sistema; a galeria abre no
escuro. O `main()` chama `AppFonts.registerLicenses()`, como o app.

## Páginas

| Página | O que mostra |
| --- | --- |
| Tokens | paleta, gradientes, brilhos, vidro, auroras e sombras (com os alphas "AA cap"), tipos de lançamento, orçamentos de uso, tipografia (eixos `wght` e licenças OFL, com o botão **Ver licenças**), raios, espaçamento e movimento |
| Botões | `AppButton` (primário, secundário, texto, destrutivo, carregando) e `AppFab` |
| Campos | `AppTextField` (valor, observação, busca, erro, desabilitado), `PasswordField`, `AppErrorBanner` e `AppAvatar` |
| Listas | `BalanceCard`, `TransactionTile` (lista e cápsula), `MoneyText`, `CategoryBar` e `EmptyDivider` |
| Estados | `StateView` (carregando, vazio, erro) |
| Filtros e detalhes | `AppChoiceChips`, `TransactionKindSelector` (também desabilitado), `DetailRow`, `ProfileHeader` e `showConfirmDialog` |
| Protótipos de telas | Login, Home, Extrato, Detalhe, Novo lançamento e Perfil montados só com o pacote |

## Análise

```sh
flutter analyze   # deve dizer "No issues found!"
```

Regras, catálogo completo e testes do pacote em [`../README.md`](../README.md).
