# Ripple Counter

A 4-bit ripple counter that counts from 0 to 15 and displays the value in hex (0–F) on the Nexys A7's seven-segment display. Has an asynchronous clear that resets the count instantly regardless of the clock.

## Ports (counter_top)

`clk`, `clear` (async, active-high) — inputs. `a`–`g` — segment outputs. `an[7:0]` — digit select (active-low), only the rightmost digit is used.

## How it works

Each bit is its own T flip-flop, and instead of all being clocked by the main clock, each one is clocked by the output of the previous stage — that's what makes it a "ripple" counter. `Q[0]` toggles every clock, `Q[1]` toggles every time `Q[0]` falls, and so on. The count ripples through the stages one by one.

The seven-segment decoder handles 0–9 and A–F since the counter goes into hex territory above 9.

## Things I learned

**It's called ripple because the count literally ripples through** — `Q[0]` updates first, then `Q[1]`, then `Q[2]`, then `Q[3]`. They don't all update at the same time like a synchronous counter would. This means there are brief moments mid-transition where the output shows a garbage value — not a big deal here but it's why ripple counters aren't used in timing-critical designs.

**Async clear means it doesn't wait for the clock** — the moment `clear` goes high, all flip-flops reset immediately. You can see this clearly in the testbench — the counter gets cut off mid-sequence and jumps straight to 0.

**The T flip-flop is just a D flip-flop with `D = ~Q`** — every clock edge it just flips its own output. Simple but that's all you need to build a counter.

## File structure

```
ripple_counter/
├── counter_top.sv   ← top level with seven-segment decoder, connect to .xdc
├── counter.sv       ← ripple counter + t_ff + edge_dff all in one file
└── counter_tb.sv    ← testbench
```

## Testbench

Resets fire at random points mid-sequence (around counts 4, 10, and 6) to show the async clear works no matter where the counter is. Each restart counts from 0 again so you can clearly see the reset behavior in the waveform.
