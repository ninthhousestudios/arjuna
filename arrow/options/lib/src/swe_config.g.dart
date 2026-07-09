// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swe_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SweConfig _$SweConfigFromJson(Map<String, dynamic> json) => _SweConfig(
  bodies:
      (json['bodies'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$BodyEnumMap, e))
          .toSet() ??
      const {
        Body.sun,
        Body.moon,
        Body.mercury,
        Body.venus,
        Body.mars,
        Body.jupiter,
        Body.saturn,
        Body.rahu,
        Body.ketu,
      },
  signAyanamsa:
      $enumDecodeNullable(_$AyanamsaEnumMap, json['signAyanamsa']) ??
      Ayanamsa.tropical,
  houseSystem:
      $enumDecodeNullable(_$HouseSystemEnumMap, json['houseSystem']) ??
      HouseSystem.campanus,
  trueNode: json['trueNode'] as bool? ?? true,
  topocentric: json['topocentric'] as bool? ?? false,
  ephemerisSource:
      $enumDecodeNullable(_$EphemerisSourceEnumMap, json['ephemerisSource']) ??
      EphemerisSource.swissEph,
  extraFrames:
      (json['extraFrames'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ReferencePointEnumMap, e))
          .toSet() ??
      const <ReferencePoint>{},
  stars:
      (json['stars'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$StarEnumMap, e))
          .toSet() ??
      const <Star>{},
  customStarNames:
      (json['customStarNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet() ??
      const <String>{},
  nakAyanamsa:
      $enumDecodeNullable(_$AyanamsaEnumMap, json['nakAyanamsa']) ??
      Ayanamsa.dhruva,
);

Map<String, dynamic> _$SweConfigToJson(_SweConfig instance) =>
    <String, dynamic>{
      'bodies': instance.bodies.map((e) => _$BodyEnumMap[e]!).toList(),
      'signAyanamsa': _$AyanamsaEnumMap[instance.signAyanamsa]!,
      'houseSystem': _$HouseSystemEnumMap[instance.houseSystem]!,
      'trueNode': instance.trueNode,
      'topocentric': instance.topocentric,
      'ephemerisSource': _$EphemerisSourceEnumMap[instance.ephemerisSource]!,
      'extraFrames': instance.extraFrames
          .map((e) => _$ReferencePointEnumMap[e]!)
          .toList(),
      'stars': instance.stars.map((e) => _$StarEnumMap[e]!).toList(),
      'customStarNames': instance.customStarNames.toList(),
      'nakAyanamsa': _$AyanamsaEnumMap[instance.nakAyanamsa]!,
    };

const _$BodyEnumMap = {
  Body.sun: 'sun',
  Body.moon: 'moon',
  Body.mercury: 'mercury',
  Body.venus: 'venus',
  Body.mars: 'mars',
  Body.jupiter: 'jupiter',
  Body.saturn: 'saturn',
  Body.uranus: 'uranus',
  Body.neptune: 'neptune',
  Body.pluto: 'pluto',
  Body.chiron: 'chiron',
  Body.rahu: 'rahu',
  Body.ketu: 'ketu',
};

const _$AyanamsaEnumMap = {
  Ayanamsa.tropical: 'tropical',
  Ayanamsa.fagan: 'fagan',
  Ayanamsa.lahiri: 'lahiri',
  Ayanamsa.deLuce: 'deLuce',
  Ayanamsa.raman: 'raman',
  Ayanamsa.ushashashi: 'ushashashi',
  Ayanamsa.krishnamurti: 'krishnamurti',
  Ayanamsa.djwhalKhul: 'djwhalKhul',
  Ayanamsa.yukteswar: 'yukteswar',
  Ayanamsa.jnBhasin: 'jnBhasin',
  Ayanamsa.babylKugler1: 'babylKugler1',
  Ayanamsa.babylKugler2: 'babylKugler2',
  Ayanamsa.babylKugler3: 'babylKugler3',
  Ayanamsa.babylHuber: 'babylHuber',
  Ayanamsa.babylEtaPsc: 'babylEtaPsc',
  Ayanamsa.aldebaran15Tau: 'aldebaran15Tau',
  Ayanamsa.hipparchus: 'hipparchus',
  Ayanamsa.sassanian: 'sassanian',
  Ayanamsa.galcent0Sag: 'galcent0Sag',
  Ayanamsa.j2000: 'j2000',
  Ayanamsa.j1900: 'j1900',
  Ayanamsa.b1950: 'b1950',
  Ayanamsa.suryaSiddhanta: 'suryaSiddhanta',
  Ayanamsa.suryaSiddhantaMeanSun: 'suryaSiddhantaMeanSun',
  Ayanamsa.aryabhata: 'aryabhata',
  Ayanamsa.aryabhataMeanSun: 'aryabhataMeanSun',
  Ayanamsa.ssRevati: 'ssRevati',
  Ayanamsa.ssCitra: 'ssCitra',
  Ayanamsa.trueCitra: 'trueCitra',
  Ayanamsa.trueRevati: 'trueRevati',
  Ayanamsa.truePushya: 'truePushya',
  Ayanamsa.galcentRgilbrand: 'galcentRgilbrand',
  Ayanamsa.galequIau1958: 'galequIau1958',
  Ayanamsa.galequTrue: 'galequTrue',
  Ayanamsa.galequMula: 'galequMula',
  Ayanamsa.galalignMardyks: 'galalignMardyks',
  Ayanamsa.trueMula: 'trueMula',
  Ayanamsa.galCenterMula: 'galCenterMula',
  Ayanamsa.aryabhata522: 'aryabhata522',
  Ayanamsa.babylBritton: 'babylBritton',
  Ayanamsa.trueSheoran: 'trueSheoran',
  Ayanamsa.galcentCochrane: 'galcentCochrane',
  Ayanamsa.galequFiorenza: 'galequFiorenza',
  Ayanamsa.valensMoon: 'valensMoon',
  Ayanamsa.lahiri1940: 'lahiri1940',
  Ayanamsa.lahiriVp285: 'lahiriVp285',
  Ayanamsa.krishnamurtiVp291: 'krishnamurtiVp291',
  Ayanamsa.lahiriIcrc: 'lahiriIcrc',
  Ayanamsa.trueSidereal: 'trueSidereal',
  Ayanamsa.dhruva: 'dhruva',
  Ayanamsa.eclipticVedangaJyotisha: 'eclipticVedangaJyotisha',
  Ayanamsa.equatorialVedangaJyotisha: 'equatorialVedangaJyotisha',
  Ayanamsa.equal28Nakshatras: 'equal28Nakshatras',
};

const _$HouseSystemEnumMap = {
  HouseSystem.placidus: 'placidus',
  HouseSystem.koch: 'koch',
  HouseSystem.porphyrius: 'porphyrius',
  HouseSystem.regiomontanus: 'regiomontanus',
  HouseSystem.campanus: 'campanus',
  HouseSystem.equalAsc: 'equalAsc',
  HouseSystem.vehlowEqual: 'vehlowEqual',
  HouseSystem.wholeSigns: 'wholeSigns',
  HouseSystem.meridian: 'meridian',
  HouseSystem.horizon: 'horizon',
  HouseSystem.topocentric: 'topocentric',
  HouseSystem.alcabitus: 'alcabitus',
  HouseSystem.morinus: 'morinus',
  HouseSystem.krusinski: 'krusinski',
  HouseSystem.equalAries: 'equalAries',
};

const _$EphemerisSourceEnumMap = {
  EphemerisSource.swissEph: 'swissEph',
  EphemerisSource.moshier: 'moshier',
  EphemerisSource.jplEph: 'jplEph',
};

const _$ReferencePointEnumMap = {
  ReferencePoint.geocentric: 'geocentric',
  ReferencePoint.barycentric: 'barycentric',
  ReferencePoint.heliocentric: 'heliocentric',
};

const _$StarEnumMap = {
  Star.sheratan: 'sheratan',
  Star.fortyOneArietis: 'fortyOneArietis',
  Star.alcyone: 'alcyone',
  Star.aldebaran: 'aldebaran',
  Star.meissa: 'meissa',
  Star.betelgeuse: 'betelgeuse',
  Star.pollux: 'pollux',
  Star.asellus: 'asellus',
  Star.epsilonHydrae: 'epsilonHydrae',
  Star.regulus: 'regulus',
  Star.zosma: 'zosma',
  Star.denebola: 'denebola',
  Star.algorab: 'algorab',
  Star.spica: 'spica',
  Star.arcturus: 'arcturus',
  Star.zubenelgenubi: 'zubenelgenubi',
  Star.dschubba: 'dschubba',
  Star.antares: 'antares',
  Star.shaula: 'shaula',
  Star.kausMedia: 'kausMedia',
  Star.nunki: 'nunki',
  Star.altair: 'altair',
  Star.rotanev: 'rotanev',
  Star.lambdaAquarii: 'lambdaAquarii',
  Star.markab: 'markab',
  Star.algenib: 'algenib',
  Star.zetaPiscium: 'zetaPiscium',
  Star.sirius: 'sirius',
  Star.canopus: 'canopus',
  Star.rigel: 'rigel',
  Star.procyon: 'procyon',
  Star.achernar: 'achernar',
  Star.capella: 'capella',
  Star.vega: 'vega',
  Star.rigilKentaurus: 'rigilKentaurus',
  Star.castor: 'castor',
  Star.fomalhaut: 'fomalhaut',
  Star.deneb: 'deneb',
  Star.mimosa: 'mimosa',
  Star.acrux: 'acrux',
  Star.hamal: 'hamal',
  Star.polaris: 'polaris',
  Star.bellatrix: 'bellatrix',
  Star.elNath: 'elNath',
  Star.alnilam: 'alnilam',
  Star.alnitak: 'alnitak',
  Star.mintaka: 'mintaka',
  Star.alhena: 'alhena',
  Star.alphard: 'alphard',
  Star.rasalhague: 'rasalhague',
  Star.sabik: 'sabik',
  Star.zubeneschamali: 'zubeneschamali',
  Star.mesarthim: 'mesarthim',
  Star.botein: 'botein',
  Star.omicronTauri: 'omicronTauri',
  Star.zetaTauri: 'zetaTauri',
  Star.oneGeminorum: 'oneGeminorum',
  Star.kappaGeminorum: 'kappaGeminorum',
  Star.chiCancri: 'chiCancri',
  Star.acubens: 'acubens',
  Star.kappaLeonis: 'kappaLeonis',
  Star.nuVirginis: 'nuVirginis',
  Star.muVirginis: 'muVirginis',
  Star.fortyEightLibrae: 'fortyEightLibrae',
  Star.tauScorpii: 'tauScorpii',
  Star.fortyFiveOphiuchi: 'fortyFiveOphiuchi',
  Star.nash: 'nash',
  Star.omegaSagittarii: 'omegaSagittarii',
  Star.dabih: 'dabih',
  Star.denebAlgedi: 'denebAlgedi',
  Star.iotaAquarii: 'iotaAquarii',
  Star.phiAquarii: 'phiAquarii',
  Star.gammaPiscium: 'gammaPiscium',
  Star.alrescha: 'alrescha',
  Star.galacticCenter: 'galacticCenter',
};
