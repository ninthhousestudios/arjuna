import 'package:grpc/grpc.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:quiver_core/src/generated/arrow/chart.pb.dart';
import 'package:quiver_core/src/mapping/request_mapper.dart';
import 'package:test/test.dart';

void main() {
  // J2000.0: 2000-01-01T12:00:00Z = JD 2451545.0
  const j2000Jd = 2451545.0;
  final j2000Dt = DateTime.utc(2000, 1, 1, 12);

  group('resolveJdUt', () {
    test('jd_ut passes through', () {
      final request = CalcRequest(jdUt: j2000Jd);
      expect(RequestMapper.resolveJdUt(request), j2000Jd);
    });

    test('Timestamp converts to correct JD', () {
      final request = CalcRequest(datetime: Timestamp.fromDateTime(j2000Dt));
      expect(RequestMapper.resolveJdUt(request), closeTo(j2000Jd, 0.0001));
    });

    test('ISO 8601 string converts to correct JD', () {
      final request = CalcRequest(datetimeIso: '2000-01-01T12:00:00Z');
      expect(RequestMapper.resolveJdUt(request), closeTo(j2000Jd, 0.0001));
    });

    test('ISO 8601 with timezone offset converts correctly', () {
      // 2000-01-01T17:30:00+05:30 = 2000-01-01T12:00:00Z
      final request = CalcRequest(datetimeIso: '2000-01-01T17:30:00+05:30');
      expect(RequestMapper.resolveJdUt(request), closeTo(j2000Jd, 0.0001));
    });

    test('errors when no time field is set', () {
      final request = CalcRequest();
      expect(
        () => RequestMapper.resolveJdUt(request),
        throwsA(
          isA<GrpcError>().having(
            (e) => e.code,
            'code',
            StatusCode.invalidArgument,
          ),
        ),
      );
    });

    test('errors when multiple time fields are set', () {
      final request = CalcRequest(
        jdUt: j2000Jd,
        datetime: Timestamp.fromDateTime(j2000Dt),
      );
      expect(
        () => RequestMapper.resolveJdUt(request),
        throwsA(
          isA<GrpcError>().having(
            (e) => e.code,
            'code',
            StatusCode.invalidArgument,
          ),
        ),
      );
    });

    test('errors when jd_ut and datetime_iso are both set', () {
      final request = CalcRequest(
        jdUt: j2000Jd,
        datetimeIso: '2000-01-01T12:00:00Z',
      );
      expect(
        () => RequestMapper.resolveJdUt(request),
        throwsA(
          isA<GrpcError>().having(
            (e) => e.code,
            'code',
            StatusCode.invalidArgument,
          ),
        ),
      );
    });

    test('errors on invalid ISO string', () {
      final request = CalcRequest(datetimeIso: 'not-a-date');
      expect(
        () => RequestMapper.resolveJdUt(request),
        throwsA(
          isA<GrpcError>().having(
            (e) => e.code,
            'code',
            StatusCode.invalidArgument,
          ),
        ),
      );
    });

    test('errors on ISO string without timezone designator', () {
      final request = CalcRequest(datetimeIso: '2000-01-01T12:00:00');
      expect(
        () => RequestMapper.resolveJdUt(request),
        throwsA(
          isA<GrpcError>().having(
            (e) => e.code,
            'code',
            StatusCode.invalidArgument,
          ),
        ),
      );
    });

    test('errors when jd_ut set alongside empty datetime_iso', () {
      final request = CalcRequest(jdUt: j2000Jd, datetimeIso: '');
      expect(
        () => RequestMapper.resolveJdUt(request),
        throwsA(
          isA<GrpcError>().having(
            (e) => e.code,
            'code',
            StatusCode.invalidArgument,
          ),
        ),
      );
    });
  });
}
