import 'package:args/command_runner.dart';
import 'package:nock/src/commands/chart.dart';
import 'package:nock/src/commands/health.dart';

void main(List<String> args) async {
  final runner = CommandRunner<void>(
    'nock',
    'CLI astrology app — living API docs for Quiver.',
  )
    ..addCommand(HealthCommand())
    ..addCommand(ChartCommand());

  await runner.run(args);
}
