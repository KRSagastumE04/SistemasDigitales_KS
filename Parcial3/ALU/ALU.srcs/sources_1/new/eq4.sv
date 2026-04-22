`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.10.2024 18:43:57
// Design Name: 
// Module Name: eq4
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


module eq4(input logic [3:0] c,d,
output logic aeqb1
    );
    
    logic e0,e1;
    
    eq2 eq_2 (.a(d[1:0]), .b(d[1:0]), .aeqb(e0));
    eq2 eq_3 (.aeqb(e1), .a(c[3:2]), .b(d[3:2]));
    
    assign aeqb1 = e0 & e1;
    
endmodule
