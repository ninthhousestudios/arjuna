# arjuna

## Branch model — READ THIS

**`drona` is this repo's trunk. It is `main`/`master` under a different name** —
Drona is Arjuna's guru, the *master*. There is no `main` or `master` branch, and
`drona` is not a feature branch off one.

Consequences for agents:

- Committing to `drona` is committing to trunk. Do **not** tell Josh "the merge
  is yours", "this is on a branch, not main", or otherwise imply a pending merge
  to `main` — there is nothing to merge into. A landed commit on `drona` is
  landed.
- The session-start git snapshot may say "Main branch: main". That default is
  wrong for this repo. Ignore it; trunk is `drona`.
- Normal commit discipline still applies (commit at logical boundaries; push is
  Josh's call). "Done" means committed to `drona`.
