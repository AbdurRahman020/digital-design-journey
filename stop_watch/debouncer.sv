module debouncer(
    input  logic clockin,    // 100MHz clock
    input  logic reset,
    input  logic PB,
    output logic PB_state
);

    // two-flop synchronizer to prevent metastability
    logic PB_sync_0;
    always_ff @(posedge clockin or posedge reset)
        if (reset)
            PB_sync_0 <= 1'b0;
        else
            PB_sync_0 <= PB;

    logic PB_sync_1;
    always_ff @(posedge clockin or posedge reset)
        if (reset)
            PB_sync_1 <= 1'b0;
        else
        PB_sync_1 <= PB_sync_0;

    // waits for ~20ms of stable signal before accepting the change 2,000,000 cycles at 100MHz = 20ms
    logic [20:0] PB_cnt;  // 21 bits to hold up to 2M

    always_ff @(posedge clockin or posedge reset) begin
        if (reset) begin
            PB_cnt   <= '0;
            PB_state <= 1'b0;
        end
        else if (PB_state == PB_sync_1) begin
            PB_cnt <= '0;  // input matches state, reset counter
        end
        else begin
            PB_cnt <= PB_cnt + 1;
            if (PB_cnt == 21'd1999999)  // 20ms reached, accept the change
                PB_state <= ~PB_state;
        end
    end

endmodule