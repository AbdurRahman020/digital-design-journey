`timescale 1ns/1ps

module alu_tb;
    parameter int WIDTH = 8;  // options: 2, 4, 8, 16, 32, 64
    parameter PERIOD = 10;    // 10ns clock period (100 MHz)

    logic [WIDTH-1:0] a, b;
    logic [3:0] alu_control;
    logic [WIDTH-1:0] result;
    logic zero, negative, carry, overflow;
    
    alu #(.WIDTH(WIDTH)) dut (
        .a,
        .b,
        .alu_control,
        .result,
        .zero,
        .negative,
        .carry,
        .overflow
    );
    
    // test procedure
    initial begin
        
        // test ADD (no overflow)
        a = 15; b = 23; alu_control = 4'b0010; #PERIOD;
        
        // test ADD (with carry)
        a = {WIDTH{1'b1}}; b = 1; alu_control = 4'b0010; #PERIOD;
        
        // test ADD (overflow: positive + positive = negative)
        a = {1'b0, {(WIDTH-1){1'b1}}}; b = 1; alu_control = 4'b0010; #PERIOD;
        
        // test SUB (no borrow)
        a = 37; b = 13; alu_control = 4'b0110; #PERIOD;
        
        // test SUB (zero result)
        a = 25; b = 25; alu_control = 4'b0110; #PERIOD;
        
        // test SUB (negative result)
        a = 13; b = 27; alu_control = 4'b0110; #PERIOD;
        
        // test SUB (overflow: positive - negative = negative)
        a = {1'b0, {(WIDTH-1){1'b1}}}; b = {1'b1, {(WIDTH-1){1'b0}}}; alu_control = 4'b0110; #PERIOD;
        
        // test AND
        a = {WIDTH{1'b1}} & ({WIDTH{1'b1}} << (WIDTH/2)); b = {WIDTH{1'b0}} | ({WIDTH{1'b1}} >> (WIDTH/2)); alu_control = 4'b0000; #PERIOD;

        // test OR
        a = {WIDTH{1'b1}} & ({WIDTH{1'b1}} << (WIDTH/2)); b = {WIDTH{1'b0}} | ({WIDTH{1'b1}} >> (WIDTH/2)); alu_control = 4'b0001; #PERIOD;
        
        // test NOR
        a = {WIDTH{1'b1}} & ({WIDTH{1'b1}} << (WIDTH/2)); b = {WIDTH{1'b0}} | ({WIDTH{1'b1}} >> (WIDTH/2)); alu_control = 4'b1100; #PERIOD;

        // test XOR
        a = {WIDTH{1'b1}} & ({WIDTH{1'b1}} << (WIDTH/2)); b = {WIDTH{1'b0}} | ({WIDTH{1'b1}} >> (WIDTH/2)); alu_control = 4'b1101; #PERIOD;

        // test SLT (a < b)
        a = 13; b = 17; alu_control = 4'b0111; #PERIOD;
        
        // test SLT (a >= b)
        a = 27; b = 18; alu_control = 4'b0111; #PERIOD;

        // test SLL
        a = 33; b = 22; alu_control = 4'b0011; #PERIOD;

        // test SRL
        a = {WIDTH{1'b1}} & ({WIDTH{1'b1}} << (WIDTH/2)); b = 2; alu_control = 4'b0100; #PERIOD;
        
        // test SRA (positive number)
        a = (1 << (WIDTH-2)) | (1 << (WIDTH-3)); b = 1; alu_control = 4'b0101; #PERIOD;
        
        // test SRA (negative number)
        a = {WIDTH{1'b1}} & ({WIDTH{1'b1}} << (WIDTH/2)); b = 1; alu_control = 4'b0101; #PERIOD;
        
        // test MUL
        a = 33; b = 44; alu_control = 4'b1000; #PERIOD;
        
        // test NOT
        a = {WIDTH{1'b1}} & ({WIDTH{1'b1}} << (WIDTH/2)); b = 0; alu_control = 4'b1001; #PERIOD;
        
        $stop;
    end
    
    // waveform dump
    initial begin
        $dumpfile("alu_sim.vcd");
        $dumpvars(0, alu_tb);
    end

endmodule
