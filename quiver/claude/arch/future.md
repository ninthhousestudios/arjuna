---

## Broadheads Right Now

```
Broadheads that exist:     KalaBrain
Broadheads that are planned: (nothing concrete)

What was designed:
    BroadheadContract (abstract)
    BroadheadRegistry
    Dynamic registration
    Pattern-matched routing (handles: [llm.*, interpret.*])
    Health checking per broadhead
    Broadhead lifecycle management
```

That's a plugin architecture for **one plugin**.

---

## What Happens If You Build It

```
You build the generic system
    │
    You wire KalaBrain into it
    │
    It works
    │
    6 months later, you add a second broadhead
    │
    You discover it doesn't fit the contract
    because you designed the contract
    based on one example
    │
    You refactor the generic system
    │
    Which breaks KalaBrain
    │
    Which was working fine
```

---

## What To Do Instead

```
Now:
    Build KalaBrain integration directly into Quiver
    No abstract contract
    No registry
    No plugin system
    Just: Quiver calls KalaBrain

When broadhead #2 appears:
    Look at KalaBrain and broadhead #2
    NOW you have two real examples
    NOW you can see what's actually shared
    Extract the pattern
    The abstraction is discovered, not invented
```

---

## The Rule

```
One instance  → just build it
Two instances → notice the pattern
Three instances → extract the abstraction
```

You're at one. Build it direct.
