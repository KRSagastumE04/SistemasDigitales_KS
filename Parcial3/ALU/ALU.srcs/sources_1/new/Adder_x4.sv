`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2024 09:28:52
// Design Name: 
// Module Name: Adder_x4
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


module Adder_x4(input logic [3:0] a,b,
                input logic cin ,
                output logic [3:0] k,
                output logic cout

    );
    logic c_int;

    
    Adder_x2 add0 (a[1:0], b[1:0], cin, k[1:0], c_int);
    Adder_x2 add1 (a[3:2], b[3:2], c_int, k[3:2], cout );

    
    
endmodule