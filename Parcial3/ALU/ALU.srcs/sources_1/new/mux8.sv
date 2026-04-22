`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.10.2024 18:05:17
// Design Name: 
// Module Name: mux8
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
// /////////////////////////////////////////////////////////////////////////////////

module mux8(input logic [3:0] d0, d1, d2, d3, d4, d5, d6, d7, input logic [2:0] s,
output logic [3:0] y);

assign y = s[2] ? (s[1] ?(s[0] ? d7: d6) : (s[0] ? d5 : d4)) : 
          (s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1 : d0));

endmodule

