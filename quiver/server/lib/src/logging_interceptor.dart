import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';

final _log = Logger('Quiver.Access');

const _healthMethods = {'Check', 'Watch'};

class LoggingInterceptor extends ServerInterceptor {
  @override
  Stream<R> intercept<Q, R>(
    ServiceCall call,
    ServiceMethod<Q, R> method,
    Stream<Q> requests,
    ServerStreamingInvoker<Q, R> invoker,
  ) {
    if (_healthMethods.contains(method.name)) {
      return invoker(call, method, requests);
    }

    final stopwatch = Stopwatch()..start();
    final ip = call.remoteAddress?.address ?? 'unknown';
    var logged = false;

    void log(String status, Level level) {
      if (logged) return;
      logged = true;
      stopwatch.stop();
      _log.log(
        level,
        '${method.name} $ip $status ${stopwatch.elapsedMilliseconds}ms',
      );
    }

    final upstream = invoker(call, method, requests);
    late final StreamSubscription<R> sub;
    final controller = StreamController<R>(
      onPause: () => sub.pause(),
      onResume: () => sub.resume(),
      onCancel: () {
        log('CANCELLED', Level.INFO);
        return sub.cancel();
      },
    );

    sub = upstream.listen(
      controller.add,
      onError: (Object error, StackTrace st) {
        final status = error is GrpcError ? error.codeName : 'INTERNAL';
        log(status, Level.WARNING);
        controller.addError(error, st);
      },
      onDone: () {
        log('OK', Level.INFO);
        controller.close();
      },
    );

    return controller.stream;
  }
}
