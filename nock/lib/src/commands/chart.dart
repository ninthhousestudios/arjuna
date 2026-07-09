// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:args/command_runner.dart';
import 'package:grpc/grpc.dart';
import 'package:quiver_core/quiver_core.dart';

const _signNames = [
  'Ari',
  'Tau',
  'Gem',
  'Can',
  'Leo',
  'Vir',
  'Lib',
  'Sco',
  'Sag',
  'Cap',
  'Aqu',
  'Pis',
];

class ChartCommand extends Command<void> {
  @override
  final name = 'chart';

  @override
  final description = 'Calculate and display a birth chart.';

  ChartCommand() {
    argParser
      ..addOption('jd', help: 'Julian Day UT (e.g. 2451545.0)')
      ..addOption('date', help: 'Date as YYYY-MM-DD HH:MM (UTC)')
      ..addOption('lat', help: 'Latitude', mandatory: true)
      ..addOption('lon', help: 'Longitude', mandatory: true)
      ..addOption('host', defaultsTo: 'localhost')
      ..addOption('port', abbr: 'p', defaultsTo: '50051');
  }

  @override
  Future<void> run() async {
    final jd = _parseJd();
    final lat = double.parse(argResults!.option('lat')!);
    final lon = double.parse(argResults!.option('lon')!);
    final host = argResults!.option('host')!;
    final port = int.parse(argResults!.option('port')!);

    final channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    try {
      final client = ChartServiceClient(channel);
      final response = await client.calculate(
        CalcRequest(
          jdUt: jd,
          location: Location(latitude: lat, longitude: lon),
        ),
      );

      _printChart(response.snapshot, lat, lon);
    } on GrpcError catch (e) {
      print('Failed: ${e.message}');
    } finally {
      await channel.shutdown();
    }
  }

  double _parseJd() {
    if (argResults!.option('jd') != null) {
      return double.parse(argResults!.option('jd')!);
    }
    if (argResults!.option('date') != null) {
      final dt = DateTime.parse(argResults!.option('date')!);
      // Approximate Julian Day from DateTime
      // JD = 2440587.5 + (unix_seconds / 86400)
      return 2440587.5 + dt.millisecondsSinceEpoch / 86400000.0;
    }
    usageException('Provide --jd or --date');
  }

  void _printChart(EphSnapshot snapshot, double lat, double lon) {
    print('');
    print('┌─────────────────────────────────────────┐');
    print('│  Chart @ JD ${snapshot.jdUt.toStringAsFixed(4)}');
    print(
      '│  Location: ${lat.toStringAsFixed(4)}N, '
      '${lon.toStringAsFixed(4)}E',
    );
    print('├─────────────────────────────────────────┤');
    print(
      '│  Asc ${_fmtLon(snapshot.ascmc.ascendant)}  '
      'MC ${_fmtLon(snapshot.ascmc.mc)}',
    );
    print('├─────────┬───────────┬───────────────────┤');
    print('│  Body   │ Longitude │ Speed             │');
    print('├─────────┼───────────┼───────────────────┤');

    for (final entry in snapshot.bodiesEcliptic) {
      final name = entry.body.name.padRight(7);
      final lon = _fmtLon(entry.position.longitude);
      final speed = entry.position.speedLongitude;
      final retro = speed < 0 ? ' R' : '  ';
      print(
        '│  $name │ $lon │ '
        '${speed.toStringAsFixed(4).padLeft(8)}$retro      │',
      );
    }

    print('├─────────┴───────────┴───────────────────┤');
    print('│  Cusps                                  │');
    print('├─────────────────────────────────────────┤');

    for (var i = 0; i < snapshot.cusps.length; i++) {
      print(
        '│  House ${(i + 1).toString().padLeft(2)}: ${_fmtLon(snapshot.cusps[i])}',
      );
    }

    print('└─────────────────────────────────────────┘');
  }

  String _fmtLon(double lon) {
    final sign = (lon ~/ 30).toInt() % 12;
    final deg = lon % 30;
    final d = deg.toInt();
    final m = ((deg - d) * 60).toInt();
    return '${d.toString().padLeft(2)}°${m.toString().padLeft(2, '0')} ${_signNames[sign]}';
  }
}
