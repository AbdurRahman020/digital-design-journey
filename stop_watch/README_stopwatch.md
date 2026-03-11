# Stopwatch

A stopwatch that runs on the Nexys A7 and shows `M:SS.T` on the seven-segment display. Hold `start` to run, release to pause, pulse `reset` to clear.

## Ports

`clock`, `reset`, `start` — inputs. `a`–`g`, `dp` — the individual segments. `an[3:0]` — selects which of the 4 digits is active.

## How it works

The clock runs at 100MHz which is way too fast to count seconds directly. So first I count 10 million cycles and use that as a 0.1s "tick" — everything else updates on that tick, not the raw clock.

The four digits (`reg_d0` to `reg_d3`) work like an odometer — when tenths hit 9 it resets and bumps the seconds, when seconds hit 59 it resets and bumps the minutes, and so on. Minutes wrap back at 9.

The display part was a bit tricky — turns out you can't drive all 4 digits at once on the FPGA, you have to switch between them really fast so it looks like they're all on. I used an 18-bit counter for that, cycles through all 4 digits fast enough that you don't see any flicker.

The seven-segment decoder is just a lookup table that maps each digit (0–9) to which segments to turn on. The display is active-low so `0` = on and `1` = off which is a bit confusing at first.

## Things I learned

- `click` needs to be registered (put through a flop) before driving the counters, otherwise glitches from the comparator can cause wrong counts
- The mux counter needs to be 18 bits for ~380Hz refresh — any slower and the display starts to flicker

## File structure

```
stopwatch/
├── stopwatch_top.sv   ← top level that connects everything
├── stopwatch.sv       ← main logic
├── debouncer.sv       ← needed because buttons bounce without it
└── tb_stopwatch.sv    ← testbench
```

## Testbench

Overriding `TICK_MAX` to 100 instead of 10 million makes the simulation finish in microseconds. The `wait_ticks()` task hooks onto the internal `click` signal so tests are based on actual ticks, not raw clock cycles.
