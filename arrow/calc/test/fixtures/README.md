# arrow_calc golden fixtures

Reference outputs from libaditya (and optionally fletch) used to verify
arrow_calc ports of Lajjitaadi, Baladi, Jagradadi, and Deeptadi avasthas.

## Layout

```
libaditya-golden/<chart-slug>.json   # generated from libaditya
fletch-golden/<chart-slug>.json      # generated from fletch (when wired)
```

## Regenerating libaditya fixtures

**Run from `/home/josh/nhs/soft/astrology/libaditya`** (Python finds the
`libaditya/` package via cwd):

```bash
cd /home/josh/nhs/soft/astrology/libaditya && \
  uv run --no-project --with swisseph --with toml \
    python /home/josh/nhs/soft/astrology/arjuna/arrow/tool/bin/gen-libaditya-fixtures.py
```

The `--no-project` flag sidesteps libaditya's `requires-python = "<=3.13"`
pin that resolves awkwardly against 3.13.x patch versions; the `--with`
flags install the runtime deps ad-hoc into a throwaway venv.

Some `.chtk` files have a blank DST line that fails `intize_line`
(`ValueError: invalid literal for int()`). Skip those charts; pick ones
with valid DST integers.

## Fixture schema

```jsonc
{
  "_source": "libaditya",          // or "fletch"
  "_chart": "<slug>",
  "lajjitaadi": {
    "<Planet>": {
      "<state>": [{"source": "...", "planet"|"lord"|"dignity": "...", "strength": <number>}]
    }
  },
  "baladi":    {"<Planet>": "<state>"},
  "jagradadi": {"<Planet>": "<state>"},
  "deeptadi":  {"<Planet>": "<state>"},
  "bodies_ecliptic": {"<Planet>": {"longitude": <°>, "sign": <1..12>}}
}
```

Notes on libaditya vs arrow conventions:

- **Sign numbering:** libaditya's Longitude class normalizes so sign 1 is
  always sign 1 regardless of circle (Aditya / Zodiac) or zodiac (tropical
  / sidereal). Arrow follows the same convention.
- **State names — English throughout:** Arrow uses libaditya's English
  Lajjitaadi labels verbatim (`delighted`, `proud`, `starved`, `shamed`,
  `thirsty`, `stirred`, `healthy`). Baladi / Jagradadi / Deeptadi states
  also carry through from libaditya as-is.

## Fletch cross-reference — status

Not yet wired. If fletch ships a Lajjitaadi equivalent, add
`gen-fletch-fixtures.*` alongside this file and write
`fletch-golden/<slug>.json` with matching slugs so the port tests can
assert equality against either source. Until then, libaditya is the sole
golden source — fine per the plan's "libaditya-only downgrade" clause.
