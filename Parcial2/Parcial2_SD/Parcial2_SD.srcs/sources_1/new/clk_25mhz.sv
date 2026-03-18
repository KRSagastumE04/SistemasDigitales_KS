module clk_25mhz(
    input  logic clk_in,   // 100 MHz
    input  logic rst,
    output logic clk_out   // 25 MHz REAL
);

    logic [1:0] count;

    always_ff @(posedge clk_in) begin
        if (rst) begin
            count   <= 2'd0;
            clk_out <= 1'b0;
        end else begin
            count <= count + 2'd1;
            clk_out <= count[1];  // 👈 CLAVE
        end
    end

endmodule