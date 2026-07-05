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
    var failed = false;

    return invoker(call, method, requests).transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) => sink.add(data),
        handleError: (error, stackTrace, sink) {
          failed = true;
          stopwatch.stop();
          final status = error is GrpcError ? error.codeName : 'INTERNAL';
          _log.warning(
            '${method.name} $ip $status ${stopwatch.elapsedMilliseconds}ms',
          );
          sink.addError(error, stackTrace);
        },
        handleDone: (sink) {
          if (!failed) {
            stopwatch.stop();
            _log.info(
              '${method.name} $ip OK ${stopwatch.elapsedMilliseconds}ms',
            );
          }
          sink.close();
        },
      ),
    );
  }
}
