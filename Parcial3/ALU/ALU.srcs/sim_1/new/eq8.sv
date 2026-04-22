`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.10.2024 19:02:21
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


module eq8(input logic [7:0] a,b,
output logic aeqb
    );
    
    //variables internas
    logic e0,e1;    
    
    eq4 eq_0 (.sw0(a[3:0]), .sw1(b[3:0]), .LED0(e0));
    eq4 eq_1 (.LED0(e1), .sw0(a[7:4]), .sw1(b[7:4]));
    
    assign aeqb = e0 & e1;
    
endmodule
