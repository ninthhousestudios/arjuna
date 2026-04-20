import 'package:arrow_calc/arrow_calc.dart';
import 'package:test/test.dart';

void main() {
  group('Baladi.of', () {
    test('odd sign — normal order', () {
      // sign 1 (Aries, odd): 0–6°=Bala, 6–12°=Kumara, 12–18°=Yuva,
      // 18–24°=Vriddha, 24–30°=Mrita.
      expect(Baladi.of(1, 0), BaladiState.bala);
      expect(Baladi.of(1, 5.99), BaladiState.bala);
      expect(Baladi.of(1, 6), BaladiState.kumara);
      expect(Baladi.of(1, 12), BaladiState.yuva);
      expect(Baladi.of(1, 18), BaladiState.vriddha);
      expect(Baladi.of(1, 24), BaladiState.mrita);
      expect(Baladi.of(1, 29.99), BaladiState.mrita);
    });

    test('even sign — reversed order', () {
      expect(Baladi.of(2, 0), BaladiState.mrita);
      expect(Baladi.of(2, 6), BaladiState.vriddha);
      expect(Baladi.of(2, 12), BaladiState.yuva);
      expect(Baladi.of(2, 18), BaladiState.kumara);
      expect(Baladi.of(2, 24), BaladiState.bala);
      expect(Baladi.of(2, 29.99), BaladiState.bala);
    });

    test('clamps inSignDeg=30 to last bucket', () {
      // `floor(30/6) = 5` → clamped to 4 (mrita) in odd, 0 (bala) in even.
      expect(Baladi.of(1, 30), BaladiState.mrita);
      expect(Baladi.of(2, 30), BaladiState.bala);
    });

    test('libaditya name', () {
      expect(BaladiState.bala.libadityaName, 'Bala');
      expect(BaladiState.mrita.libadityaName, 'Mrita');
    });
  });
}
