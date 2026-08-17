# Build: docker build -f quiver/Dockerfile .   (from monorepo root)
# Run:   docker run -p 50051:50051 quiver

# --- Stage 1: Resolve dependencies ---
FROM dart:3.12 AS deps

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy pubspecs first for layer caching.
# All workspace members need a pubspec for `dart pub get` to succeed.
COPY pubspec.yaml ./
COPY arrow/pubspec.yaml arrow/
COPY arrow/options/pubspec.yaml arrow/options/
COPY arrow/swe/pubspec.yaml arrow/swe/
COPY arrow/core/pubspec.yaml arrow/core/
COPY arrow/calc/pubspec.yaml arrow/calc/
COPY arrow/rdf/pubspec.yaml arrow/rdf/
COPY arrow/tool/pubspec.yaml arrow/tool/
COPY quiver/core/pubspec.yaml quiver/core/
COPY quiver/server/pubspec.yaml quiver/server/
COPY quiver/embedded/pubspec.yaml quiver/embedded/
COPY nock/pubspec.yaml nock/
COPY bowyer/core/pubspec.yaml bowyer/core/
COPY bowyer/cli/pubspec.yaml bowyer/cli/
COPY drishti/pubspec.yaml drishti/

RUN dart pub get

# --- Stage 2: Build AOT binary ---
FROM deps AS build

RUN dart pub global activate protoc_plugin

RUN apt-get update && apt-get install -y --no-install-recommends \
    protobuf-compiler libprotobuf-dev && rm -rf /var/lib/apt/lists/*

COPY proto/ proto/
COPY arrow/options/ arrow/options/
COPY arrow/swe/ arrow/swe/
COPY arrow/core/ arrow/core/
COPY arrow/calc/ arrow/calc/
COPY quiver/core/ quiver/core/
COPY quiver/server/ quiver/server/

RUN protoc \
      --proto_path=proto \
      -I/usr/include \
      --plugin=protoc-gen-dart=$HOME/.pub-cache/bin/protoc-gen-dart \
      --dart_out=grpc:quiver/core/lib/src/generated \
      proto/arrow/types.proto \
      proto/arrow/chart.proto \
      proto/quiver/health.proto \
      proto/quiver/types.proto \
      proto/quiver/chart.proto \
      proto/grpc/health/v1/health.proto

# dart compile exe (3.12) does not invoke native asset build hooks, so the
# pre-built .so from the host workspace is copied in via the build context.
# `dart pub get` does NOT refresh that file, so it silently goes stale on a
# swisseph_rs bump: run scripts/check-quiver-native-lib.sh before building.
# See docs/swisseph-rs-native-lib.md.
COPY arrow/swe/.dart_tool/lib/libswisseph_rs_dart.so /app/lib/

RUN mkdir -p /app/bin && \
    dart compile exe quiver/server/bin/quiver_server.dart \
    -o /app/bin/quiver_server

# --- Stage 3: Slim runtime ---
FROM debian:trixie-slim AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

ARG GRPC_HEALTH_PROBE_VERSION=v0.4.28
RUN curl -fsSL -o /usr/local/bin/grpc_health_probe \
      "https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64" && \
    chmod +x /usr/local/bin/grpc_health_probe

RUN apt-get purge -y curl && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /app/bin/ /app/bin/
COPY --from=build /app/lib/ /app/lib/
COPY drishti/ephe/ /app/ephe/

ENV LD_PRELOAD=/app/lib/libswisseph_rs_dart.so
ENV QUIVER_PORT=50051
ENV QUIVER_POOL_SIZE=2
ENV QUIVER_EPHE_PATH=/app/ephe

EXPOSE 50051

CMD ["/bin/sh", "-c", \
  "exec /app/bin/quiver_server --port $QUIVER_PORT --ephe-path $QUIVER_EPHE_PATH --pool-size $QUIVER_POOL_SIZE"]
