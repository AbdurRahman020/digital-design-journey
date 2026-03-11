# Thunderbird Turn Signal FSM

This models the tail-light controller from a 1965 Ford Thunderbird. Six lights arranged as `L2 L1 L0 | R0 R1 R2`, controlled by a Moore FSM.

## Inputs / Outputs

`clk`, `reset` (async, active-high), `left`, `right`, `haz` — inputs. `light[5:0]` — output, maps to `{ L2, L1, L0, R0, R1, R2 }`.

## Light Sequences

```
LEFT  : L0 → L0+L1 → L0+L1+L2 → OFF
RIGHT : R0 → R0+R1 → R0+R1+R2 → OFF
HAZARD: ALL ON → ALL OFF → ALL ON → ... (until haz is released)
```

Hazard overrides everything — it can cut into a turn sequence mid-way.

## States

| State | Lights |
|---|---|
| IDLE | all off |
| L1S | L0 |
| L2S | L0, L1 |
| L3S | L0, L1, L2 |
| R1S | R0 |
| R2S | R0, R1 |
| R3S | R0, R1, R2 |
| HAZ_ON | all on |
| HAZ_OF | all off |

## Things I learned

**Moore FSM means outputs come from state, not inputs** — I initially got confused between Mealy and Moore. In this design the light pattern is fully determined by which state you're in, inputs only affect the next state.

**Hazard doesn't resume the turn** — if hazard fires mid left-turn and you release it, the FSM goes back to IDLE, not where it left off. You have to assert `left` again to restart the sequence.

**`left` only needs a one cycle pulse** — the FSM walks through L1S → L2S → L3S → IDLE on its own each clock. I thought you had to hold `left` the whole time but you don't.

## Testbench

Samples on negedge to avoid racing with the clock edge. `reset_dut()` pulses reset for only a quarter period — that's intentional since the reset is asynchronous and doesn't need a full cycle.
