// Servidor mock mínimo da API Carteira, seguindo docs/api-referencia.pdf.
//
// Uso: dart run tool/mock_server.dart
// Sobe em http://localhost:8080 (no emulador Android, http://10.0.2.2:8080).
// Credenciais: ana@carteira.dev / 123456 e bruno@carteira.dev / 123456.
//
// Cobre as rotas que o app usa hoje: /health, /auth/login, /auth/logout,
// /me, /summary e /transactions (GET). Não substitui o server/ do curso.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

const _port = 8080;

const _users = <String, Map<String, dynamic>>{
  'ana@carteira.dev': {
    'id': 'usr_01',
    'name': 'Ana Ribeiro',
    'email': 'ana@carteira.dev',
    'avatarUrl': null,
    'createdAt': '2024-03-11T09:00:00Z',
  },
  'bruno@carteira.dev': {
    'id': 'usr_02',
    'name': 'Bruno Lima',
    'email': 'bruno@carteira.dev',
    'avatarUrl': null,
    'createdAt': '2024-05-02T10:00:00Z',
  },
};

final _sessions = <String, Map<String, dynamic>>{};
final _random = Random();

/// Lançamentos do mês, do mais recente para o mais antigo.
List<Map<String, dynamic>> _seed(String month) => [
  {
    'id': 'tx_0060',
    'type': 'expense',
    'amount': 306.7,
    'description': 'Mercado Pão de Açúcar',
    'category': 'Alimentação',
    'date': '$month-27T20:55:00Z',
    'note': 'Dividido com a Carla',
    'account': 'Nubank',
    'toAccount': null,
  },
  {
    'id': 'tx_0059',
    'type': 'income',
    'amount': 9526.55,
    'description': 'Salário',
    'category': 'Renda',
    'date': '$month-25T12:00:00Z',
    'note': null,
    'account': 'Itaú',
    'toAccount': null,
  },
  {
    'id': 'tx_0058',
    'type': 'transfer',
    'amount': 500.0,
    'description': 'Reserva',
    'category': null,
    'date': '$month-20T09:00:00Z',
    'note': null,
    'account': 'Nubank',
    'toAccount': 'Itaú',
  },
  {
    'id': 'tx_0057',
    'type': 'expense',
    'amount': 89.9,
    'description': 'Mercado',
    'category': 'Alimentação',
    'date': '$month-06T14:32:00Z',
    'note': null,
    'account': 'Nubank',
    'toAccount': null,
  },
  {
    'id': 'tx_0056',
    'type': 'expense',
    'amount': 4813.44,
    'description': 'Aluguel',
    'category': 'Moradia',
    'date': '$month-05T08:00:00Z',
    'note': null,
    'account': 'Itaú',
    'toAccount': null,
  },
  {
    'id': 'tx_0055',
    'type': 'expense',
    'amount': 120.0,
    'description': 'Internet',
    'category': 'Casa',
    'date': '$month-03T08:00:00Z',
    'note': null,
    'account': 'Itaú',
    'toAccount': null,
  },
];

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
  stdout.writeln('Mock da API Carteira em http://localhost:$_port');
  await for (final request in server) {
    try {
      await _handle(request);
    } on Object catch (e) {
      await _json(request, 500, {
        'error': {'code': 'internal', 'message': '$e'},
      });
    }
  }
}

Future<void> _handle(HttpRequest request) async {
  final response = request.response;
  response.headers.set('Access-Control-Allow-Origin', '*');
  // "*" não cobre Authorization no preflight; precisa ser listado.
  response.headers.set(
    'Access-Control-Allow-Headers',
    'Authorization, Content-Type, Accept',
  );
  response.headers.set('Access-Control-Allow-Methods', '*');
  if (request.method == 'OPTIONS') {
    response.statusCode = 204;
    await response.close();
    return;
  }

  // Latência de 300 a 800 ms, como o servidor real.
  await Future<void>.delayed(
    Duration(milliseconds: 300 + _random.nextInt(500)),
  );

  final path = request.uri.path;
  stdout.writeln('${request.method} ${request.uri}');

  if (request.method == 'GET' && path == '/health') {
    return _json(request, 200, {'status': 'ok', 'version': '0.1.0'});
  }

  if (request.method == 'POST' && path == '/auth/login') {
    return _login(request);
  }

  // Daqui para baixo, rotas protegidas.
  final auth = request.headers.value('authorization') ?? '';
  final token = auth.startsWith('Bearer ') ? auth.substring(7) : '';
  final user = _sessions[token];
  if (user == null) {
    return _json(request, 401, {
      'error': {'code': 'unauthorized', 'message': 'Missing or invalid token'},
    });
  }

  if (request.method == 'POST' && path == '/auth/logout') {
    _sessions.remove(token);
    response.statusCode = 204;
    await response.close();
    return;
  }
  if (request.method == 'GET' && path == '/me') {
    return _json(request, 200, user);
  }

  final now = DateTime.now().toUtc();
  final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  final query = request.uri.queryParameters;

  if (request.method == 'GET' && path == '/summary') {
    final month = query['month'] ?? currentMonth;
    if (!_isMonth(month)) {
      return _validation(request, {'month': 'must be in the format YYYY-MM'});
    }
    return _json(request, 200, {
      'month': month,
      'income': 9526.55,
      'expense': 5330.04,
      'balance': 4196.51,
    });
  }

  if (request.method == 'GET' && path == '/transactions') {
    final month = query['month'];
    final page = int.tryParse(query['page'] ?? '1') ?? 0;
    final pageSize = int.tryParse(query['pageSize'] ?? '20') ?? 0;
    final fields = <String, String>{
      if (month != null && !_isMonth(month))
        'month': 'must be in the format YYYY-MM',
      if (page < 1) 'page': 'must be an integer greater than zero',
      if (pageSize < 1 || pageSize > 100)
        'pageSize': 'must be an integer between 1 and 100',
    };
    if (fields.isNotEmpty) return _validation(request, fields);

    final all = _seed(month ?? currentMonth);
    final start = (page - 1) * pageSize;
    final items = start >= all.length
        ? <Map<String, dynamic>>[]
        : all.sublist(start, min(all.length, start + pageSize));
    return _json(request, 200, {
      'items': items,
      'page': page,
      'pageSize': pageSize,
      'total': all.length,
    });
  }

  return _json(request, 404, {
    'error': {'code': 'not_found', 'message': 'Route $path not found'},
  });
}

Future<void> _login(HttpRequest request) async {
  final Map<String, dynamic> body;
  try {
    final raw = await utf8.decoder.bind(request).join();
    body = jsonDecode(raw) as Map<String, dynamic>;
  } on Object {
    return _json(request, 400, {
      'error': {'code': 'bad_request', 'message': 'Malformed JSON body'},
    });
  }

  final email = (body['email'] as String?) ?? '';
  final password = (body['password'] as String?) ?? '';
  final fields = <String, String>{
    if (email.isEmpty) 'email': 'must not be empty',
    if (password.isEmpty) 'password': 'must not be empty',
  };
  if (fields.isNotEmpty) return _validation(request, fields);

  final user = _users[email];
  if (user == null || password != '123456') {
    return _json(request, 401, {
      'error': {
        'code': 'invalid_credentials',
        'message': 'Invalid email or password',
      },
    });
  }

  final token = 'tok_${_random.nextInt(1 << 30).toRadixString(36)}';
  _sessions[token] = user;
  return _json(request, 200, {'token': token, 'user': user});
}

bool _isMonth(String value) =>
    RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(value);

Future<void> _validation(HttpRequest request, Map<String, String> fields) =>
    _json(request, 422, {
      'error': {
        'code': 'validation',
        'message': 'Invalid parameters',
        'fields': fields,
      },
    });

Future<void> _json(HttpRequest request, int status, Object body) async {
  final response = request.response;
  response.statusCode = status;
  response.headers.contentType = ContentType(
    'application',
    'json',
    charset: 'utf-8',
  );
  response.write(jsonEncode(body));
  await response.close();
}
