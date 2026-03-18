module vga_sync(
    input  logic        clk,
    input  logic        on_sw,
    output logic        hsync,
    output logic        vsync,
    output logic        video_on,
    output logic [10:0] pixel_x,
    output logic [10:0] pixel_y
);

    // 640x480 @ 60 Hz
    localparam int HD = 640;  // horizontal display area
    localparam int HF = 16;   // horizontal front porch
    localparam int HS = 96;   // horizontal sync pulse
    localparam int HB = 48;   // horizontal back porch

    localparam int VD = 480;  // vertical display area
    localparam int VF = 10;   // vertical front porch
    localparam int VS = 2;    // vertical sync pulse
    localparam int VB = 33;   // vertical back porch

    logic [1:0] pix_div;
    logic       pixel_tick;

    logic [10:0] h_count_reg, h_count_next;
    logic [10:0] v_count_reg, v_count_next;
    logic        h_sync_reg, h_sync_next;
    logic        v_sync_reg, v_sync_next;
    logic        h_end, v_end;

    // Divisor 100 MHz -> 25 MHz
    always_ff @(posedge clk) begin
        if (!on_sw)
            pix_div <= 2'b00;
        else
            pix_div <= pix_div + 2'b01;
    end

    assign pixel_tick = (pix_div == 2'b00);

    // Registros principales
    always_ff @(posedge clk) begin
        if (!on_sw) begin
            h_count_reg <= 11'd0;
            v_count_reg <= 11'd0;
            h_sync_reg  <= 1'b1;
            v_sync_reg  <= 1'b1;
        end
        else begin
            h_count_reg <= h_count_next;
            v_count_reg <= v_count_next;
            h_sync_reg  <= h_sync_next;
            v_sync_reg  <= v_sync_next;
        end
    end

    // Fin de línea y cuadro
    assign h_end = (h_count_reg == (HD + HF + HS + HB - 1));
    assign v_end = (v_count_reg == (VD + VF + VS + VB - 1));

    // Contador horizontal
    always_comb begin
        h_count_next = h_count_reg;
        if (pixel_tick) begin
            if (h_end)
                h_count_next = 11'd0;
            else
                h_count_next = h_count_reg + 11'd1;
        end
    end

    // Contador vertical
    always_comb begin
        v_count_next = v_count_reg;
        if (pixel_tick && h_end) begin
            if (v_end)
                v_count_next = 11'd0;
            else
                v_count_next = v_count_reg + 11'd1;
        end
    end

    // Sincronías VGA estándar (activas en bajo)
    assign h_sync_next = ~((h_count_reg >= (HD + HF)) &&
                           (h_count_reg <  (HD + HF + HS)));

    assign v_sync_next = ~((v_count_reg >= (VD + VF)) &&
                           (v_count_reg <  (VD + VF + VS)));

    // Zona visible
    assign video_on = (h_count_reg < HD) && (v_count_reg < VD);

    // Salidas
    assign hsync   = h_sync_reg;
    assign vsync   = v_sync_reg;
    assign pixel_x = h_count_reg;
    assign pixel_y = v_count_reg;

endmodule