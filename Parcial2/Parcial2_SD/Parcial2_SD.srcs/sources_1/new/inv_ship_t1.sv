module inv_ship_t1 (
    input  logic        s_clk,
    input  logic        clk,
    input  logic        en,
    input  logic        on_sw,
    input  logic        shift_right,
    input  logic        shift_left,
    input  logic        shift_down,
    input  logic [10:0] orig_x,
    input  logic [10:0] orig_y,
    input  logic [10:0] pixel_x,
    input  logic [10:0] pixel_y,
    input  logic        shot_pixel,
    output logic        ship_pixel,
    output logic        line_crossed
);

    // -------------------------------
    // Parámetros del sprite examen
    // -------------------------------
    localparam logic [10:0] EXAM_W = 11'd36;
    localparam logic [10:0] EXAM_H = 11'd24;

    logic [10:0] ship_x, ship_y;
    logic        destroyed;
    logic [10:0] rel_x, rel_y;

    // Movimiento
    always_ff @(posedge clk) begin
        if (!on_sw) begin
            ship_x <= orig_x;
            ship_y <= orig_y;
        end
        else begin
            if (shift_right)
                ship_x <= ship_x + 1'b1;
            else if (shift_left)
                ship_x <= ship_x - 1'b1;
            else if (shift_down)
                ship_y <= ship_y + 1'b1;
        end
    end

    // Destrucción por impacto
    always_ff @(posedge s_clk) begin
        if (!on_sw)
            destroyed <= 1'b0;
        else if (shot_pixel && ship_pixel)
            destroyed <= 1'b1;
    end

    // Dibujo del examen:
    // hoja + líneas + check rojo
    always_comb begin
        ship_pixel = 1'b0;
        rel_x      = 11'd0;
        rel_y      = 11'd0;

        if (en && !destroyed) begin
            if ((pixel_x >= ship_x) && (pixel_x < ship_x + EXAM_W) &&
                (pixel_y >= ship_y) && (pixel_y < ship_y + EXAM_H)) begin

                rel_x = pixel_x - ship_x;
                rel_y = pixel_y - ship_y;

                // Marco exterior de la hoja
                if ((rel_y >= 1 && rel_y <= 2) && (rel_x >= 5 && rel_x <= 29))
                    ship_pixel = 1'b1;
                else if ((rel_y >= 19 && rel_y <= 20) && (rel_x >= 5 && rel_x <= 29))
                    ship_pixel = 1'b1;
                else if ((rel_x >= 5 && rel_x <= 6) && (rel_y >= 2 && rel_y <= 20))
                    ship_pixel = 1'b1;
                else if ((rel_x >= 28 && rel_x <= 29) && (rel_y >= 2 && rel_y <= 20))
                    ship_pixel = 1'b1;

                // Esquina doblada
                else if ((rel_x >= 25 && rel_x <= 29) && (rel_y >= 2 && rel_y <= 6))
                    ship_pixel = 1'b1;
                else if ((rel_x == 24 && rel_y == 3) || (rel_x == 23 && rel_y == 4) ||
                         (rel_x == 22 && rel_y == 5) || (rel_x == 21 && rel_y == 6))
                    ship_pixel = 1'b1;

                // Líneas del examen
                else if ((rel_y >= 6 && rel_y <= 7) && (rel_x >= 9 && rel_x <= 22))
                    ship_pixel = 1'b1;
                else if ((rel_y >= 10 && rel_y <= 11) && (rel_x >= 9 && rel_x <= 24))
                    ship_pixel = 1'b1;
                else if ((rel_y >= 14 && rel_y <= 15) && (rel_x >= 9 && rel_x <= 20))
                    ship_pixel = 1'b1;

                // Cuadrito / casilla
                else if ((rel_x >= 9 && rel_x <= 12) && (rel_y >= 16 && rel_y <= 19))
                    ship_pixel = 1'b1;

                // Check / marca buena
                else if ((rel_x == 15 && rel_y == 17) ||
                         (rel_x == 16 && rel_y == 18) ||
                         (rel_x == 17 && rel_y == 19) ||
                         (rel_x == 18 && rel_y == 18) ||
                         (rel_x == 19 && rel_y == 17) ||
                         (rel_x == 20 && rel_y == 16) ||
                         (rel_x == 21 && rel_y == 15))
                    ship_pixel = 1'b1;
            end
        end
    end

    // Indicador de línea cruzada
    always_comb begin
        if (en && !destroyed && ship_y > 11'd544)
            line_crossed = 1'b1;
        else
            line_crossed = 1'b0;
    end

endmodule