import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system_ponto/design_system.dart';

Widget _host(ThemeData theme, Widget child) => MaterialApp(
      theme: theme,
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
    );

void main() {
  for (final entry in {'claro': DsTheme.light(), 'escuro': DsTheme.dark()}.entries) {
    group('tema ${entry.key}', () {
      testWidgets('botão primário renderiza e dispara onPressed', (tester) async {
        var taps = 0;
        await tester.pumpWidget(_host(entry.value, DsButtonFactory.primary(label: 'Entrar', onPressed: () => taps++)));
        expect(find.text('Entrar'), findsOneWidget);
        await tester.tap(find.text('Entrar'));
        expect(taps, 1);
      });

      testWidgets('botão desabilitado não dispara', (tester) async {
        await tester.pumpWidget(_host(entry.value, DsButtonFactory.primary(label: 'Off', onPressed: null)));
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNull);
      });

      testWidgets('botão em loading mostra progresso e some o texto', (tester) async {
        await tester.pumpWidget(_host(entry.value, DsButtonFactory.primary(label: 'Salvar', isLoading: true, onPressed: () {})));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Salvar'), findsNothing);
      });

      testWidgets('card com título e filho', (tester) async {
        await tester.pumpWidget(_host(entry.value, const DsCard(title: 'Saldo', subtitle: 'Hoje', child: Text('R\$ 10'))));
        expect(find.text('Saldo'), findsOneWidget);
        expect(find.text('Hoje'), findsOneWidget);
        expect(find.text('R\$ 10'), findsOneWidget);
      });

      testWidgets('status pill mostra rótulo', (tester) async {
        await tester.pumpWidget(_host(entry.value, DsStatusPill(label: 'Em dia', tone: entry.value.colorScheme.primary)));
        expect(find.text('Em dia'), findsOneWidget);
      });

      testWidgets('campo de texto mostra rótulo e erro', (tester) async {
        await tester.pumpWidget(_host(entry.value, const DsTextField(label: 'E-mail', errorText: 'Inválido')));
        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Inválido'), findsOneWidget);
      });

      testWidgets('navegação troca de aba ao tocar', (tester) async {
        var selected = 0;
        await tester.pumpWidget(MaterialApp(
          theme: entry.value,
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) => DsNavigationBar(
                selectedIndex: selected,
                onDestinationSelected: (i) => setState(() => selected = i),
                items: const [
                  DsNavItem(label: 'Início', icon: Icons.home_outlined),
                  DsNavItem(label: 'Perfil', icon: Icons.person_outline),
                ],
              ),
            ),
          ),
        ));
        await tester.tap(find.text('Perfil'));
        await tester.pump();
        expect(selected, 1);
      });

      testWidgets('vitrine renderiza sem erros', (tester) async {
        await tester.pumpWidget(MaterialApp(theme: entry.value, home: const DsSampleScreen()));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('Saldo do mês'), findsOneWidget);
      });
    });
  }

  test('DsTheme injeta a extensão semântica nos dois temas', () {
    expect(DsTheme.light().extension<DsThemeExtension>(), isNotNull);
    expect(DsTheme.dark().extension<DsThemeExtension>(), isNotNull);
  });
}
