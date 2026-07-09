// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

/// All unique deities that appear across the 16 varga deity tables.
enum VargaDeity {
  // D2 hora
  sun('Sun'),
  moon('Moon'),

  // D3 drekkana
  narada('Narada'),
  agastya('Agastya'),
  durvasas('Durvasas'),

  // D4 chaturthamsha
  sanaka('Sanaka'),
  sananda('Sananda'),
  sanatkumara('Sanatkumara'),
  sanatana('Sanatana'),

  // D7 saptamsha
  kshara('Kshara'),
  kshira('Kshira'),
  dadhya('Dadhya'),
  ajya('Ajya'),
  ikshurasa('Ikshurasa'),
  madhya('Madhya'),
  shuddhaJala('Shuddha Jala'),

  // D9 navamsha (repeating cycle of 3)
  deva('Deva'),
  nri('Nri'),
  rakshasa('Rakshasa'),

  // D10 dashamsha
  indra('Indra'),
  agni('Agni'),
  yama('Yama'),
  varuna('Varuna'),
  vayu('Vayu'),
  kubera('Kubera'),
  ishana('Ishana'),
  brahma('Brahma'),
  ananta('Ananta'),

  // D12 dwadashamsha
  ganesha('Ganesha'),
  ashvins('Ashvins'),
  hayagriva('Hayagriva'),

  // D16 shodashamsha
  vishnu('Vishnu'),
  shiva('Shiva'),

  // D20 vimshamsha (even signs)
  daya('Daya'),
  megha('Megha'),
  chinnashirsha('Chinnashirsha'),
  pishachani('Pishachani'),
  dhumavati('Dhumavati'),
  matangi('Matangi'),
  bala('Bala'),
  bhadra('Bhadra'),
  aruna('Aruna'),
  anala('Anala'),
  pingala('Pingala'),
  chucchuka('Chucchuka'),
  ghora('Ghora'),
  varahi('Varahi'),
  vaishnavi('Vaishnavi'),
  sita('Sita'),
  bhuvanesvari('Bhuvanesvari'),
  bhairavi('Bhairavi'),
  mangala('Mangala'),
  aparajita('Aparajita'),

  // D20 vimshamsha (odd signs)
  kali('Kali'),
  gauri('Gauri'),
  jaya('Jaya'),
  lakshmi('Lakshmi'),
  vijaya('Vijaya'),
  vimala('Vimala'),
  sati('Sati'),
  tara('Tara'),
  jvalamukhi('Jvalamukhi'),
  shveta('Shveta'),
  lalita('Lalita'),
  bagalamukhi('Bagalamukhi'),
  pratyangira('Pratyangira'),
  sachi('Sachi'),
  raudri('Raudri'),
  bhavani('Bhavani'),
  varada('Varada'),
  tripura('Tripura'),
  sumukhi('Sumukhi'),

  // D24 chaturvimshamsha
  skanda('Skanda'),
  parsudhara('Parsudhara'),
  vishwakarma('Vishwakarma'),
  bhaga('Bhaga'),
  mitra('Mitra'),
  maya('Maya'),
  antaka('Antaka'),
  vrishadhwaja('Vrishadhwaja'),
  govinda('Govinda'),
  madana('Madana'),
  bhima('Bhima'),

  // D27 bhamsha
  dastra('Dastra'),
  pitamaha('Pitamaha'),
  chandra('Chandra'),
  isha('Isha'),
  aditi('Aditi'),
  jiva('Jiva'),
  ahi('Ahi'),
  pitara('Pitara'),
  aryama('Aryama'),
  arka('Arka'),
  tvashta('Tvashta'),
  marut('Marut'),
  shakragni('Shakragni'),
  vasava('Vasava'),
  nirriti('Nirriti'),
  vishvadeva('Vishvadeva'),
  vasu('Vasu'),
  ajapa('Ajapa'),
  ahirbudhanya('Ahirbudhanya'),
  pusha('Pusha'),

  // D40 khavedamsha
  marichi('Marichi'),
  dhata('Dhata'),
  ravi('Ravi'),
  yaksha('Yaksha'),
  gandharva('Gandharva'),
  kala('Kala'),

  // D45 akshavedamsha
  vidhi('Vidhi'),
  acyuta('Acyuta'),
  surajyeshta('Surajyeshta'),
  ka('Ka'),

  // D60 shashtyamsha
  kulaghna('Kulaghna'),
  garala('Garala'),
  vahni('Vahni'),
  purishaka('Purishaka'),
  apampathi('Apampathi'),
  sarpa('Sarpa'),
  amrita('Amrita'),
  indu('Indu'),
  mridu('Mridu'),
  komala('Komala'),
  heramba('Heramba'),
  maheshwara('Maheshwara'),
  ardra('Ardra'),
  kalinasha('Kalinasha'),
  kshitisha('Kshitisha'),
  kamalakara('Kamalakara'),
  gulika('Gulika'),
  mrityu('Mrityu'),
  davagni('Davagni'),
  kantaka('Kantaka'),
  sudha('Sudha'),
  purnachandra('Purnachandra'),
  vishadaghda('Vishadaghda'),
  kulanasa('Kulanasa'),
  vamsakshaya('Vamsakshaya'),
  utpata('Utpata'),
  saumya('Saumya'),
  sitala('Sitala'),
  karaladamshtra('Karaladamshtra'),
  chandramukhi('Chandramukhi'),
  pravina('Pravina'),
  kalaPavaka('Kala Pavaka'),
  dandayudha('Dandayudha'),
  nirmala('Nirmala'),
  krura('Krura'),
  atisitala('Atisitala'),
  payodhi('Payodhi'),
  bhramana('Bhramana'),
  chandraRekha('Chandra Rekha'),
  kimnara('Kimnara'),
  bhrashta('Bhrashta');

  const VargaDeity(this.displayName);
  final String displayName;
}

// ---------------------------------------------------------------------------
// Deity lookup tables
// ---------------------------------------------------------------------------

/// D2 hora deities.
const _d2 = [VargaDeity.sun, VargaDeity.moon];

/// D3 drekkana deities (cycle of 3).
const _d3 = [VargaDeity.narada, VargaDeity.agastya, VargaDeity.durvasas];

/// D4 chaturthamsha deities (cycle of 4).
const _d4 = [
  VargaDeity.sanaka,
  VargaDeity.sananda,
  VargaDeity.sanatkumara,
  VargaDeity.sanatana,
];

/// D7 saptamsha deities (7 entries; reversed for even signs).
const _d7 = [
  VargaDeity.kshara,
  VargaDeity.kshira,
  VargaDeity.dadhya,
  VargaDeity.ajya,
  VargaDeity.ikshurasa,
  VargaDeity.madhya,
  VargaDeity.shuddhaJala,
];

/// D9 navamsha deities (cycle of 3).
const _d9 = [VargaDeity.deva, VargaDeity.nri, VargaDeity.rakshasa];

/// D10 dashamsha deities (10 entries; reversed for even signs).
const _d10 = [
  VargaDeity.indra,
  VargaDeity.agni,
  VargaDeity.yama,
  VargaDeity.rakshasa,
  VargaDeity.varuna,
  VargaDeity.vayu,
  VargaDeity.kubera,
  VargaDeity.ishana,
  VargaDeity.brahma,
  VargaDeity.ananta,
];

/// D12 dvadashamsha deities (cycle of 4).
const _d12 = [
  VargaDeity.ganesha,
  VargaDeity.ashvins,
  VargaDeity.yama,
  VargaDeity.hayagriva,
];

/// D16 shodashamsha deities (cycle of 4; reversed for even signs).
const _d16 = [
  VargaDeity.brahma,
  VargaDeity.vishnu,
  VargaDeity.shiva,
  VargaDeity.sun,
];

/// D20 vimshamsha deities for even signs (20 entries).
const _d20Even = [
  VargaDeity.daya,
  VargaDeity.megha,
  VargaDeity.chinnashirsha,
  VargaDeity.pishachani,
  VargaDeity.dhumavati,
  VargaDeity.matangi,
  VargaDeity.bala,
  VargaDeity.bhadra,
  VargaDeity.aruna,
  VargaDeity.anala,
  VargaDeity.pingala,
  VargaDeity.chucchuka,
  VargaDeity.ghora,
  VargaDeity.varahi,
  VargaDeity.vaishnavi,
  VargaDeity.sita,
  VargaDeity.bhuvanesvari,
  VargaDeity.bhairavi,
  VargaDeity.mangala,
  VargaDeity.aparajita,
];

/// D20 vimshamsha deities for odd signs (20 entries).
const _d20Odd = [
  VargaDeity.kali,
  VargaDeity.gauri,
  VargaDeity.jaya,
  VargaDeity.lakshmi,
  VargaDeity.vijaya,
  VargaDeity.vimala,
  VargaDeity.sati,
  VargaDeity.tara,
  VargaDeity.jvalamukhi,
  VargaDeity.shveta,
  VargaDeity.lalita,
  VargaDeity.bagalamukhi,
  VargaDeity.pratyangira,
  VargaDeity.sachi,
  VargaDeity.raudri,
  VargaDeity.bhavani,
  VargaDeity.varada,
  VargaDeity.jaya,
  VargaDeity.tripura,
  VargaDeity.sumukhi,
];

/// D24 chaturvimshamsha deities (cycle of 12; reversed for even signs).
const _d24 = [
  VargaDeity.skanda,
  VargaDeity.parsudhara,
  VargaDeity.anala,
  VargaDeity.vishwakarma,
  VargaDeity.bhaga,
  VargaDeity.mitra,
  VargaDeity.maya,
  VargaDeity.antaka,
  VargaDeity.vrishadhwaja,
  VargaDeity.govinda,
  VargaDeity.madana,
  VargaDeity.bhima,
];

/// D27 bhamsha deities (27 entries; reversed for even signs).
const _d27 = [
  VargaDeity.dastra,
  VargaDeity.yama,
  VargaDeity.agni,
  VargaDeity.pitamaha,
  VargaDeity.chandra,
  VargaDeity.isha,
  VargaDeity.aditi,
  VargaDeity.jiva,
  VargaDeity.ahi,
  VargaDeity.pitara,
  VargaDeity.bhaga,
  VargaDeity.aryama,
  VargaDeity.arka,
  VargaDeity.tvashta,
  VargaDeity.marut,
  VargaDeity.shakragni,
  VargaDeity.mitra,
  VargaDeity.vasava,
  VargaDeity.nirriti,
  VargaDeity.varuna,
  VargaDeity.vishvadeva,
  VargaDeity.govinda,
  VargaDeity.vasu,
  VargaDeity.varuna,
  VargaDeity.ajapa,
  VargaDeity.ahirbudhanya,
  VargaDeity.pusha,
];

/// D40 khavedamsha deities (cycle of 12; same for all signs).
const _d40 = [
  VargaDeity.vishnu,
  VargaDeity.chandra,
  VargaDeity.marichi,
  VargaDeity.tvashta,
  VargaDeity.dhata,
  VargaDeity.shiva,
  VargaDeity.ravi,
  VargaDeity.yama,
  VargaDeity.yaksha,
  VargaDeity.gandharva,
  VargaDeity.kala,
  VargaDeity.varuna,
];

/// D45 akshavedamsha deities by sign modality.
const _d45Moveable = [VargaDeity.vidhi, VargaDeity.isha, VargaDeity.acyuta];
const _d45Fixed = [VargaDeity.isha, VargaDeity.acyuta, VargaDeity.surajyeshta];
const _d45Dual = [VargaDeity.vishnu, VargaDeity.ka, VargaDeity.isha];

/// D60 shashtyamsha deities (60 entries; reversed for even signs).
const _d60 = [
  VargaDeity.ghora,
  VargaDeity.rakshasa,
  VargaDeity.deva,
  VargaDeity.kubera,
  VargaDeity.yaksha,
  VargaDeity.kimnara,
  VargaDeity.bhrashta,
  VargaDeity.kulaghna,
  VargaDeity.garala,
  VargaDeity.vahni,
  VargaDeity.maya,
  VargaDeity.purishaka,
  VargaDeity.apampathi,
  VargaDeity.marut,
  VargaDeity.kala,
  VargaDeity.sarpa,
  VargaDeity.amrita,
  VargaDeity.indu,
  VargaDeity.mridu,
  VargaDeity.komala,
  VargaDeity.heramba,
  VargaDeity.brahma,
  VargaDeity.vishnu,
  VargaDeity.maheshwara,
  VargaDeity.deva,
  VargaDeity.ardra,
  VargaDeity.kalinasha,
  VargaDeity.kshitisha,
  VargaDeity.kamalakara,
  VargaDeity.gulika,
  VargaDeity.mrityu,
  VargaDeity.kala,
  VargaDeity.davagni,
  VargaDeity.ghora,
  VargaDeity.yama,
  VargaDeity.kantaka,
  VargaDeity.sudha,
  VargaDeity.amrita,
  VargaDeity.purnachandra,
  VargaDeity.vishadaghda,
  VargaDeity.kulanasa,
  VargaDeity.vamsakshaya,
  VargaDeity.utpata,
  VargaDeity.kala,
  VargaDeity.saumya,
  VargaDeity.komala,
  VargaDeity.sitala,
  VargaDeity.karaladamshtra,
  VargaDeity.chandramukhi,
  VargaDeity.pravina,
  VargaDeity.kalaPavaka,
  VargaDeity.dandayudha,
  VargaDeity.nirmala,
  VargaDeity.saumya,
  VargaDeity.krura,
  VargaDeity.atisitala,
  VargaDeity.amrita,
  VargaDeity.payodhi,
  VargaDeity.bhramana,
  VargaDeity.chandraRekha,
];

// Pre-computed reversed tables for even-sign lookups.
final _d7Rev = _d7.reversed.toList();
final _d10Rev = _d10.reversed.toList();
final _d16Rev = _d16.reversed.toList();
final _d24Rev = _d24.reversed.toList();
final _d27Rev = _d27.reversed.toList();
final _d60Rev = _d60.reversed.toList();

// ---------------------------------------------------------------------------
// Lookup function
// ---------------------------------------------------------------------------

/// Whether [signNum] (1-12) is an odd sign.
bool _isOdd(int signNum) => signNum.isOdd;

/// Sign modality: 0 = moveable, 1 = fixed, 2 = dual.
int _modality(int signNum) => (signNum - 1) % 3;

/// Look up the deity for a given varga division.
///
/// [type] is the VargaType.
/// [divisionIndex] is the 0-based index within the varga's divisions
///   (i.e., which of the amsha subdivisions the longitude falls in).
/// [signNum] is 1-12, the ecliptic sign number (before circle adjustment).
///   Required for vargas with sign-dependent deity tables.
VargaDeity? lookupDeity(VargaType type, int divisionIndex, {int? signNum}) {
  final amsha = type.amsha;

  // Parivritti vargas use the same deity tables as their special counterparts
  // (keyed by amsha number). The division index cycles through the table.
  switch (amsha) {
    case 2:
      if (signNum == null) return _d2[divisionIndex % 2];
      // Odd signs: odd portions = Sun, even = Moon. Even signs: reversed.
      final idx = divisionIndex % 2;
      return _isOdd(signNum) ? _d2[idx] : _d2[1 - idx];

    case 3:
      return _d3[divisionIndex % 3];

    case 4:
      return _d4[divisionIndex % 4];

    case 7:
      final t7 = (signNum != null && !_isOdd(signNum)) ? _d7Rev : _d7;
      return t7[divisionIndex % 7];

    case 9:
      return _d9[divisionIndex % 3];

    case 10:
      final t10 = (signNum != null && !_isOdd(signNum)) ? _d10Rev : _d10;
      return t10[divisionIndex % 10];

    case 12:
      return _d12[divisionIndex % 4];

    case 16:
      final t16 = (signNum != null && !_isOdd(signNum)) ? _d16Rev : _d16;
      return t16[divisionIndex % 4];

    case 20:
      if (signNum != null && _isOdd(signNum)) {
        return _d20Odd[divisionIndex % 20];
      }
      return _d20Even[divisionIndex % 20];

    case 24:
      final t24 = (signNum != null && !_isOdd(signNum)) ? _d24Rev : _d24;
      return t24[divisionIndex % 12];

    case 27:
      final t27 = (signNum != null && !_isOdd(signNum)) ? _d27Rev : _d27;
      return t27[divisionIndex % 27];

    case 40:
      return _d40[divisionIndex % 12];

    case 45:
      if (signNum == null) return _d45Moveable[divisionIndex % 3];
      final mod = _modality(signNum);
      final table = switch (mod) {
        0 => _d45Moveable,
        1 => _d45Fixed,
        _ => _d45Dual,
      };
      return table[divisionIndex % 3];

    case 60:
      final t60 = (signNum != null && !_isOdd(signNum)) ? _d60Rev : _d60;
      return t60[divisionIndex % 60];

    default:
      return null;
  }
}
