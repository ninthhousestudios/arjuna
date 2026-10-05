cd ~/nhs/soft/astrology/arjuna/arrow
dart run tool/bin/rank_planet_health.dart --chart ~/adityas/reports/test-charts/"Stephen Colbert.chtk"

- Output: the report prints to the terminal only, unless you also pass --out <file>.
- Several charts: repeat --chart and they're ranked in the order you give them.
- Missing file: you get "Chart file not found: …" and exit code 1.
- No --chart: it works as before, ranking the 16 test charts and rewriting docs/planet-health-results.md.

I ran all four cases. Colbert prints 6. Jupiter, 7. Mars, and running it without --chart rebuilt the results doc exactly as before.
