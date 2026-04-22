`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2024 09:28:52
// Design Name: 
// Module Name: Adder_x2
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



module Adder_x2(input logic [1:0] a,b,
                input logic cin ,
                output logic [1:0] k,
                output logic cout);
                
    logic c_int;
               
    Adder_x1_bit add0 (a[0], b[0], cin, k[0], c_int);
    Adder_x1_bit add1 (a[1], b[1], c_int, k[1], cout );//cout

endmodule
