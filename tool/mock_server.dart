// Servidor mock da API Carteira, seguindo docs/api.md
// (resumo de docs/api-referencia.pdf do curso).
//
// Uso: dart run tool/mock_server.dart
// Sobe em http://localhost:8080 (no emulador Android, http://10.0.2.2:8080).
// Credenciais: ana@carteira.dev / 123456 e bruno@carteira.dev / 123456.
//
// Cobre todas as rotas da referência: /health, /auth/login, /auth/logout,
// GET e PUT /me, CRUD de /transactions, /summary e /reset, além dos
// cabeçalhos de simulação X-Delay-Ms e X-Fail. Cada login recebe uma cópia
// própria dos dados. Não substitui o server/ do curso.
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

/// Dados de uma sessão: o usuário (editável por PUT /me) e os lançamentos.
class _Session {
  _Session(Map<String, dynamic> user)
    : user = Map.of(user),
      transactions = _seed();

  Map<String, dynamic> user;
  List<Map<String, dynamic>> transactions;
  int nextId = 81;
}

final _sessions = <String, _Session>{};
final _random = Random();

String _monthOffset(int back) {
  final now = DateTime.now().toUtc();
  final date = DateTime.utc(now.year, now.month - back);
  return '${date.year}-${date.month.toString().padLeft(2, '0')}';
}

/// Lançamentos do mês atual e do anterior, do mais recente para o mais antigo.
List<Map<String, dynamic>> _seed() {
  final current = _monthOffset(0);
  final previous = _monthOffset(1);
  Map<String, dynamic> tx(
    String id,
    String type,
    num amount,
    String description,
    String? category,
    String date,
    String account, {
    String? note,
    String? toAccount,
  }) => {
    'id': id,
    'type': type,
    'amount': amount.toDouble(),
    'description': description,
    'category': category,
    'date': date,
    'note': note,
    'account': account,
    'toAccount': toAccount,
  };

  return [
    tx(
      'tx_0060',
      'expense',
      306.7,
      'Mercado Pão de Açúcar',
      'Alimentação',
      '$current-27T20:55:00Z',
      'Nubank',
      note: 'Dividido com a Carla',
    ),
    tx(
      'tx_0059',
      'income',
      9526.55,
      'Salário',
      'Renda',
      '$current-25T12:00:00Z',
      'Itaú',
    ),
    tx(
      'tx_0058',
      'transfer',
      500,
      'Reserva',
      null,
      '$current-20T09:00:00Z',
      'Nubank',
      toAccount: 'Itaú',
    ),
    tx(
      'tx_0057',
      'expense',
      89.9,
      'Mercado',
      'Alimentação',
      '$current-06T14:32:00Z',
      'Nubank',
    ),
    tx(
      'tx_0056',
      'expense',
      4813.44,
      'Aluguel',
      'Moradia',
      '$current-05T08:00:00Z',
      'Itaú',
    ),
    tx(
      'tx_0055',
      'expense',
      120,
      'Internet',
      'Casa',
      '$current-03T08:00:00Z',
      'Itaú',
    ),
    tx(
      'tx_0054',
      'expense',
      64.5,
      'Farmácia',
      'Saúde',
      '$previous-28T18:10:00Z',
      'Nubank',
    ),
    tx(
      'tx_0053',
      'income',
      9526.55,
      'Salário',
      'Renda',
      '$previous-25T12:00:00Z',
      'Itaú',
    ),
    tx(
      'tx_0052',
      'expense',
      42.9,
      'Streaming',
      'Lazer',
      '$previous-15T10:00:00Z',
      'Nubank',
    ),
    tx(
      'tx_0051',
      'expense',
      4813.44,
      'Aluguel',
      'Moradia',
      '$previous-05T08:00:00Z',
      'Itaú',
    ),
  ];
}

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
  stdout.writeln('Mock da API Carteira em http://localhost:$_port');
  await for (final request in server) {
    try {
      await _handle(request);
    } on Object catch (e) {
      await _json(request, 500, _error('internal', '$e'));
    }
  }
}

Future<void> _handle(HttpRequest request) async {
  final response = request.response;
  response.headers.set('Access-Control-Allow-Origin', '*');
  // "*" não cobre Authorization no preflight; precisa ser listado.
  response.headers.set(
    'Access-Control-Allow-Headers',
    'Authorization, Content-Type, Accept, X-Fail, X-Delay-Ms',
  );
  response.headers.set('Access-Control-Allow-Methods', '*');
  if (request.method == 'OPTIONS') {
    response.statusCode = 204;
    await response.close();
    return;
  }

  // Latência de 300 a 800 ms, como o servidor real; X-Delay-Ms fixa o valor.
  final delay =
      int.tryParse(request.headers.value('x-delay-ms') ?? '') ??
      300 + _random.nextInt(500);
  await Future<void>.delayed(Duration(milliseconds: delay));

  final path = request.uri.path;
  stdout.writeln('${request.method} ${request.uri}');

  // Cabeçalhos de simulação valem antes da autenticação.
  switch (request.headers.value('x-fail')) {
    case '500':
      return _json(request, 500, _error('internal', 'Simulated failure'));
    case 'expired':
      return _json(request, 401, _error('token_expired', 'Token has expired'));
    case 'timeout':
      await Future<void>.delayed(const Duration(seconds: 60));
      response.statusCode = 504;
      response.write('Gateway Timeout');
      await response.close();
      return;
  }

  if (request.method == 'GET' && path == '/health') {
    return _json(request, 200, {'status': 'ok', 'version': '0.1.0'});
  }

  if (request.method == 'POST' && path == '/auth/login') {
    return _login(request);
  }

  // Daqui para baixo, rotas protegidas.
  final auth = request.headers.value('authorization') ?? '';
  final token = auth.startsWith('Bearer ') ? auth.substring(7) : '';
  final session = _sessions[token];
  if (session == null) {
    return _json(
      request,
      401,
      _error('unauthorized', 'Missing or invalid token'),
    );
  }

  final segments = request.uri.pathSegments;
  final query = request.uri.queryParameters;

  switch ((request.method, segments)) {
    case ('POST', ['auth', 'logout']):
      _sessions.remove(token);
      return _noContent(request);

    case ('GET', ['me']):
      return _json(request, 200, session.user);

    case ('PUT', ['me']):
      final body = await _readBody(request);
      if (body == null) return _badRequest(request);
      final name = (body['name'] as String? ?? '').trim();
      if (name.isEmpty) {
        return _validation(request, 'Invalid user', {
          'name': 'must not be empty',
        });
      }
      final avatar = (body['avatarUrl'] as String?)?.trim();
      session.user = {
        ...session.user,
        'name': name,
        'avatarUrl': avatar == null || avatar.isEmpty ? null : avatar,
      };
      return _json(request, 200, session.user);

    case ('GET', ['summary']):
      final month = query['month'] ?? _monthOffset(0);
      if (!_isMonth(month)) {
        return _validation(request, 'Invalid parameters', {
          'month': 'must be in the format YYYY-MM',
        });
      }
      return _json(request, 200, _summary(session, month));

    case ('GET', ['transactions']):
      return _list(request, session, query);

    case ('GET', ['transactions', final id]):
      final found = _find(session, id);
      if (found == null) return _txNotFound(request, id);
      return _json(request, 200, found);

    case ('POST', ['transactions']):
      final body = await _readBody(request);
      if (body == null) return _badRequest(request);
      final fields = _validateTransaction(body);
      if (fields.isNotEmpty) {
        return _validation(request, 'Invalid transaction', fields);
      }
      final id = 'tx_${(session.nextId++).toString().padLeft(4, '0')}';
      final created = _normalize(id, body);
      session.transactions.add(created);
      return _json(request, 201, created);

    case ('PUT', ['transactions', final id]):
      final body = await _readBody(request);
      if (body == null) return _badRequest(request);
      // A validação vem antes do 404, como no servidor do curso.
      final fields = _validateTransaction(body);
      if (fields.isNotEmpty) {
        return _validation(request, 'Invalid transaction', fields);
      }
      final index = session.transactions.indexWhere((t) => t['id'] == id);
      if (index < 0) return _txNotFound(request, id);
      final updated = _normalize(id, body);
      session.transactions[index] = updated;
      return _json(request, 200, updated);

    case ('DELETE', ['transactions', final id]):
      final index = session.transactions.indexWhere((t) => t['id'] == id);
      if (index < 0) return _txNotFound(request, id);
      session.transactions.removeAt(index);
      return _noContent(request);

    case ('POST', ['reset']):
      session.transactions = _seed();
      session.nextId = 81;
      return _noContent(request);
  }

  return _json(request, 404, _error('not_found', 'Route $path not found'));
}

Future<void> _login(HttpRequest request) async {
  final body = await _readBody(request);
  if (body == null) return _badRequest(request);

  final email = (body['email'] as String?) ?? '';
  final password = (body['password'] as String?) ?? '';
  final fields = <String, String>{
    if (email.isEmpty) 'email': 'must not be empty',
    if (password.isEmpty) 'password': 'must not be empty',
  };
  if (fields.isNotEmpty) {
    return _validation(request, 'Invalid parameters', fields);
  }

  final user = _users[email.trim()];
  if (user == null || password != '123456') {
    return _json(
      request,
      401,
      _error('invalid_credentials', 'Invalid email or password'),
    );
  }

  final token = 'tok_${_random.nextInt(1 << 30).toRadixString(36)}';
  final session = _Session(user);
  _sessions[token] = session;
  return _json(request, 200, {'token': token, 'user': session.user});
}

Future<void> _list(
  HttpRequest request,
  _Session session,
  Map<String, String> query,
) async {
  final month = query['month'];
  final type = query['type'];
  final q = query['q']?.toLowerCase();
  final page = int.tryParse(query['page'] ?? '1') ?? 0;
  final pageSize = int.tryParse(query['pageSize'] ?? '20') ?? 0;
  final fields = <String, String>{
    if (month != null && !_isMonth(month))
      'month': 'must be in the format YYYY-MM',
    if (type != null && !_types.contains(type))
      'type': 'must be income, expense or transfer',
    if (page < 1) 'page': 'must be an integer greater than zero',
    if (pageSize < 1 || pageSize > 100)
      'pageSize': 'must be an integer between 1 and 100',
  };
  if (fields.isNotEmpty) {
    return _validation(request, 'Invalid parameters', fields);
  }

  final all =
      session.transactions
          .where(
            (t) => month == null || (t['date'] as String).startsWith(month),
          )
          .where((t) => type == null || t['type'] == type)
          .where(
            (t) =>
                q == null ||
                (t['description'] as String).toLowerCase().contains(q),
          )
          .toList()
        ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

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

Map<String, dynamic> _summary(_Session session, String month) {
  double sum(String type) => session.transactions
      .where((t) => t['type'] == type)
      .where((t) => (t['date'] as String).startsWith(month))
      .fold(0, (total, t) => total + (t['amount'] as num));
  final income = _round(sum('income'));
  final expense = _round(sum('expense'));
  return {
    'month': month,
    'income': income,
    'expense': expense,
    'balance': _round(income - expense),
  };
}

const _types = {'income', 'expense', 'transfer'};

Map<String, String> _validateTransaction(Map<String, dynamic> body) {
  final type = body['type'];
  final amount = body['amount'];
  final description = body['description'];
  final account = body['account'];
  final date = body['date'];
  final toAccount = body['toAccount'];
  return {
    if (!_types.contains(type)) 'type': 'must be income, expense or transfer',
    if (amount is! num || amount <= 0) 'amount': 'must be greater than zero',
    if (description is! String || description.trim().isEmpty)
      'description': 'must not be empty',
    if (account is! String || account.trim().isEmpty)
      'account': 'must not be empty',
    if (date is! String || DateTime.tryParse(date) == null)
      'date': 'must be an ISO 8601 date',
    if (type == 'transfer' &&
        (toAccount is! String || toAccount.trim().isEmpty))
      'toAccount': 'is required for transfers',
  };
}

/// Aplica as regras do contrato: valor com duas casas, data em UTC, texto
/// vazio vira null e toAccount só existe em transferência.
Map<String, dynamic> _normalize(String id, Map<String, dynamic> body) {
  String? optional(Object? value) {
    final text = (value as String?)?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  final type = body['type'] as String;
  return {
    'id': id,
    'type': type,
    'amount': _round((body['amount'] as num).toDouble()),
    'description': (body['description'] as String).trim(),
    'category': optional(body['category']),
    'date': DateTime.parse(body['date'] as String)
        .toUtc()
        .toIso8601String()
        .replaceFirst(RegExp(r'\.\d+Z$'), 'Z'),
    'note': optional(body['note']),
    'account': (body['account'] as String).trim(),
    'toAccount': type == 'transfer' ? optional(body['toAccount']) : null,
  };
}

Map<String, dynamic>? _find(_Session session, String id) {
  for (final t in session.transactions) {
    if (t['id'] == id) return t;
  }
  return null;
}

double _round(double value) => (value * 100).roundToDouble() / 100;

bool _isMonth(String value) =>
    RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(value);

Map<String, dynamic> _error(
  String code,
  String message, [
  Map<String, String>? fields,
]) => {
  'error': {'code': code, 'message': message, 'fields': ?fields},
};

/// Corpo JSON como objeto, ou null quando não é JSON válido.
Future<Map<String, dynamic>?> _readBody(HttpRequest request) async {
  try {
    final raw = await utf8.decoder.bind(request).join();
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    return null;
  }
}

Future<void> _badRequest(HttpRequest request) =>
    _json(request, 400, _error('bad_request', 'Malformed JSON body'));

Future<void> _txNotFound(HttpRequest request, String id) =>
    _json(request, 404, _error('not_found', 'Transaction $id not found'));

Future<void> _validation(
  HttpRequest request,
  String message,
  Map<String, String> fields,
) => _json(request, 422, _error('validation', message, fields));

Future<void> _noContent(HttpRequest request) async {
  request.response.statusCode = 204;
  await request.response.close();
}

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
