`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2024 06:27:57
// Design Name: 
// Module Name: eq8
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


module eq8 (
    input logic [7:0] e, f,
    output logic aeqb2
);
    logic e0, e1;

  
    eq4 eq_0 (.c(e[3:0]), .d(f[3:0]), .aeqb1(e0));
    eq4 eq_1 (.c(e[7:4]), .d(f[7:4]), .aeqb1(e1));

    assign aeqb2 = e0 & e1;

endmodule
