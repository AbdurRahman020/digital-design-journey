module stopwatch_top (
    input  logic clock,
    input  logic reset_btn,
    input  logic start_btn,
    output logic a, b, c, d, e, f, g, dp,
    output logic [3:0] an
);

    logic reset_clean, start_clean;

    debouncer db_reset (
        .clockin  (clock),
        .reset    (1'b0),        // can't debounce the debouncer's own reset
        .PB       (reset_btn),
        .PB_state (reset_clean)
    );

    debouncer db_start (
        .clockin  (clock),
        .reset    (reset_clean),
        .PB       (start_btn),
        .PB_state (start_clean)
    );

    stopwatch sw (
        .clock (clock),
        .reset (reset_clean),
        .start (start_clean),
        .a, .b, .c, .d, .e, .f, .g, .dp,
        .an
    );

endmodule
