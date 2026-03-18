module shot (
    input  logic        s_clk,
    input  logic        clk_0,
    input  logic        en,
    input  logic [10:0] orig_x,
    input  logic [10:0] orig_y,
    input  logic [10:0] pixel_x,
    input  logic [10:0] pixel_y,
    input  logic        ship_pixel,
    output logic        shot_pixel,
    output logic        done
);

    logic [10:0] shot_x, shot_y;
    logic        hit;
    logic        en_d;

    always_ff @(posedge clk_0) begin
        en_d <= en;
    end

    always_ff @(posedge clk_0) begin
        if (!en) begin
            shot_x <= orig_x;
            shot_y <= orig_y;
        end
        else if (!en_d && en) begin
            shot_x <= orig_x;
            shot_y <= orig_y;
        end
        else if (!hit && shot_y > 11'd4) begin
            shot_y <= shot_y - 11'd4;
        end
    end

    always_ff @(posedge s_clk) begin
        if (!en)
            hit <= 1'b0;
        else if (shot_pixel && ship_pixel)
            hit <= 1'b1;
    end

    // láser grande: 8x20
    always_comb begin
        shot_pixel = 1'b0;

        if (en && !hit) begin
            if ((pixel_x >= shot_x) && (pixel_x < shot_x + 11'd8) &&
                (pixel_y >= shot_y) && (pixel_y < shot_y + 11'd20)) begin
                shot_pixel = 1'b1;
            end
        end
    end

    assign done = en && (hit || (shot_y <= 11'd4));

endmodule