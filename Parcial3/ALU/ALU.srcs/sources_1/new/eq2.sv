`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.10.2024 11:03:04
// Design Name: 
// Module Name: eq2
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


module eq2(input logic [1:0] a,b,
output logic aeqb
    );
    
    
    logic e0,e1;
    
    
    
    Comparator_x2_bit eq_0 (.sw0(a[0]), .sw1(b[0]), .LED0(e0));
    Comparator_x2_bit eq_1 (.LED0(e1), .sw0(a[1]), .sw1(b[1]));
    
    assign aeqb = e0 & e1;
    
endmodule
