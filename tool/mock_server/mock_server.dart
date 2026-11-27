// Servidor mock da API Carteira como biblioteca, para ser usado tanto pelo
// `tool/mock_server.dart` (linha de comando) quanto por testes.
//
// Segue a referência do curso (resumida em docs/api.md): as 12 rotas, o
// formato de erro, as regras de normalização dos campos, CORS, os cabeçalhos
// de simulação X-Delay-Ms e X-Fail e a latência configurável. Usa só dart:io,
// sem dependências, para poder ser importado de qualquer pacote do projeto.
//
// Exemplo em teste:
//
//   final server = await startMockServer(
//     port: 0,
//     minLatency: Duration.zero,
//     maxLatency: Duration.zero,
//   );
//   // ... requisições em server.baseUrl ...
//   await server.close();
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'seed.dart';

/// Sobe o mock e devolve o servidor já escutando.
///
/// [port] 0 escolhe uma porta livre (veja [MockServer.port]). [address] é um
/// [InternetAddress] ou um host em texto; o padrão aceita conexões de
/// qualquer interface IPv4 (emulador, Chrome, aparelho na rede).
/// A latência de cada requisição é sorteada entre [minLatency] e
/// [maxLatency]; `Duration.zero` nos dois a desliga. [timeoutHold] é quanto
/// `X-Fail: timeout` segura a requisição antes do 504. [clock] define "agora"
/// (mês atual do `/summary` e datas do seed). [log] recebe uma linha por
/// requisição.
Future<MockServer> startMockServer({
  int port = MockServer.defaultPort,
  Object? address,
  Duration minLatency = MockServer.defaultMinLatency,
  Duration maxLatency = MockServer.defaultMaxLatency,
  Duration timeoutHold = MockServer.defaultTimeoutHold,
  DateTime Function()? clock,
  void Function(String line)? log,
}) async {
  if (minLatency.isNegative || maxLatency < minLatency) {
    throw ArgumentError(
      'Latência inválida: mínimo $minLatency, máximo $maxLatency',
    );
  }
  final server = await HttpServer.bind(
    address ?? InternetAddress.anyIPv4,
    port,
  );
  return MockServer._(
    server: server,
    minLatency: minLatency,
    maxLatency: maxLatency,
    timeoutHold: timeoutHold,
    clock: clock ?? DateTime.now,
    log: log,
  );
}

/// Um mock em execução. Cada instância tem as próprias sessões.
class MockServer {
  MockServer._({
    required this._server,
    required this.minLatency,
    required this.maxLatency,
    required this.timeoutHold,
    required this._clock,
    required this._log,
  }) {
    _server.listen((request) => unawaited(_handleSafely(request)));
  }

  static const defaultPort = 8080;
  static const defaultMinLatency = Duration(milliseconds: 300);
  static const defaultMaxLatency = Duration(milliseconds: 800);
  static const defaultTimeoutHold = Duration(seconds: 60);

  /// Versão devolvida por `GET /health`.
  static const version = '0.1.0';

  final Duration minLatency;
  final Duration maxLatency;
  final Duration timeoutHold;

  final HttpServer _server;
  final DateTime Function() _clock;
  final void Function(String line)? _log;
  final _sessions = <String, _Session>{};
  final _random = Random();
  final _tokenRandom = Random.secure();

  /// Esperas em andamento (latência e `X-Fail: timeout`), canceladas no
  /// [close] para não prender o processo.
  final _waits = <Completer<bool>, Timer>{};
  bool _closed = false;

  /// Porta em que o servidor escuta (a real, quando subiu com porta 0).
  int get port => _server.port;

  /// Endereço para os clientes: `http://127.0.0.1:<porta>` quando escuta em
  /// todas as interfaces ou no loopback.
  Uri get baseUrl {
    final address = _server.address;
    final host = switch (address) {
      _ when address.isLoopback || address == InternetAddress.anyIPv4 =>
        address.type == InternetAddressType.IPv6 ? '::1' : '127.0.0.1',
      _ when address == InternetAddress.anyIPv6 => '::1',
      _ => address.address,
    };
    return Uri(scheme: 'http', host: host, port: port);
  }

  /// Quantidade de sessões abertas (logins sem logout).
  int get sessionCount => _sessions.length;

  /// Para o servidor, derruba as conexões abertas e cancela as esperas.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    for (final MapEntry(key: completer, value: timer) in _waits.entries) {
      timer.cancel();
      completer.complete(false);
    }
    _waits.clear();
    await _server.close(force: true);
  }

  /// Espera [duration]; devolve false se o servidor fechou antes.
  Future<bool> _wait(Duration duration) {
    if (_closed) return Future.value(false);
    if (duration <= Duration.zero) return Future.value(true);
    final completer = Completer<bool>();
    _waits[completer] = Timer(duration, () {
      _waits.remove(completer);
      completer.complete(true);
    });
    return completer.future;
  }

  Duration _latency(HttpRequest request) {
    final fixed = int.tryParse(request.headers.value('x-delay-ms') ?? '');
    if (fixed != null) return Duration(milliseconds: max(0, fixed));
    final spread = (maxLatency - minLatency).inMicroseconds;
    return minLatency + Duration(microseconds: _random.nextInt(spread + 1));
  }

  Future<void> _handleSafely(HttpRequest request) async {
    try {
      await _handle(request);
    } on Object catch (error, stack) {
      _log?.call('Erro em ${request.method} ${request.uri}: $error\n$stack');
      try {
        await _json(request, 500, _error('internal', 'Internal server error'));
      } on Object {
        // Resposta já enviada ou conexão encerrada: nada mais a fazer.
      }
    }
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    response.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
      // "*" não cobre Authorization no preflight; precisa ser listado.
      ..set(
        'Access-Control-Allow-Headers',
        request.headers.value('access-control-request-headers') ??
            'Authorization, Content-Type, Accept, X-Fail, X-Delay-Ms',
      )
      ..set('Access-Control-Max-Age', '600');
    if (request.method == 'OPTIONS') return _noContent(request);

    _log?.call('${request.method} ${request.uri}');
    if (!await _wait(_latency(request))) return;

    // Cabeçalhos de simulação valem em qualquer rota, antes da autenticação.
    switch (request.headers.value('x-fail')?.trim().toLowerCase()) {
      case '500':
        return _json(request, 500, _error('internal', 'Simulated failure'));
      case 'expired':
        return _json(
          request,
          401,
          _error('token_expired', 'Token has expired'),
        );
      case 'timeout':
        if (!await _wait(timeoutHold)) return;
        response
          ..statusCode = 504
          ..headers.contentType = ContentType.text
          ..write('Gateway Timeout');
        return response.close();
    }

    final path = request.uri.path;
    if (request.method == 'GET' && path == '/health') {
      return _json(request, 200, {'status': 'ok', 'version': version});
    }
    if (request.method == 'POST' && path == '/auth/login') {
      return _login(request);
    }

    // Daqui para baixo, rotas protegidas.
    final token = _bearer(request);
    final session = _sessions[token];
    if (token == null || session == null) {
      return _json(
        request,
        401,
        _error('unauthorized', 'Missing or invalid token'),
      );
    }

    // Escapes %XX que não formam UTF-8 válido só estouram ao decodificar.
    final Map<String, String> query;
    final List<String> segments;
    try {
      query = request.uri.queryParameters;
      segments = request.uri.pathSegments;
    } on FormatException {
      return _json(request, 400, _error('bad_request', 'Malformed URL'));
    }
    switch ((request.method, segments)) {
      case ('POST', ['auth', 'logout']):
        _sessions.remove(token);
        return _noContent(request);

      case ('GET', ['me']):
        return _json(request, 200, session.user);

      case ('PUT', ['me']):
        final body = await _readBody(request);
        if (body == null) return _badRequest(request);
        final name = body['name'];
        final avatar = body['avatarUrl'];
        final fields = {
          'name': ?_requiredText(name),
          'avatarUrl': ?_optionalText(avatar),
        };
        if (fields.isNotEmpty) {
          return _validation(request, 'Invalid user', fields);
        }
        session.user = {
          ...session.user,
          'name': (name as String).trim(),
          'avatarUrl': _blankToNull(avatar),
        };
        return _json(request, 200, session.user);

      case ('GET', ['summary']):
        final month = query['month'] ?? monthOf(_clock());
        if (!_isMonth(month)) {
          return _validation(request, 'Invalid parameters', {
            'month': 'must be in the format YYYY-MM',
          });
        }
        return _json(request, 200, _summary(session, month));

      case ('GET', ['transactions']):
        return _list(request, session, query);

      case ('GET', ['transactions', final id]) when id.isNotEmpty:
        final index = session.indexOf(id);
        if (index < 0) return _transactionNotFound(request, id);
        return _json(request, 200, session.transactions[index]);

      case ('POST', ['transactions']):
        final body = await _readBody(request);
        if (body == null) return _badRequest(request);
        final fields = _validateTransaction(body);
        if (fields.isNotEmpty) {
          return _validation(request, 'Invalid transaction', fields);
        }
        final created = _normalize(session.newId(), body);
        session.transactions.add(created);
        return _json(request, 201, created);

      case ('PUT', ['transactions', final id]) when id.isNotEmpty:
        final body = await _readBody(request);
        if (body == null) return _badRequest(request);
        // A validação vem antes do 404, como no servidor do curso.
        final fields = _validateTransaction(body);
        if (fields.isNotEmpty) {
          return _validation(request, 'Invalid transaction', fields);
        }
        final index = session.indexOf(id);
        if (index < 0) return _transactionNotFound(request, id);
        final updated = _normalize(id, body);
        session.transactions[index] = updated;
        return _json(request, 200, updated);

      case ('DELETE', ['transactions', final id]) when id.isNotEmpty:
        final index = session.indexOf(id);
        if (index < 0) return _transactionNotFound(request, id);
        session.transactions.removeAt(index);
        return _noContent(request);

      case ('POST', ['reset']):
        session.reset(_clock());
        return _noContent(request);
    }

    return _json(request, 404, _error('not_found', 'Route $path not found'));
  }

  Future<void> _login(HttpRequest request) async {
    final body = await _readBody(request);
    if (body == null) return _badRequest(request);

    final email = body['email'];
    final password = body['password'];
    final fields = {
      'email': ?_requiredText(email),
      'password': ?_requiredText(password),
    };
    if (fields.isNotEmpty) {
      return _validation(request, 'Invalid credentials', fields);
    }

    final user = seedUsers[(email as String).trim().toLowerCase()];
    if (user == null || password != seedPassword) {
      return _json(
        request,
        401,
        _error('invalid_credentials', 'Invalid email or password'),
      );
    }

    final token = _newToken();
    final session = _Session(user, _clock());
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
    final q = query['q']?.trim().toLowerCase() ?? '';
    final page = int.tryParse(query['page'] ?? '1') ?? 0;
    final pageSize = int.tryParse(query['pageSize'] ?? '20') ?? 0;
    final fields = {
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

    // Datas já estão normalizadas em UTC, então o prefixo é o mês.
    final all =
        session.transactions
            .where(
              (t) => month == null || (t['date']! as String).startsWith(month),
            )
            .where((t) => type == null || t['type'] == type)
            .where(
              (t) => (t['description']! as String).toLowerCase().contains(q),
            )
            .toList()
          ..sort((a, b) {
            final byDate = (b['date']! as String).compareTo(
              a['date']! as String,
            );
            return byDate != 0
                ? byDate
                : (b['id']! as String).compareTo(a['id']! as String);
          });

    final start = (page - 1) * pageSize;
    final items = start >= all.length
        ? const <Map<String, Object?>>[]
        : all.sublist(start, min(all.length, start + pageSize));
    return _json(request, 200, {
      'items': items,
      'page': page,
      'pageSize': pageSize,
      'total': all.length,
    });
  }

  String _newToken() {
    const alphabet = '0123456789abcdefghijklmnopqrstuvwxyz';
    final suffix = List.generate(
      24,
      (_) => alphabet[_tokenRandom.nextInt(alphabet.length)],
    ).join();
    return 'tok_$suffix';
  }
}

/// Dados de uma sessão: o usuário (editável por PUT /me) e os lançamentos.
/// Cada login recebe a sua cópia do seed.
class _Session {
  _Session(this._seedUser, DateTime now) {
    reset(now);
  }

  final Map<String, Object?> _seedUser;
  late Map<String, Object?> user;
  late List<Map<String, Object?>> transactions;
  late int _nextId;

  /// Volta ao estado do seed: usuário, lançamentos e numeração dos ids.
  void reset(DateTime now) {
    user = Map.of(_seedUser);
    transactions = seedTransactions(now);
    _nextId = seedNextId;
  }

  String newId() => 'tx_${(_nextId++).toString().padLeft(4, '0')}';

  int indexOf(String id) => transactions.indexWhere((t) => t['id'] == id);
}

const _types = {'income', 'expense', 'transfer'};

Map<String, Object?> _summary(_Session session, String month) {
  double sum(String type) => session.transactions
      .where((t) => t['type'] == type)
      .where((t) => (t['date']! as String).startsWith(month))
      .fold(0, (total, t) => total + (t['amount']! as num));
  // Transferências ficam de fora: só income e expense entram no saldo.
  final income = _round(sum('income'));
  final expense = _round(sum('expense'));
  return {
    'month': month,
    'income': income,
    'expense': expense,
    'balance': _round(income - expense),
  };
}

Map<String, String> _validateTransaction(Map<String, Object?> body) {
  final type = body['type'];
  final amount = body['amount'];
  final toAccount = body['toAccount'];
  return {
    if (!_types.contains(type)) 'type': 'must be income, expense or transfer',
    if (amount is! num)
      'amount': 'must be a number'
    else if (_round(amount.toDouble()) <= 0)
      'amount': 'must be greater than zero',
    'description': ?_requiredText(body['description']),
    'category': ?_optionalText(body['category']),
    if (_parseDate(body['date']) == null) 'date': 'must be an ISO 8601 date',
    'note': ?_optionalText(body['note']),
    'account': ?_requiredText(body['account']),
    if (type == 'transfer')
      'toAccount': ?_requiredText(
        toAccount,
        empty: 'is required for transfers',
      ),
  };
}

/// Aplica as regras do contrato: valor com duas casas, data em UTC, textos
/// sem espaços nas pontas, texto vazio vira null e toAccount só existe em
/// transferência. Um `id` no corpo é ignorado.
Map<String, Object?> _normalize(String id, Map<String, Object?> body) {
  final type = body['type']! as String;
  return {
    'id': id,
    'type': type,
    'amount': _round((body['amount']! as num).toDouble()),
    'description': (body['description']! as String).trim(),
    'category': _blankToNull(body['category']),
    'date': _formatDate(_parseDate(body['date'])!),
    'note': _blankToNull(body['note']),
    'account': (body['account']! as String).trim(),
    'toAccount': type == 'transfer' ? _blankToNull(body['toAccount']) : null,
  };
}

/// Erro de um campo obrigatório de texto, ou null se estiver ok.
String? _requiredText(Object? value, {String empty = 'must not be empty'}) =>
    switch (value) {
      null => empty,
      String() when value.trim().isEmpty => empty,
      String() => null,
      _ => 'must be a string',
    };

/// Erro de um campo opcional de texto (string ou null), ou null se ok.
String? _optionalText(Object? value) =>
    value == null || value is String ? null : 'must be a string or null';

String? _blankToNull(Object? value) {
  final text = (value as String?)?.trim();
  return text == null || text.isEmpty ? null : text;
}

final _isoDate = RegExp(
  r'^(\d{4})-(\d{2})-(\d{2})'
  r'(?:[Tt](\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{1,9}))?)?'
  r'([Zz]|[+-]\d{2}(?::?\d{2})?)?)?$',
);

/// Lê uma data ISO 8601 de forma estrita (o `DateTime.parse` aceita
/// 30 de fevereiro e outros valores fora da faixa). Sem fuso, vale UTC.
DateTime? _parseDate(Object? value) {
  if (value is! String) return null;
  final match = _isoDate.firstMatch(value.trim());
  if (match == null) return null;
  int part(int group) => int.parse(match.group(group) ?? '0');
  final (year, month, day) = (part(1), part(2), part(3));
  final (hour, minute, second) = (part(4), part(5), part(6));
  final daysInMonth = DateTime.utc(year, month + 1, 0).day;
  if (month < 1 || month > 12 || day < 1 || day > daysInMonth) return null;
  if (hour > 23 || minute > 59 || second > 59) return null;

  var offset = Duration.zero;
  final zone = match.group(8);
  if (zone != null && zone.toUpperCase() != 'Z') {
    final digits = zone.substring(1).replaceAll(':', '');
    final (hours, minutes) = (
      int.parse(digits.substring(0, 2)),
      digits.length > 2 ? int.parse(digits.substring(2)) : 0,
    );
    if (hours > 23 || minutes > 59) return null;
    offset = Duration(hours: hours, minutes: minutes);
    if (zone.startsWith('-')) offset = -offset;
  }
  return DateTime.utc(year, month, day, hour, minute, second).subtract(offset);
}

/// `2026-09-06T14:32:00Z`: UTC, sem frações de segundo.
String _formatDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  final utc = date.toUtc();
  return '${utc.year.toString().padLeft(4, '0')}-${two(utc.month)}-'
      '${two(utc.day)}T${two(utc.hour)}:${two(utc.minute)}:${two(utc.second)}Z';
}

double _round(double value) => (value * 100).roundToDouble() / 100;

bool _isMonth(String value) =>
    RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(value);

String? _bearer(HttpRequest request) {
  final auth = request.headers.value('authorization')?.trim() ?? '';
  if (!auth.toLowerCase().startsWith('bearer ')) return null;
  final token = auth.substring(7).trim();
  return token.isEmpty ? null : token;
}

Map<String, Object?> _error(
  String code,
  String message, [
  Map<String, String>? fields,
]) => {
  'error': {'code': code, 'message': message, 'fields': ?fields},
};

/// Corpo como objeto JSON, ou null quando não é JSON válido (ou não é um
/// objeto).
Future<Map<String, Object?>?> _readBody(HttpRequest request) async {
  try {
    final raw = await utf8.decoder.bind(request).join();
    final decoded = jsonDecode(raw);
    return decoded is Map<String, Object?> ? decoded : null;
  } on FormatException {
    return null;
  }
}

Future<void> _badRequest(HttpRequest request) =>
    _json(request, 400, _error('bad_request', 'Malformed JSON body'));

Future<void> _transactionNotFound(HttpRequest request, String id) =>
    _json(request, 404, _error('not_found', 'Transaction $id not found'));

Future<void> _validation(
  HttpRequest request,
  String message,
  Map<String, String> fields,
) {
  // O dart:io não conhece o 422 e mandaria "Status 422" como frase.
  request.response.reasonPhrase = 'Unprocessable Entity';
  return _json(request, 422, _error('validation', message, fields));
}

/// 204 sem corpo e sem Content-Type (o dart:io poria `text/plain`).
Future<void> _noContent(HttpRequest request) {
  final response = request.response;
  response.statusCode = 204;
  response.headers.removeAll(HttpHeaders.contentTypeHeader);
  return response.close();
}

Future<void> _json(HttpRequest request, int status, Object body) {
  final response = request.response;
  response.statusCode = status;
  response.headers.contentType = ContentType(
    'application',
    'json',
    charset: 'utf-8',
  );
  response.write(jsonEncode(body));
  return response.close();
}
