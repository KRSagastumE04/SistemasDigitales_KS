module vga_rgb_text (
    input  logic        video_on,
    input  logic [10:0] pixel_x,
    input  logic [10:0] pixel_y,
    output logic [4:0]  vga_rgb
);

    always_comb begin
        if (video_on)
            vga_rgb = 5'b11111;
        else
            vga_rgb = 5'b00000;
    end

endmodule