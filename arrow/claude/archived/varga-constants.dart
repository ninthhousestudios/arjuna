// Arrow Varga Constants — Design Sketch
// Shows idiomatic Dart for domain constants: enums with values, const maps, nullable lookups.
// This is a design sketch, not compilable code.

// ============================================================
// DEITIES
//
// VargaDeity is an enum because:
// - Many deities repeat across vargas (Agni appears in D10, D27, D40…).
//   An enum means one canonical instance, not a dozen equal strings.
// - Future properties (devanagari name, IAST, associated planet) attach here,
//   not scattered through lookup tables.
// - Type safety: a function returning VargaDeity can't accidentally return
//   a typo'd string.
//
// Contrast with raw strings in a Map<int,List<String>>: any typo compiles fine.
// ============================================================

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
  sanatkumara('Sanatkumāra'),
  sanatana('Sanātana'),

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

  // D20 vimsamsha (even signs)
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

  // D20 odd signs (different set)
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

  // D24 chaturvimsamsha
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

  // D60 shashtyamsha (many unique entries; shared with other vargas above where possible)
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

  // Future: add iast, devanagari, associated planet, etc. here — not in lookup tables.
}

// ============================================================
// DEITY LOOKUP TABLES
//
// Keyed by amsha (varga division number), using the same integer codes as libkala:
//   positive = parivritti varga of that division
//   negative = special varga (hora=-2, drekkana=-3, etc.)
//
// Null entries in the map = no deity system for that amsha (use sign lord instead).
// Access pattern: vargaDeities[9]![whichAmsha % 3]
// ============================================================

const Map<int, List<VargaDeity>> vargaDeities = {
  2: [VargaDeity.sun, VargaDeity.moon],

  3: [VargaDeity.narada, VargaDeity.agastya, VargaDeity.durvasas],

  4: [VargaDeity.sanaka, VargaDeity.sananda, VargaDeity.sanatkumara, VargaDeity.sanatana],

  7: [
    VargaDeity.kshara, VargaDeity.kshira, VargaDeity.dadhya, VargaDeity.ajya,
    VargaDeity.ikshurasa, VargaDeity.madhya, VargaDeity.shuddhaJala,
  ],

  // D9: cycle repeats every 3 — access with whichAmsha % 3
  9: [VargaDeity.deva, VargaDeity.nri, VargaDeity.rakshasa],

  10: [
    VargaDeity.indra, VargaDeity.agni, VargaDeity.yama, VargaDeity.rakshasa,
    VargaDeity.varuna, VargaDeity.vayu, VargaDeity.kubera, VargaDeity.ishana,
    VargaDeity.brahma, VargaDeity.ananta,
  ],

  // D12: cycle repeats every 4 — access with whichAmsha % 4
  12: [VargaDeity.ganesha, VargaDeity.ashvins, VargaDeity.yama, VargaDeity.hayagriva],

  // D16: cycle repeats every 4 — odd signs forward, even signs reversed
  16: [VargaDeity.brahma, VargaDeity.vishnu, VargaDeity.shiva, VargaDeity.sun],

  // D20 even signs
  20: [
    VargaDeity.daya, VargaDeity.megha, VargaDeity.chinnashirsha, VargaDeity.pishachani,
    VargaDeity.dhumavati, VargaDeity.matangi, VargaDeity.bala, VargaDeity.bhadra,
    VargaDeity.aruna, VargaDeity.anala, VargaDeity.pingala, VargaDeity.chucchuka,
    VargaDeity.ghora, VargaDeity.varahi, VargaDeity.vaishnavi, VargaDeity.sita,
    VargaDeity.bhuvanesvari, VargaDeity.bhairavi, VargaDeity.mangala, VargaDeity.aparajita,
  ],

  // D20 odd signs (separate key — libkala uses dict key 21 for this)
  21: [
    VargaDeity.kali, VargaDeity.gauri, VargaDeity.jaya, VargaDeity.lakshmi,
    VargaDeity.vijaya, VargaDeity.vimala, VargaDeity.sati, VargaDeity.tara,
    VargaDeity.jvalamukhi, VargaDeity.shveta, VargaDeity.lalita, VargaDeity.bagalamukhi,
    VargaDeity.pratyangira, VargaDeity.sachi, VargaDeity.raudri, VargaDeity.bhavani,
    VargaDeity.varada, VargaDeity.jaya, VargaDeity.tripura, VargaDeity.sumukhi,
  ],

  // D24: cycle repeats every 12 — odd signs forward, even signs reversed
  24: [
    VargaDeity.skanda, VargaDeity.parsudhara, VargaDeity.anala, VargaDeity.vishwakarma,
    VargaDeity.bhaga, VargaDeity.mitra, VargaDeity.maya, VargaDeity.antaka,
    VargaDeity.vrishadhwaja, VargaDeity.govinda, VargaDeity.madana, VargaDeity.bhima,
  ],

  27: [
    VargaDeity.dastra, VargaDeity.yama, VargaDeity.agni, VargaDeity.pitamaha,
    VargaDeity.chandra, VargaDeity.isha, VargaDeity.aditi, VargaDeity.jiva,
    VargaDeity.ahi, VargaDeity.pitara, VargaDeity.bhaga, VargaDeity.aryama,
    VargaDeity.arka, VargaDeity.tvashta, VargaDeity.marut, VargaDeity.shakragni,
    VargaDeity.mitra, VargaDeity.vasava, VargaDeity.nirriti, VargaDeity.varuna,
    VargaDeity.vishvadeva, VargaDeity.govinda, VargaDeity.vasu, VargaDeity.varuna,
    VargaDeity.ajapa, VargaDeity.ahirbudhanya, VargaDeity.pusha,
  ],

  // D40: cycle repeats every 12
  40: [
    VargaDeity.vishnu, VargaDeity.chandra, VargaDeity.marichi, VargaDeity.tvashta,
    VargaDeity.dhata, VargaDeity.shiva, VargaDeity.ravi, VargaDeity.yama,
    VargaDeity.yaksha, VargaDeity.gandharva, VargaDeity.kala, VargaDeity.varuna,
  ],

  // D45: three sub-tables by sign modality (keys 45, 46, 47 as in libkala)
  45: [VargaDeity.vidhi, VargaDeity.isha, VargaDeity.acyuta],           // moveable signs
  46: [VargaDeity.isha, VargaDeity.acyuta, VargaDeity.surajyeshta],     // fixed signs
  47: [VargaDeity.vishnu, VargaDeity.ka, VargaDeity.isha],              // dual signs

  60: [
    VargaDeity.ghora, VargaDeity.rakshasa, VargaDeity.deva, VargaDeity.kubera,
    VargaDeity.yaksha, VargaDeity.kimnara, VargaDeity.bhrashta, VargaDeity.kulaghna,
    VargaDeity.garala, VargaDeity.vahni, VargaDeity.maya, VargaDeity.purishaka,
    VargaDeity.apampathi, VargaDeity.marut, VargaDeity.kala, VargaDeity.sarpa,
    VargaDeity.amrita, VargaDeity.indu, VargaDeity.mridu, VargaDeity.komala,
    VargaDeity.heramba, VargaDeity.brahma, VargaDeity.vishnu, VargaDeity.maheshwara,
    VargaDeity.deva, VargaDeity.ardra, VargaDeity.kalinasha, VargaDeity.kshitisha,
    VargaDeity.kamalakara, VargaDeity.gulika, VargaDeity.mrityu, VargaDeity.kala,
    VargaDeity.davagni, VargaDeity.ghora, VargaDeity.yama, VargaDeity.kantaka,
    VargaDeity.sudha, VargaDeity.amrita, VargaDeity.purnachandra, VargaDeity.vishadaghda,
    VargaDeity.kulanasa, VargaDeity.vamsakshaya, VargaDeity.utpata, VargaDeity.kala,
    VargaDeity.saumya, VargaDeity.komala, VargaDeity.sitala, VargaDeity.karaladamshtra,
    VargaDeity.chandramukhi, VargaDeity.pravina, VargaDeity.kalaPavaka, VargaDeity.dandayudha,
    VargaDeity.nirmala, VargaDeity.saumya, VargaDeity.krura, VargaDeity.atisitala,
    VargaDeity.amrita, VargaDeity.payodhi, VargaDeity.bhramana, VargaDeity.chandraRekha,
  ],
};

// ============================================================
// VARGA FUNCTION SIGNATURES (how deities flow through Arrow)
//
// VargaResult carries both the output longitude AND the deity,
// so callers don't have to look them up separately.
// ============================================================

class VargaResult {
  final double longitude;    // longitude in the varga's coordinate frame
  final VargaDeity? deity;   // null for parivritti vargas without a deity system
  const VargaResult(this.longitude, this.deity);
}

// arrow_core — one function per special varga, one generic for parivritti
// VargaResult parivritti(double longitude, int amsha, CalcConfig config);
// VargaResult hora(double longitude, CalcConfig config);
// VargaResult drekkana(double longitude, CalcConfig config);
// VargaResult chaturthamsha(double longitude, CalcConfig config);
// VargaResult dashamsha(double longitude, CalcConfig config);
// VargaResult navamsha(double longitude, CalcConfig config);   // convenience alias
// VargaResult shashtyamsha(double longitude, CalcConfig config);
// ... etc.
//
// All take CalcConfig because Circle (aditya vs zodiac) shifts the base longitude.
