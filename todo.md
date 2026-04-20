# Arjuna TODO

## Quiver: Broadhead Strategy

Return to plan the broadhead strategy. Currently KalaBrain is integrated directly (no abstraction). When the architecture stabilizes and a second external service appears, extract the broadhead pattern. Blueprint in `quiver/claude/arch/future.md`.

Questions to resolve:
- Broadhead registration: static config vs dynamic discovery
- Broadhead-to-Arrow access: through Quiver or direct?
- Health/capabilities contract design
- Proto ownership per broadhead

## Quiver: Vayu Deep Dive

After broadhead strategy, take a closer look at Vayu (embedded local Quiver):
- What determines local vs remote calc routing?
- Sync protocol between Local and Remote Quiver
- Offline queue behavior for broadhead requests
- Vayu for non-Dart frontends (if ever needed)
