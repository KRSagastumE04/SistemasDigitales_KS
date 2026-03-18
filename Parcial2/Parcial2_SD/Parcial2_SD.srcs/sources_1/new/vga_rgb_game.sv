module vga_rgb_game(
    input  logic        video_on,
    input  logic        player_pixel,
    input  logic        shot_pixel,
    input  logic        ship_pixel,
    input  logic [2:0]  level,
    input  logic [2:0]  charge_count,
    input  logic [11:0] score,
    input  logic [10:0] pixel_x,
    input  logic [10:0] pixel_y,
    output logic [4:0]  vga_rgb
);

    // Definición de colores para mantener coherencia con el título
    localparam logic [4:0] COLOR_TEXTO  = 5'b01110; // Dorado UNIS
    localparam logic [4:0] COLOR_NUMERO = 5'b00011; // Azul para niveles/puntos
    localparam logic [4:0] COLOR_PLAYER = 5'b01111; 
    localparam logic [4:0] COLOR_SHOT   = 5'b00001;
    localparam logic [4:0] COLOR_SHIP   = 5'b01100;
    localparam logic [4:0] COLOR_BORDER = 5'b11111; // Blanco

    always_comb begin
        vga_rgb = 5'b00000; // Fondo negro por defecto

        if (video_on) begin
            // --- ÁREAS DE MARGEN (Negro) ---
            if ((pixel_y >= 0 && pixel_y < 10) || (pixel_y >= 50 && pixel_y < 60) ||
                (pixel_y >= 708 && pixel_y < 718) || (pixel_y >= 758)) begin
                vga_rgb = 5'b00000;
            end

            // --- HUD SUPERIOR (Nivel / "LEVEL") ---
            else if (pixel_y >= 10 && pixel_y < 50) begin
                // Dibujo de letras L-E-V-E-L (Simplificado en lógica)
                if ((pixel_x >= 20 && pixel_x < 30 && pixel_y < 42) || (pixel_x >= 20 && pixel_x < 50 && pixel_y >= 42)) // L
                    vga_rgb = COLOR_TEXTO;
                else if (pixel_x >= 60 && pixel_x < 90 && (pixel_y < 16 || (pixel_y >= 27 && pixel_y < 33) || pixel_y >= 44)) // E
                    vga_rgb = COLOR_TEXTO;
                else if (pixel_x >= 60 && pixel_x < 70) // E (barra lateral)
                    vga_rgb = COLOR_TEXTO;
                // ... (aquí sigue tu lógica de la V y la otra E)
                else if (pixel_x >= 100 && pixel_x < 117) // V
                    vga_rgb = COLOR_TEXTO; 
                else if (pixel_x >= 144 && pixel_x < 174) // E
                    vga_rgb = COLOR_TEXTO;
                else if (pixel_x >= 184 && pixel_x < 214) // L
                    vga_rgb = COLOR_TEXTO;

                // Números del Nivel
                else if (pixel_x >= 224 && pixel_x < 254) begin
                    case (level)
                        3'b001: vga_rgb = (pixel_x >= 244) ? COLOR_NUMERO : 5'b00000;
                        3'b010: vga_rgb = (pixel_y < 16 || pixel_y >= 44 || (pixel_y >= 27 && pixel_y < 33)) ? COLOR_NUMERO : 5'b00000;
                        // ... resto de lógica de niveles
                        default: vga_rgb = 5'b00000;
                    endcase
                end
            end

            // --- HUD INFERIOR (Score y Carga) ---
            else if (pixel_y >= 718 && pixel_y < 758) begin
                // Letras S-C-O-R-E
                if (pixel_x >= 20 && pixel_x < 210)
                    vga_rgb = COLOR_TEXTO; 
                
                // Score dinámico (Dígitos)
                else if (pixel_x >= 224 && pixel_x < 334) begin
                    vga_rgb = COLOR_NUMERO; // Simplificación para el bloque de código
                end
                
                // Barra de Carga (Power Bar)
                else if (pixel_x >= 856 && pixel_x < 984) begin
                    if (pixel_y < 722 || pixel_y >= 754 || pixel_x < 860 || pixel_x >= 980)
                        vga_rgb = COLOR_BORDER;
                    else begin
                        // Lógica de carga según charge_count
                        case (charge_count)
                            3'b110: vga_rgb = 5'b00010; // Carga llena
                            default: vga_rgb = (pixel_x < (860 + charge_count*20)) ? COLOR_SHOT : 5'b00000;
                        endcase
                    end
                end
            end

            // --- ELEMENTOS DEL JUEGO (Sprites) ---
            else begin
                // Bordes de la pantalla de juego
                if ((pixel_y >= 60 && pixel_y < 64) || (pixel_y > 703 && pixel_y <= 707))
                    vga_rgb = COLOR_BORDER;
                else if (pixel_y > 589 && pixel_y <= 593)
                    vga_rgb = 5'b00010; // Línea de advertencia
                
                // Pixeles de objetos (Prioridad: Disparo > Jugador > Nave enemiga)
                else if (shot_pixel)
                    vga_rgb = COLOR_SHOT;
                else if (player_pixel)
                    vga_rgb = COLOR_PLAYER;
                else if (ship_pixel)
                    vga_rgb = COLOR_SHIP;
                else
                    vga_rgb = 5'b00000;
            end
        end
    end

endmodule