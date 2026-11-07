// Servidor mock da API Carteira, seguindo docs/api.md (resumo da referência
// da API do curso, um PDF que fica fora do repositório).
//
// Uso: dart run tool/mock_server.dart [--port <porta>]
// Sobe em http://localhost:8080 (no emulador Android, http://10.0.2.2:8080).
// Credenciais: ana@carteira.dev / 123456 e bruno@carteira.dev / 123456.
//
// Variáveis de ambiente:
//   PORT            porta (o --port tem prioridade); 0 escolhe uma livre
//   LATENCY_MIN_MS  latência mínima por requisição (padrão 300)
//   LATENCY_MAX_MS  latência máxima por requisição (padrão 800)
//
// A implementação fica em tool/mock_server/mock_server.dart, que os testes
// importam para subir o mock numa porta livre e sem latência; a leitura das
// opções fica em tool/mock_server/cli.dart.
import 'dart:io';

import 'mock_server/cli.dart';
import 'mock_server/mock_server.dart';

Future<void> main(List<String> args) async {
  final MockServerOptions options;
  try {
    options = parseMockServerOptions(args, Platform.environment);
  } on FormatException catch (e) {
    stderr
      ..writeln('Erro: ${e.message}')
      ..writeln()
      ..writeln(mockServerUsage);
    exitCode = exitUsage;
    return;
  }
  if (options.help) {
    stdout.writeln(mockServerUsage);
    return;
  }

  final MockServer server;
  try {
    server = await startMockServer(
      port: options.port,
      minLatency: options.minLatency,
      maxLatency: options.maxLatency,
      log: stdout.writeln,
    );
  } on SocketException catch (e) {
    stderr.writeln(
      'Não foi possível escutar na porta ${options.port} '
      '(${e.osError?.message ?? e.message}). '
      'Outro mock já está rodando? Use --port ou PORT para escolher outra.',
    );
    exitCode = exitPortBusy;
    return;
  }

  stdout
    ..writeln('Mock da API Carteira em http://localhost:${server.port}')
    ..writeln(
      'Latência: ${options.minLatency.inMilliseconds}–'
      '${options.maxLatency.inMilliseconds} ms '
      '(LATENCY_MIN_MS/LATENCY_MAX_MS). Ctrl+C para parar.',
    );
}
