module player (
    input  logic        s_clk,
    input  logic        clk_0,
    input  logic        clk_1,
    input  logic        clk_2,
    input  logic        en,
    input  logic        on_sw,
    input  logic        move_rt_btn,
    input  logic        move_lft_btn,
    input  logic        shoot_btn,
    input  logic [10:0] pixel_x,
    input  logic [10:0] pixel_y,
    input  logic        ship_pixel,
    output logic        player_pixel,
    output logic [2:0]  charge_count,
    output logic        shot_pixel_out
);

    localparam logic [10:0] ORIG_X = 11'd420;
    localparam logic [10:0] ORIG_Y = 11'd640;
    localparam logic [10:0] P_W    = 11'd40;
    localparam logic [10:0] P_H    = 11'd28;

    localparam logic [10:0] X_MIN  = 11'd20;
    localparam logic [10:0] X_MAX  = 11'd960;

    logic [10:0] ship_x;
    logic [10:0] shot_orig_x0, shot_orig_y0;
    logic [10:0] rel_x, rel_y;

    logic        shot_active;
    logic        shot_pixel0;
    logic        shot_done0;

    logic [19:0] move_div;
    logic        shoot_btn_d;
    logic        shoot_rise;

    assign shoot_rise = shoot_btn && !shoot_btn_d;

    // -------------------------------
    // Movimiento horizontal
    // -------------------------------
    always_ff @(posedge s_clk) begin
        if (!on_sw) begin
            ship_x   <= ORIG_X;
            move_div <= 20'd0;
        end
        else begin
            move_div <= move_div + 20'd1;

            if (move_div == 20'd0) begin
                if (move_rt_btn && ship_x < (X_MAX - P_W))
                    ship_x <= ship_x + 11'd4;
                else if (move_lft_btn && ship_x > X_MIN)
                    ship_x <= ship_x - 11'd4;
            end
        end
    end

    // -------------------------------
    // Disparo SIMPLE para depuración
    // -------------------------------
    always_ff @(posedge s_clk) begin
        if (!on_sw) begin
            shoot_btn_d  <= 1'b0;
            shot_active  <= 1'b0;
            charge_count <= 3'd6;
        end
        else begin
            shoot_btn_d <= shoot_btn;

            // si terminó el disparo, apagarlo
            if (shot_done0) begin
                shot_active  <= 1'b0;
                charge_count <= 3'd6;
            end
            // disparar con un clic
            else if (shoot_rise && !shot_active) begin
                shot_active  <= 1'b1;
                charge_count <= 3'd0;
            end
        end
    end

    // -------------------------------
    // Dibujo del jugador
    // -------------------------------
    always_comb begin
        player_pixel = 1'b0;
        rel_x        = 11'd0;
        rel_y        = 11'd0;

        if (en) begin
            if ((pixel_x >= ship_x) && (pixel_x < ship_x + P_W) &&
                (pixel_y >= ORIG_Y) && (pixel_y < ORIG_Y + P_H)) begin

                rel_x = pixel_x - ship_x;
                rel_y = pixel_y - ORIG_Y;

                // Marco exterior
                if ((rel_y <= 2) || (rel_y >= P_H-3) || (rel_x <= 2) || (rel_x >= P_W-3))
                    player_pixel = 1'b1;

                // U interna
                else if ((rel_x >= 10 && rel_x <= 12) && (rel_y >= 7 && rel_y <= 19))
                    player_pixel = 1'b1;
                else if ((rel_x >= 27 && rel_x <= 29) && (rel_y >= 7 && rel_y <= 19))
                    player_pixel = 1'b1;
                else if ((rel_y >= 18 && rel_y <= 20) && (rel_x >= 12 && rel_x <= 27))
                    player_pixel = 1'b1;
            end
        end
    end

    // -------------------------------
    // Origen del disparo
    // -------------------------------
    assign shot_orig_x0 = ship_x + 11'd14;
    assign shot_orig_y0 = ORIG_Y - 11'd16;

    assign shot_pixel_out = shot_pixel0;

    // -------------------------------
    // Disparo
    // -------------------------------
    shot s0 (
        .s_clk      (s_clk),
        .clk_0      (clk_2),
        .en         (shot_active),
        .orig_x     (shot_orig_x0),
        .orig_y     (shot_orig_y0),
        .pixel_x    (pixel_x),
        .pixel_y    (pixel_y),
        .ship_pixel (ship_pixel),
        .shot_pixel (shot_pixel0),
        .done       (shot_done0)
    );

endmodule