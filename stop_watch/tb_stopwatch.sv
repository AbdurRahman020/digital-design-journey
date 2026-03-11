`timescale 1ns / 1ps

module tb_stopwatch_fast;

    parameter int CLK_PERIOD = 10;        // 100MHz clock (10ns period) for Nexys A7
    parameter int SIM_TICK_COUNT = 100;   // shrunk from 10M so simulation finishes fast

    logic clock, reset, start;
    logic a, b, c, d, e, f, g, dp;
    logic [3:0] an;

    stopwatch #(.TICK_MAX(SIM_TICK_COUNT)) uut (
        .clock,
        .reset,
        .start,
        .a,
        .b,
        .c,
        .d,
        .e,
        .f,
        .g,
        .dp,
        .an
    );

    // keeps the clock toggling forever
    initial begin
        clock = 0;
        forever #(CLK_PERIOD/2) clock = ~clock;
    end

    // prints current stopwatch reading to the transcript
    task automatic display_count();
        $display("[%0t ns] %0d:%0d%0d.%0d", $time, uut.reg_d3, uut.reg_d2, uut.reg_d1, uut.reg_d0);
    endtask

    // waits for N internal 0.1s ticks instead of counting raw clock cycles
    task automatic wait_ticks(input int num_ticks);
        for (int i = 0; i < num_ticks; i++) begin
            @(posedge uut.click);
            #1;
        end
    endtask

    initial begin
        $dumpfile("stopwatch_sim.vcd");
        $dumpvars(0, tb_stopwatch_fast);
        
        reset = 1; start = 0;
        #(CLK_PERIOD*10);  // hold reset for 10 cycles
        reset = 0;
        #(CLK_PERIOD*10);

        // TEST 1: all digits should be zero after reset
        if (uut.reg_d0 == 0 && uut.reg_d1 == 0 && uut.reg_d2 == 0 && uut.reg_d3 == 0)
            $display("PASS: Reset"); else $display("FAIL: Reset");
        
        // TEST 2: run for 12 ticks, expect 0:01.2
        start = 1;
        wait_ticks(12);
        display_count();
        if (uut.reg_d0 == 2 && uut.reg_d1 == 1)
            $display("PASS: Count to 1.2s"); else $display("FAIL: Expected 0:01.2");
        
        // TEST 3: drop start, counter should freeze
        start = 0;
        #(CLK_PERIOD * 1000);
        if (uut.reg_d0 == 2 && uut.reg_d1 == 1)
            $display("PASS: Pause"); else $display("FAIL: Counter changed during pause");
        
        // TEST 4: resume and run 8 more ticks, expect 0:02.0
        start = 1;
        wait_ticks(8);
        display_count();
        if (uut.reg_d0 == 0 && uut.reg_d1 == 2)
            $display("PASS: Resume"); else $display("FAIL: Expected 0:02.0");
        
        // TEST 5: run 80 more ticks, tenths and ones should roll into tens of seconds
        wait_ticks(80);
        display_count();
        if (uut.reg_d0 == 0 && uut.reg_d1 == 0 && uut.reg_d2 == 1)
            $display("PASS: 9.9 -> 10.0"); else $display("FAIL: Expected 0:10.0");
        
        // TEST 6: run 500 more ticks, seconds should roll into minutes
        wait_ticks(500);
        display_count();
        if (uut.reg_d3 == 1 && uut.reg_d2 == 0 && uut.reg_d1 == 0 && uut.reg_d0 == 0)
            $display("PASS: 59.9 -> 1:00.0"); else $display("FAIL: Expected 1:00.0");
        
        // TEST 7: reset while running, everything should go back to zero
        reset = 1;
        #(CLK_PERIOD*10);
        reset = 0;
        #(CLK_PERIOD*10);
        if (uut.reg_d0 == 0 && uut.reg_d1 == 0 && uut.reg_d2 == 0 && uut.reg_d3 == 0)
            $display("PASS: Reset during operation"); else $display("FAIL: Reset during operation");
        
        $finish;
    end

    // kills simulation if something hangs
    initial begin
        #50000000;
        $display("ERROR: Timeout!");
        $finish;
    end

endmodule

