// Ponta a ponta: a camada de dados real do app (ApiClient + repositórios
// Remote* do carteira_core) falando com o mock de tool/mock_server. Prova que
// o app e o mock entendem o mesmo contrato: login, perfil, resumo, lista com
// filtros e páginas, CRUD de lançamentos, erros mapeados para AppError e
// logout.
import 'package:carteira_core/carteira_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/mock_server/mock_server.dart';
import '../../tool/mock_server/seed.dart';

/// "Agora" fixo no fim do mês (nenhuma data do seed é limitada a "agora"):
/// o mês atual é 2026-09 e o anterior, 2026-08.
final _agora = DateTime.utc(2026, 9, 30, 12);
const _mesAtual = '2026-09';
const _mesAnterior = '2026-08';

late MockServer _server;

/// A pilha de dados como o app monta, apontando para o mock.
class _App {
  _App({Duration? timeout, Map<String, String> headers = const {}})
    : client = ApiClient(
        baseUrl: _server.baseUrl.toString(),
        timeout: timeout ?? const Duration(seconds: 10),
        headers: headers,
      ) {
    auth = RemoteAuthRepository(client: client, storage: storage);
    users = RemoteUserRepository(client: client);
    transactions = RemoteTransactionRepository(client: client);
  }

  final ApiClient client;
  final storage = InMemorySessionStorage();
  late final RemoteAuthRepository auth;
  late final RemoteUserRepository users;
  late final RemoteTransactionRepository transactions;

  Future<Session> entrar([String email = 'ana@carteira.dev']) async {
    final result = await auth.login(email: email, password: seedPassword);
    return result.when(
      ok: (session) => session,
      failure: (error) => fail('login falhou: $error'),
    );
  }

  void fechar() {
    transactions.dispose();
    client.close();
  }
}

/// Valor de um [Ok], ou falha o teste mostrando o erro.
T _ok<T>(Result<T> result) => result.when(
  ok: (value) => value,
  failure: (error) => fail('esperava Ok, veio $error'),
);

/// Erro de um [Failure], ou falha o teste.
AppError _erro(Result<Object?> result) =>
    result.errorOrNull ?? fail('esperava Failure, veio $result');

List<String> _ids(Page<Transaction> page) => [
  for (final item in page.items) item.id,
];

void main() {
  setUpAll(() async {
    _server = await startMockServer(
      port: 0,
      minLatency: Duration.zero,
      maxLatency: Duration.zero,
      clock: () => _agora,
    );
  });

  tearDownAll(() => _server.close());

  late _App app;

  setUp(() => app = _App());
  tearDown(() => app.fechar());

  group('autenticação', () {
    test('login certo devolve a sessão, guarda e liga o token', () async {
      final result = await app.auth.login(
        email: '  ana@carteira.dev ',
        password: '123456',
      );

      final session = _ok(result);
      expect(session.token, matches(RegExp(r'^tok_[0-9a-z]{24}$')));
      expect(
        session.user,
        User(
          id: 'usr_01',
          name: 'Ana Ribeiro',
          email: 'ana@carteira.dev',
          createdAt: DateTime.utc(2024, 3, 11, 9),
        ),
      );
      expect(app.auth.currentSession, session);
      expect(await app.storage.read(), session);
      expect(app.client.token, session.token);
    });

    test('senha errada vira UnauthorizedError(invalidCredentials)', () async {
      final result = await app.auth.login(
        email: 'ana@carteira.dev',
        password: 'errada',
      );

      final erro = _erro(result);
      expect(erro, const UnauthorizedError(invalidCredentials: true));
      expect(erro.message, 'E-mail ou senha incorretos.');
      expect(app.auth.currentSession, isNull);
      expect(await app.storage.read(), isNull);
      expect(app.client.token, isNull);
    });

    test('e-mail vazio vira ValidationError com os campos', () async {
      final result = await app.auth.login(email: '  ', password: '');

      expect(
        _erro(result),
        const ValidationError({
          'email': 'must not be empty',
          'password': 'must not be empty',
        }),
      );
    });

    test('sessão restaurada do storage continua válida no mock', () async {
      final session = await app.entrar();
      final outra = _App();
      addTearDown(outra.fechar);
      await outra.storage.write(session);

      final restored = _ok(await outra.auth.restore());
      final perfil = _ok(await outra.users.getProfile());

      expect(restored, session);
      expect(perfil.id, 'usr_01');
    });

    test('logout encerra no mock e uma chamada depois dá 401', () async {
      await app.entrar();
      final sessoes = _server.sessionCount;
      final token = app.client.token;

      final logout = await app.auth.logout();
      final semToken = await app.users.getProfile();
      // O token antigo também deixou de valer no servidor.
      app.client.token = token;
      final tokenAntigo = await app.transactions.summary(_mesAtual);

      expect(logout.isOk, isTrue);
      expect(app.auth.currentSession, isNull);
      expect(await app.storage.read(), isNull);
      expect(_server.sessionCount, sessoes - 1);
      expect(_erro(semToken), const UnauthorizedError());
      expect(_erro(tokenAntigo), const UnauthorizedError());
      expect(_erro(tokenAntigo).message, 'Você precisa entrar para continuar.');
    });
  });

  group('perfil', () {
    setUp(() => app.entrar());

    test('getProfile devolve o usuário da sessão', () async {
      final user = _ok(await app.users.getProfile());

      expect(user.id, 'usr_01');
      expect(user.name, 'Ana Ribeiro');
      expect(user.email, 'ana@carteira.dev');
      expect(user.avatarUrl, isNull);
      expect(user.createdAt, DateTime.utc(2024, 3, 11, 9));
      expect(user.initials, 'AR');
    });

    test('updateProfile salva e o getProfile seguinte enxerga', () async {
      final atualizado = _ok(
        await app.users.updateProfile(
          name: '  Ana R. ',
          avatarUrl: 'https://img.dev/ana.png',
        ),
      );
      final lido = _ok(await app.users.getProfile());

      expect(atualizado.name, 'Ana R.');
      expect(atualizado.avatarUrl, 'https://img.dev/ana.png');
      expect(atualizado.email, 'ana@carteira.dev');
      expect(lido, atualizado);
    });

    test('nome vazio vira ValidationError com fields.name', () async {
      final result = await app.users.updateProfile(name: '   ');

      final erro = _erro(result);
      expect(erro, isA<ValidationError>());
      expect((erro as ValidationError).fields, {'name': 'must not be empty'});
      expect(erro.detail, 'Invalid user');
    });

    test('o segundo usuário de teste tem o próprio perfil', () async {
      final bruno = _App();
      addTearDown(bruno.fechar);
      await bruno.entrar('bruno@carteira.dev');

      final user = _ok(await bruno.users.getProfile());

      expect(user.id, 'usr_02');
      expect(user.initials, 'BL');
    });
  });

  group('resumo', () {
    setUp(() => app.entrar());

    test('summary do mês atual bate com a referência', () async {
      final summary = _ok(await app.transactions.summary(_mesAtual));

      expect(
        summary,
        const Summary(month: _mesAtual, income: 9526.55, expense: 5330.04),
      );
      expect(summary.balance, closeTo(4196.51, 0.001));
    });

    test('summary do mês anterior e de um mês vazio', () async {
      final anterior = _ok(await app.transactions.summary(_mesAnterior));
      final vazio = _ok(await app.transactions.summary('2020-01'));

      expect(anterior.income, 9526.55);
      expect(anterior.expense, 4920.84);
      expect(vazio, const Summary(month: '2020-01', income: 0, expense: 0));
    });

    test('mês inválido vira ValidationError', () async {
      final result = await app.transactions.summary('setembro');

      expect(
        _erro(result),
        const ValidationError({'month': 'must be in the format YYYY-MM'}),
      );
    });
  });

  group('lista', () {
    setUp(() => app.entrar());

    test('sem filtro traz o seed, com os subtipos certos', () async {
      final page = _ok(await app.transactions.list(const TransactionFilter()));

      expect(page.total, seedTransactionCount);
      expect(page.page, 1);
      expect(page.pageSize, 20);
      expect(page.hasMore, isTrue);
      expect(_ids(page), [for (var n = 60; n >= 41; n--) 'tx_00$n']);

      final mercado = page.items.first;
      expect(mercado, isA<Expense>());
      expect(mercado.description, 'Mercado Pão de Açúcar');
      expect(mercado.amount, 306.7);
      expect(mercado.signedAmount, -306.7);
      expect(mercado.date, DateTime.utc(2026, 9, 27, 20, 55));
      expect(mercado.note, 'Dividido com a Carla');

      final salario = page.items[1];
      expect(salario, isA<Income>());
      expect(salario.signedAmount, 9526.55);

      final reserva = page.items[2];
      expect(reserva, isA<Transfer>());
      expect((reserva as Transfer).toAccount, 'Itaú');
      expect(reserva.category, isNull);
      expect(reserva.signedAmount, 0);
    });

    test('o extrato padrão (20 por página) carrega até o fim', () async {
      var filtro = const TransactionFilter(pageSize: 20);
      final paginas = <Page<Transaction>>[];
      do {
        paginas.add(_ok(await app.transactions.list(filtro)));
        filtro = filtro.nextPage();
      } while (paginas.last.hasMore);

      expect(paginas, hasLength(3));
      expect([for (final p in paginas) p.items.length], [20, 20, 20]);
      expect([for (final p in paginas) p.hasMore], [true, true, false]);
      expect(_ids(paginas.last).last, 'tx_0001');
      expect({
        for (final p in paginas) ..._ids(p),
      }, hasLength(seedTransactionCount));
    });

    test('filtro por mês e tipo, página a página', () async {
      const filtro = TransactionFilter(
        month: _mesAtual,
        type: TransactionType.expense,
        pageSize: 2,
      );

      final primeira = _ok(await app.transactions.list(filtro));
      final segunda = _ok(await app.transactions.list(filtro.nextPage()));
      final alemDoFim = _ok(
        await app.transactions.list(filtro.copyWith(page: 5)),
      );

      expect(_ids(primeira), ['tx_0060', 'tx_0057']);
      expect(primeira.total, 4);
      expect(primeira.hasMore, isTrue);
      expect(primeira.items, everyElement(isA<Expense>()));
      expect(_ids(segunda), ['tx_0056', 'tx_0055']);
      expect(segunda.page, 2);
      expect(segunda.hasMore, isFalse);
      expect(alemDoFim.isEmpty, isTrue);
      expect(alemDoFim.total, 4);
    });

    test('busca por texto sem diferenciar maiúsculas', () async {
      final page = _ok(
        await app.transactions.list(const TransactionFilter(query: 'MERCADO')),
      );

      expect(_ids(page), [
        'tx_0060',
        'tx_0057',
        'tx_0043',
        'tx_0033',
        'tx_0023',
        'tx_0013',
        'tx_0003',
      ]);
      expect(page.total, 7);
    });

    test('filtro do mês anterior com receitas', () async {
      final page = _ok(
        await app.transactions.list(
          const TransactionFilter(
            month: _mesAnterior,
            type: TransactionType.income,
          ),
        ),
      );

      expect(_ids(page), ['tx_0053']);
      expect(page.items.single, isA<Income>());
    });

    test('pageSize fora da faixa vira ValidationError', () async {
      final result = await app.transactions.list(
        const TransactionFilter(pageSize: 500),
      );

      expect(
        _erro(result),
        const ValidationError({
          'pageSize': 'must be an integer between 1 and 100',
        }),
      );
    });
  });

  group('lançamentos', () {
    setUp(() => app.entrar());

    test('Income: cria, lê, edita, apaga e some com NotFoundError', () async {
      final novo = Income(
        id: 'ignorado',
        amount: 1250.5,
        description: 'Freela',
        date: DateTime.utc(2026, 9, 10, 15),
        account: 'Itaú',
        category: 'Renda extra',
      );

      final criado = _ok(await app.transactions.create(novo));
      expect(criado, isA<Income>());
      expect(criado.id, 'tx_0081');
      expect(criado, novo.copyWith(id: 'tx_0081'));

      final lido = _ok(await app.transactions.getById(criado.id));
      expect(lido, criado);

      final editado = _ok(
        await app.transactions.update(
          criado.copyWith(
            amount: 1300,
            description: 'Freela site',
            note: () => 'Pago via Pix',
          ),
        ),
      );
      expect(editado.id, 'tx_0081');
      expect(editado.amount, 1300);
      expect(editado.description, 'Freela site');
      expect(editado.note, 'Pago via Pix');
      expect(_ok(await app.transactions.getById(criado.id)), editado);

      final resumo = _ok(await app.transactions.summary(_mesAtual));
      expect(resumo.income, closeTo(9526.55 + 1300, 0.001));

      expect((await app.transactions.delete(criado.id)).isOk, isTrue);
      expect(
        _erro(await app.transactions.getById(criado.id)),
        const NotFoundError('Transaction tx_0081 not found'),
      );
      expect(
        _erro(await app.transactions.delete(criado.id)),
        isA<NotFoundError>(),
      );
    });

    test('Expense: os opcionais vazios voltam como null', () async {
      final novo = Expense(
        id: '',
        amount: 42.5,
        description: 'Padaria',
        date: DateTime.utc(2026, 9, 11, 8, 30),
        account: 'Nubank',
        category: 'Alimentação',
      );

      final criado = _ok(await app.transactions.create(novo));
      final lista = _ok(
        await app.transactions.list(
          const TransactionFilter(month: _mesAtual, query: 'padaria'),
        ),
      );
      final resumo = _ok(await app.transactions.summary(_mesAtual));

      expect(criado, isA<Expense>());
      expect(criado, novo.copyWith(id: criado.id));
      expect(criado.note, isNull);
      expect(lista.items.single, criado);
      expect(resumo.expense, closeTo(5330.04 + 42.5, 0.001));
    });

    test('Transfer: guarda toAccount e não mexe no resumo', () async {
      final antes = _ok(await app.transactions.summary(_mesAtual));
      final novo = Transfer(
        id: '',
        amount: 800,
        description: 'Poupança',
        date: DateTime.utc(2026, 9, 12),
        account: 'Itaú',
        toAccount: 'Nubank',
      );

      final criado = _ok(await app.transactions.create(novo));
      final lido = _ok(await app.transactions.getById(criado.id));
      final depois = _ok(await app.transactions.summary(_mesAtual));

      expect(lido, isA<Transfer>());
      expect((lido as Transfer).toAccount, 'Nubank');
      expect(lido, novo.copyWith(id: criado.id));
      expect(depois, antes);
    });

    test('update troca o subtipo de um lançamento do seed', () async {
      final original = _ok(await app.transactions.getById('tx_0058'));
      expect(original, isA<Transfer>());

      final virouDespesa = Expense(
        id: 'tx_0058',
        amount: original.amount,
        description: 'Reserva gasta',
        date: original.date,
        account: original.account,
      );
      final salvo = _ok(await app.transactions.update(virouDespesa));

      expect(salvo, virouDespesa);
      expect(
        _ok(await app.transactions.summary(_mesAtual)).expense,
        closeTo(5330.04 + 500, 0.001),
      );
    });

    test('update e delete de id inexistente viram NotFoundError', () async {
      final fantasma = Expense(
        id: 'tx_9999',
        amount: 10,
        description: 'Fantasma',
        date: DateTime.utc(2026, 9, 1),
        account: 'Nubank',
      );

      expect(
        _erro(await app.transactions.update(fantasma)),
        const NotFoundError('Transaction tx_9999 not found'),
      );
      expect(
        _erro(await app.transactions.delete('tx_9999')),
        isA<NotFoundError>(),
      );
    });

    test('422 do mock vira ValidationError campo a campo', () async {
      final invalido = Expense(
        id: '',
        amount: 0,
        description: '   ',
        date: DateTime.utc(2026, 9, 1),
        account: '',
      );

      final erro = _erro(await app.transactions.create(invalido));

      expect(erro, isA<ValidationError>());
      final validation = erro as ValidationError;
      expect(validation.fields, {
        'amount': 'must be greater than zero',
        'description': 'must not be empty',
        'account': 'must not be empty',
      });
      expect(validation.detail, 'Invalid transaction');
      expect(validation.message, 'Invalid transaction');
    });

    test('transferência sem destino vira ValidationError', () async {
      final semDestino = Transfer(
        id: '',
        amount: 100,
        description: 'Reserva',
        date: DateTime.utc(2026, 9, 1),
        account: 'Nubank',
        toAccount: ' ',
      );

      expect(
        _erro(await app.transactions.create(semDestino)),
        const ValidationError({'toAccount': 'is required for transfers'}),
      );
    });

    test('watch emite a lista nova depois de uma mutação', () async {
      final emitida = app.transactions.watch().first;

      await app.transactions.delete('tx_0060');
      final lista = await emitida.timeout(const Duration(seconds: 5));

      expect(lista, hasLength(seedTransactionCount - 1));
      expect(lista.map((t) => t.id), isNot(contains('tx_0060')));
    });

    test('duas sessões não enxergam os lançamentos uma da outra', () async {
      final outra = _App();
      addTearDown(outra.fechar);
      await outra.entrar();

      final criado = _ok(
        await app.transactions.create(
          Expense(
            id: '',
            amount: 15,
            description: 'Só minha',
            date: DateTime.utc(2026, 9, 2),
            account: 'Nubank',
          ),
        ),
      );

      expect(
        _erro(await outra.transactions.getById(criado.id)),
        isA<NotFoundError>(),
      );
      expect(
        _ok(await outra.transactions.list(const TransactionFilter())).total,
        seedTransactionCount,
      );
    });
  });

  group('falhas simuladas', () {
    test('X-Fail: expired vira UnauthorizedError(expired)', () async {
      final expirado = _App(headers: {'X-Fail': 'expired'});
      addTearDown(expirado.fechar);

      final erro = _erro(await expirado.users.getProfile());

      expect(erro, const UnauthorizedError(expired: true));
      expect(erro.message, 'Sua sessão expirou. Entre novamente.');
    });

    test('X-Fail: 500 vira ServerError(500)', () async {
      final quebrado = _App(headers: {'X-Fail': '500'});
      addTearDown(quebrado.fechar);

      final erro = _erro(await quebrado.transactions.summary(_mesAtual));

      expect(erro, const ServerError(500));
    });

    test('X-Delay-Ms além do timeout do cliente vira TimeoutError', () async {
      final lento = _App(
        timeout: const Duration(milliseconds: 200),
        headers: {'X-Delay-Ms': '3000'},
      );
      addTearDown(lento.fechar);

      final erro = _erro(
        await lento.auth.login(email: 'ana@carteira.dev', password: '123456'),
      );

      expect(erro, const TimeoutError());
    });

    test('mock fora do ar vira NetworkError', () async {
      final desligado = await startMockServer(port: 0);
      final baseUrl = desligado.baseUrl.toString();
      await desligado.close();
      final client = ApiClient(baseUrl: baseUrl);
      addTearDown(client.close);

      final result = await RemoteAuthRepository(
        client: client,
        storage: InMemorySessionStorage(),
      ).login(email: 'ana@carteira.dev', password: '123456');

      expect(_erro(result), const NetworkError());
    });
  });
}
