`timescale 1ns / 1ps

module FSM_Top(

    input  logic clk,
    input  logic btnC,
    input  logic [5:0]sw,

    output logic [5:0]led,
    output logic clk_out

);

logic int_clk;

clck_psc clck_psc (
    .clk(clk),
    .clk_out(int_clk)
); 

    FSM_Complete complete (

        .clk(int_clk),
        .rst(btnC),

        .T(sw[0]),
        .C(sw[1]),
        .D1(sw[2]),
        .D0(sw[3]),
        .Sauto(sw[4]),
        .Spaso(sw[5]),

        .Pt(led[1:0]),
        .L(led[2]),
        .Disp(led[4:3]),
        .A(led[5])
    );

endmodule
