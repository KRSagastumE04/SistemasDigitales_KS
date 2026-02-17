`timescale 1ns / 1ps

module FSM_Mealy(
    input  logic clk,
    input  logic rst,
    input  logic T,      
    input  logic C,    
    input  logic D1, D0,  
    output logic A,
    output logic [1:0] Disp
);

typedef enum logic [2:0] {
    ESPERANDO_TICKET,
    TOTAL_0,
    TOTAL_10,
    TOTAL_20
} state_t;

state_t estado_actual, proximo_estado;

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        estado_actual <= ESPERANDO_TICKET;
    else
        estado_actual <= proximo_estado;
end

localparam DISP_0  = 2'b00;
localparam DISP_10 = 2'b01;
localparam DISP_20 = 2'b10;

always_comb begin

    proximo_estado = estado_actual;
    A    = 1'b0;
    Disp = DISP_0;

    case (estado_actual)

        ESPERANDO_TICKET: begin
            Disp = DISP_0;
            if (T)
                proximo_estado = TOTAL_0;
        end

        TOTAL_0: begin
            Disp = DISP_0;
            if (C)
                proximo_estado = ESPERANDO_TICKET;
            else if ({D1,D0} == 2'b01)
                proximo_estado = TOTAL_10;
            else if ({D1,D0} == 2'b10)
                proximo_estado = TOTAL_20;
        end

        TOTAL_10: begin
            Disp = DISP_10;
            if (C)
                proximo_estado = ESPERANDO_TICKET;
            else if ({D1,D0} == 2'b01)
                proximo_estado = TOTAL_20;
            else if ({D1,D0} == 2'b10) begin
                proximo_estado = ESPERANDO_TICKET;
                A = 1'b1;   // Pulso de aceptación
            end
        end

        TOTAL_20: begin
            Disp = DISP_20;
            if (C)
                proximo_estado = ESPERANDO_TICKET;
            else if ({D1,D0} == 2'b01) begin
                proximo_estado = ESPERANDO_TICKET;
                A = 1'b1;
            end
        end

    endcase
end

endmodule


