`timescale 1ns/1ps

module tb_tbird ();

    logic  clk, reset, left, right, haz;
    logic [5:0]  light;

    thunderBird_fsm uut (
        .clk   (clk),
        .reset (reset),
        .left  (left),
        .right (right),
        .haz   (haz),
        .light (light)
    );

    localparam PERIOD = 10;

    initial clk = 0;
    always #(PERIOD/2) clk = ~clk;

    // test vector generator
    initial begin
        // initialize all inputs
        left  = 0;
        right = 0;
        haz   = 0;

        // apply reset
        reset_dut();

        @(negedge clk);

        // test 1: Left Turn
        // 'left' asserted for 7 cycles; sequence must complete fully
        left <= 1;
        repeat(7) @(negedge clk);

        // test 2: Right Turn
        left  <= 0;
        right <= 1;
        repeat(5) @(negedge clk);

        // test 3: Hazard interrupt during Right Turn
        // Wait until light pattern indicates step 2 of right turn (R0+R1 on)
        wait (light == 6'b000110);
        haz <= 1;
        repeat(5) @(negedge clk);

        // test 4: Resume Right Turn after Hazard
        haz <= 0;
        repeat(4) @(negedge clk);

        // test 5: Return to Idle
        right <= 0;
        repeat(5) @(negedge clk);

        $stop;
    end

    // task: reset_dut
    // applies a brief asynchronous reset pulse
    task automatic reset_dut();
        reset <= 1;
        #(PERIOD/4);
        reset <= 0;
    endtask

endmodule
