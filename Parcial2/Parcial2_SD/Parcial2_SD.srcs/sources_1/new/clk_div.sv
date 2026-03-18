module clk_div(
    input  logic        clk,
    input  logic        clk_rst,
    input  logic [31:0] div_count,
    output logic        clk_div
);

    logic [31:0] count;

    always_ff @(posedge clk) begin
        if (!clk_rst) begin
            count   <= 32'h0000_0000;
            clk_div <= 1'b0;
        end
        else if (count == div_count - 1) begin
            count   <= 32'h0000_0000;
            clk_div <= ~clk_div;
        end
        else begin
            count   <= count + 1'b1;
            clk_div <= clk_div;
        end
    end

endmodule