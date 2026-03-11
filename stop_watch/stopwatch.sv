module stopwatch #(
    parameter int TICK_MAX = 9999999                // counts to this before generating a 0.1s tick
)(
    input  logic clock, reset, start,
    output logic a, b, c, d, e, f, g, dp,
    output logic [3:0] an
);
 
    logic [3:0]  reg_d0, reg_d1, reg_d2, reg_d3;    // the four display digits: tenths, seconds(ones), seconds(tens), minutes
    logic [22:0] ticker;                            // counts clock cycles up to TICK_MAX
    logic click;                                    // pulses once every 0.1 second
 
    // counts clock cycles, resets at TICK_MAX to generate 0.1s intervals
    always_ff @(posedge clock or posedge reset) begin
        if (reset)
            ticker <= '0;
        else if (start) begin
            if (ticker == TICK_MAX)
                ticker <= '0;
            else
                ticker <= ticker + 1;
        end
    end

    // click goes high for one cycle when ticker hits its max
    always_ff @(posedge clock or posedge reset) begin
        if (reset)
            click <= '0;
        else
            click <= (ticker == TICK_MAX) ? 1'b1 : 1'b0;
    end

    // odometer-style counter: each digit rolls over and carries into the next
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            reg_d0 <= '0;
            reg_d1 <= '0;
            reg_d2 <= '0;
            reg_d3 <= '0;
        end
        else if (click) begin
            // tenths rolled over, bump seconds
            if (reg_d0 == 9) begin
                reg_d0 <= '0;
                
                // ones of seconds rolled over, bump tens
                if (reg_d1 == 9) begin
                    reg_d1 <= '0;
                    
                    // tens of seconds maxes at 5 (59 seconds)
                    if (reg_d2 == 5) begin
                        reg_d2 <= '0;
                        
                        // minutes rolled over, wrap back to 0
                        if (reg_d3 == 9)
                            reg_d3 <= '0;
                        else
                            reg_d3 <= reg_d3 + 1;
                    end
                    else
                        reg_d2 <= reg_d2 + 1;
                end
                else
                    reg_d1 <= reg_d1 + 1;
            end
            else
                reg_d0 <= reg_d0 + 1;
        end
    end

    // free-running counter used to cycle through the 4 digits rapidly
    localparam int N = 18;
    logic [N-1:0] count;

    always_ff @(posedge clock or posedge reset) begin
        if (reset)
            count <= '0;
        else
            count <= count + 1;
    end

    // top 2 bits of count select which digit to show right now
    logic [6:0] sseg;
    logic [3:0] an_temp;
    logic reg_dp;

    always_comb begin
        case(count[N-1:N-2])
            2'b00 : begin
                sseg = reg_d0;
                an_temp = 4'b1110; // enable rightmost digit
                reg_dp = 1'b0;
            end
            
            2'b01: begin
                sseg = reg_d1;
                an_temp = 4'b1101;
                reg_dp = 1'b1;     // decimal point here gives SS.T format
            end
            
            2'b10: begin
                sseg = reg_d2;
                an_temp = 4'b1011;
                reg_dp = 1'b0;
            end
            
            2'b11: begin
                sseg = reg_d3;
                an_temp = 4'b0111;
                reg_dp = 1'b1;     // decimal point here gives M:SS format
            end
        endcase
    end

    assign an = an_temp;

    // converts a digit (0-9) to the segments that need to light up (active low)
    logic [6:0] sseg_temp;

    always_comb begin
        case(sseg)
            4'd0 : sseg_temp = 7'b1000000;
            4'd1 : sseg_temp = 7'b1111001;
            4'd2 : sseg_temp = 7'b0100100;
            4'd3 : sseg_temp = 7'b0110000;
            4'd4 : sseg_temp = 7'b0011001;
            4'd5 : sseg_temp = 7'b0010010;
            4'd6 : sseg_temp = 7'b0000010;
            4'd7 : sseg_temp = 7'b1111000;
            4'd8 : sseg_temp = 7'b0000000;
            4'd9 : sseg_temp = 7'b0010000;
            default : sseg_temp = 7'b0111111; // dash
        endcase
    end

    assign {g, f, e, d, c, b, a} = sseg_temp;
    assign dp = reg_dp;

endmodule
