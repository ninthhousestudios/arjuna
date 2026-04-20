## The Core Insight

Quiver is a **hub** that handles bidirectional communication:

- Frontends call Quiver for astrological calculations
- Frontends also route **unknown requests** through Quiver to broadheads
- Broadheads call Quiver for calculations they need
- Broadheads can also be forwarded requests from Quiver

```
┌─────────────┐
│  Frontend   │ ──▶ Quiver ──▶ Arrow (calc)
│  (Celestial) │ ──▶ Quiver ──▶ Broadhead (forwarded)
└─────────────┘     │
                    │
┌─────────────┐     │
│ Broadhead   │ ────┘     (Broadhead is client of Quiver)
│ (e.g.,      │           (Broadhead may also receive forwarded requests)
│  social     │
│  network)   │
└─────────────┘
```

## How Routing Works

1. Request arrives at Quiver
2. Is it a known Arrow calculation? → Handle it, return
3. Is it unknown? → Check registered broadheads
   - Match found → Forward request, return response
   - No match → Error

## How Broadheads Get Astrological Data

Broadheads are also clients of Quiver:

```
Broadhead ──▶ Quiver.getPlanetPositions(birth_data)
            ──▶ Arrow ──▶ Returns positions
            
Broadhead uses positions for its own analysis (LLM, social graph, etc.)
```

## Why Reflection Matters

**Current (static config):**

```yaml
broadheads:
  kalabrain:
    url: "grpc://kalabrain:50051"
    handles: [llm.*, interpret.*]  # hardcoded
```

**With gRPC reflection:**

```
Quiver queries each broadhead:
  "What methods do you expose?"
  ◀── [llm.Generate, llm.Stream, interpret.Chart]
  
Routing table builds dynamically — no config needed
```

Benefits:

- Add broadhead → auto-discovery, no config edits
- Quiver routes based on actual exposed methods
- Broadheads self-describe via standard gRPC reflection

**Limitation:** Dart gRPC doesn't support server reflection. Broadheads would need to be Go/Node/Python services, not Dart.
