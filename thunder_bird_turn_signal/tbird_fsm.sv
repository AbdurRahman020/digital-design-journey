/*
Thunderbird Turn Signal - FSM

Description:
    Models the tail-light controller for a 1965 Ford Thunderbird.
    Six lights (L2 L1 L0 | R0 R1 R2) are driven by a Mealy/Moore

    FSM with the following sequences:
        LEFT  TURN : L0 -> L0 + L1 -> L0 + L1 + L2 -> OFF
        RIGHT TURN : R0 -> R0 + R1 -> R0 + R1 + R2 -> OFF
        HAZARD     : ALL ON -> ALL OFF (alternating, highest priority)

    light[5:0] = { L2, L1, L0, R0, R1, R2 }
*/

module thunderBird_fsm (
    input  logic clk,
    input  logic reset,   // asynchronous reset (active-high)
    input  logic left,
    input  logic right,
    input  logic haz,
    output logic [5:0]  light
);

    // state encoding
    typedef enum logic [3:0] {
        IDLE = 4'd0,    // all lights OFF, waiting for input
        L1S = 4'd1,     // left  step 1 : L0 ON
        L2S = 4'd2,     // left  step 2 : L0+L1 ON
        L3S = 4'd3,     // left  step 3 : L0+L1+L2 ON
        R1S = 4'd4,     // right step 1 : R0 ON
        R2S = 4'd5,     // right step 2 : R0+R1 ON
        R3S = 4'd6,     // right step 3 : R0+R1+R2 ON
        HAZ_ON = 4'd7,  // hazard: all six lights ON
        HAZ_OF = 4'd8   // hazard: all six lights OFF
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;

        case (state)
            // hazard has highest priority, and check it first in every state
            IDLE: begin
                if (haz)
                    next_state = HAZ_ON;
                else if (left) 
                    next_state = L1S;
                else if (right)
                    next_state = R1S;
                else
                    next_state = IDLE;
            end

            L1S: begin
                if (haz)
                    next_state = HAZ_ON;
                else
                    next_state = L2S;
            end

            L2S: begin
                if (haz)
                    next_state = HAZ_ON;
                else
                    next_state = L3S;
            end
            
            L3S: begin
                if (haz)
                    next_state = HAZ_ON;
                else
                    next_state = IDLE;
            end

            R1S: begin
                if (haz)
                    next_state = HAZ_ON;
                else
                    next_state = R2S;
            end
            
            R2S: begin
                if (haz)
                    next_state = HAZ_ON;
                else
                    next_state = R3S;
            end
            
            R3S: begin
                if (haz)
                    next_state = HAZ_ON;
                else
                    next_state = IDLE;
            end

            HAZ_ON: begin
                if (!haz)
                    next_state = IDLE;
                else
                    next_state = HAZ_OF;
            end

            HAZ_OF: begin
                if (!haz)
                    next_state = IDLE;
                else
                    next_state = HAZ_ON;
            end

            default: next_state = IDLE;
        endcase
    end

    always_comb begin
        case (state)
            IDLE : light = 6'b000_000;    // all off
            L1S : light = 6'b001_000;     // L0 only
            L2S : light = 6'b011_000;     // L0 + L1
            L3S : light = 6'b111_000;     // L0 + L1 + L2
            R1S : light = 6'b000_100;     // R0 only
            R2S : light = 6'b000_110;     // R0 + R1
            R3S : light = 6'b000_111;     // R0 + R1 + R2
            HAZ_ON : light = 6'b111_111;  // all on
            HAZ_OF : light = 6'b000_000;  // all off
            default: light = 6'b000_000;
        endcase
    end

endmodule
