/// IAST name tables for panchanga elements.
///
/// Primary set is IAST transliteration; abbreviated variants follow.
/// English nakshatra names live separately in `arrow_core/NakshatraData`.
library;

const List<String> nakshatras = [
  'aśvinī',
  'bharaṇī',
  'kṛttikā',
  'rohiṇī',
  'mṛgaśīrṣa',
  'ārdrā',
  'punarvasu',
  'puṣya',
  'āśleṣā',
  'maghā',
  'pūrvā phalgunī',
  'uttarā phalgunī',
  'hasta',
  'citrā',
  'svāti',
  'viśākhā',
  'anurādhā',
  'jyeṣṭhā',
  'mūla',
  'pūrvāṣāḍhā',
  'uttarāṣāḍhā',
  'śravaṇa',
  'dhaniṣṭhā',
  'śatabhiṣa',
  'pūrvabhādrapadā',
  'uttarabhādrapadā',
  'revatī',
];

const List<String> nakshatrasAbbreviated = [
  'aśv', 'bha', 'kṛt', 'roh', 'mṛg', 'ārd', 'pun', 'puṣ', 'āśl',
  'mag', 'pph', 'uph', 'has', 'cit', 'svā', 'viś', 'anu', 'jye',
  'mūl', 'pāṣ', 'uāṣ', 'śra', 'dha', 'śat', 'pdā', 'udā', 'rev',
];

/// Tithi types cycle every 5 tithis: 1/6/11 = nanda, 2/7/12 = bhadra, etc.
const List<String> tithiTypes = [
  'nanda',
  'bhadra',
  'jāya',
  'ṛkta',
  'pūrṇa',
];

/// Karanas indexed by tithi (0-29). Each tithi has two karanas [first, second].
const List<List<String>> karanas = [
  ['kiṃtughna', 'bava'],
  ['balava', 'kaulava'],
  ['taitila', 'garija'],
  ['vaṇija', 'viṣṭi'],
  ['bava', 'balava'],
  ['kaulava', 'taitila'],
  ['garija', 'vaṇija'],
  ['viṣṭi', 'bava'],
  ['balava', 'kaulava'],
  ['taitila', 'garija'],
  ['vaṇija', 'viṣṭi'],
  ['bava', 'balava'],
  ['kaulava', 'taitila'],
  ['garija', 'vaṇija'],
  ['viṣṭi', 'bava'],
  ['balava', 'kaulava'],
  ['taitila', 'garija'],
  ['vaṇija', 'viṣṭi'],
  ['bava', 'balava'],
  ['kaulava', 'taitila'],
  ['garija', 'vaṇija'],
  ['viṣṭi', 'bava'],
  ['balava', 'kaulava'],
  ['taitila', 'garija'],
  ['vaṇija', 'viṣṭi'],
  ['bava', 'balava'],
  ['kaulava', 'taitila'],
  ['garija', 'vaṇija'],
  ['viṣṭi', 'śakuni'],
  ['catuṣpada', 'nāga'],
];

const List<String> yogas = [
  'viṣkambha',
  'prīti',
  'āyuṣmān',
  'saubhāgya',
  'śobhana',
  'atigaṇḍa',
  'sukarma',
  'dhṛti',
  'śula',
  'gaṇḍa',
  'vṛddhi',
  'dhruva',
  'vyāghāta',
  'harṣaṇa',
  'vajra',
  'siddhi',
  'vyātipata',
  'varīyas',
  'parighā',
  'śiva',
  'siddha',
  'sādhya',
  'śubha',
  'śukla',
  'brahmā',
  'indra',
  'vaidhṛti',
];

const List<String> varas = [
  'ravivāra',
  'somavāra',
  'maṅgalavāra',
  'budhavāra',
  'guruvāra',
  'śukravāra',
  'śanivāra',
];

const List<String> varasAbbreviated = [
  'rav', 'som', 'maṅ', 'bud', 'gur', 'śuk', 'śan',
];
