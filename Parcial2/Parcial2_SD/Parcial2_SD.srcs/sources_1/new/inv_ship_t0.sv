module inv_ship_t0 (
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
    // Parámetros del sprite libro
    // -------------------------------
    localparam logic [10:0] BOOK_W = 11'd36;
    localparam logic [10:0] BOOK_H = 11'd24;

    // posición actual del enemigo
    logic [10:0] ship_x, ship_y;
    logic        destroyed;

    logic [10:0] rel_x, rel_y;

    // -------------------------------
    // Movimiento del enemigo
    // -------------------------------
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

    // -------------------------------
    // Destrucción por impacto
    // -------------------------------
    always_ff @(posedge s_clk) begin
        if (!on_sw)
            destroyed <= 1'b0;
        else if (shot_pixel && ship_pixel)
            destroyed <= 1'b1;
    end

    // -------------------------------
    // Dibujo del libro
    //
    // Idea aproximada:
    // | - \ _ / - |
    // |     |     |
    // | _ /   \ _ |
    // -------------------------------
    always_comb begin
        ship_pixel = 1'b0;
        rel_x      = 11'd0;
        rel_y      = 11'd0;

        if (en && !destroyed) begin
            if ((pixel_x >= ship_x) && (pixel_x < ship_x + BOOK_W) &&
                (pixel_y >= ship_y) && (pixel_y < ship_y + BOOK_H)) begin

                rel_x = pixel_x - ship_x;
                rel_y = pixel_y - ship_y;

                // borde superior
                if ((rel_y >= 0 && rel_y <= 1) && (rel_x >= 4 && rel_x <= 31))
                    ship_pixel = 1'b1;

                // bordes laterales
                else if ((rel_x >= 3 && rel_x <= 4) && (rel_y >= 2 && rel_y <= 20))
                    ship_pixel = 1'b1;
                else if ((rel_x >= 31 && rel_x <= 32) && (rel_y >= 2 && rel_y <= 20))
                    ship_pixel = 1'b1;

                // borde inferior
                else if ((rel_y >= 20 && rel_y <= 22) && (rel_x >= 2 && rel_x <= 33))
                    ship_pixel = 1'b1;

                // línea central del libro abierto
                else if ((rel_x >= 17 && rel_x <= 18) && (rel_y >= 4 && rel_y <= 18))
                    ship_pixel = 1'b1;

                // diagonales superiores hacia el centro
                else if ((rel_y == 4)  && (rel_x == 10 || rel_x == 25))
                    ship_pixel = 1'b1;
                else if ((rel_y == 5)  && (rel_x == 11 || rel_x == 24))
                    ship_pixel = 1'b1;
                else if ((rel_y == 6)  && (rel_x == 12 || rel_x == 23))
                    ship_pixel = 1'b1;
                else if ((rel_y == 7)  && (rel_x == 13 || rel_x == 22))
                    ship_pixel = 1'b1;
                else if ((rel_y == 8)  && (rel_x == 14 || rel_x == 21))
                    ship_pixel = 1'b1;

                // línea superior interna
                else if ((rel_y >= 3 && rel_y <= 4) && (rel_x >= 7 && rel_x <= 14))
                    ship_pixel = 1'b1;
                else if ((rel_y >= 3 && rel_y <= 4) && (rel_x >= 21 && rel_x <= 28))
                    ship_pixel = 1'b1;

                // diagonales inferiores alejándose del centro
                else if ((rel_y == 12) && (rel_x == 14 || rel_x == 21))
                    ship_pixel = 1'b1;
                else if ((rel_y == 13) && (rel_x == 13 || rel_x == 22))
                    ship_pixel = 1'b1;
                else if ((rel_y == 14) && (rel_x == 12 || rel_x == 23))
                    ship_pixel = 1'b1;
                else if ((rel_y == 15) && (rel_x == 11 || rel_x == 24))
                    ship_pixel = 1'b1;
                else if ((rel_y == 16) && (rel_x == 10 || rel_x == 25))
                    ship_pixel = 1'b1;
                else if ((rel_y == 17) && (rel_x == 9  || rel_x == 26))
                    ship_pixel = 1'b1;

                // base interior de cada página
                else if ((rel_y >= 16 && rel_y <= 17) && (rel_x >= 6 && rel_x <= 14))
                    ship_pixel = 1'b1;
                else if ((rel_y >= 16 && rel_y <= 17) && (rel_x >= 21 && rel_x <= 29))
                    ship_pixel = 1'b1;

                // lomo inferior para reforzar forma
                else if ((rel_y >= 18 && rel_y <= 19) && (rel_x >= 15 && rel_x <= 20))
                    ship_pixel = 1'b1;
            end
        end
    end

    // -------------------------------
    // Indicador de línea cruzada
    // -------------------------------
    always_comb begin
        if (en && !destroyed && ship_y > 11'd544)
            line_crossed = 1'b1;
        else
            line_crossed = 1'b0;
    end

endmodule