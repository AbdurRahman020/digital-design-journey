module counter(
    output logic [3:0] Q,
    input  logic clk, clear
);
    // ripple counter: each FF clocked by previous stage output
    t_ff tff0(.q(Q[0]), .clk, .clear);
    t_ff tff1(.q(Q[1]), .clk(Q[0]), .clear);
    t_ff tff2(.q(Q[2]), .clk(Q[1]), .clear);
    t_ff tff3(.q(Q[3]), .clk(Q[2]), .clear);

endmodule


module t_ff(
    output logic q,
    input  logic clk, clear
);
    // connect all ports to D flip-flop
    edge_dff ff1(
        .q, 
        .d(~q),       // T flip-flop: D = ~Q
        .clk, 
        .clear
    );

endmodule


module edge_dff(
    input  logic d, clk, clear,
    output logic q,
    output logic qbar
);
    // edge-triggered D flip-flop with asynchronous clear
    always_ff @(negedge clk or posedge clear) begin
        // asynchronous clear has priority
        if (clear) begin
            q <= 1'b0;
            qbar <= 1'b1;
        end else begin
            q <= d;
            qbar <= ~d;
        end
    end

endmodule
