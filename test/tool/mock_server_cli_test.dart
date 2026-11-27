// Linha de comando do mock (tool/mock_server.dart): a leitura das opções e
// variáveis de ambiente (sem abrir porta nenhuma) e o processo de verdade,
// sempre numa porta livre ou efêmera, nunca na 8080.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/mock_server/cli.dart';
import '../../tool/mock_server/mock_server.dart';

/// O `dart` do SDK que roda os testes, ou null se não for encontrado.
String? _dartExecutable() {
  final name = Platform.isWindows ? 'dart.exe' : 'dart';
  final root = Platform.environment['FLUTTER_ROOT'];
  final candidates = [if (root != null) '$root/bin/cache/dart-sdk/bin/$name'];
  // No `flutter test` o executável é o flutter_tester, dentro de bin/cache.
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 8; i++) {
    candidates.add('${dir.path}/dart-sdk/bin/$name');
    candidates.add('${dir.path}/bin/$name');
    if (dir.parent.path == dir.path) break;
    dir = dir.parent;
  }
  for (final path in candidates) {
    if (File(path).existsSync()) return path;
  }
  return null;
}

final _dart = _dartExecutable();

/// Processo do mock em execução, com a saída já acumulada.
class _Mock {
  _Mock(this.process) {
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_stdout.add);
    process.stderr.transform(utf8.decoder).listen(_stderr.write);
  }

  final Process process;
  final _stdout = <String>[];
  final _stderr = StringBuffer();

  List<String> get stdoutLines => _stdout;
  String get stderrText => _stderr.toString();

  /// Espera a linha do banner e devolve a porta anunciada.
  Future<int> port() async {
    final banner = RegExp(r'^Mock da API Carteira em http://localhost:(\d+)$');
    final limit = DateTime.now().add(const Duration(seconds: 25));
    while (DateTime.now().isBefore(limit)) {
      for (final line in _stdout) {
        final match = banner.firstMatch(line);
        if (match != null) return int.parse(match.group(1)!);
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    fail('Banner não apareceu. stdout: $_stdout stderr: $_stderr');
  }
}

Future<_Mock> _start(
  List<String> args, {
  Map<String, String> env = const {},
}) async {
  final process = await Process.start(
    _dart!,
    ['tool/mock_server.dart', ...args],
    environment: {
      // Sem PORT herdado do terminal: cada teste diz a porta que quer.
      'PORT': '',
      'LATENCY_MIN_MS': '',
      'LATENCY_MAX_MS': '',
      ...env,
    },
  );
  return _Mock(process);
}

Future<int> _health(int port) async {
  final http = HttpClient();
  try {
    final request = await http.getUrl(
      Uri.parse('http://127.0.0.1:$port/health'),
    );
    final response = await request.close();
    await response.drain<void>();
    return response.statusCode;
  } finally {
    http.close(force: true);
  }
}

void main() {
  group('parseMockServerOptions', () {
    test('sem nada usa a porta 8080 e latência de 300 a 800 ms', () {
      final options = parseMockServerOptions(const [], const {});

      expect(options.port, 8080);
      expect(options.port, MockServer.defaultPort);
      expect(options.minLatency, const Duration(milliseconds: 300));
      expect(options.maxLatency, const Duration(milliseconds: 800));
      expect(options.help, isFalse);
    });

    test('aceita --port N, -p N e --port=N', () {
      expect(parseMockServerOptions(['--port', '9000'], const {}).port, 9000);
      expect(parseMockServerOptions(['-p', '9001'], const {}).port, 9001);
      expect(parseMockServerOptions(['--port=9002'], const {}).port, 9002);
      expect(parseMockServerOptions(['--port=0'], const {}).port, 0);
    });

    test('PORT vale quando não há --port, e --port tem prioridade', () {
      expect(parseMockServerOptions(const [], {'PORT': '9100'}).port, 9100);
      expect(
        parseMockServerOptions(['--port', '9200'], {'PORT': '9100'}).port,
        9200,
      );
      expect(parseMockServerOptions(const [], {'PORT': '  '}).port, 8080);
    });

    test('LATENCY_MIN_MS e LATENCY_MAX_MS juntos definem a faixa', () {
      final options = parseMockServerOptions(const [], {
        'LATENCY_MIN_MS': '50',
        'LATENCY_MAX_MS': '120',
      });

      expect(options.minLatency, const Duration(milliseconds: 50));
      expect(options.maxLatency, const Duration(milliseconds: 120));
    });

    test('só uma das latências: a outra acompanha se cruzar o padrão', () {
      final soMinimo = parseMockServerOptions(const [], {
        'LATENCY_MIN_MS': '1000',
      });
      final soMaximo = parseMockServerOptions(const [], {
        'LATENCY_MAX_MS': '100',
      });
      final desligada = parseMockServerOptions(const [], {
        'LATENCY_MAX_MS': '0',
      });
      final dentro = parseMockServerOptions(const [], {
        'LATENCY_MIN_MS': '500',
      });

      expect(soMinimo.minLatency, const Duration(milliseconds: 1000));
      expect(soMinimo.maxLatency, const Duration(milliseconds: 1000));
      expect(soMaximo.minLatency, const Duration(milliseconds: 100));
      expect(soMaximo.maxLatency, const Duration(milliseconds: 100));
      expect(desligada.minLatency, Duration.zero);
      expect(desligada.maxLatency, Duration.zero);
      expect(dentro.minLatency, const Duration(milliseconds: 500));
      expect(dentro.maxLatency, const Duration(milliseconds: 800));
    });

    test('-h e --help pedem a ajuda', () {
      expect(parseMockServerOptions(['-h'], const {}).help, isTrue);
      expect(parseMockServerOptions(['--help'], const {}).help, isTrue);
      expect(mockServerUsage, contains('--port'));
      expect(mockServerUsage, contains('LATENCY_MIN_MS'));
    });

    test('entradas inválidas lançam FormatException com a mensagem', () {
      Matcher erro(String mensagem) => throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains(mensagem),
        ),
      );

      expect(
        () => parseMockServerOptions(['--bogus'], const {}),
        erro('opção desconhecida: --bogus'),
      );
      expect(
        () => parseMockServerOptions(['--port'], const {}),
        erro('--port sem valor'),
      );
      expect(
        () => parseMockServerOptions(['-p', 'abc'], const {}),
        erro('porta inválida: "abc"'),
      );
      expect(
        () => parseMockServerOptions(['--port=70000'], const {}),
        erro('porta fora da faixa'),
      );
      expect(
        () => parseMockServerOptions(const [], {'PORT': 'abc'}),
        erro('PORT deve ser um inteiro ≥ 0'),
      );
      expect(
        () => parseMockServerOptions(const [], {'LATENCY_MIN_MS': '-1'}),
        erro('LATENCY_MIN_MS deve ser um inteiro ≥ 0'),
      );
      expect(
        () => parseMockServerOptions(const [], {
          'LATENCY_MIN_MS': '500',
          'LATENCY_MAX_MS': '100',
        }),
        erro('LATENCY_MIN_MS (500) maior que LATENCY_MAX_MS (100)'),
      );
    });
  });

  group('processo dart tool/mock_server.dart', () {
    test('--port 0 sobe, anuncia a porta e a latência e responde', () async {
      final mock = await _start(
        ['--port', '0'],
        env: {'LATENCY_MIN_MS': '0', 'LATENCY_MAX_MS': '0'},
      );
      try {
        final port = await mock.port();

        expect(port, isNot(8080));
        expect(await _health(port), 200);
        expect(
          mock.stdoutLines,
          contains(startsWith('Latência: 0–0 ms (LATENCY_MIN_MS')),
        );
      } finally {
        mock.process.kill();
        await mock.process.exitCode;
      }
    });

    test('PORT=0 vale quando não vem --port', () async {
      final mock = await _start(
        const [],
        env: {'PORT': '0', 'LATENCY_MAX_MS': '0'},
      );
      try {
        final port = await mock.port();

        expect(port, isNot(8080));
        expect(await _health(port), 200);
      } finally {
        mock.process.kill();
        await mock.process.exitCode;
      }
    });

    test('--help mostra a ajuda e sai com 0', () async {
      final mock = await _start(['--help']);

      expect(await mock.process.exitCode, 0);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(mock.stdoutLines.join('\n'), contains('Uso: dart run'));
    });

    test('opção inválida sai com 64 e mostra o erro e a ajuda', () async {
      final mock = await _start(['--bogus']);

      expect(await mock.process.exitCode, exitUsage);
      expect(exitUsage, 64);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(mock.stderrText, contains('Erro: opção desconhecida: --bogus'));
      expect(mock.stderrText, contains('Uso: dart run'));
    });

    test('porta ocupada sai com 1 e uma mensagem amigável', () async {
      final ocupada = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
      try {
        final mock = await _start(['--port', '${ocupada.port}']);

        expect(await mock.process.exitCode, exitPortBusy);
        expect(exitPortBusy, 1);
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(mock.stderrText, contains('Outro mock já está rodando?'));
      } finally {
        await ocupada.close();
      }
    });
  }, skip: _dart == null ? 'executável dart não encontrado' : false);
}
