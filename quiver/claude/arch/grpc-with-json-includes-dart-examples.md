# Arrow Server — gRPC with JSON Codec Support

## The Concept

A single gRPC server that speaks **binary protobuf by default** but can accept **JSON-encoded protobuf** on the same port, same service, same endpoints. No separate REST API. No gateway. One server, two encodings.

```
Production:   KalaBrain ── gRPC (protobuf) ──▶ Arrow Server  (fast, binary)
Development:  grpcurl    ── gRPC (JSON)     ──▶ Arrow Server  (readable, debuggable)
Future:       Any client ── gRPC (protobuf) ──▶ Arrow Server  (typed, generated)
```

---

## How the Two Codecs Work

gRPC uses `content-type` headers to determine encoding:

```
content-type: application/grpc+proto    →  binary protobuf (default)
content-type: application/grpc+json     →  JSON protobuf
```

The server registers **both codecs**. The client chooses which one to use. The proto file defines the contract either way — JSON is just a different serialization of the same messages.

```
┌──────────────┐
│  arrow.proto │ ← single source of truth
└──────┬───────┘
       │
       │  generates
       ▼
┌──────────────────────────────────────┐
│          Arrow gRPC Server           │
│                                      │
│   ┌────────────┐  ┌──────────────┐   │
│   │  Protobuf  │  │     JSON     │   │
│   │   Codec    │  │    Codec     │   │
│   └────────────┘  └──────────────┘   │
│                                      │
│   Same service, same methods,        │
│   same port                          │
└──────────────────────────────────────┘
```

---

## The Proto File

This is the **single contract** that defines everything. All generated code — Dart, Python, or anything else — comes from this file.

```protobuf
syntax = "proto3";

package arrow;

// ─── Services ────────────────────────────────────────

service ArrowService {
  rpc CalculateChart (ChartRequest)       returns (EphSnapshot);
  rpc CalculateTransits (TransitRequest)  returns (TransitResult);
  rpc GetStatus (Empty)                   returns (ServerStatus);
}

// ─── Request Messages ────────────────────────────────

message ChartRequest {
  double julian_day = 1;
  double latitude = 2;
  double longitude = 3;
  double altitude = 4;
  SweConfig swe_config = 5;
}

message TransitRequest {
  double julian_day_start = 1;
  double julian_day_end = 2;
  double latitude = 3;
  double longitude = 4;
  SweConfig swe_config = 5;
}

// ─── Core Data Types ─────────────────────────────────

message SweConfig {
  Ayanamsa ayanamsa = 1;
  HouseSystem house_system = 2;
  NodeType node_type = 3;
  bool topocentric = 4;
}

message EphSnapshot {
  double julian_day = 1;
  double ayanamsa_value = 2;
  repeated GrahaPosition graha_positions = 3;
  repeated HouseCusp house_cusps = 4;
  AscMcPoints asc_mc = 5;
  SweConfig config_used = 6;
}

message GrahaPosition {
  GrahaId graha = 1;
  double longitude = 2;
  double latitude = 3;
  double distance = 4;
  double speed_longitude = 5;
  double speed_latitude = 6;
  double speed_distance = 7;
}

message HouseCusp {
  int32 house_number = 1;
  double longitude = 2;
}

message AscMcPoints {
  double ascendant = 1;
  double mc = 2;
  double armc = 3;
  double vertex = 4;
  double equatorial_ascendant = 5;
}

// ─── Enums ───────────────────────────────────────────

enum Ayanamsa {
  LAHIRI = 0;
  RAMAN = 1;
  KRISHNAMURTI = 2;
  FAGAN_BRADLEY = 3;
}

enum HouseSystem {
  WHOLE_SIGN = 0;
  PLACIDUS = 1;
  KOCH = 2;
  EQUAL = 3;
  CAMPANUS = 4;
  REGIOMONTANUS = 5;
  SRIPATI = 6;
}

enum NodeType {
  TRUE_NODE = 0;
  MEAN_NODE = 1;
}

enum GrahaId {
  SUN = 0;
  MOON = 1;
  MARS = 2;
  MERCURY = 3;
  JUPITER = 4;
  VENUS = 5;
  SATURN = 6;
  RAHU = 7;
  KETU = 8;
  URANUS = 9;
  NEPTUNE = 10;
  PLUTO = 11;
}

message Empty {}

message ServerStatus {
  string version = 1;
  bool ephemeris_loaded = 2;
}
```

---

## Generated Dart Code → Arrow Domain Types

The proto file generates **raw Dart classes** (prefixed with generated names). Your Arrow domain types **wrap** them, keeping the clean API you already designed.

### What Gets Generated

```
arrow.proto
    │
    │  protoc + dart plugin
    ▼
lib/generated/
    ├── arrow.pb.dart          # Message classes
    ├── arrow.pbenum.dart      # Enum classes
    ├── arrow.pbgrpc.dart      # Service stubs + client
    └── arrow.pbjson.dart      # JSON codec support
```

### Bridging Generated Code → Arrow Domain Types

```dart
// lib/src/bridge/snapshot_bridge.dart

import 'package:arrow_swe/src/eph_snapshot.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_server/generated/arrow.pb.dart' as pb;

/// Converts between protobuf generated types and Arrow domain types.
/// This is the ONLY place that knows about both worlds.

class SnapshotBridge {

  /// Proto → Domain (server receives request, or client receives response)
  static EphSnapshot fromProto(pb.EphSnapshot proto) {
    return EphSnapshot(
      julianDay: proto.julianDay,
      ayanamsaValue: proto.ayanamsaValue,
      grahaPositions: {
        for (final g in proto.grahaPositions)
          _grahaIdFromProto(g.graha): GrahaPositionData(
            longitude: g.longitude,
            latitude: g.latitude,
            distance: g.distance,
            speedLongitude: g.speedLongitude,
            speedLatitude: g.speedLatitude,
            speedDistance: g.speedDistance,
          ),
      },
      houseCusps: [
        for (final h in proto.houseCusps)
          h.longitude,
      ],
      ascMc: AscMcData(
        ascendant: proto.ascMc.ascendant,
        mc: proto.ascMc.mc,
        armc: proto.ascMc.armc,
        vertex: proto.ascMc.vertex,
        equatorialAscendant: proto.ascMc.equatorialAscendant,
      ),
      configUsed: _sweConfigFromProto(proto.configUsed),
    );
  }

  /// Domain → Proto (server sends response, or client sends request)
  static pb.EphSnapshot toProto(EphSnapshot snapshot) {
    return pb.EphSnapshot()
      ..julianDay = snapshot.julianDay
      ..ayanamsaValue = snapshot.ayanamsaValue
      ..grahaPositions.addAll(
        snapshot.grahaPositions.entries.map((e) =>
          pb.GrahaPosition()
            ..graha = _grahaIdToProto(e.key)
            ..longitude = e.value.longitude
            ..latitude = e.value.latitude
            ..distance = e.value.distance
            ..speedLongitude = e.value.speedLongitude
            ..speedLatitude = e.value.speedLatitude
            ..speedDistance = e.value.speedDistance,
        ),
      )
      ..houseCusps.addAll(
        snapshot.houseCusps.asMap().entries.map((e) =>
          pb.HouseCusp()
            ..houseNumber = e.key + 1
            ..longitude = e.value,
        ),
      )
      ..ascMc = (pb.AscMcPoints()
        ..ascendant = snapshot.ascMc.ascendant
        ..mc = snapshot.ascMc.mc
        ..armc = snapshot.ascMc.armc
        ..vertex = snapshot.ascMc.vertex
        ..equatorialAscendant = snapshot.ascMc.equatorialAscendant)
      ..configUsed = _sweConfigToProto(snapshot.configUsed);
  }

  // ─── Enum Mapping ──────────────────────────────────

  static GrahaId _grahaIdFromProto(pb.GrahaId id) {
    return GrahaId.values[id.value];
  }

  static pb.GrahaId _grahaIdToProto(GrahaId id) {
    return pb.GrahaId.valueOf(id.index)!;
  }

  static SweConfig _sweConfigFromProto(pb.SweConfig proto) {
    return SweConfig(
      ayanamsa: Ayanamsa.values[proto.ayanamsa.value],
      houseSystem: HouseSystem.values[proto.houseSystem.value],
      nodeType: NodeType.values[proto.nodeType.value],
      topocentric: proto.topocentric,
    );
  }

  static pb.SweConfig _sweConfigToProto(SweConfig config) {
    return pb.SweConfig()
      ..ayanamsa = pb.Ayanamsa.valueOf(config.ayanamsa.index)!
      ..houseSystem = pb.HouseSystem.valueOf(config.houseSystem.index)!
      ..nodeType = pb.NodeType.valueOf(config.nodeType.index)!
      ..topocentric = config.topocentric;
  }
}
```

### The Arrow gRPC Server

```dart
// lib/src/server/arrow_grpc_server.dart

import 'package:grpc/grpc.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:arrow_server/generated/arrow.pbgrpc.dart' as pb;
import 'package:arrow_server/src/bridge/snapshot_bridge.dart';

class ArrowGrpcService extends pb.ArrowServiceBase {
  final SweFacade _swe;

  ArrowGrpcService(this._swe);

  @override
  Future<pb.EphSnapshot> calculateChart(
    ServiceCall call,
    pb.ChartRequest request,
  ) async {
    // 1. Convert proto request → Arrow domain types
    final config = SnapshotBridge._sweConfigFromProto(request.sweConfig);

    // 2. Run the actual Arrow calculation (same code as on-device)
    final snapshot = await _swe.calculateAll(
      julianDay: request.julianDay,
      latitude: request.latitude,
      longitude: request.longitude,
      altitude: request.altitude,
      config: config,
    );

    // 3. Convert Arrow domain → proto response
    return SnapshotBridge.toProto(snapshot);
  }

  @override
  Future<pb.ServerStatus> getStatus(
    ServiceCall call,
    pb.Empty request,
  ) async {
    return pb.ServerStatus()
      ..version = '0.0.1'
      ..ephemerisLoaded = true;
  }
}

// ─── Server Startup ──────────────────────────────────

Future<void> main() async {
  final swe = SweFacade();
  await swe.initialize();

  final server = Server.create(
    services: [ArrowGrpcService(swe)],
    codecRegistry: CodecRegistry(
      codecs: [GzipCodec(), JsonCodec()],  // ← JSON codec registered here
    ),
  );

  await server.serve(port: 50051);
  print('Arrow gRPC server listening on port 50051');
  print('  protobuf: default');
  print('  JSON:     content-type: application/grpc+json');
}
```

### KalaBrain Calling Arrow (Python)

```python
# kalabrain/services/arrow_client.py

import grpc
from arrow_pb2 import ChartRequest, SweConfig, Ayanamsa, HouseSystem, NodeType
from arrow_pb2_grpc import ArrowServiceStub

class ArrowClient:
    def __init__(self, host: str = "localhost", port: int = 50051):
        self.channel = grpc.insecure_channel(f"{host}:{port}")
        self.stub = ArrowServiceStub(self.channel)

    def calculate_chart(
        self,
        julian_day: float,
        latitude: float,
        longitude: float,
        altitude: float = 0.0,
    ):
        """Feels like a local function call. Returns typed EphSnapshot."""
        request = ChartRequest(
            julian_day=julian_day,
            latitude=latitude,
            longitude=longitude,
            altitude=altitude,
            swe_config=SweConfig(
                ayanamsa=Ayanamsa.LAHIRI,
                house_system=HouseSystem.WHOLE_SIGN,
                node_type=NodeType.TRUE_NODE,
                topocentric=False,
            ),
        )
        return self.stub.CalculateChart(request)


# ─── Usage in a FastAPI route ─────────────────────────

# kalabrain/api/calc_router.py

from fastapi import APIRouter
from kalabrain.services.arrow_client import ArrowClient

router = APIRouter()
arrow = ArrowClient()

@router.get("/chart")
async def get_chart(julian_day: float, lat: float, lon: float):
    snapshot = arrow.calculate_chart(julian_day, lat, lon)
    # snapshot is a fully typed protobuf object
    # snapshot.graha_positions[0].longitude, etc.
    return {"ayanamsa": snapshot.ayanamsa_value, "ascendant": snapshot.asc_mc.ascendant}
```

### Debugging with JSON

```bash
# Install grpcurl (brew install grpcurl / go install)

# Binary protobuf (default) — need proto file for reflection
grpcurl -plaintext \
  -d '{"julian_day": 2460000.5, "latitude": 39.77, "longitude": -86.16, "swe_config": {"ayanamsa": "LAHIRI", "house_system": "WHOLE_SIGN"}}' \
  localhost:50051 \
  arrow.ArrowService/CalculateChart

# Returns human-readable JSON:
# {
#   "julianDay": 2460000.5,
#   "ayanamsaValue": 24.168,
#   "grahaPositions": [
#     {"graha": "SUN", "longitude": 132.456, "speedLongitude": 0.953},
#     {"graha": "MOON", "longitude": 267.891, "speedLongitude": 13.176},
#     ...
#   ],
#   "ascMc": {"ascendant": 184.523, "mc": 95.112}
# }
```

---

## Deployment

```
┌──────────────────────────────────────────────────┐
│              Server / Container Host              │
│                                                   │
│   ┌───────────────┐      ┌────────────────────┐  │
│   │   KalaBrain   │      │   Arrow Server     │  │
│   │   (FastAPI)   │      │   (Dart gRPC)      │  │
│   │   port 8000   │─gRPC─│   port 50051       │  │
│   │               │      │                    │  │
│   │  - Auth       │      │  - SWE calc        │  │
│   │  - Aditi/LLM  │      │  - Same engine     │  │
│   │  - Supabase   │      │    as on-device    │  │
│   └───────────────┘      └────────────────────┘  │
│                                                   │
│   Communication is localhost — fast, no TLS       │
└──────────────────────────────────────────────────┘
```

---

## Open Questions

**Should the client (Celestial) ever talk directly to Arrow Server?**
Currently the design assumes client → KalaBrain → Arrow Server. But there may be cases where the client could bypass KalaBrain and hit Arrow Server directly for pure calculation with no auth/business logic. Needs further thought on security and simplicity tradeoffs.

**Can multiple Arrow Server instances sit behind a load balancer?**
Arrow calculations are stateless — no session, no database, pure function in / result out. This makes it a natural candidate for horizontal scaling. Multiple Dart gRPC instances behind a load balancer (nginx, envoy, k8s service) should work cleanly. But is this premature? What scale triggers the need? TBD.
