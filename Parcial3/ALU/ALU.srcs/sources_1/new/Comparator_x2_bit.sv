`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.10.2024 10:54:29
// Design Name: 
// Module Name: Comparator_x2_bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Comparator_x2_bit( input logic sw0,sw1,
                         output LED0 );

//signal declaration                         
logic p0, p1;

//body
//sum of two product terms
assign LED0 = p0 | p1;
//product terms
    assign p0 = ~sw0 & ~sw1;
    assign p1 = sw0 & sw1;                                                 
endmodule
