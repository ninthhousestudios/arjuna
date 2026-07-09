// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:logging/logging.dart';

final _log = Logger('Quiver.Server.IsolatePool');

/// Request sent to a worker isolate via SendPort.
///
/// Dart isolate messages must be "sendable" — primitive types, lists, maps,
/// SendPort, etc. Freezed objects' `toJson()` may retain typed sub-objects
/// that are not sendable, so we use `jsonEncode` to produce a pure JSON string
/// and `jsonDecode` on the other side to get raw maps.
class _CalcRequest {
  final int id;
  final double jdUt;
  final String locationJsonStr;
  final String optionsJsonStr;
  final SendPort replyPort;

  _CalcRequest({
    required this.id,
    required this.jdUt,
    required this.locationJsonStr,
    required this.optionsJsonStr,
    required this.replyPort,
  });

  /// Encode as a sendable list of primitives + SendPort.
  List<Object> toMessage() => [
    id,
    jdUt,
    locationJsonStr,
    optionsJsonStr,
    replyPort,
  ];

  static _CalcRequest fromMessage(List<Object> msg) => _CalcRequest(
    id: msg[0] as int,
    jdUt: msg[1] as double,
    locationJsonStr: msg[2] as String,
    optionsJsonStr: msg[3] as String,
    replyPort: msg[4] as SendPort,
  );
}

/// Response sent back from a worker isolate.
class _CalcResponse {
  final int id;
  final String? snapshotJsonStr;
  final String? error;

  _CalcResponse({required this.id, this.snapshotJsonStr, this.error});

  List<Object?> toMessage() => [id, snapshotJsonStr, error];

  static _CalcResponse fromMessage(List<Object?> msg) => _CalcResponse(
    id: msg[0] as int,
    snapshotJsonStr: msg[1] as String?,
    error: msg[2] as String?,
  );
}

/// Pool of worker isolates for concurrent ephemeris calculations.
///
/// Each worker gets its own copy of `libswisseph.so` so that `dlopen` sees a
/// distinct path and allocates independent C globals per isolate.
///
/// Dispatch is round-robin. Each request gets a unique [Completer]; the worker
/// sends back the result (serialized as JSON) which completes the future.
class IsolatePool {
  final int size;
  final String? ephePath;

  final List<Isolate> _isolates = [];
  final List<SendPort> _sendPorts = [];
  int _nextWorker = 0;
  int _nextId = 0;
  final Map<int, Completer<EphSnapshot>> _pending = {};
  final List<ReceivePort> _receivePorts = [];
  final List<String> _libCopyPaths = [];
  bool _started = false;
  bool _disposed = false;

  IsolatePool({int? size, this.ephePath})
    : size = (size ?? Platform.numberOfProcessors).clamp(2, 16);

  static String _findBaseLibPath() {
    final dartTool = Directory('.dart_tool');
    if (!dartTool.existsSync()) {
      throw StateError('Cannot find .dart_tool directory for libswisseph');
    }
    return dartTool
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (f) =>
              f.path.endsWith('libswisseph.so') ||
              f.path.endsWith('libswisseph.dylib'),
        )
        .first
        .path;
  }

  static String _copyLibForWorker(String sourcePath, int workerId) {
    final tmpDir = Directory.systemTemp.createTempSync('quiver_worker_');
    final ext = sourcePath.endsWith('.dylib') ? 'dylib' : 'so';
    final destPath = '${tmpDir.path}/libswisseph_$workerId.$ext';
    File(sourcePath).copySync(destPath);
    return destPath;
  }

  /// Start all worker isolates. Must be called before [calculate].
  Future<void> start() async {
    if (_started) return;
    _started = true;
    _log.info('Starting isolate pool with $size workers');

    final baseLibPath = _findBaseLibPath();
    _log.fine('Found base library at $baseLibPath');
    for (var i = 0; i < size; i++) {
      final copyPath = _copyLibForWorker(baseLibPath, i);
      _libCopyPaths.add(copyPath);
    }
    _log.fine('Created $size per-worker library copies');

    for (var i = 0; i < size; i++) {
      final receivePort = ReceivePort();
      _receivePorts.add(receivePort);

      final initPort = ReceivePort();
      final isolate = await Isolate.spawn(
        _workerEntryPoint,
        _WorkerInit(
          sendPort: initPort.sendPort,
          ephePath: ephePath,
          libPath: _libCopyPaths[i],
          workerId: i,
        ).toMessage(),
      );
      _isolates.add(isolate);

      // Worker sends its SendPort back on the init port.
      final workerSendPort =
          await initPort.first.timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw StateError(
                  'Worker $i failed to initialize within 10s',
                ),
              )
              as SendPort;
      _sendPorts.add(workerSendPort);
      initPort.close();

      // Listen for responses from this worker.
      receivePort.listen((message) {
        final response = _CalcResponse.fromMessage(message as List<Object?>);
        final completer = _pending.remove(response.id);
        if (completer == null) return;

        if (response.error != null) {
          completer.completeError(
            StateError('Worker calculation failed: ${response.error}'),
          );
        } else {
          try {
            final jsonMap =
                jsonDecode(response.snapshotJsonStr!) as Map<String, dynamic>;
            final snapshot = EphSnapshot.fromJson(jsonMap);
            completer.complete(snapshot);
          } catch (e, stack) {
            completer.completeError(e, stack);
          }
        }
      });

      _log.fine('Worker $i started');
    }

    _log.info('Isolate pool ready');
  }

  /// Send a calc request to the next available isolate (round-robin).
  Future<EphSnapshot> calculate(
    double jdUt,
    Location location,
    ArrowOptions options, {
    Duration? timeout,
  }) {
    if (!_started || _disposed) {
      throw StateError('IsolatePool is not running');
    }

    final id = _nextId++;
    final completer = Completer<EphSnapshot>();
    _pending[id] = completer;

    final workerIndex = _nextWorker;
    _nextWorker = (_nextWorker + 1) % size;

    final request = _CalcRequest(
      id: id,
      jdUt: jdUt,
      locationJsonStr: jsonEncode(location.toJson()),
      optionsJsonStr: jsonEncode(options.toJson()),
      replyPort: _receivePorts[workerIndex].sendPort,
    );

    _sendPorts[workerIndex].send(request.toMessage());
    _log.fine('Dispatched request $id to worker $workerIndex');

    final future = completer.future;
    if (timeout != null) {
      return future.timeout(
        timeout,
        onTimeout: () {
          _pending.remove(id);
          throw TimeoutException('IsolatePool request $id timed out', timeout);
        },
      );
    }
    return future;
  }

  /// Graceful shutdown — complete in-flight requests, then close all isolates.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _log.info('Disposing isolate pool...');

    // Wait for in-flight requests with a grace period.
    if (_pending.isNotEmpty) {
      _log.fine('Waiting for ${_pending.length} in-flight requests');
      try {
        await Future.wait(
          _pending.values.map((c) => c.future.catchError((_) {})),
        ).timeout(const Duration(seconds: 5));
      } on TimeoutException {
        _log.warning(
          'Timed out waiting for ${_pending.length} in-flight requests during dispose',
        );
        for (final c in _pending.values) {
          if (!c.isCompleted) {
            c.completeError(
              StateError('IsolatePool disposed while request was pending'),
            );
          }
        }
      }
    }

    for (final rp in _receivePorts) {
      rp.close();
    }
    for (final isolate in _isolates) {
      isolate.kill(priority: Isolate.beforeNextEvent);
    }

    _isolates.clear();
    _sendPorts.clear();
    _receivePorts.clear();
    _pending.clear();

    for (final path in _libCopyPaths) {
      try {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
        final dir = file.parent;
        if (dir.existsSync()) dir.deleteSync();
      } catch (e) {
        _log.fine('Failed to clean up library copy $path: $e');
      }
    }
    _libCopyPaths.clear();

    _log.info('Isolate pool disposed');
  }
}

/// Init message sent to each worker isolate.
class _WorkerInit {
  final SendPort sendPort;
  final String? ephePath;
  final String libPath;
  final int workerId;

  _WorkerInit({
    required this.sendPort,
    this.ephePath,
    required this.libPath,
    required this.workerId,
  });

  List<Object?> toMessage() => [sendPort, ephePath, libPath, workerId];

  static _WorkerInit fromMessage(List<Object?> msg) => _WorkerInit(
    sendPort: msg[0] as SendPort,
    ephePath: msg[1] as String?,
    libPath: msg[2] as String,
    workerId: msg[3] as int,
  );
}

/// Entry point for each worker isolate.
///
/// Each worker receives its own copy of `libswisseph.so` via [_WorkerInit.libPath]
/// so that `dlopen` allocates independent C globals per isolate.
///
/// Serialization relies on freezed-generated `toJson`/`fromJson` for
/// [Location], [ArrowOptions], and [EphSnapshot]. If `.g.dart` files are stale,
/// deserialization may silently drop fields. Run `melos generate` after
/// modifying freezed model classes.
void _workerEntryPoint(List<Object?> initMessage) {
  final init = _WorkerInit.fromMessage(initMessage);
  final log = Logger('Quiver.Server.IsolatePool.Worker${init.workerId}');

  final swe = SweFacade.create(libPath: init.libPath, ephePath: init.ephePath);
  log.fine('Worker ${init.workerId} initialized with ${init.libPath}');

  // Create a receive port for incoming requests and send it back.
  final receivePort = ReceivePort();
  init.sendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    final request = _CalcRequest.fromMessage(message as List<Object>);

    try {
      final locationMap =
          jsonDecode(request.locationJsonStr) as Map<String, dynamic>;
      final optionsMap =
          jsonDecode(request.optionsJsonStr) as Map<String, dynamic>;
      final location = Location.fromJson(locationMap);
      final options = ArrowOptions.fromJson(optionsMap);

      final snapshot = swe.calcAll(request.jdUt, location, options.sweConfig);
      final response = _CalcResponse(
        id: request.id,
        snapshotJsonStr: jsonEncode(snapshot.toJson()),
      );
      request.replyPort.send(response.toMessage());
    } catch (e, stack) {
      log.severe('Calculation failed for request ${request.id}', e, stack);
      final response = _CalcResponse(id: request.id, error: e.toString());
      request.replyPort.send(response.toMessage());
    }
  });
}
