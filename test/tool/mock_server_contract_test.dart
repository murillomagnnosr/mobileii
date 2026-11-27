// Contrato do mock (tool/mock_server) conferido rota a rota contra a
// referência da API do curso (resumida em docs/api.md): status, formato das
// respostas, erros com as mensagens exatas, normalização dos campos,
// paginação e filtros, sessões, CORS e os cabeçalhos de simulação.
//
// Fala HTTP direto com dart:io, sem passar pela camada de dados do app (essa
// integração fica em mock_server_e2e_test.dart).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/mock_server/mock_server.dart';
import '../../tool/mock_server/seed.dart';

/// "Agora" fixo no fim do mês, para nenhuma data do seed ser limitada a
/// "agora": o mês atual é 2026-09 e o anterior, 2026-08.
final _agora = DateTime.utc(2026, 9, 30, 12);
const _mesAtual = '2026-09';
const _mesAnterior = '2026-08';

late MockServer _server;
late HttpClient _http;

/// Resposta já lida por inteiro.
class _Resposta {
  _Resposta(this.status, this.headers, this.texto);

  final int status;
  final HttpHeaders headers;
  final String texto;

  Object? get json => jsonDecode(texto);

  Map<String, Object?> get mapa => json! as Map<String, Object?>;

  List<Object?> get itens => mapa['items']! as List<Object?>;

  List<Object?> get ids => [for (final item in itens) (item! as Map)['id']];

  Map<String, Object?> get erro => mapa['error']! as Map<String, Object?>;

  Map<String, Object?> get campos => erro['fields']! as Map<String, Object?>;

  String? get contentType => headers.value(HttpHeaders.contentTypeHeader);
}

/// Faz uma requisição ao mock. [corpo] vai como JSON; [bruto] vai como está
/// (para testar JSON malformado).
Future<_Resposta> _req(
  String method,
  String path, {
  String? token,
  Object? corpo,
  String? bruto,
  Map<String, String> headers = const {},
}) async {
  final request = await _http.openUrl(method, _server.baseUrl.resolve(path));
  if (token != null) {
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
  }
  headers.forEach(request.headers.set);
  if (corpo != null || bruto != null) {
    request.headers.contentType = ContentType.json;
    request.write(bruto ?? jsonEncode(corpo));
  }
  final response = await request.close();
  final texto = await utf8.decoder.bind(response).join();
  return _Resposta(response.statusCode, response.headers, texto);
}

/// Faz login e devolve o token de uma sessão nova (com o seed intacto).
Future<String> _login([String email = 'ana@carteira.dev']) async {
  final resposta = await _req(
    'POST',
    '/auth/login',
    corpo: {'email': email, 'password': seedPassword},
  );
  expect(resposta.status, 200, reason: resposta.texto);
  return resposta.mapa['token']! as String;
}

/// Um lançamento válido no formato do POST, com [extra] sobrescrevendo campos.
Map<String, Object?> _lancamento([Map<String, Object?> extra = const {}]) => {
  'type': 'expense',
  'amount': 89.9,
  'description': 'Mercado',
  'category': 'Alimentação',
  'date': '$_mesAtual-06T14:32:00Z',
  'note': null,
  'account': 'Nubank',
  'toAccount': null,
  ...extra,
};

const _jsonUtf8 = 'application/json; charset=utf-8';
const _chavesTransaction = {
  'id',
  'type',
  'amount',
  'description',
  'category',
  'date',
  'note',
  'account',
  'toAccount',
};
const _chavesUser = {'id', 'name', 'email', 'avatarUrl', 'createdAt'};

void main() {
  setUpAll(() async {
    _server = await startMockServer(
      port: 0,
      minLatency: Duration.zero,
      maxLatency: Duration.zero,
      clock: () => _agora,
    );
    _http = HttpClient();
  });

  tearDownAll(() async {
    _http.close(force: true);
    await _server.close();
  });

  group('GET /health', () {
    test('responde 200 com status e versão, sem autenticação', () async {
      final resposta = await _req('GET', '/health');

      expect(resposta.status, 200);
      expect(resposta.contentType, _jsonUtf8);
      expect(resposta.json, {'status': 'ok', 'version': '0.1.0'});
      expect(MockServer.version, '0.1.0');
    });
  });

  group('POST /auth/login', () {
    test('devolve token tok_ + 24 caracteres e o user completo', () async {
      final resposta = await _req(
        'POST',
        '/auth/login',
        corpo: {'email': 'ana@carteira.dev', 'password': '123456'},
      );

      expect(resposta.status, 200);
      expect(resposta.contentType, _jsonUtf8);
      expect(resposta.mapa.keys.toSet(), {'token', 'user'});
      expect(resposta.mapa['token'], matches(RegExp(r'^tok_[0-9a-z]{24}$')));
      expect(resposta.mapa['user'], {
        'id': 'usr_01',
        'name': 'Ana Ribeiro',
        'email': 'ana@carteira.dev',
        'avatarUrl': null,
        'createdAt': '2024-03-11T09:00:00Z',
      });
    });

    test('cada login gera um token diferente', () async {
      final primeiro = await _login();
      final segundo = await _login();

      expect(primeiro, isNot(segundo));
    });

    test('o segundo usuário de teste também entra', () async {
      final token = await _login('bruno@carteira.dev');
      final me = await _req('GET', '/me', token: token);

      expect(me.mapa['id'], 'usr_02');
      expect(me.mapa['name'], 'Bruno Lima');
    });

    test('e-mail é aparado e comparado sem diferenciar maiúsculas', () async {
      final resposta = await _req(
        'POST',
        '/auth/login',
        corpo: {'email': '  ANA@Carteira.DEV ', 'password': '123456'},
      );

      expect(resposta.status, 200);
      expect((resposta.mapa['user']! as Map)['email'], 'ana@carteira.dev');
    });

    test('senha errada dá 401 invalid_credentials', () async {
      final resposta = await _req(
        'POST',
        '/auth/login',
        corpo: {'email': 'ana@carteira.dev', 'password': 'errada'},
      );

      expect(resposta.status, 401);
      expect(resposta.contentType, _jsonUtf8);
      expect(resposta.json, {
        'error': {
          'code': 'invalid_credentials',
          'message': 'Invalid email or password',
        },
      });
    });

    test('e-mail desconhecido dá 401 invalid_credentials', () async {
      final resposta = await _req(
        'POST',
        '/auth/login',
        corpo: {'email': 'carla@carteira.dev', 'password': '123456'},
      );

      expect(resposta.status, 401);
      expect(resposta.erro['code'], 'invalid_credentials');
    });

    test('campos vazios dão 422 com uma mensagem por campo', () async {
      final resposta = await _req(
        'POST',
        '/auth/login',
        corpo: {'email': '', 'password': ''},
      );

      expect(resposta.status, 422);
      expect(resposta.erro['code'], 'validation');
      expect(resposta.campos, {
        'email': 'must not be empty',
        'password': 'must not be empty',
      });
    });

    test('e-mail só com espaços conta como vazio', () async {
      final resposta = await _req(
        'POST',
        '/auth/login',
        corpo: {'email': '   ', 'password': '123456'},
      );

      expect(resposta.status, 422);
      expect(resposta.campos, {'email': 'must not be empty'});
    });

    test('campos ausentes dão 422 e tipos errados também', () async {
      final ausentes = await _req('POST', '/auth/login', corpo: {});
      final tipos = await _req(
        'POST',
        '/auth/login',
        corpo: {'email': 42, 'password': true},
      );

      expect(ausentes.status, 422);
      expect(ausentes.campos, {
        'email': 'must not be empty',
        'password': 'must not be empty',
      });
      expect(tipos.status, 422);
      expect(tipos.campos, {
        'email': 'must be a string',
        'password': 'must be a string',
      });
    });

    test('JSON malformado dá 400 bad_request', () async {
      final resposta = await _req('POST', '/auth/login', bruto: '{"email":');

      expect(resposta.status, 400);
      expect(resposta.contentType, _jsonUtf8);
      expect(resposta.json, {
        'error': {'code': 'bad_request', 'message': 'Malformed JSON body'},
      });
    });

    test('corpo JSON que não é objeto dá 400', () async {
      final lista = await _req('POST', '/auth/login', bruto: '[1, 2]');
      final vazio = await _req('POST', '/auth/login', bruto: '');

      expect(lista.status, 400);
      expect(lista.erro['code'], 'bad_request');
      expect(vazio.status, 400);
    });
  });

  group('autenticação das rotas protegidas', () {
    final protegidas = [
      ('POST', '/auth/logout'),
      ('GET', '/me'),
      ('PUT', '/me'),
      ('GET', '/transactions'),
      ('GET', '/transactions/tx_0060'),
      ('POST', '/transactions'),
      ('PUT', '/transactions/tx_0060'),
      ('DELETE', '/transactions/tx_0060'),
      ('GET', '/summary'),
      ('POST', '/reset'),
    ];

    for (final (method, path) in protegidas) {
      test('$method $path sem token dá 401 unauthorized', () async {
        final resposta = await _req(method, path);

        expect(resposta.status, 401);
        expect(resposta.contentType, _jsonUtf8);
        expect(resposta.erro['code'], 'unauthorized');
        expect(resposta.erro['message'], isA<String>());
      });
    }

    test('token desconhecido dá 401 unauthorized', () async {
      final resposta = await _req(
        'GET',
        '/me',
        token: 'tok_000000000000000000000000',
      );

      expect(resposta.status, 401);
      expect(resposta.erro['code'], 'unauthorized');
    });

    test('esquema diferente de Bearer dá 401', () async {
      final token = await _login();
      final resposta = await _req(
        'GET',
        '/me',
        headers: {'Authorization': 'Basic $token'},
      );

      expect(resposta.status, 401);
      expect(resposta.erro['code'], 'unauthorized');
    });

    test('aceita "bearer" em qualquer caixa', () async {
      final token = await _login();
      final resposta = await _req(
        'GET',
        '/me',
        headers: {'Authorization': 'bEaReR $token'},
      );

      expect(resposta.status, 200);
    });
  });

  group('POST /auth/logout', () {
    test('responde 204 sem corpo e o token passa a dar 401', () async {
      final token = await _login();
      final sessoesAntes = _server.sessionCount;

      final logout = await _req('POST', '/auth/logout', token: token);
      final depois = await _req('GET', '/me', token: token);
      final deNovo = await _req('POST', '/auth/logout', token: token);

      expect(logout.status, 204);
      expect(logout.texto, isEmpty);
      expect(_server.sessionCount, sessoesAntes - 1);
      expect(depois.status, 401);
      expect(depois.erro['code'], 'unauthorized');
      expect(deNovo.status, 401);
    });

    test('encerrar uma sessão não afeta outra do mesmo usuário', () async {
      final primeira = await _login();
      final segunda = await _login();

      await _req('POST', '/auth/logout', token: primeira);
      final resposta = await _req('GET', '/me', token: segunda);

      expect(resposta.status, 200);
    });
  });

  group('GET /me', () {
    test('devolve o user da sessão com todos os campos', () async {
      final token = await _login();
      final resposta = await _req('GET', '/me', token: token);

      expect(resposta.status, 200);
      expect(resposta.contentType, _jsonUtf8);
      expect(resposta.json, seedUsers['ana@carteira.dev']);
      expect(resposta.mapa.keys.toSet(), _chavesUser);
    });
  });

  group('PUT /me', () {
    test('atualiza nome (aparado) e avatar e devolve o user', () async {
      final token = await _login();
      final resposta = await _req(
        'PUT',
        '/me',
        token: token,
        corpo: {'name': '  Ana R.  ', 'avatarUrl': 'https://img.dev/ana.png'},
      );
      final me = await _req('GET', '/me', token: token);

      expect(resposta.status, 200);
      expect(resposta.json, {
        'id': 'usr_01',
        'name': 'Ana R.',
        'email': 'ana@carteira.dev',
        'avatarUrl': 'https://img.dev/ana.png',
        'createdAt': '2024-03-11T09:00:00Z',
      });
      expect(me.json, resposta.json);
    });

    test('avatar vazio vira null', () async {
      final token = await _login();
      final resposta = await _req(
        'PUT',
        '/me',
        token: token,
        corpo: {'name': 'Ana', 'avatarUrl': '   '},
      );

      expect(resposta.status, 200);
      expect(resposta.mapa['avatarUrl'], isNull);
    });

    test('os outros campos do user não mudam', () async {
      final token = await _login();
      final resposta = await _req(
        'PUT',
        '/me',
        token: token,
        corpo: {
          'name': 'Ana R.',
          'avatarUrl': null,
          'id': 'usr_99',
          'email': 'outra@carteira.dev',
          'createdAt': '2020-01-01T00:00:00Z',
        },
      );

      expect(resposta.status, 200);
      expect(resposta.mapa['id'], 'usr_01');
      expect(resposta.mapa['email'], 'ana@carteira.dev');
      expect(resposta.mapa['createdAt'], '2024-03-11T09:00:00Z');
      expect(resposta.mapa.keys.toSet(), _chavesUser);
    });

    test('nome vazio dá 422 com fields.name', () async {
      final token = await _login();
      final resposta = await _req(
        'PUT',
        '/me',
        token: token,
        corpo: {'name': '  ', 'avatarUrl': null},
      );
      final me = await _req('GET', '/me', token: token);

      expect(resposta.status, 422);
      expect(resposta.erro['code'], 'validation');
      expect(resposta.erro['message'], 'Invalid user');
      expect(resposta.campos, {'name': 'must not be empty'});
      expect(me.mapa['name'], 'Ana Ribeiro');
    });

    test('tipos errados dão 422 em vez de 500', () async {
      final token = await _login();
      final resposta = await _req(
        'PUT',
        '/me',
        token: token,
        corpo: {'name': 7, 'avatarUrl': false},
      );

      expect(resposta.status, 422);
      expect(resposta.campos, {
        'name': 'must be a string',
        'avatarUrl': 'must be a string or null',
      });
    });

    test('JSON malformado dá 400', () async {
      final token = await _login();
      final resposta = await _req('PUT', '/me', token: token, bruto: 'nome');

      expect(resposta.status, 400);
      expect(resposta.erro['code'], 'bad_request');
    });
  });

  group('GET /transactions', () {
    test('sem filtros lista o seed do mais recente ao mais antigo', () async {
      final token = await _login();
      final resposta = await _req('GET', '/transactions', token: token);

      expect(resposta.status, 200);
      expect(resposta.contentType, _jsonUtf8);
      expect(resposta.mapa.keys.toSet(), {
        'items',
        'page',
        'pageSize',
        'total',
      });
      expect(resposta.mapa['page'], 1);
      expect(resposta.mapa['pageSize'], 20);
      expect(resposta.mapa['total'], seedTransactionCount);
      expect(resposta.ids, [for (var n = 60; n >= 41; n--) 'tx_00$n']);
    });

    test('cada item tem todos os campos, com null nos opcionais', () async {
      final token = await _login();
      final resposta = await _req('GET', '/transactions', token: token);

      for (final item in resposta.itens) {
        expect((item! as Map).keys.toSet(), _chavesTransaction);
      }
      expect(resposta.itens.first, {
        'id': 'tx_0060',
        'type': 'expense',
        'amount': 306.7,
        'description': 'Mercado Pão de Açúcar',
        'category': 'Alimentação',
        'date': '$_mesAtual-27T20:55:00Z',
        'note': 'Dividido com a Carla',
        'account': 'Nubank',
        'toAccount': null,
      });
      expect(resposta.itens[2], {
        'id': 'tx_0058',
        'type': 'transfer',
        'amount': 500,
        'description': 'Reserva',
        'category': null,
        'date': '$_mesAtual-20T09:00:00Z',
        'note': null,
        'account': 'Nubank',
        'toAccount': 'Itaú',
      });
    });

    test('filtra por mês', () async {
      final token = await _login();
      final atual = await _req(
        'GET',
        '/transactions?month=$_mesAtual',
        token: token,
      );
      final anterior = await _req(
        'GET',
        '/transactions?month=$_mesAnterior',
        token: token,
      );
      final vazio = await _req(
        'GET',
        '/transactions?month=2020-01',
        token: token,
      );

      expect(atual.mapa['total'], 6);
      expect(atual.ids, [
        'tx_0060',
        'tx_0059',
        'tx_0058',
        'tx_0057',
        'tx_0056',
        'tx_0055',
      ]);
      expect(anterior.mapa['total'], 4);
      expect(anterior.ids, ['tx_0054', 'tx_0053', 'tx_0052', 'tx_0051']);
      expect(vazio.mapa['total'], 0);
      expect(vazio.itens, isEmpty);
    });

    test('filtra por tipo e combina com o mês', () async {
      final token = await _login();
      final despesas = await _req(
        'GET',
        '/transactions?month=$_mesAtual&type=expense',
        token: token,
      );
      final transferencias = await _req(
        'GET',
        '/transactions?type=transfer',
        token: token,
      );
      final receitas = await _req(
        'GET',
        '/transactions?type=income',
        token: token,
      );

      expect(despesas.mapa['total'], 4);
      expect(despesas.ids, ['tx_0060', 'tx_0057', 'tx_0056', 'tx_0055']);
      expect(transferencias.ids, [
        'tx_0058',
        'tx_0047',
        'tx_0037',
        'tx_0027',
        'tx_0017',
        'tx_0007',
      ]);
      expect(receitas.ids, [
        'tx_0059',
        'tx_0053',
        'tx_0049',
        'tx_0039',
        'tx_0029',
        'tx_0019',
        'tx_0009',
      ]);
    });

    test('q busca na description sem diferenciar maiúsculas', () async {
      final token = await _login();
      final resposta = await _req(
        'GET',
        '/transactions?q=MERCADO',
        token: token,
      );
      final nada = await _req(
        'GET',
        '/transactions?q=inexistente',
        token: token,
      );

      expect(resposta.mapa['total'], 7);
      expect(resposta.ids, [
        'tx_0060',
        'tx_0057',
        'tx_0043',
        'tx_0033',
        'tx_0023',
        'tx_0013',
        'tx_0003',
      ]);
      expect(nada.mapa['total'], 0);
    });

    test('pagina e total conta os itens depois dos filtros', () async {
      final token = await _login();
      Future<_Resposta> pagina(int n) =>
          _req('GET', '/transactions?page=$n&pageSize=4', token: token);

      final primeira = await pagina(1);
      final segunda = await pagina(2);
      final terceira = await pagina(3);
      final filtrada = await _req(
        'GET',
        '/transactions?q=mercado&pageSize=1',
        token: token,
      );

      expect(primeira.ids, ['tx_0060', 'tx_0059', 'tx_0058', 'tx_0057']);
      expect(segunda.ids, ['tx_0056', 'tx_0055', 'tx_0054', 'tx_0053']);
      expect(segunda.mapa['page'], 2);
      expect(segunda.mapa['pageSize'], 4);
      expect(segunda.mapa['total'], seedTransactionCount);
      expect(terceira.ids, ['tx_0052', 'tx_0051', 'tx_0050', 'tx_0049']);
      expect(filtrada.ids, ['tx_0060']);
      expect(filtrada.mapa['total'], 7);
    });

    test('página além do fim devolve items vazio, não erro', () async {
      final token = await _login();
      final resposta = await _req(
        'GET',
        '/transactions?page=99&pageSize=20',
        token: token,
      );

      expect(resposta.status, 200);
      expect(resposta.itens, isEmpty);
      expect(resposta.mapa['page'], 99);
      expect(resposta.mapa['total'], seedTransactionCount);
    });

    test('pageSize aceita os limites 1 e 100', () async {
      final token = await _login();
      final um = await _req('GET', '/transactions?pageSize=1', token: token);
      final cem = await _req('GET', '/transactions?pageSize=100', token: token);

      expect(um.status, 200);
      expect(um.ids, ['tx_0060']);
      expect(cem.status, 200);
      expect(cem.itens, hasLength(seedTransactionCount));
    });

    test('datas iguais desempatam pelo id decrescente', () async {
      final token = await _login();
      const data = '2020-01-01T10:00:00Z';
      for (final descricao in ['Primeiro', 'Segundo', 'Terceiro']) {
        await _req(
          'POST',
          '/transactions',
          token: token,
          corpo: _lancamento({'description': descricao, 'date': data}),
        );
      }

      final resposta = await _req(
        'GET',
        '/transactions?month=2020-01',
        token: token,
      );

      expect(resposta.ids, ['tx_0083', 'tx_0082', 'tx_0081']);
    });

    test('parâmetros inválidos dão 422 com uma mensagem por campo', () async {
      final token = await _login();
      final resposta = await _req(
        'GET',
        '/transactions?month=2026-9&type=gasto&page=0&pageSize=101',
        token: token,
      );

      expect(resposta.status, 422);
      expect(resposta.erro['code'], 'validation');
      expect(resposta.erro['message'], 'Invalid parameters');
      expect(resposta.campos, {
        'month': 'must be in the format YYYY-MM',
        'type': 'must be income, expense or transfer',
        'page': 'must be an integer greater than zero',
        'pageSize': 'must be an integer between 1 and 100',
      });
    });

    test('page e pageSize não numéricos e mês 13 dão 422', () async {
      final token = await _login();
      final resposta = await _req(
        'GET',
        '/transactions?month=2026-13&page=abc&pageSize=0',
        token: token,
      );

      expect(resposta.status, 422);
      expect(resposta.campos.keys.toSet(), {'month', 'page', 'pageSize'});
    });
  });

  group('GET /transactions/:id', () {
    test('devolve um lançamento', () async {
      final token = await _login();
      final resposta = await _req('GET', '/transactions/tx_0057', token: token);

      expect(resposta.status, 200);
      expect(resposta.contentType, _jsonUtf8);
      expect(resposta.json, {
        'id': 'tx_0057',
        'type': 'expense',
        'amount': 89.9,
        'description': 'Mercado',
        'category': 'Alimentação',
        'date': '$_mesAtual-06T14:32:00Z',
        'note': null,
        'account': 'Nubank',
        'toAccount': null,
      });
    });

    test('id inexistente dá 404 com a mensagem da referência', () async {
      final token = await _login();
      final resposta = await _req('GET', '/transactions/tx_9999', token: token);

      expect(resposta.status, 404);
      expect(resposta.contentType, _jsonUtf8);
      expect(resposta.json, {
        'error': {
          'code': 'not_found',
          'message': 'Transaction tx_9999 not found',
        },
      });
    });
  });

  group('POST /transactions', () {
    test('cria com 201, gera tx_0081 e ignora o id do corpo', () async {
      final token = await _login();
      final resposta = await _req(
        'POST',
        '/transactions',
        token: token,
        corpo: _lancamento({'id': 'tx_9999'}),
      );
      final lido = await _req('GET', '/transactions/tx_0081', token: token);
      final ignorado = await _req('GET', '/transactions/tx_9999', token: token);

      expect(resposta.status, 201);
      expect(resposta.contentType, _jsonUtf8);
      expect(resposta.json, {
        'id': 'tx_0081',
        'type': 'expense',
        'amount': 89.9,
        'description': 'Mercado',
        'category': 'Alimentação',
        'date': '$_mesAtual-06T14:32:00Z',
        'note': null,
        'account': 'Nubank',
        'toAccount': null,
      });
      expect(lido.json, resposta.json);
      expect(ignorado.status, 404);
    });

    test('os ids seguem em sequência', () async {
      final token = await _login();
      final ids = <Object?>[];
      for (var i = 0; i < 3; i++) {
        final resposta = await _req(
          'POST',
          '/transactions',
          token: token,
          corpo: _lancamento(),
        );
        ids.add(resposta.mapa['id']);
      }

      expect(ids, ['tx_0081', 'tx_0082', 'tx_0083']);
    });

    test('normaliza valor, textos, opcionais e toAccount', () async {
      final token = await _login();
      final resposta = await _req(
        'POST',
        '/transactions',
        token: token,
        corpo: _lancamento({
          'amount': 89.899,
          'description': '  Café  ',
          'category': '',
          'note': '   ',
          'account': ' Nubank ',
          'toAccount': 'Itaú',
        }),
      );

      expect(resposta.status, 201);
      expect(resposta.mapa['amount'], 89.9);
      expect(resposta.mapa['description'], 'Café');
      expect(resposta.mapa['category'], isNull);
      expect(resposta.mapa['note'], isNull);
      expect(resposta.mapa['account'], 'Nubank');
      // toAccount só existe em transferência.
      expect(resposta.mapa['toAccount'], isNull);
      expect(resposta.mapa.keys.toSet(), _chavesTransaction);
    });

    test('valor inteiro é aceito e devolvido como número', () async {
      final token = await _login();
      final resposta = await _req(
        'POST',
        '/transactions',
        token: token,
        corpo: _lancamento({'amount': 500}),
      );

      expect(resposta.status, 201);
      expect(resposta.mapa['amount'], 500);
    });

    test('transferência guarda o toAccount aparado', () async {
      final token = await _login();
      final resposta = await _req(
        'POST',
        '/transactions',
        token: token,
        corpo: _lancamento({
          'type': 'transfer',
          'amount': 250,
          'description': 'Reserva',
          'category': null,
          'toAccount': '  Itaú ',
        }),
      );

      expect(resposta.status, 201);
      expect(resposta.mapa['type'], 'transfer');
      expect(resposta.mapa['toAccount'], 'Itaú');
    });

    final datas = {
      '2026-09-06T11:32:00-03:00': '2026-09-06T14:32:00Z',
      '2026-09-06T17:02:00+0230': '2026-09-06T14:32:00Z',
      '2026-09-06T14:32:00.123Z': '2026-09-06T14:32:00Z',
      '2026-09-06T14:32:00': '2026-09-06T14:32:00Z',
      '2026-09-06T14:32Z': '2026-09-06T14:32:00Z',
      '2026-09-06': '2026-09-06T00:00:00Z',
      '2026-09-05T23:00:00-03:00': '2026-09-06T02:00:00Z',
      '2026-09-06T17:32+03': '2026-09-06T14:32:00Z',
      '2026-09-06t14:32:00z': '2026-09-06T14:32:00Z',
    };
    for (final MapEntry(key: entrada, value: saida) in datas.entries) {
      test('data "$entrada" é devolvida em UTC como "$saida"', () async {
        final token = await _login();
        final resposta = await _req(
          'POST',
          '/transactions',
          token: token,
          corpo: _lancamento({'date': entrada}),
        );

        expect(resposta.status, 201, reason: resposta.texto);
        expect(resposta.mapa['date'], saida);
      });
    }

    test('erros da referência dão 422 com uma mensagem por campo', () async {
      final token = await _login();
      final resposta = await _req(
        'POST',
        '/transactions',
        token: token,
        corpo: _lancamento({
          'type': 'transfer',
          'amount': 0,
          'description': '',
          'date': 'ontem',
          'toAccount': null,
        }),
      );

      expect(resposta.status, 422);
      expect(resposta.contentType, _jsonUtf8);
      expect(resposta.json, {
        'error': {
          'code': 'validation',
          'message': 'Invalid transaction',
          'fields': {
            'amount': 'must be greater than zero',
            'description': 'must not be empty',
            'date': 'must be an ISO 8601 date',
            'toAccount': 'is required for transfers',
          },
        },
      });
    });

    test('tipo, conta e tipos de campo errados dão 422', () async {
      final token = await _login();
      final resposta = await _req(
        'POST',
        '/transactions',
        token: token,
        corpo: {
          'type': 'gasto',
          'amount': '10',
          'description': 3,
          'category': 5,
          'date': 20260906,
          'note': ['x'],
          'account': '  ',
        },
      );

      expect(resposta.status, 422);
      expect(resposta.campos, {
        'type': 'must be income, expense or transfer',
        'amount': 'must be a number',
        'description': 'must be a string',
        'category': 'must be a string or null',
        'date': 'must be an ISO 8601 date',
        'note': 'must be a string or null',
        'account': 'must not be empty',
      });
    });

    test('corpo vazio lista todos os obrigatórios', () async {
      final token = await _login();
      final resposta = await _req(
        'POST',
        '/transactions',
        token: token,
        corpo: <String, Object?>{},
      );

      expect(resposta.status, 422);
      expect(resposta.campos.keys.toSet(), {
        'type',
        'amount',
        'description',
        'date',
        'account',
      });
    });

    final valoresInvalidos = <Object>[-10, 0, 0.004];
    for (final valor in valoresInvalidos) {
      test('amount $valor dá 422 must be greater than zero', () async {
        final token = await _login();
        final resposta = await _req(
          'POST',
          '/transactions',
          token: token,
          corpo: _lancamento({'amount': valor}),
        );

        expect(resposta.status, 422);
        expect(resposta.campos, {'amount': 'must be greater than zero'});
      });
    }

    final datasInvalidas = [
      '2026-02-30T10:00:00Z',
      '2026-13-01T00:00:00Z',
      '2026-09-06T25:00:00Z',
      '2026-09-06T14:60:00Z',
      '06/09/2026',
      '20260906T143200Z',
      '2026-09-06T14:32:00+3',
      '',
    ];
    for (final data in datasInvalidas) {
      test('data "$data" dá 422 must be an ISO 8601 date', () async {
        final token = await _login();
        final resposta = await _req(
          'POST',
          '/transactions',
          token: token,
          corpo: _lancamento({'date': data}),
        );

        expect(resposta.status, 422);
        expect(resposta.campos, {'date': 'must be an ISO 8601 date'});
      });
    }

    test('29 de fevereiro só vale em ano bissexto', () async {
      final token = await _login();
      final bissexto = await _req(
        'POST',
        '/transactions',
        token: token,
        corpo: _lancamento({'date': '2028-02-29T10:00:00Z'}),
      );
      final comum = await _req(
        'POST',
        '/transactions',
        token: token,
        corpo: _lancamento({'date': '2027-02-29T10:00:00Z'}),
      );

      expect(bissexto.status, 201);
      expect(comum.status, 422);
    });

    test('JSON malformado dá 400 e não cria nada', () async {
      final token = await _login();
      final resposta = await _req(
        'POST',
        '/transactions',
        token: token,
        bruto: '{"type": "expense",',
      );
      final lista = await _req('GET', '/transactions', token: token);

      expect(resposta.status, 400);
      expect(resposta.erro['code'], 'bad_request');
      expect(lista.mapa['total'], seedTransactionCount);
    });
  });

  group('PUT /transactions/:id', () {
    test('substitui o lançamento inteiro, como no exemplo', () async {
      final token = await _login();
      final resposta = await _req(
        'PUT',
        '/transactions/tx_0060',
        token: token,
        corpo: {
          'type': 'transfer',
          'amount': 500,
          'description': 'Reserva',
          'category': null,
          'date': '2026-09-27T20:55:00Z',
          'note': null,
          'account': 'Nubank',
          'toAccount': 'Itaú',
        },
      );
      final lido = await _req('GET', '/transactions/tx_0060', token: token);

      expect(resposta.status, 200);
      expect(resposta.contentType, _jsonUtf8);
      expect(resposta.json, {
        'id': 'tx_0060',
        'type': 'transfer',
        'amount': 500.0,
        'description': 'Reserva',
        'category': null,
        'date': '2026-09-27T20:55:00Z',
        'note': null,
        'account': 'Nubank',
        'toAccount': 'Itaú',
      });
      expect(lido.json, resposta.json);
    });

    test('o id do caminho prevalece sobre o do corpo', () async {
      final token = await _login();
      final resposta = await _req(
        'PUT',
        '/transactions/tx_0057',
        token: token,
        corpo: _lancamento({'id': 'tx_0059', 'description': 'Feira'}),
      );
      final outro = await _req('GET', '/transactions/tx_0059', token: token);

      expect(resposta.status, 200);
      expect(resposta.mapa['id'], 'tx_0057');
      expect(resposta.mapa['description'], 'Feira');
      expect(outro.mapa['description'], 'Salário');
    });

    test('normaliza como no POST', () async {
      final token = await _login();
      final resposta = await _req(
        'PUT',
        '/transactions/tx_0058',
        token: token,
        corpo: _lancamento({
          'amount': 10.004,
          'description': ' Padaria ',
          'note': '',
          'date': '2026-09-20T06:00:00-03:00',
          'toAccount': 'Itaú',
        }),
      );

      expect(resposta.status, 200);
      expect(resposta.mapa['type'], 'expense');
      expect(resposta.mapa['amount'], 10.0);
      expect(resposta.mapa['description'], 'Padaria');
      expect(resposta.mapa['note'], isNull);
      expect(resposta.mapa['date'], '2026-09-20T09:00:00Z');
      expect(resposta.mapa['toAccount'], isNull);
    });

    test('id inexistente com corpo válido dá 404', () async {
      final token = await _login();
      final resposta = await _req(
        'PUT',
        '/transactions/tx_9999',
        token: token,
        corpo: _lancamento(),
      );

      expect(resposta.status, 404);
      expect(resposta.erro, {
        'code': 'not_found',
        'message': 'Transaction tx_9999 not found',
      });
    });

    test('a validação vem antes do 404', () async {
      final token = await _login();
      final resposta = await _req(
        'PUT',
        '/transactions/tx_9999',
        token: token,
        corpo: _lancamento({'amount': -1}),
      );

      expect(resposta.status, 422);
      expect(resposta.campos, {'amount': 'must be greater than zero'});
    });

    test('corpo inválido não altera o lançamento', () async {
      final token = await _login();
      final resposta = await _req(
        'PUT',
        '/transactions/tx_0060',
        token: token,
        corpo: _lancamento({'description': ''}),
      );
      final lido = await _req('GET', '/transactions/tx_0060', token: token);

      expect(resposta.status, 422);
      expect(lido.mapa['description'], 'Mercado Pão de Açúcar');
    });

    test('JSON malformado dá 400', () async {
      final token = await _login();
      final resposta = await _req(
        'PUT',
        '/transactions/tx_0060',
        token: token,
        bruto: '{',
      );

      expect(resposta.status, 400);
      expect(resposta.erro['code'], 'bad_request');
    });
  });

  group('DELETE /transactions/:id', () {
    test('remove com 204 e apagar de novo dá 404', () async {
      final token = await _login();
      final primeiro = await _req(
        'DELETE',
        '/transactions/tx_0060',
        token: token,
      );
      final lido = await _req('GET', '/transactions/tx_0060', token: token);
      final segundo = await _req(
        'DELETE',
        '/transactions/tx_0060',
        token: token,
      );
      final lista = await _req('GET', '/transactions', token: token);

      expect(primeiro.status, 204);
      expect(primeiro.texto, isEmpty);
      expect(lido.status, 404);
      expect(segundo.status, 404);
      expect(segundo.erro['message'], 'Transaction tx_0060 not found');
      expect(lista.mapa['total'], seedTransactionCount - 1);
    });
  });

  group('GET /summary', () {
    test('soma o mês pedido como no exemplo da referência', () async {
      final token = await _login();
      final resposta = await _req(
        'GET',
        '/summary?month=$_mesAtual',
        token: token,
      );

      expect(resposta.status, 200);
      expect(resposta.contentType, _jsonUtf8);
      expect(resposta.json, {
        'month': _mesAtual,
        'income': 9526.55,
        'expense': 5330.04,
        'balance': 4196.51,
      });
    });

    test('sem month usa o mês atual', () async {
      final token = await _login();
      final resposta = await _req('GET', '/summary', token: token);

      expect(resposta.status, 200);
      expect(resposta.mapa['month'], _mesAtual);
      expect(resposta.mapa['balance'], 4196.51);
    });

    test('soma o mês anterior e devolve zeros num mês sem dados', () async {
      final token = await _login();
      final anterior = await _req(
        'GET',
        '/summary?month=$_mesAnterior',
        token: token,
      );
      final vazio = await _req('GET', '/summary?month=2020-01', token: token);

      expect(anterior.json, {
        'month': _mesAnterior,
        'income': 9526.55,
        'expense': 4920.84,
        'balance': 4605.71,
      });
      expect(vazio.json, {
        'month': '2020-01',
        'income': 0,
        'expense': 0,
        'balance': 0,
      });
    });

    test('transferências ficam de fora do resumo', () async {
      final token = await _login();
      await _req(
        'POST',
        '/transactions',
        token: token,
        corpo: _lancamento({
          'type': 'transfer',
          'amount': 1000,
          'toAccount': 'Itaú',
        }),
      );
      final resposta = await _req(
        'GET',
        '/summary?month=$_mesAtual',
        token: token,
      );

      expect(resposta.mapa['income'], 9526.55);
      expect(resposta.mapa['expense'], 5330.04);
      expect(resposta.mapa['balance'], 4196.51);
    });

    test('acompanha criação, edição e remoção', () async {
      final token = await _login();
      await _req(
        'POST',
        '/transactions',
        token: token,
        corpo: _lancamento({'amount': 69.96}),
      );
      await _req('DELETE', '/transactions/tx_0055', token: token);
      await _req(
        'PUT',
        '/transactions/tx_0059',
        token: token,
        corpo: _lancamento({
          'type': 'income',
          'amount': 10000,
          'description': 'Salário',
          'date': '$_mesAtual-25T12:00:00Z',
        }),
      );
      final resposta = await _req(
        'GET',
        '/summary?month=$_mesAtual',
        token: token,
      );

      // Despesas: 5330.04 + 69.96 - 120 = 5280.00.
      expect(resposta.json, {
        'month': _mesAtual,
        'income': 10000,
        'expense': 5280,
        'balance': 4720,
      });
    });

    test('mês fora do formato dá 422', () async {
      final token = await _login();
      final resposta = await _req(
        'GET',
        '/summary?month=09-2026',
        token: token,
      );

      expect(resposta.status, 422);
      expect(resposta.erro['code'], 'validation');
      expect(resposta.campos, {'month': 'must be in the format YYYY-MM'});
    });
  });

  group('POST /reset', () {
    test(
      'volta ao seed (perfil, lançamentos e ids) e mantém o token',
      () async {
        final token = await _login();
        await _req(
          'PUT',
          '/me',
          token: token,
          corpo: {'name': 'Outra', 'avatarUrl': 'https://img.dev/x.png'},
        );
        await _req('DELETE', '/transactions/tx_0060', token: token);
        await _req('POST', '/transactions', token: token, corpo: _lancamento());
        await _req('POST', '/transactions', token: token, corpo: _lancamento());

        final reset = await _req('POST', '/reset', token: token);
        final me = await _req('GET', '/me', token: token);
        final lista = await _req('GET', '/transactions', token: token);
        final criado = await _req(
          'POST',
          '/transactions',
          token: token,
          corpo: _lancamento(),
        );

        expect(reset.status, 204);
        expect(reset.texto, isEmpty);
        expect(me.status, 200);
        expect(me.json, seedUsers['ana@carteira.dev']);
        expect(lista.mapa['total'], seedTransactionCount);
        expect(lista.ids.first, 'tx_0060');
        expect(criado.mapa['id'], 'tx_0081');
      },
    );

    test('só afeta a sessão que pediu', () async {
      final quemReseta = await _login();
      final outra = await _login();
      await _req('DELETE', '/transactions/tx_0060', token: outra);

      await _req('POST', '/reset', token: quemReseta);
      final lista = await _req('GET', '/transactions', token: outra);

      expect(lista.mapa['total'], seedTransactionCount - 1);
    });
  });

  group('dados por sessão', () {
    test('dois logins não veem as alterações um do outro', () async {
      final primeira = await _login();
      final segunda = await _login();

      final criado = await _req(
        'POST',
        '/transactions',
        token: primeira,
        corpo: _lancamento({'description': 'Só da primeira'}),
      );
      await _req('DELETE', '/transactions/tx_0060', token: primeira);
      await _req(
        'PUT',
        '/me',
        token: primeira,
        corpo: {'name': 'Ana Primeira', 'avatarUrl': null},
      );

      final listaSegunda = await _req('GET', '/transactions', token: segunda);
      final criadoNaSegunda = await _req(
        'GET',
        '/transactions/${criado.mapa['id']}',
        token: segunda,
      );
      final meSegunda = await _req('GET', '/me', token: segunda);
      final resumoSegunda = await _req('GET', '/summary', token: segunda);

      expect(listaSegunda.mapa['total'], seedTransactionCount);
      expect(listaSegunda.ids.first, 'tx_0060');
      expect(criadoNaSegunda.status, 404);
      expect(meSegunda.mapa['name'], 'Ana Ribeiro');
      expect(resumoSegunda.mapa['expense'], 5330.04);
    });

    test('cada sessão numera os próprios ids a partir de tx_0081', () async {
      final primeira = await _login();
      final segunda = await _login('bruno@carteira.dev');

      final a = await _req(
        'POST',
        '/transactions',
        token: primeira,
        corpo: _lancamento(),
      );
      final b = await _req(
        'POST',
        '/transactions',
        token: segunda,
        corpo: _lancamento(),
      );

      expect(a.mapa['id'], 'tx_0081');
      expect(b.mapa['id'], 'tx_0081');
    });

    test('sessionCount conta logins sem logout', () async {
      final antes = _server.sessionCount;
      final token = await _login();
      expect(_server.sessionCount, antes + 1);

      await _req('POST', '/auth/logout', token: token);
      expect(_server.sessionCount, antes);
    });
  });

  group('rota inexistente', () {
    test('com token dá 404 Route <caminho> not found', () async {
      final token = await _login();
      final resposta = await _req('GET', '/nada', token: token);

      expect(resposta.status, 404);
      expect(resposta.contentType, _jsonUtf8);
      expect(resposta.json, {
        'error': {'code': 'not_found', 'message': 'Route /nada not found'},
      });
    });

    test('verbo sem rota também dá 404', () async {
      final token = await _login();
      final patch = await _req('PATCH', '/me', token: token);
      final delete = await _req('DELETE', '/transactions', token: token);
      final aninhada = await _req(
        'GET',
        '/transactions/tx_0060/extra',
        token: token,
      );

      expect(patch.status, 404);
      expect(patch.erro['message'], 'Route /me not found');
      expect(delete.status, 404);
      expect(aninhada.status, 404);
      expect(
        aninhada.erro['message'],
        'Route /transactions/tx_0060/extra not found',
      );
    });

    test('/transactions/ com id vazio é rota inexistente', () async {
      final token = await _login();
      final resposta = await _req('GET', '/transactions/', token: token);

      expect(resposta.status, 404);
      expect(resposta.erro['message'], 'Route /transactions/ not found');
    });

    test('sem token a autenticação vem antes e dá 401', () async {
      final resposta = await _req('GET', '/nada');

      expect(resposta.status, 401);
      expect(resposta.erro['code'], 'unauthorized');
    });
  });

  group('CORS', () {
    test('OPTIONS responde 204 sem token, com os cabeçalhos de CORS', () async {
      final resposta = await _req(
        'OPTIONS',
        '/transactions',
        headers: {
          'Origin': 'http://localhost:5000',
          'Access-Control-Request-Method': 'PUT',
          'Access-Control-Request-Headers': 'authorization,content-type,x-fail',
        },
      );

      expect(resposta.status, 204);
      expect(resposta.texto, isEmpty);
      expect(resposta.headers.value('access-control-allow-origin'), '*');
      final metodos = resposta.headers
          .value('access-control-allow-methods')!
          .split(',')
          .map((m) => m.trim());
      expect(metodos, containsAll(['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']));
      expect(
        resposta.headers.value('access-control-allow-headers'),
        'authorization,content-type,x-fail',
      );
      expect(resposta.headers.value('access-control-max-age'), '600');
    });

    test('preflight sem cabeçalhos pedidos lista Authorization', () async {
      final resposta = await _req('OPTIONS', '/me');

      expect(resposta.status, 204);
      expect(
        resposta.headers.value('access-control-allow-headers'),
        contains('Authorization'),
      );
    });

    test('respostas comuns e de erro também liberam qualquer origem', () async {
      final health = await _req('GET', '/health');
      final erro = await _req('GET', '/me');

      expect(health.headers.value('access-control-allow-origin'), '*');
      expect(erro.headers.value('access-control-allow-origin'), '*');
    });
  });

  group('cabeçalhos de simulação', () {
    test(
      'X-Fail: 500 dá 500 internal em qualquer rota, antes da auth',
      () async {
        final health = await _req('GET', '/health', headers: {'X-Fail': '500'});
        final semToken = await _req('GET', '/me', headers: {'X-Fail': '500'});

        for (final resposta in [health, semToken]) {
          expect(resposta.status, 500);
          expect(resposta.contentType, _jsonUtf8);
          expect(resposta.json, {
            'error': {'code': 'internal', 'message': 'Simulated failure'},
          });
        }
      },
    );

    test(
      'X-Fail: expired dá 401 token_expired mesmo com token válido',
      () async {
        final token = await _login();
        final resposta = await _req(
          'GET',
          '/me',
          token: token,
          headers: {'X-Fail': 'expired'},
        );
        final semToken = await _req(
          'GET',
          '/transactions',
          headers: {'X-Fail': 'expired'},
        );

        expect(resposta.status, 401);
        expect(resposta.json, {
          'error': {'code': 'token_expired', 'message': 'Token has expired'},
        });
        expect(semToken.status, 401);
        expect(semToken.erro['code'], 'token_expired');
      },
    );

    test('X-Fail não altera os dados', () async {
      final token = await _login();
      await _req(
        'DELETE',
        '/transactions/tx_0060',
        token: token,
        headers: {'X-Fail': '500'},
      );
      final lido = await _req('GET', '/transactions/tx_0060', token: token);

      expect(lido.status, 200);
    });

    test('X-Fail com valor desconhecido é ignorado', () async {
      final resposta = await _req(
        'GET',
        '/health',
        headers: {'X-Fail': 'talvez'},
      );

      expect(resposta.status, 200);
    });

    test('X-Delay-Ms segura a resposta pelo tempo pedido', () async {
      final relogio = Stopwatch()..start();
      final resposta = await _req(
        'GET',
        '/health',
        headers: {'X-Delay-Ms': '400'},
      );
      relogio.stop();

      expect(resposta.status, 200);
      expect(relogio.elapsedMilliseconds, greaterThanOrEqualTo(380));
      expect(relogio.elapsedMilliseconds, lessThan(3000));
    });

    test('X-Delay-Ms vale antes do X-Fail', () async {
      final relogio = Stopwatch()..start();
      final resposta = await _req(
        'GET',
        '/health',
        headers: {'X-Delay-Ms': '250', 'X-Fail': '500'},
      );
      relogio.stop();

      expect(resposta.status, 500);
      expect(relogio.elapsedMilliseconds, greaterThanOrEqualTo(230));
    });
  });

  group('servidor', () {
    test('baseUrl usa 127.0.0.1 e a porta real quando sobe na porta 0', () {
      expect(_server.port, isNot(0));
      expect(_server.baseUrl, Uri.parse('http://127.0.0.1:${_server.port}'));
      expect(_server.minLatency, Duration.zero);
      expect(_server.maxLatency, Duration.zero);
      expect(_server.timeoutHold, MockServer.defaultTimeoutHold);
    });

    test('padrões documentados', () {
      expect(MockServer.defaultPort, 8080);
      expect(MockServer.defaultMinLatency, const Duration(milliseconds: 300));
      expect(MockServer.defaultMaxLatency, const Duration(milliseconds: 800));
      expect(MockServer.defaultTimeoutHold, const Duration(seconds: 60));
    });

    test('latência inválida lança ArgumentError', () async {
      await expectLater(
        startMockServer(port: 0, minLatency: const Duration(milliseconds: -1)),
        throwsArgumentError,
      );
      await expectLater(
        startMockServer(
          port: 0,
          minLatency: const Duration(milliseconds: 500),
          maxLatency: const Duration(milliseconds: 100),
        ),
        throwsArgumentError,
      );
    });

    test('porta ocupada lança SocketException', () async {
      await expectLater(
        startMockServer(port: _server.port),
        throwsA(isA<SocketException>()),
      );
    });

    test('address no loopback e log de uma linha por requisição', () async {
      final linhas = <String>[];
      final server = await startMockServer(
        port: 0,
        address: InternetAddress.loopbackIPv4,
        minLatency: Duration.zero,
        maxLatency: Duration.zero,
        log: linhas.add,
      );
      addTearDown(server.close);

      final request = await _http.getUrl(server.baseUrl.resolve('/health?x=1'));
      final response = await request.close();
      await response.drain<void>();

      expect(server.baseUrl.host, '127.0.0.1');
      expect(response.statusCode, 200);
      expect(linhas, ['GET /health?x=1']);
    });

    test('a latência sorteada respeita o mínimo', () async {
      final server = await startMockServer(
        port: 0,
        minLatency: const Duration(milliseconds: 200),
        maxLatency: const Duration(milliseconds: 250),
      );
      addTearDown(server.close);

      final relogio = Stopwatch()..start();
      final request = await _http.getUrl(server.baseUrl.resolve('/health'));
      await (await request.close()).drain<void>();
      relogio.stop();

      expect(relogio.elapsedMilliseconds, greaterThanOrEqualTo(190));
    });

    test('X-Delay-Ms: 0 dispensa a latência padrão', () async {
      final server = await startMockServer(
        port: 0,
        minLatency: const Duration(seconds: 2),
        maxLatency: const Duration(seconds: 2),
      );
      addTearDown(server.close);

      final relogio = Stopwatch()..start();
      final request = await _http.getUrl(server.baseUrl.resolve('/health'));
      request.headers.set('X-Delay-Ms', '0');
      await (await request.close()).drain<void>();
      relogio.stop();

      expect(relogio.elapsedMilliseconds, lessThan(1500));
    });

    test(
      'X-Fail: timeout segura pelo timeoutHold e dá 504 em texto puro',
      () async {
        final server = await startMockServer(
          port: 0,
          minLatency: Duration.zero,
          maxLatency: Duration.zero,
          timeoutHold: const Duration(milliseconds: 300),
        );
        addTearDown(server.close);

        final relogio = Stopwatch()..start();
        final request = await _http.getUrl(server.baseUrl.resolve('/me'));
        request.headers.set('X-Fail', 'timeout');
        final response = await request.close();
        final texto = await utf8.decoder.bind(response).join();
        relogio.stop();

        expect(response.statusCode, 504);
        expect(response.headers.contentType?.mimeType, 'text/plain');
        expect(texto, 'Gateway Timeout');
        expect(relogio.elapsedMilliseconds, greaterThanOrEqualTo(280));
      },
    );

    test(
      'um X-Fail: timeout pendente não trava as outras requisições',
      () async {
        final server = await startMockServer(
          port: 0,
          minLatency: Duration.zero,
          maxLatency: Duration.zero,
          timeoutHold: const Duration(seconds: 5),
        );
        addTearDown(server.close);
        final cliente = HttpClient();
        addTearDown(() => cliente.close(force: true));

        final pendente = Completer<int>();
        unawaited(
          () async {
            final request = await cliente.getUrl(server.baseUrl.resolve('/me'));
            request.headers.set('X-Fail', 'timeout');
            final response = await request.close();
            await response.drain<void>();
            pendente.complete(response.statusCode);
          }().catchError((Object _) => pendente.complete(-1)),
        );

        // Dá tempo para o pedido com timeout chegar primeiro.
        await Future<void>.delayed(const Duration(milliseconds: 100));
        final relogio = Stopwatch()..start();
        final request = await cliente.getUrl(server.baseUrl.resolve('/health'));
        final response = await request.close();
        await response.drain<void>();
        relogio.stop();

        expect(response.statusCode, 200);
        expect(relogio.elapsedMilliseconds, lessThan(2000));
        expect(pendente.isCompleted, isFalse);
      },
    );

    test('close() cancela esperas pendentes e encerra na hora', () async {
      final server = await startMockServer(
        port: 0,
        minLatency: Duration.zero,
        maxLatency: Duration.zero,
      );
      final cliente = HttpClient();
      addTearDown(() => cliente.close(force: true));

      final request = await cliente.getUrl(server.baseUrl.resolve('/me'));
      request.headers.set('X-Fail', 'timeout');
      final resposta = request.close().then(
        (response) => response.drain<void>(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final relogio = Stopwatch()..start();
      await server.close();
      await expectLater(resposta, throwsA(isA<IOException>()));
      relogio.stop();

      expect(relogio.elapsedMilliseconds, lessThan(2000));
      // Fechar de novo não faz nada.
      await server.close();
    });

    test('a latência sorteada respeita o máximo', () async {
      final server = await startMockServer(
        port: 0,
        minLatency: const Duration(milliseconds: 50),
        maxLatency: const Duration(milliseconds: 100),
      );
      addTearDown(server.close);

      for (var i = 0; i < 3; i++) {
        final relogio = Stopwatch()..start();
        final request = await _http.getUrl(server.baseUrl.resolve('/health'));
        await (await request.close()).drain<void>();
        relogio.stop();

        expect(relogio.elapsedMilliseconds, greaterThanOrEqualTo(45));
        expect(relogio.elapsedMilliseconds, lessThan(1000));
      }
    });

    test('erro inesperado vira 500 internal sem expor a exceção', () async {
      // O callback de log roda dentro do atendimento: lançar nele é a forma
      // de provocar uma falha que nenhuma rota trata.
      final linhas = <String>[];
      final server = await startMockServer(
        port: 0,
        minLatency: Duration.zero,
        maxLatency: Duration.zero,
        log: (linha) {
          if (linha.startsWith('GET /explode')) throw StateError('boom');
          linhas.add(linha);
        },
      );
      addTearDown(server.close);

      final request = await _http.getUrl(server.baseUrl.resolve('/explode'));
      final response = await request.close();
      final texto = await utf8.decoder.bind(response).join();
      final saude = await _http.getUrl(server.baseUrl.resolve('/health'));
      final depois = await saude.close();
      await depois.drain<void>();

      expect(response.statusCode, 500);
      expect(response.headers.value(HttpHeaders.contentTypeHeader), _jsonUtf8);
      expect(jsonDecode(texto), {
        'error': {'code': 'internal', 'message': 'Internal server error'},
      });
      expect(texto, isNot(contains('boom')));
      expect(linhas.first, startsWith('Erro em GET /explode: Bad state: boom'));
      expect(depois.statusCode, 200);
    });
  });

  group('respostas sem corpo e frases de status', () {
    test('todo 204 vem sem corpo e sem Content-Type', () async {
      final token = await _login();
      final respostas = [
        await _req('OPTIONS', '/transactions'),
        await _req('DELETE', '/transactions/tx_0059', token: token),
        await _req('POST', '/reset', token: token),
        await _req('POST', '/auth/logout', token: token),
      ];

      for (final resposta in respostas) {
        expect(resposta.status, 204);
        expect(resposta.texto, isEmpty);
        expect(resposta.contentType, isNull);
      }
    });

    test('422 usa a frase Unprocessable Entity', () async {
      final request = await _http.postUrl(
        _server.baseUrl.resolve('/auth/login'),
      );
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'email': '', 'password': ''}));
      final response = await request.close();
      await response.drain<void>();

      expect(response.statusCode, 422);
      expect(response.reasonPhrase, 'Unprocessable Entity');
    });

    test('URL com escape que não é UTF-8 dá 400 Malformed URL', () async {
      final token = await _login();
      final query = await _req('GET', '/transactions?q=%E0%A4%A', token: token);
      final caminho = await _req('GET', '/transactions/%E0%A4', token: token);

      for (final resposta in [query, caminho]) {
        expect(resposta.status, 400);
        expect(resposta.erro, {
          'code': 'bad_request',
          'message': 'Malformed URL',
        });
      }
    });
  });

  group('seed', () {
    test('tem tx_0001 a tx_0060, com ids em ordem cronológica', () async {
      final token = await _login();
      final resposta = await _req(
        'GET',
        '/transactions?pageSize=100',
        token: token,
      );

      expect(seedTransactionCount, 60);
      expect(resposta.mapa['total'], 60);
      expect(resposta.ids, [
        for (var n = 60; n >= 1; n--) 'tx_${n.toString().padLeft(4, '0')}',
      ]);
      // Do mais recente ao mais antigo, sem empates nem datas no futuro.
      final datas = [
        for (final item in resposta.itens) (item! as Map)['date']! as String,
      ];
      for (var i = 1; i < datas.length; i++) {
        expect(datas[i].compareTo(datas[i - 1]), lessThan(0));
      }
      expect(DateTime.parse(datas.first).isAfter(_agora), isFalse);
    });

    test('o extrato padrão (20 por página) tem três páginas', () async {
      final token = await _login();
      Future<_Resposta> pagina(int n) =>
          _req('GET', '/transactions?page=$n', token: token);

      final paginas = [for (var n = 1; n <= 4; n++) await pagina(n)];

      expect([for (final p in paginas) p.itens.length], [20, 20, 20, 0]);
      expect(paginas[2].ids.last, 'tx_0001');
    });

    test('cobre sete meses: atual, anterior e cinco de histórico', () async {
      final token = await _login();
      final porMes = <String, int>{};
      for (var back = 0; back <= 7; back++) {
        final mes = monthOf(_agora, back);
        final resposta = await _req(
          'GET',
          '/transactions?month=$mes',
          token: token,
        );
        porMes[mes] = resposta.mapa['total']! as int;
      }

      expect(porMes, {
        '2026-09': 6,
        '2026-08': 4,
        '2026-07': 10,
        '2026-06': 10,
        '2026-05': 10,
        '2026-04': 10,
        '2026-03': 10,
        '2026-02': 0,
      });
    });

    test('nenhuma data fica no futuro no começo do mês', () {
      final agora = DateTime.utc(2026, 11, 6, 10, 15, 42);
      final lancamentos = seedTransactions(agora);
      final porId = {for (final t in lancamentos) t['id']: t['date']};

      for (final t in lancamentos) {
        final data = DateTime.parse(t['date']! as String);
        expect(data.isAfter(agora), isFalse, reason: '${t['id']}');
      }
      // Os que cairiam depois de agora ficam com agora, truncado ao minuto.
      for (final id in ['tx_0060', 'tx_0059', 'tx_0058', 'tx_0057']) {
        expect(porId[id], '2026-11-06T10:15:00Z');
      }
      expect(porId['tx_0056'], '2026-11-05T08:00:00Z');
      expect(porId['tx_0054'], '2026-10-28T18:10:00Z');
    });

    test('no começo do mês o resumo e a ordem continuam os mesmos', () async {
      final server = await startMockServer(
        port: 0,
        minLatency: Duration.zero,
        maxLatency: Duration.zero,
        clock: () => DateTime.utc(2026, 11, 1, 0, 30),
      );
      addTearDown(server.close);
      Future<Map<String, Object?>> get(String path, String? token) async {
        final request = await _http.openUrl(
          path == '/auth/login' ? 'POST' : 'GET',
          server.baseUrl.resolve(path),
        );
        if (token != null) {
          request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        } else {
          request.write(
            jsonEncode({'email': 'ana@carteira.dev', 'password': seedPassword}),
          );
        }
        final response = await request.close();
        return jsonDecode(await utf8.decoder.bind(response).join())
            as Map<String, Object?>;
      }

      final token = (await get('/auth/login', null))['token']! as String;
      final resumo = await get('/summary', token);
      final lista = await get('/transactions?month=2026-11', token);
      final ids = [for (final t in lista['items']! as List) (t as Map)['id']];

      expect(resumo, {
        'month': '2026-11',
        'income': 9526.55,
        'expense': 5330.04,
        'balance': 4196.51,
      });
      expect(ids, [
        'tx_0060',
        'tx_0059',
        'tx_0058',
        'tx_0057',
        'tx_0056',
        'tx_0055',
      ]);
    });
  });
}
