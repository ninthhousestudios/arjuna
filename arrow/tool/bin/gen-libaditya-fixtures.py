#!/usr/bin/env python3
"""Generate golden avastha fixtures from libaditya for arrow_calc tests.

Runs libaditya's LajjitaadiAvasthas/BaladiAvasthas/JagradadiAvasthas/
DeeptadiAvasthas against a set of .chtk charts and writes one JSON per
chart into ``arrow/calc/test/fixtures/libaditya-golden/``.

Usage (from arjuna/ root):
    uv --project /home/josh/nhs/soft/astrology/libaditya run \\
        python arrow/tool/bin/gen-libaditya-fixtures.py

Preset alignment: we use the libaditya default (Aditya circle, ayanamsa 98
= dhruva, house system C = Campanus) to match arrow's ArrowPresets.ernst
as closely as libaditya allows. If presets diverge, bodies_ecliptic output
in the fixture lets arrow tests verify input alignment before asserting
output equality.
"""

import json
import os
import sys
import traceback
from pathlib import Path

# Charts to generate fixtures from. Committed charts under ~/charts/mine.
FIXTURE_CHARTS = [
    "amber-flynn.chtk",
    "amma.chtk",
    "arnold-schwarzenegger.chtk",
    "astor-piazzolla.chtk",
    "bjork.chtk",
]

CHART_DIR = Path.home() / "charts" / "mine"
OUT_DIR = Path(__file__).resolve().parents[2] / "calc" / "test" / "fixtures" / "libaditya-golden"


def _jsonable(obj):
    """Recursively coerce libaditya objects to JSON-safe primitives."""
    if isinstance(obj, dict):
        return {str(k): _jsonable(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)):
        return [_jsonable(x) for x in obj]
    if isinstance(obj, (str, int, float, bool)) or obj is None:
        return obj
    # Fallback: stringify anything exotic (e.g. Planet objects) using their
    # identity/name if available.
    for attr in ("identity", "name", "_id"):
        if hasattr(obj, attr):
            try:
                v = getattr(obj, attr)
                return v() if callable(v) else v
            except Exception:
                pass
    return repr(obj)


def _build_chart(chtk_path):
    from libaditya.read import chtk_to_context
    # Chart class lives at libaditya.charts.* — try common spellings.
    try:
        from libaditya.charts import Chart
    except ImportError:
        from libaditya import Chart  # type: ignore
    ctx = chtk_to_context(str(chtk_path))
    return Chart(context=ctx)


def _extract(chart):
    rashi = chart.rashi()
    # Rashi caches these in __init__; re-pull via the mixin methods so any
    # refinements pick up the freshest state.
    signs = rashi.signs()
    cusps = rashi.cusps()
    lagna = signs.lagna()
    lagna_sign = lagna.astrological_signs_forward(1)
    fifth_cusp_sign = cusps[5].sign()
    return {
        "lajjitaadi": _jsonable(rashi.lajjitaadi_avasthas()),
        "baladi": _jsonable(rashi.baladi_avasthas()),
        "jagradadi": _jsonable(rashi.jagradadi_avasthas()),
        "deeptadi": _jsonable(rashi.deeptadi_avasthas()),
        "bodies_ecliptic": {
            p.identity(): {
                "longitude": p.ecliptic_longitude(),
                "sign": p.sign(),
            }
            for p in rashi.planets().grahas().values()
        },
        "retrograde": {
            p.identity(): bool(p.retrograde())
            for p in rashi.planets().grahas().values()
        },
        "dignities": {
            p.identity(): p.dignity()
            for p in rashi.planets().grahas().values()
        },
        "lagna_sign": int(lagna_sign),
        "fifth_cusp_sign": int(fifth_cusp_sign),
    }


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    results = []
    for chtk in FIXTURE_CHARTS:
        path = CHART_DIR / chtk
        if not path.exists():
            print(f"skip (missing): {path}", file=sys.stderr)
            continue
        slug = chtk.replace(".chtk", "")
        try:
            chart = _build_chart(path)
            data = _extract(chart)
            data["_source"] = "libaditya"
            data["_chart"] = slug
            out = OUT_DIR / f"{slug}.json"
            out.write_text(json.dumps(data, indent=2, sort_keys=True))
            print(f"wrote {out}")
            results.append(slug)
        except Exception as e:
            print(f"fail {slug}: {e}", file=sys.stderr)
            traceback.print_exc()
    if not results:
        sys.exit("no fixtures generated")
    print(f"done: {len(results)} fixtures")


if __name__ == "__main__":
    main()
