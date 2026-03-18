module space_invader_top(
    input  logic       clk,
    input  logic       clk_rst,
    input  logic       cont_btn,
    input  logic       move_rt_btn,
    input  logic       move_lft_btn,
    input  logic       shoot_btn,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue,
    output logic       Hsync,
    output logic       Vsync
);

    logic        clk_1, clk_2, clk_3, clk_4;
    logic        player_en;
    logic [2:0]  level;
    logic [23:0] inv_en;
    logic        ship_pixel, line_crossed;
    logic        player_pixel;
    logic        shot_pixel;
    logic        lvl_start;
    logic [10:0] pixel_x, pixel_y;
    logic [2:0]  mode;
    logic [11:0] score;
    logic [2:0]  charge_count;
    logic        on_sw;
    logic [26:0] count;

    clk_div cd1 (
        .clk      (clk),
        .clk_rst  (clk_rst),
        .div_count(32'd738281),
        .clk_div  (clk_1)
    );

    clk_div cd2 (
        .clk      (clk),
        .clk_rst  (clk_rst),
        .div_count(32'd184570),
        .clk_div  (clk_2)
    );

    clk_div cd3 (
        .clk      (clk),
        .clk_rst  (clk_rst),
        .div_count(32'd92285),
        .clk_div  (clk_3)
    );

    clk_div cd4 (
        .clk      (clk),
        .clk_rst  (clk_rst),
        .div_count(32'd23625000),
        .clk_div  (clk_4)
    );

    // Retardo de arranque
    // btnU = reset activo en alto
    always_ff @(posedge clk) begin
        if (clk_rst) begin
            on_sw <= 1'b0;
            count <= 27'd0;
        end
        else if (count < 27'd94500000) begin
            count <= count + 1'b1;
            on_sw <= 1'b0;
        end
        else begin
            on_sw <= 1'b1;
        end
    end

    game_ctrl gc0 (
        .s_clk        (clk),
        .rst          (on_sw),
        .ship_pixel   (ship_pixel),
        .shot_pixel   (shot_pixel),
        .cont_btn     (cont_btn),
        .line_crossed (line_crossed),
        .lvl_start    (lvl_start),
        .player_en    (player_en),
        .mode         (mode),
        .level        (level),
        .inv_en       (inv_en),
        .score        (score)
    );

    player pl0 (
        .s_clk          (clk),
        .clk_0          (clk_4),
        .clk_1          (clk_2),
        .clk_2          (clk_3),
        .en             (player_en),
        .on_sw          (lvl_start),
        .move_rt_btn    (move_rt_btn),
        .move_lft_btn   (move_lft_btn),
        .shoot_btn      (shoot_btn),
        .pixel_x        (pixel_x),
        .pixel_y        (pixel_y),
        .ship_pixel     (ship_pixel),
        .player_pixel   (player_pixel),
        .charge_count   (charge_count),
        .shot_pixel_out (shot_pixel)
    );

    inv_ship_controller isc0 (
        .s_clk            (clk),
        .clk              (clk_1),
        .on_sw            (lvl_start),
        .en               (inv_en),
        .pixel_x          (pixel_x),
        .pixel_y          (pixel_y),
        .shot_pixel       (shot_pixel),
        .ship_pixel_out   (ship_pixel),
        .line_crossed_out (line_crossed)
    );

    vga_top vt0 (
        .clk          (clk),
        .btnC         (cont_btn),
        .btnL         (move_lft_btn),
        .btnR         (move_rt_btn),
        .btnD         (shoot_btn),
        .mode         (mode),
        .level        (level),
        .score        (score),
        .charge_count (charge_count),
        .player_pixel (player_pixel),
        .shot_pixel   (shot_pixel),
        .ship_pixel   (ship_pixel),
        .Hsync        (Hsync),
        .Vsync        (Vsync),
        .vgaRed       (vgaRed),
        .vgaGreen     (vgaGreen),
        .vgaBlue      (vgaBlue),
        .pixel_x      (pixel_x),
        .pixel_y      (pixel_y)
    );

endmodule