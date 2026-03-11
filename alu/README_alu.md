# ALU Module

A parameterized ALU — WIDTH defaults to 16 but you can set it to 2, 4, 8, 32, or 64.

## Ports

`a`, `b` — inputs. `alu_control` — 4-bit opcode that selects the operation. `result` — output. Four flags: `zero`, `negative`, `carry`, `overflow`.

## Opcodes

| `alu_control` | Op |
|---|---|
| `0000` | AND |
| `0001` | OR |
| `0010` | ADD |
| `0110` | SUB |
| `0111` | SLT (1 if a < b, else 0) |
| `1100` | NOR |
| `1101` | XOR |
| `0011` | SLL |
| `0100` | SRL |
| `0101` | SRA |
| `1000` | MUL |
| `1001` | NOT |
| `1010` | Pass A |
| `1011` | Pass B |

## Things I learned

**carry and overflow are not the same thing** — I mixed these up at first. carry is for unsigned math, overflow is for signed. To understand overflow, take this example: in 4-bit signed, `0111` (+7) + `0001` (+1) gives `1000`, which looks like -8. The math broke the sign bit — that's overflow. carry would fire if the addition produced a 5th bit, which is a completely different situation.

**Why max positive is `0111` not `1111` (for WIDTH=4)** — because the MSB is the sign bit in 2's complement. `1111` is actually -1, not 15. So the testbench uses `{1'b0, {(WIDTH-1){1'b1}}}` when it wants the largest positive signed number.

**SRA vs SRL** — both shift right but SRA fills in copies of the sign bit from the left, so a negative number stays negative. SRL always fills 0s regardless.

**MUL silently drops the upper half** — the full product is 2×WIDTH bits wide but only the lower WIDTH bits come out. No flag is set, it just disappears quietly.

**Shift amount gets masked** — only `$clog2(WIDTH)` bits of `b` are actually used. At WIDTH=4 that's 2 bits, so the max shift is 3. Passing `b = 22` actually shifts by 2.

## Running the testbench

Change `WIDTH = 4` at the top of the testbench to whatever you want — 2, 8, 16, 32, or 64 — and everything scales on its own.
