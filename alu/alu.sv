`timescale 1ns/1ps

module alu #(parameter int WIDTH = 8)(
    input  logic [WIDTH-1:0] a, b,
    input  logic [3:0] alu_control,
    output logic [WIDTH-1:0] result,
    output logic zero, negative, carry, overflow
);
    localparam int SHIFT_BITS = $clog2(WIDTH);
    
    logic carry_out;
    logic overflow_out;
    
    always_comb begin
        carry_out = 1'b0;
        overflow_out = 1'b0;
        
        unique case (alu_control)
            4'b0000: result = a & b;                                                        // AND
            4'b0001: result = a | b;                                                        // OR
            4'b0010: begin                                                                  // ADD
                {carry_out, result} = a + b;
                overflow_out = (a[WIDTH-1] == b[WIDTH-1]) && (result[WIDTH-1] != a[WIDTH-1]);
            end
            4'b0110: begin                                                                  // SUB
                {carry_out, result} = a - b;
                overflow_out = (a[WIDTH-1] != b[WIDTH-1]) && (result[WIDTH-1] != a[WIDTH-1]);
            end
            4'b0111: result = (a < b) ? {{(WIDTH-1){1'b0}}, 1'b1} : {WIDTH{1'b0}};          // SLT
            4'b1100: result = ~(a | b);                                                     // NOR
            4'b1101: result = a ^ b;                                                        // XOR
            4'b0011: result = a << b[SHIFT_BITS-1:0];                                       // SLL
            4'b0100: result = a >> b[SHIFT_BITS-1:0];                                       // SRL
            4'b0101: result = $signed(a) >>> b[SHIFT_BITS-1:0];                             // SRA
            4'b1000: result = a * b;                                                        // MUL
            4'b1001: result = ~a;                                                           // NOT
            4'b1010: result = a;                                                            // Pass A
            4'b1011: result = b;                                                            // Pass B
            default: result = {WIDTH{1'b0}};
        endcase
    end
    
    // status flags
    assign zero = (result == {WIDTH{1'b0}});
    assign negative = result[WIDTH-1];
    assign carry = carry_out;
    assign overflow = overflow_out;

endmodule
