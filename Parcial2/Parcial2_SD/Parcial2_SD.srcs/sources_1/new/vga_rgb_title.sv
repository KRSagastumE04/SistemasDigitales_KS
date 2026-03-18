module vga_rgb_title (
    input  logic        video_on,
    input  logic [10:0] pixel_x,
    input  logic [10:0] pixel_y,
    output logic [4:0]  vga_rgb
);

    // Colores (puedes cambiarlos aquí)
    localparam logic [4:0] COLOR_UNIS = 5'b01110; // Dorado/Amarillo
    localparam logic [4:0] COLOR_HALCON = 5'b00010; // Azul/Verde según tu código anterior

    always_comb begin
        vga_rgb = 5'b00000; // Fondo negro por defecto

        if (video_on) begin
            
            // =====================================================
            // FILA SUPERIOR: "UNIS" (y: 294 - 374)
            // =====================================================
            
            // Letra U
            if (pixel_y >= 294 && pixel_y < 374 && pixel_x >= 342 && pixel_x < 402) begin
                if (pixel_x < 354 || pixel_x >= 390 || pixel_y >= 362)
                    vga_rgb = COLOR_HALCON;
            end
            
            // Letra N
            else if (pixel_y >= 294 && pixel_y < 374 && pixel_x >= 412 && pixel_x < 472) begin
                if (pixel_x < 424 || pixel_x >= 460 || (pixel_x == pixel_y + 118)) // Diagonal simple
                    vga_rgb = COLOR_HALCON;
            end

            // Letra I
            else if (pixel_y >= 294 && pixel_y < 374 && pixel_x >= 482 && pixel_x < 542) begin
                if (pixel_y < 306 || pixel_y >= 362 || (pixel_x >= 506 && pixel_x < 518))
                    vga_rgb = COLOR_HALCON;
            end

            // Letra S
            else if (pixel_y >= 294 && pixel_y < 374 && pixel_x >= 552 && pixel_x < 612) begin
                if (pixel_y < 306 || pixel_y >= 362 || (pixel_y >= 328 && pixel_y < 340) ||
                   (pixel_y < 328 && pixel_x < 564) || (pixel_y > 340 && pixel_x >= 600))
                    vga_rgb = COLOR_HALCON;
            end

            // =====================================================
            // FILA INFERIOR: "HALCON FORCE" (y: 384 - 464)
            // =====================================================
            
            // H (Simplificada para el ejemplo)
            if (pixel_y >= 384 && pixel_y < 464 && pixel_x >= 200 && pixel_x < 250) begin
                if (pixel_x < 210 || pixel_x >= 240 || (pixel_y >= 418 && pixel_y < 430))
                    vga_rgb = COLOR_UNIS;
            end

            // A
            else if (pixel_y >= 384 && pixel_y < 464 && pixel_x >= 260 && pixel_x < 310) begin
                if (pixel_y < 396 || (pixel_y >= 418 && pixel_y < 430) || pixel_x < 270 || pixel_x >= 300)
                    vga_rgb = COLOR_UNIS;
            end

            // L
            else if (pixel_y >= 384 && pixel_y < 464 && pixel_x >= 320 && pixel_x < 370) begin
                if (pixel_x < 330 || pixel_y >= 450)
                    vga_rgb = COLOR_UNIS;
            end

            // C
            else if (pixel_y >= 384 && pixel_y < 464 && pixel_x >= 380 && pixel_x < 430) begin
                if (pixel_x < 390 || pixel_y < 394 || pixel_y >= 454)
                    vga_rgb = COLOR_UNIS;
            end

            // O
            else if (pixel_y >= 384 && pixel_y < 464 && pixel_x >= 440 && pixel_x < 490) begin
                if (pixel_x < 450 || pixel_x >= 480 || pixel_y < 394 || pixel_y >= 454)
                    vga_rgb = COLOR_UNIS;
            end

            // N
            else if (pixel_y >= 384 && pixel_y < 464 && pixel_x >= 500 && pixel_x < 550) begin
                if (pixel_x < 510 || pixel_x >= 540 || (pixel_x == pixel_y + 116))
                    vga_rgb = COLOR_UNIS;
            end

            // --- Espacio y luego "FORCE" ---
            
            // F
            else if (pixel_y >= 384 && pixel_y < 464 && pixel_x >= 570 && pixel_x < 620) begin
                if (pixel_x < 580 || pixel_y < 394 || (pixel_y >= 418 && pixel_y < 430))
                    vga_rgb = COLOR_UNIS;
            end

            // O (Igual que la anterior pero desplazada)
            else if (pixel_y >= 384 && pixel_y < 464 && pixel_x >= 630 && pixel_x < 680) begin
                if (pixel_x < 640 || pixel_x >= 670 || pixel_y < 394 || pixel_y >= 454)
                    vga_rgb = COLOR_UNIS;
            end

            // R (Simplificada)
            else if (pixel_y >= 384 && pixel_y < 464 && pixel_x >= 690 && pixel_x < 740) begin
                if (pixel_x < 700 || pixel_y < 394 || (pixel_y >= 418 && pixel_y < 430) || (pixel_y > 430 && pixel_x >= 730))
                    vga_rgb = COLOR_UNIS;
            end

            // C (Igual que la anterior)
            else if (pixel_y >= 384 && pixel_y < 464 && pixel_x >= 750 && pixel_x < 800) begin
                if (pixel_x < 760 || pixel_y < 394 || pixel_y >= 454)
                    vga_rgb = COLOR_UNIS;
            end

            // E
            else if (pixel_y >= 384 && pixel_y < 464 && pixel_x >= 810 && pixel_x < 860) begin
                if (pixel_x < 820 || pixel_y < 394 || pixel_y >= 454 || (pixel_y >= 418 && pixel_y < 430))
                    vga_rgb = COLOR_UNIS;
            end

        end
    end

endmodule