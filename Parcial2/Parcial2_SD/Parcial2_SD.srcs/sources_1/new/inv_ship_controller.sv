module inv_ship_controller(
    input  logic        s_clk,
    input  logic        clk,
    input  logic        on_sw,
    input  logic        shot_pixel,
    input  logic [23:0] en,
    input  logic [10:0] pixel_x,
    input  logic [10:0] pixel_y,
    output logic        ship_pixel_out,
    output logic        line_crossed_out
);

    parameter logic [1:0] S0 = 2'b00,
                          S1 = 2'b01,
                          S2 = 2'b10,
                          S3 = 2'b11;

    // Movimiento de toda la formación
    localparam logic [8:0] MOVE_X_MAX = 9'd220;
    localparam logic [5:0] MOVE_Y_MAX = 6'd24;

    // Posiciones base mejor distribuidas
    localparam logic [10:0] X0 = 11'd60;
    localparam logic [10:0] X1 = 11'd155;
    localparam logic [10:0] X2 = 11'd250;
    localparam logic [10:0] X3 = 11'd345;
    localparam logic [10:0] X4 = 11'd440;
    localparam logic [10:0] X5 = 11'd535;
    localparam logic [10:0] X6 = 11'd630;
    localparam logic [10:0] X7 = 11'd725;

    localparam logic [10:0] Y0 = 11'd110;
    localparam logic [10:0] Y1 = 11'd190;
    localparam logic [10:0] Y2 = 11'd270;

    logic       shift_right, shift_left, shift_down;
    logic [1:0] state;
    logic [8:0] h_count;
    logic [5:0] v_count;

    logic [23:0] ship_pixel, line_crossed;

    assign ship_pixel_out   = |ship_pixel;
    assign line_crossed_out = |line_crossed;

    always_ff @(posedge clk) begin
        if (!on_sw) begin
            state       <= S0;
            h_count     <= 9'd0;
            v_count     <= 6'd0;
            shift_right <= 1'b0;
            shift_left  <= 1'b0;
            shift_down  <= 1'b0;
        end
        else begin
            shift_right <= 1'b0;
            shift_left  <= 1'b0;
            shift_down  <= 1'b0;

            case (state)
                S0: begin
                    if (h_count < MOVE_X_MAX) begin
                        shift_right <= 1'b1;
                        h_count     <= h_count + 1'b1;
                    end
                    else begin
                        state   <= S1;
                        h_count <= 9'd0;
                    end
                end

                S1: begin
                    if (v_count < MOVE_Y_MAX) begin
                        shift_down <= 1'b1;
                        v_count    <= v_count + 1'b1;
                    end
                    else begin
                        state   <= S2;
                        v_count <= 6'd0;
                    end
                end

                S2: begin
                    if (h_count < MOVE_X_MAX) begin
                        shift_left <= 1'b1;
                        h_count    <= h_count + 1'b1;
                    end
                    else begin
                        state   <= S3;
                        h_count <= 9'd0;
                    end
                end

                S3: begin
                    if (v_count < MOVE_Y_MAX) begin
                        shift_down <= 1'b1;
                        v_count    <= v_count + 1'b1;
                    end
                    else begin
                        state   <= S0;
                        v_count <= 6'd0;
                    end
                end

                default: begin
                    state       <= S0;
                    h_count     <= 9'd0;
                    v_count     <= 6'd0;
                    shift_right <= 1'b0;
                    shift_left  <= 1'b0;
                    shift_down  <= 1'b0;
                end
            endcase
        end
    end

    // =========================
    // FILA 1 -> LIBROS
    // =========================
    inv_ship_t0 is0  (.s_clk(s_clk), .clk(clk), .en(en[0]),  .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X0), .orig_y(Y0), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[0]),  .ship_pixel(ship_pixel[0]),  .shot_pixel(shot_pixel));
    inv_ship_t0 is1  (.s_clk(s_clk), .clk(clk), .en(en[1]),  .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X1), .orig_y(Y0), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[1]),  .ship_pixel(ship_pixel[1]),  .shot_pixel(shot_pixel));
    inv_ship_t0 is2  (.s_clk(s_clk), .clk(clk), .en(en[2]),  .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X2), .orig_y(Y0), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[2]),  .ship_pixel(ship_pixel[2]),  .shot_pixel(shot_pixel));
    inv_ship_t0 is3  (.s_clk(s_clk), .clk(clk), .en(en[3]),  .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X3), .orig_y(Y0), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[3]),  .ship_pixel(ship_pixel[3]),  .shot_pixel(shot_pixel));
    inv_ship_t0 is4  (.s_clk(s_clk), .clk(clk), .en(en[4]),  .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X4), .orig_y(Y0), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[4]),  .ship_pixel(ship_pixel[4]),  .shot_pixel(shot_pixel));
    inv_ship_t0 is5  (.s_clk(s_clk), .clk(clk), .en(en[5]),  .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X5), .orig_y(Y0), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[5]),  .ship_pixel(ship_pixel[5]),  .shot_pixel(shot_pixel));
    inv_ship_t0 is6  (.s_clk(s_clk), .clk(clk), .en(en[6]),  .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X6), .orig_y(Y0), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[6]),  .ship_pixel(ship_pixel[6]),  .shot_pixel(shot_pixel));
    inv_ship_t0 is7  (.s_clk(s_clk), .clk(clk), .en(en[7]),  .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X7), .orig_y(Y0), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[7]),  .ship_pixel(ship_pixel[7]),  .shot_pixel(shot_pixel));

    // =========================
    // FILA 2 -> EXÁMENES
    // =========================
    inv_ship_t1 is8  (.s_clk(s_clk), .clk(clk), .en(en[8]),  .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X0), .orig_y(Y1), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[8]),  .ship_pixel(ship_pixel[8]),  .shot_pixel(shot_pixel));
    inv_ship_t1 is9  (.s_clk(s_clk), .clk(clk), .en(en[9]),  .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X1), .orig_y(Y1), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[9]),  .ship_pixel(ship_pixel[9]),  .shot_pixel(shot_pixel));
    inv_ship_t1 is10 (.s_clk(s_clk), .clk(clk), .en(en[10]), .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X2), .orig_y(Y1), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[10]), .ship_pixel(ship_pixel[10]), .shot_pixel(shot_pixel));
    inv_ship_t1 is11 (.s_clk(s_clk), .clk(clk), .en(en[11]), .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X3), .orig_y(Y1), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[11]), .ship_pixel(ship_pixel[11]), .shot_pixel(shot_pixel));
    inv_ship_t1 is12 (.s_clk(s_clk), .clk(clk), .en(en[12]), .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X4), .orig_y(Y1), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[12]), .ship_pixel(ship_pixel[12]), .shot_pixel(shot_pixel));
    inv_ship_t1 is13 (.s_clk(s_clk), .clk(clk), .en(en[13]), .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X5), .orig_y(Y1), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[13]), .ship_pixel(ship_pixel[13]), .shot_pixel(shot_pixel));
    inv_ship_t1 is14 (.s_clk(s_clk), .clk(clk), .en(en[14]), .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X6), .orig_y(Y1), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[14]), .ship_pixel(ship_pixel[14]), .shot_pixel(shot_pixel));
    inv_ship_t1 is15 (.s_clk(s_clk), .clk(clk), .en(en[15]), .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X7), .orig_y(Y1), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[15]), .ship_pixel(ship_pixel[15]), .shot_pixel(shot_pixel));

    // =========================
    // FILA 3 -> COMPUTADORAS
    // =========================
    inv_ship_t2 is16 (.s_clk(s_clk), .clk(clk), .en(en[16]), .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X0), .orig_y(Y2), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[16]), .ship_pixel(ship_pixel[16]), .shot_pixel(shot_pixel));
    inv_ship_t2 is17 (.s_clk(s_clk), .clk(clk), .en(en[17]), .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X1), .orig_y(Y2), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[17]), .ship_pixel(ship_pixel[17]), .shot_pixel(shot_pixel));
    inv_ship_t2 is18 (.s_clk(s_clk), .clk(clk), .en(en[18]), .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X2), .orig_y(Y2), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[18]), .ship_pixel(ship_pixel[18]), .shot_pixel(shot_pixel));
    inv_ship_t2 is19 (.s_clk(s_clk), .clk(clk), .en(en[19]), .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X3), .orig_y(Y2), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[19]), .ship_pixel(ship_pixel[19]), .shot_pixel(shot_pixel));
    inv_ship_t2 is20 (.s_clk(s_clk), .clk(clk), .en(en[20]), .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X4), .orig_y(Y2), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[20]), .ship_pixel(ship_pixel[20]), .shot_pixel(shot_pixel));
    inv_ship_t2 is21 (.s_clk(s_clk), .clk(clk), .en(en[21]), .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X5), .orig_y(Y2), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[21]), .ship_pixel(ship_pixel[21]), .shot_pixel(shot_pixel));
    inv_ship_t2 is22 (.s_clk(s_clk), .clk(clk), .en(en[22]), .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X6), .orig_y(Y2), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[22]), .ship_pixel(ship_pixel[22]), .shot_pixel(shot_pixel));
    inv_ship_t2 is23 (.s_clk(s_clk), .clk(clk), .en(en[23]), .on_sw(on_sw), .shift_right(shift_right), .shift_left(shift_left), .shift_down(shift_down), .orig_x(X7), .orig_y(Y2), .pixel_x(pixel_x), .pixel_y(pixel_y), .line_crossed(line_crossed[23]), .ship_pixel(ship_pixel[23]), .shot_pixel(shot_pixel));

endmodule