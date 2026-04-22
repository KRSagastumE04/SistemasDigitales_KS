`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2024 09:28:52
// Design Name: 
// Module Name: Adder_x1_bit
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

module Adder_x1_bit(input  logic a, b, cin, 
                 output logic k, cout);
  
  logic p, g; 

  assign p = a ^ b;
  assign g = a & b;
  
  assign k = p ^ cin;
  assign cout = g | (p & cin);

endmodule
