module counter_tb;
    logic clk, clear;
    logic [3:0] Q;

    counter uut (.*);

    initial begin
        $dumpfile("ripple_counter_sim.vcd");
        $dumpvars(0, counter_tb);
    end

    initial begin
        $monitor("Time = %0t, Q = %b (%2d), clear = %b", 
                 $time, Q[3:0], Q[3:0], clear);
    end

    initial begin
        clear = 1'b1;          // start in reset
        #15  clear = 1'b0;     // release, counting begins

        #80  clear = 1'b1;     // reset early (around count 4)
        #10  clear = 1'b0;

        #210 clear = 1'b1;     // reset late into the cycle (around count 10)
        #10  clear = 1'b0;

        #130 clear = 1'b1;     // reset somewhere in the middle (around count 6)
        #10  clear = 1'b0;

        #320 $finish;          // let the last cycle run fully
    end

    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

endmodule
