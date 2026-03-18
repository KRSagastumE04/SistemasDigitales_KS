module vga_top(
    input  logic        clk,
    input  logic        btnC,
    input  logic        btnL,
    input  logic        btnR,
    input  logic        btnD,

    input  logic [2:0]  mode,
    input  logic [2:0]  level,
    input  logic [11:0] score,
    input  logic [2:0]  charge_count,
    input  logic        player_pixel,
    input  logic        shot_pixel,
    input  logic        ship_pixel,

    output logic        Hsync,
    output logic        Vsync,
    output logic [3:0]  vgaRed,
    output logic [3:0]  vgaGreen,
    output logic [3:0]  vgaBlue,
    output logic [10:0] pixel_x,
    output logic [10:0] pixel_y
);

    logic        video_on;

    // Coordenadas reales 640x480
    logic [10:0] phys_x, phys_y;

    // Coordenadas virtuales base 1024x768
    logic [10:0] ui_x, ui_y;
    logic [13:0] sx_num, sy_num;

    // Coordenadas ajustadas para juego
    logic signed [11:0] game_x_s, game_y_s;
    logic [10:0] game_x, game_y;

    logic [4:0]  rgb_game, rgb_title, rgb_inbet, rgb_win, rgb_g_over;
    logic [4:0]  cl_frm_log;

    logic        on_sw;
    logic [3:0]  vga_r, vga_g, vga_b;

    // Ajuste fino SOLO del juego
    localparam int GAME_X_OFF = -20;
    localparam int GAME_Y_OFF = 0;

    assign on_sw = 1'b1;

    // VGA real 640x480
    vga_sync vs0 (
        .clk      (clk),
        .on_sw    (on_sw),
        .hsync    (Hsync),
        .vsync    (Vsync),
        .video_on (video_on),
        .pixel_x  (phys_x),
        .pixel_y  (phys_y)
    );

    // Escalado base 640x480 -> 1024x768
    assign sx_num = phys_x * 14'd8;
    assign sy_num = phys_y * 14'd8;

    assign ui_x = sx_num / 14'd5;
    assign ui_y = sy_num / 14'd5;

    // Ajuste fino para el juego
    assign game_x_s = $signed({1'b0, ui_x}) + GAME_X_OFF;
    assign game_y_s = $signed({1'b0, ui_y}) + GAME_Y_OFF;

    // Saturación para evitar negativos
    assign game_x = (game_x_s < 0) ? 11'd0 : game_x_s[10:0];
    assign game_y = (game_y_s < 0) ? 11'd0 : game_y_s[10:0];

    // Estas coordenadas van al resto del sistema del juego
    assign pixel_x = game_x;
    assign pixel_y = game_y;

    // Pantalla del juego usa coordenadas ajustadas
    vga_rgb_game vg0 (
        .level        (level),
        .score        (score),
        .video_on     (video_on),
        .player_pixel (player_pixel),
        .shot_pixel   (shot_pixel),
        .ship_pixel   (ship_pixel),
        .charge_count (charge_count),
        .pixel_x      (game_x),
        .pixel_y      (game_y),
        .vga_rgb      (rgb_game)
    );

    // Pantallas UI usan coordenadas base escaladas
    vga_rgb_title vt0 (
        .video_on (video_on),
        .pixel_x  (ui_x),
        .pixel_y  (ui_y),
        .vga_rgb  (rgb_title)
    );

    vga_rgb_inbet vib0 (
        .video_on (video_on),
        .pixel_x  (ui_x),
        .pixel_y  (ui_y),
        .vga_rgb  (rgb_inbet)
    );

    vga_rgb_g_over vgo0 (
        .video_on (video_on),
        .pixel_x  (ui_x),
        .pixel_y  (ui_y),
        .vga_rgb  (rgb_g_over)
    );

    vga_rgb_win vw0 (
        .video_on (video_on),
        .pixel_x  (ui_x),
        .pixel_y  (ui_y),
        .vga_rgb  (rgb_win)
    );

    always_comb begin
        unique case (mode)
            3'b001:  cl_frm_log = rgb_game;
            3'b010:  cl_frm_log = rgb_inbet;
            3'b011:  cl_frm_log = rgb_win;
            3'b100:  cl_frm_log = rgb_g_over;
            default: cl_frm_log = rgb_title;
        endcase
    end

    color_decode cd0 (
        .cl_frm_log(cl_frm_log),
        .cl_to_vga ({vga_r, vga_g, vga_b})
    );

    assign vgaRed   = vga_r;
    assign vgaGreen = vga_g;
    assign vgaBlue  = vga_b;

endmodule