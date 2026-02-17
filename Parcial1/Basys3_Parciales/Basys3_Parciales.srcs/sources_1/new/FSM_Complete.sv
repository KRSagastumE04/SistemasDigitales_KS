`timescale 1ns / 1ps

module FSM_Complete(
    input  logic clk,
    input  logic btnC,
    input  logic [5:0] sw,
    output logic [5:0] led
);

logic int_clk;
logic pago_confirmado;

// Divisor de reloj
clck_psc divisor (
    .clk(clk),
    .clk_out(int_clk)
);

// Máquina de pago
FSM_Mealy sistema_pago (
    .clk(int_clk),
    .rst(btnC),
    .T(sw[0]),
    .C(sw[1]),
    .D1(sw[2]),
    .D0(sw[3]),
    .A(pago_confirmado),
    .Disp(led[4:3])
);

// Máquina talanquera
FSM_Moore sistema_talanquera (
    .clk(int_clk),
    .rst(btnC),
    .Sauto(sw[4]),
    .Spago(pago_confirmado),
    .Spaso(sw[5]),
    .Pt(led[1:0]),
    .L(led[2])
);

assign led[5] = pago_confirmado;

endmodule
