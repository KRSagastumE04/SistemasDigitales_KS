`timescale 1ns / 1ps


module seven_seg(
    input logic clk,
    input logic [3:0] d0, d1, d2, d3,
    input logic [3:0] dp_mask,
    output logic [6:0] seg,
    output logic dp,
    output logic [3:0] an
    );

        logic [19:0] refresh_cnt;
    always_ff @(posedge clk) begin
        refresh_cnt <= refresh_cnt + 1;
    end

    logic [1:0] scan;
    assign scan = refresh_cnt[17:16]; 

    logic [3:0] digit;
    logic       dp_on;


    always_comb begin

        an    = 4'b1111;   
        digit = 4'd0;
        dp_on = 1'b0;

        case (scan)
            2'd0: begin
                an    = 4'b1110; 
                digit = d0;
                dp_on = dp_mask[0];
            end
            2'd1: begin
                an    = 4'b1101;
                digit = d1;
                dp_on = dp_mask[1];
            end
            2'd2: begin
                an    = 4'b1011; 
                digit = d2;
                dp_on = dp_mask[2];
            end
            2'd3: begin
                an    = 4'b0111; 
                digit = d3;
                dp_on = dp_mask[3];
            end
        endcase
    end

    // BCD to 7-seg (active-low)
    always_comb begin
        case (digit)
            4'd0: seg = 7'b1000000; // 0
            4'd1: seg = 7'b1111001; // 1
            4'd2: seg = 7'b0100100; // 2
            4'd3: seg = 7'b0110000; // 3
            4'd4: seg = 7'b0011001; // 4
            4'd5: seg = 7'b0010010; // 5
            4'd6: seg = 7'b0000010; // 6
            4'd7: seg = 7'b1111000; // 7
            4'd8: seg = 7'b0000000; // 8
            4'd9: seg = 7'b0010000; // 9
            default: seg = 7'b1111111; // off
        endcase
    end

    assign dp = (dp_on) ? 1'b0 : 1'b1;

endmodule

