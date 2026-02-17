`timescale 1ns / 1ps

module Alarm_FSM(
   input  logic clk,
    input  logic rst,
    input  logic C_A,
    input  logic btn,
    output logic led
);
    typedef enum logic {OFF, ON} state_t;
    state_t state, state_n;

    always_comb begin
        state_n = state;
        led     = 1'b0;

        case (state)
            OFF: begin
                if (C_A) begin
                    state_n = ON;
                    led     = 1'b1;
                end else begin
                    state_n = OFF;
                    led     = 1'b0;
                end
            end

            ON: begin
                if (btn) begin
                    state_n = OFF;
                    led     = 1'b0;
                end else begin
                    state_n = ON;
                    led     = 1'b1;
                end
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) state <= OFF;
        else     state <= state_n;
    end
endmodule

