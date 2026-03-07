# On Sonnet for This Implementation Plan

---

## Short Answer

Yes. Sonnet is a strong choice for this work.

---

## Why It Fits

```
This plan is:
├── Methodical, sequential, well-scoped
├── One package at a time
├── Clear inputs and outputs per step
├── Dart (Sonnet knows Dart well)
├── FFI exploration (Sonnet can reason through this)
├── gRPC setup (well-documented patterns)
└── Not speculative — concrete tasks with concrete deliverables
```

Sonnet is good at:
```
├── Writing complete, working Dart code
├── Designing types and APIs
├── Exploring library APIs (the sweph.dart spike)
├── Writing tests alongside implementation
├── Maintaining consistency across a session
├── Following architectural constraints you've defined
└── Logging, error handling, the "boring thorough" work
```

---

## Where To Be Careful

### Session length

```
Sonnet works best when each session has a clear scope:

Good:
    "Let's build SweConfig based on this sweph.dart inventory"
    "Write the SweFacade with these methods"
    "Write tests for EphSnapshot against these known values"

Risky:
    "Build all of arrow_swe in one session"
    
    Context window fills up
    Earlier decisions get forgotten
    Consistency drifts
```

### Carrying state between sessions

```
Sonnet doesn't remember previous conversations.

What helps:
├── Keep updated architecture docs (you're already doing this)
├── Paste relevant source files at session start
├── "Here's what we built last time" + actual code
└── The implementation plan itself as a reference

What hurts:
├── "Remember what we did yesterday?"
├── Assuming it knows your naming conventions
└── Vague references to previous decisions
```

### The sweph.dart spike specifically

```
This is the highest-value task for Sonnet:

You: "Here's the sweph.dart package source / docs.
      I need to understand every function,
      every flag, every initialization pattern.
      Help me write a spike."

Sonnet: Excellent at this.
        Reads API surfaces carefully.
        Asks good clarifying questions.
        Produces systematic exploration code.
```

---

## Suggested Session Structure

```
Session 1: sweph.dart spike
    Input:  sweph.dart docs/source
    Output: Working spike code + API inventory

Session 2: SweConfig + EphSnapshot design
    Input:  API inventory from Session 1
    Output: Complete types with freezed

Session 3: SweFacade implementation
    Input:  SweConfig + EphSnapshot from Session 2
    Output: Working facade + tests

Session 4: gRPC health check
    Input:  Proto file
    Output: Working Quiver server skeleton

Session 5: Connect Arrow to Quiver
    Input:  Arrow facade + Quiver skeleton
    Output: End-to-end chart calc via gRPC
```

Each session: small, complete, tested. Feed the output of one session as input to the next.

---

## One Recommendation

At each session start, give Sonnet:

```
1. The implementation plan (this document)
2. The architecture doc for the relevant package
3. The actual code built so far
4. "We are on Step X. Here's what exists. Build Y."
```

That's the pattern that gets the best results.
