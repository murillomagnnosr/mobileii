// Leitura das opções de linha de comando e das variáveis de ambiente do
// `tool/mock_server.dart`, separada do `main` para os testes conferirem os
// padrões (porta 8080, latência de 300–800 ms) sem abrir a porta 8080.
import 'mock_server.dart';

/// Ajuda mostrada por `--help` e junto de um erro de uso.
const mockServerUsage = '''
Uso: dart run tool/mock_server.dart [--port <porta>]

Opções:
  -p, --port <porta>  porta HTTP (padrão: \$PORT ou 8080; 0 escolhe uma livre)
  -h, --help          mostra esta ajuda

Variáveis de ambiente:
  PORT            porta, quando --port não é informado
  LATENCY_MIN_MS  latência mínima por requisição, em ms (padrão 300)
  LATENCY_MAX_MS  latência máxima por requisição, em ms (padrão 800)''';

/// Código de saída para uso inválido (`EX_USAGE`).
const exitUsage = 64;

/// Código de saída quando a porta não pode ser aberta.
const exitPortBusy = 1;

/// Configuração lida de [parseMockServerOptions].
class MockServerOptions {
  const MockServerOptions({
    required this.port,
    required this.minLatency,
    required this.maxLatency,
    this.help = false,
  });

  final int port;
  final Duration minLatency;
  final Duration maxLatency;

  /// Veio `-h`/`--help`: mostrar a ajuda e sair sem subir o servidor.
  final bool help;
}

/// Lê [args] e [env]. A porta vem de `--port`/`-p`/`--port=N`, depois de
/// `PORT` e por fim [MockServer.defaultPort]. Lança [FormatException] com a
/// mensagem para o usuário quando algo é inválido.
MockServerOptions parseMockServerOptions(
  List<String> args,
  Map<String, String> env,
) {
  if (args.contains('-h') || args.contains('--help')) {
    return MockServerOptions(
      port: MockServer.defaultPort,
      minLatency: MockServer.defaultMinLatency,
      maxLatency: MockServer.defaultMaxLatency,
      help: true,
    );
  }
  final port =
      _parsePort(args) ?? _envInt(env, 'PORT') ?? MockServer.defaultPort;
  if (port < 0 || port > 65535) {
    throw FormatException('porta fora da faixa 0–65535: $port');
  }
  final (minLatency, maxLatency) = _latency(
    _envInt(env, 'LATENCY_MIN_MS'),
    _envInt(env, 'LATENCY_MAX_MS'),
  );
  return MockServerOptions(
    port: port,
    minLatency: minLatency,
    maxLatency: maxLatency,
  );
}

/// Lê `--port 9000`, `--port=9000` ou `-p 9000`; null se não veio.
int? _parsePort(List<String> args) {
  String? value;
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg.startsWith('--port=')) {
      value = arg.substring('--port='.length);
    } else if (arg == '--port' || arg == '-p') {
      if (++i >= args.length) throw FormatException('$arg sem valor');
      value = args[i];
    } else {
      throw FormatException('opção desconhecida: $arg');
    }
  }
  if (value == null) return null;
  return int.tryParse(value) ??
      (throw FormatException('porta inválida: "$value"'));
}

int? _envInt(Map<String, String> env, String name) {
  final raw = env[name]?.trim();
  if (raw == null || raw.isEmpty) return null;
  final value = int.tryParse(raw);
  if (value == null || value < 0) {
    throw FormatException('$name deve ser um inteiro ≥ 0, veio "$raw"');
  }
  return value;
}

/// Combina as variáveis com o padrão de 300–800 ms. Se só uma vier e ficar
/// fora da faixa padrão, a outra acompanha (LATENCY_MAX_MS=0 desliga tudo).
(Duration, Duration) _latency(int? minMs, int? maxMs) {
  var min = minMs ?? MockServer.defaultMinLatency.inMilliseconds;
  var max = maxMs ?? MockServer.defaultMaxLatency.inMilliseconds;
  if (min > max) {
    if (minMs == null) {
      min = max;
    } else if (maxMs == null) {
      max = min;
    } else {
      throw FormatException(
        'LATENCY_MIN_MS ($min) maior que LATENCY_MAX_MS ($max)',
      );
    }
  }
  return (Duration(milliseconds: min), Duration(milliseconds: max));
}
