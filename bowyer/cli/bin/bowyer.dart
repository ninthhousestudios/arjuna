import 'package:args/command_runner.dart';

void main(List<String> args) {
  final runner = CommandRunner<void>(
    'bowyer',
    'Admin panel CLI for Quiver.',
  );

  runner.run(args);
}
