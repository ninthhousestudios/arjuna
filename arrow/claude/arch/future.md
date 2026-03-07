## The Problem With Premature Abstraction

---

### You're solving problems that don't exist yet

```
Right now you need:
    VedicConfig

You designed:
    VedicConfig
    HellenisticConfig
    UranianConfig
    PersianConfig
    TraditionModule (abstract)
    TraditionRegistry
    TraditionRouter

That's 6 things built for traditions that have:
    - No source code to port from
    - No known requirements
    - No users asking for them
    - No timeline
```

---

### The abstractions will be wrong

You're **guessing** what Hellenistic astrology needs based on what Vedic astrology needs. When you actually sit down to build Hellenistic support, you'll discover:

```
What you assumed:
    "It's like Vedic but with different house systems"

What you find:
    "It has a completely different concept of planetary condition
     that doesn't map to any field in TraditionConfig,
     and now I have to refactor the abstract base class,
     which breaks Vedic, which was working fine"
```

The abstraction becomes a cage instead of a tool.

---

### It makes simple things complicated NOW

```
Without abstraction:
    class CalcConfig {
      final Ayanamsa ayanamsa;
      final HouseSystem houseSystem;
      final VargaMethod vargaMethod;
      // ... all Vedic stuff
    }

    // Done. Ship it. Works.

With premature abstraction:
    abstract class TraditionConfig { ... }
    class VedicConfig extends TraditionConfig { ... }
    class TraditionRegistry { ... }
    class TraditionModule { ... }
    
    // Every new field you add, you ask:
    // "Does this belong on TraditionConfig or VedicConfig?"
    // "Will Hellenistic need this?"
    // "Should this be in the base class?"
    //
    // You're designing for ghosts.
```

---

### The fix is simple

```
Build concrete.
Ship it.
When the second case appears, THEN extract the pattern.

The pattern will be obvious because you have two real examples.
The abstraction will be right because it's based on reality.
The migration will be easy because you already identified it:
    "current CalcConfig fields map exactly to VedicConfig"
```

---

### The Rule

> **Duplication is far cheaper than the wrong abstraction.**
> — Sandi Metz

Build VedicConfig. When Hellenistic actually arrives, you'll know *exactly* what to abstract because you'll have two concrete implementations to compare. Right now you have one implementation and a bunch of guesses.
