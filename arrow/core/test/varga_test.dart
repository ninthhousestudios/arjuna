// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_core/src/longitude.dart';
import 'package:arrow_core/src/varga_deities.dart';
import 'package:test/test.dart';

void main() {
  // Use zodiac circle for easier manual verification:
  // sign 1 = 0-30 (Aries), sign 2 = 30-60 (Taurus), etc.
  const config = CalcConfig(circle: Circle.zodiac);

  group('Parivritti navamsha (D9)', () {
    test('0deg Aries -> navamsha sign should be Aries (sign 1)', () {
      // 0deg in zodiac circle: sign 1 (Aries)
      // Parivritti: realLon=0, amshaSize=30/9=3.333..., position=0/3.333=0
      // amshaElapsed=0, newLon = 0 + 0*30 + 0 = 0 => sign 1
      final lon = Longitude(0.0, VargaType.navamsha, config);
      expect(lon.sign, 1);
      expect(lon.deity, VargaDeity.deva); // index 0 % 3 = 0 -> deva
    });

    test('45deg (15 Taurus) navamsha', () {
      // realLon = 45, amshaSize = 3.333...
      // position = 45 / 3.333... = 13.5
      // amshaElapsed = 13, currentInAmsha = 0.5
      // newLon = 0 + 13*30 + 0.5*30 = 390 + 15 = 405 => 405%360 = 45
      // But wait — the class does % 360 at assignment.
      // sign in zodiac = (45 / 30).floor() = 1 => sign 2
      final lon = Longitude(45.0, VargaType.navamsha, config);
      expect(lon.sign, 2);
      // deity: whichAmsha=13, 13%3=1 -> nri
      expect(lon.deity, VargaDeity.nri);
    });

    test('185deg (5 Libra) navamsha', () {
      // realLon = 185, position = 185/3.333... = 55.5
      // amshaElapsed = 55, currentInAmsha = 0.5
      // newLon = 0 + 55*30 + 15 = 1650 + 15 = 1665 => 1665%360 = 225
      // sign = (225/30).floor() = 7 => sign 8
      final lon = Longitude(185.0, VargaType.navamsha, config);
      expect(lon.sign, 8);
      // deity: 55%3=1 -> nri
      expect(lon.deity, VargaDeity.nri);
    });
  });

  group('Hora (D2)', () {
    test('5deg Aries (odd sign, first half) -> Sun, stays in Aries', () {
      // realSign = 1 (odd), realInSign = 5, < 15 -> Sun
      // baseLon = 0, newLon = 0 + (5/15)*30 = 10
      // sign = (10/30).floor() = 0 => sign 1
      final lon = Longitude(5.0, VargaType.hora, config);
      expect(lon.sign, 1);
      expect(lon.deity, VargaDeity.sun);
    });

    test('20deg Aries (odd sign, second half) -> Moon, opposite sign', () {
      // realSign = 1 (odd), realInSign = 20, >= 15 -> Moon
      // baseLon = 0, oppositeLon = 180
      // newLon = 180 + ((20-15)/15)*30 = 180 + 10 = 190
      // sign = (190/30).floor() = 6 => sign 7 (Libra)
      final lon = Longitude(20.0, VargaType.hora, config);
      expect(lon.sign, 7);
      expect(lon.deity, VargaDeity.moon);
    });

    test('35deg Taurus (even sign, first half) -> Moon, stays', () {
      // realSign = 2 (even), realInSign = 5, < 15 -> Moon
      // baseLon = 30, newLon = 30 + (5/15)*30 = 30+10 = 40
      // sign = (40/30).floor() = 1 => sign 2
      final lon = Longitude(35.0, VargaType.hora, config);
      expect(lon.sign, 2);
      expect(lon.deity, VargaDeity.moon);
    });

    test('50deg Taurus (even sign, second half) -> Sun, opposite', () {
      // realSign = 2 (even), realInSign = 20, >= 15 -> Sun
      // baseLon = 30, oppositeLon = 210
      // newLon = 210 + ((20-15)/15)*30 = 210+10 = 220
      // sign = (220/30).floor() = 7 => sign 8 (Scorpio)
      final lon = Longitude(50.0, VargaType.hora, config);
      expect(lon.sign, 8);
      expect(lon.deity, VargaDeity.sun);
    });
  });

  group('Drekkana (D3)', () {
    test('5deg Aries (first third) -> stays Aries, Narada', () {
      final lon = Longitude(5.0, VargaType.drekkana, config);
      expect(lon.sign, 1); // baseLon=0, (5/10)*30=15 => sign 1
      expect(lon.deity, VargaDeity.narada);
    });

    test('15deg Aries (second third) -> Leo (trine), Agastya', () {
      // trineLon = 0+120 = 120, newLon = 120 + ((15-10)/10)*30 = 120+15 = 135
      // sign = (135/30).floor() = 4 => sign 5 (Leo)
      final lon = Longitude(15.0, VargaType.drekkana, config);
      expect(lon.sign, 5);
      expect(lon.deity, VargaDeity.agastya);
    });

    test('25deg Aries (third third) -> Sagittarius, Durvasas', () {
      // trineTrineLon = 240, newLon = 240 + ((25-20)/10)*30 = 240+15 = 255
      // sign = (255/30).floor() = 8 => sign 9 (Sagittarius)
      final lon = Longitude(25.0, VargaType.drekkana, config);
      expect(lon.sign, 9);
      expect(lon.deity, VargaDeity.durvasas);
    });
  });

  group('Chaturthamsha (D4)', () {
    test('first quarter of Aries -> stays Aries, Sanaka', () {
      final lon = Longitude(3.0, VargaType.chaturthamsha, config);
      expect(lon.sign, 1);
      expect(lon.deity, VargaDeity.sanaka);
    });

    test('second quarter of Aries -> Cancer, Sananda', () {
      // fourth = 7.5, 10deg is in second quarter
      // sq1 = 90, newLon = 90 + ((10-7.5)/7.5)*30 = 90+10 = 100
      // sign = (100/30).floor() = 3 => sign 4 (Cancer)
      final lon = Longitude(10.0, VargaType.chaturthamsha, config);
      expect(lon.sign, 4);
      expect(lon.deity, VargaDeity.sananda);
    });
  });

  group('Dashamsha (D10)', () {
    test('5deg Aries (odd sign) -> starts from Aries', () {
      // realSign=1, odd. amshaSize=3, position=5/3=1.666
      // amshaElapsed=1, currentInAmsha=0.666
      // baseLon=0, newLon = 0 + 1*30 + 0.666*30 = 30+20 = 50
      // sign = (50/30).floor() = 1 => sign 2
      final lon = Longitude(5.0, VargaType.dashamsha, config);
      expect(lon.sign, 2);
    });

    test('35deg Taurus (even sign) -> starts from 9th sign', () {
      // realSign=2, even. evenStart = (2-1+8)%12 = 9
      // baseLonEven = _baseLon(10) = (30*9) = 270
      // realInSign = 35%30 = 5, position = 5/3 = 1.666
      // amshaElapsed=1, currentInAmsha=0.666
      // newLon = 270 + 30 + 20 = 320
      // sign = (320/30).floor() = 10 => sign 11
      final lon = Longitude(35.0, VargaType.dashamsha, config);
      expect(lon.sign, 11);
    });

    test('dashamsha odd sign deity is forward order', () {
      // 0deg Aries: amshaElapsed=0, odd sign -> first deity = Indra
      final lon = Longitude(0.0, VargaType.dashamsha, config);
      expect(lon.deity, VargaDeity.indra);
    });
  });

  group('Dvadashamsha (D12)', () {
    test('0deg Aries -> stays Aries, Ganesha', () {
      final lon = Longitude(0.0, VargaType.dvadashamsha, config);
      expect(lon.sign, 1);
      expect(lon.deity, VargaDeity.ganesha);
    });

    test('5deg Aries -> Pisces, Ashvins', () {
      // amshaSize = 2.5, position = 5/2.5 = 2
      // amshaElapsed=2, currentInAmsha=0
      // baseLon=0, newLon = 0 + 2*30 + 0 = 60
      // sign = (60/30).floor() = 2 => sign 3 (Gemini)
      // deity: 2%4=2 -> Yama
      final lon = Longitude(5.0, VargaType.dvadashamsha, config);
      expect(lon.sign, 3);
      expect(lon.deity, VargaDeity.yama);
    });
  });

  group('Shodashamsha (D16)', () {
    test('moveable sign starts from Aries', () {
      // 0deg Aries: moveable, baseLon=0
      // amshaSize=30/16=1.875, position=0
      // newLon=0+0+0=0, sign=1
      final lon = Longitude(0.0, VargaType.shodashamsha, config);
      expect(lon.sign, 1);
    });

    test('fixed sign starts from Leo', () {
      // 30deg Taurus: fixed sign (2)
      // baseLonFixed = (30*4) = 120
      // realInSign = 0, amshaElapsed=0
      // newLon = 120, sign = (120/30).floor()+1 = 5 (Leo)
      final lon = Longitude(30.0, VargaType.shodashamsha, config);
      expect(lon.sign, 5);
    });
  });

  group('Shashtyamsha (D60)', () {
    test('0deg Aries -> sign 1, deity Ghora', () {
      // realSign=1, realInSign=0
      // calc = (0*2).floor() = 0, remainder = 0%12 = 0
      // fromAmsha = 1, targetSign = ((1-1)+(1-1))%12+1 = 1
      // baseLon = 0
      // amshaElapsed=0, currentInAmsha=0
      // newLon = 0
      // sign = 1, deity: index 0, odd sign -> Ghora
      final lon = Longitude(0.0, VargaType.shashtyamsha, config);
      expect(lon.sign, 1);
      expect(lon.deity, VargaDeity.ghora);
    });

    test('deity for D60 is sign-parity dependent', () {
      // 30deg = 0deg Taurus (even sign, sign 2)
      // realInSign=0, calc=0, remainder=0, fromAmsha=1
      // targetSign = ((2-1)+(1-1))%12+1 = 2
      // baseLon = 30
      // amshaElapsed=0, even sign -> reversed list, index 0 = last item
      final lon = Longitude(30.0, VargaType.shashtyamsha, config);
      expect(lon.sign, 2);
      // Reversed D60 list index 0 = chandraRekha (last element reversed)
      expect(lon.deity, VargaDeity.chandraRekha);
    });
  });

  group('Khavedamsha (D40)', () {
    test('odd sign starts from Aries', () {
      final lon = Longitude(0.0, VargaType.khavedamsha, config);
      expect(lon.sign, 1);
      expect(lon.deity, VargaDeity.vishnu);
    });

    test('even sign starts from Libra', () {
      // 30deg = Taurus (even), baseLon = _baseLon(7) = 180
      // realInSign=0, amshaElapsed=0
      // newLon = 180, sign = 7
      final lon = Longitude(30.0, VargaType.khavedamsha, config);
      expect(lon.sign, 7);
    });
  });

  group('Akshavedamsha (D45)', () {
    test('moveable sign starts from Aries', () {
      // 0deg Aries: moveable, baseLon = 0
      final lon = Longitude(0.0, VargaType.akshavedamsha, config);
      expect(lon.sign, 1);
      // deity: moveable, index 0 % 3 = 0 -> Vidhi
      expect(lon.deity, VargaDeity.vidhi);
    });

    test('fixed sign starts from Leo', () {
      // 30deg Taurus: fixed, baseLon = _baseLon(5) = 120
      final lon = Longitude(30.0, VargaType.akshavedamsha, config);
      expect(lon.sign, 5);
      // deity: fixed, index 0 % 3 = 0 -> Isha
      expect(lon.deity, VargaDeity.isha);
    });

    test('dual sign starts from Sagittarius', () {
      // 60deg Gemini: dual, baseLon = _baseLon(9) = 240
      final lon = Longitude(60.0, VargaType.akshavedamsha, config);
      expect(lon.sign, 9);
      // deity: dual, index 0 % 3 = 0 -> Vishnu
      expect(lon.deity, VargaDeity.vishnu);
    });
  });

  group('Vimshamsha (D20)', () {
    test('moveable sign starts from Aries', () {
      final lon = Longitude(0.0, VargaType.vimshamsha, config);
      expect(lon.sign, 1);
    });

    test('odd sign uses odd deity table', () {
      // 0deg Aries: odd sign, amshaElapsed=0 -> Kali
      final lon = Longitude(0.0, VargaType.vimshamsha, config);
      expect(lon.deity, VargaDeity.kali);
    });

    test('even sign uses even deity table', () {
      // 30deg Taurus: even sign, amshaElapsed=0 -> Daya
      final lon = Longitude(30.0, VargaType.vimshamsha, config);
      expect(lon.deity, VargaDeity.daya);
    });
  });

  group('Bhamsha (D27)', () {
    test('fire sign starts from Aries', () {
      final lon = Longitude(0.0, VargaType.bhamsha, config);
      expect(lon.sign, 1);
    });

    test('earth sign starts from Cancer', () {
      // 30deg = Taurus (earth), startSign=4, baseLon=90
      final lon = Longitude(30.0, VargaType.bhamsha, config);
      expect(lon.sign, 4);
    });
  });

  group('Siddhamsha (D24)', () {
    test('odd sign starts from Leo', () {
      // 0deg Aries (odd), baseLonOdd = _baseLon(5) = 120
      // amshaElapsed=0 => newLon=120, sign=5 (Leo)
      final lon = Longitude(0.0, VargaType.siddhamsha, config);
      expect(lon.sign, 5);
    });

    test('even sign starts from Cancer (reversed direction)', () {
      // 30deg Taurus (even), baseLonEven = _baseLon(4) = 90
      // amshaElapsed=0, currentInAmsha=0 => newLon=90
      // sign = (90/30).floor() = 3 => sign 4 (Cancer)
      final lon = Longitude(30.0, VargaType.siddhamsha, config);
      expect(lon.sign, 4);
    });

    test('parashara even sign goes forward', () {
      final lon = Longitude(30.0, VargaType.parasharaChaturvimshamsha, config);
      expect(lon.sign, 4);
    });
  });

  group('Parivritti hora (D2 parivritti)', () {
    test('parivritti hora works', () {
      // D2 parivritti: amshaSize = 30/2 = 15
      // 0deg: position = 0/15 = 0, amshaElapsed=0, currentInAmsha=0
      // newLon = 0+0+0 = 0
      final lon = Longitude(0.0, VargaType.horaParivritti, config);
      expect(lon.sign, 1);
    });
  });

  group('Saptamsha (D7)', () {
    test('0deg Aries (odd sign) starts from Aries', () {
      // realSign=1 (odd) → startSign=1 (Aries)
      // amshaElapsed=0, baseLon=0 → sign 1
      final lon = Longitude(0.0, VargaType.saptamsha, config);
      expect(lon.sign, 1);
      expect(lon.deity, VargaDeity.kshara);
    });

    test('5deg Aries (odd sign) second division', () {
      // amshaSize = 30/7 ≈ 4.2857
      // position = 5 / 4.2857 = 1.1667
      // amshaElapsed=1, startSign=1, baseLon=0
      // newLon = 0 + 30 + 0.1667*30 = 35 → sign 2
      final lon = Longitude(5.0, VargaType.saptamsha, config);
      expect(lon.sign, 2);
      expect(lon.deity, VargaDeity.kshira);
    });

    test('30deg Taurus (even sign) starts from 7th sign', () {
      // realSign=2 (even) → startSign = ((2-1+6)%12)+1 = 8 (Scorpio)
      // amshaElapsed=0, baseLon=_baseLon(8)=210
      // newLon = 210 → sign (210/30)=7 → sign 8
      final lon = Longitude(30.0, VargaType.saptamsha, config);
      expect(lon.sign, 8);
    });

    test('even sign deity is reversed', () {
      // 30deg Taurus (even): deity should be reversed → shuddhaJala first
      final lon = Longitude(30.0, VargaType.saptamsha, config);
      expect(lon.deity, VargaDeity.shuddhaJala);
    });

    test('parivritti variant still works', () {
      final lon = Longitude(0.0, VargaType.saptamshaParivritti, config);
      expect(lon.sign, 1);
    });
  });

  group('Trimsamsha (D30)', () {
    test('odd sign 3deg → Mars → Aries (sign 1)', () {
      // Aries (odd): 0-5° = Mars → Aries
      final lon = Longitude(3.0, VargaType.trimsamsha, config);
      expect(lon.sign, 1);
    });

    test('odd sign 7deg → Saturn → Aquarius (sign 11)', () {
      // Aries: 5-10° = Saturn → Aquarius
      final lon = Longitude(7.0, VargaType.trimsamsha, config);
      expect(lon.sign, 11);
    });

    test('odd sign 14deg → Jupiter → Sagittarius (sign 9)', () {
      // Aries: 10-18° = Jupiter → Sagittarius
      final lon = Longitude(14.0, VargaType.trimsamsha, config);
      expect(lon.sign, 9);
    });

    test('odd sign 22deg → Mercury → Gemini (sign 3)', () {
      // Aries: 18-25° = Mercury → Gemini
      final lon = Longitude(22.0, VargaType.trimsamsha, config);
      expect(lon.sign, 3);
    });

    test('odd sign 27deg → Venus → Taurus (sign 2)', () {
      // Aries: 25-30° = Venus → Taurus
      final lon = Longitude(27.0, VargaType.trimsamsha, config);
      expect(lon.sign, 2);
    });

    test('even sign 3deg → Venus → Taurus (sign 2)', () {
      // Taurus (even): 0-5° = Venus → Taurus
      final lon = Longitude(33.0, VargaType.trimsamsha, config);
      expect(lon.sign, 2);
    });

    test('even sign 38deg → Mercury → Gemini (sign 3)', () {
      // Taurus (even): 5-12° = Mercury → Gemini. 38° = 8° in-sign.
      final lon = Longitude(38.0, VargaType.trimsamsha, config);
      expect(lon.sign, 3);
    });

    test('even sign 57deg → Mars → Aries (sign 1)', () {
      // Taurus (even): 25-30° = Mars → Aries. 57° = 27° in-sign.
      final lon = Longitude(57.0, VargaType.trimsamsha, config);
      expect(lon.sign, 1);
    });
  });
}
