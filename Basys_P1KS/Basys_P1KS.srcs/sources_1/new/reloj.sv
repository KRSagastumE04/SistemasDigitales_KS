`timescale 1ns / 1ps

module reloj (
    input  logic clk,        // 100 MHz (Basys 3)
    input  logic rst,          // reset síncrono
    output logic tick          // 1 ciclo cada 1s
);
    logic [26:0] cnt;          // suficiente para contar hasta 100,000,000

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt  <= 0;
            tick <= 1'b0;
        end else if (cnt == 27'd99_999_999) begin
            cnt  <= 0;
            tick <= 1'b1;
        end else begin
            cnt  <= cnt + 1;
            tick <= 1'b0;
        end
    end
endmodule
