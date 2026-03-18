module game_ctrl (
    input  logic        s_clk,
    input  logic        rst,
    input  logic        ship_pixel,
    input  logic        shot_pixel,
    input  logic        cont_btn,
    input  logic        line_crossed,
    output logic        lvl_start,
    output logic        player_en,
    output logic [2:0]  level,
    output logic [2:0]  mode,
    output logic [23:0] inv_en,
    output logic [11:0] score
);

    typedef enum logic [2:0] {
        MENU  = 3'b000,
        GAME  = 3'b001,
        BETWEEN = 3'b010,
        WIN   = 3'b011,
        LOSE  = 3'b100
    } state_t;

    state_t state;

    logic [5:0] destroyed_count;

    // =============================
    // ESTADOS
    // =============================
    always_ff @(posedge s_clk) begin
        if (!rst) begin
            state <= MENU;
            level <= 3'b000;
        end
        else begin
            case (state)

                MENU: begin
                    if (cont_btn) begin
                        state <= GAME;
                        level <= 3'b001;
                    end
                end

                GAME: begin
                    if (line_crossed)
                        state <= LOSE;
                    else if (destroyed_count >= 6'd10)
                        state <= BETWEEN;
                end

                BETWEEN: begin
                    if (cont_btn) begin
                        state <= GAME;
                        level <= level + 1;
                    end
                end

                WIN: state <= WIN;
                LOSE: state <= LOSE;

            endcase
        end
    end

    // =============================
    // ENABLES
    // =============================
    always_comb begin
        lvl_start = (state == GAME);
        player_en = (state == GAME);

        case (state)
            MENU:   mode = 3'b000;
            GAME:   mode = 3'b001;
            BETWEEN:mode = 3'b010;
            WIN:    mode = 3'b011;
            LOSE:   mode = 3'b100;
            default:mode = 3'b000;
        endcase
    end

    // =============================
    // ENEMIGOS (TODOS ACTIVOS)
    // =============================
    always_comb begin
        if (state == GAME)
            inv_en = 24'hFFFFFF;
        else
            inv_en = 24'h000000;
    end

    // =============================
    // CONTADOR DE DESTRUCCIÓN (FIX)
    // =============================
    logic hit_d;

    always_ff @(posedge s_clk) begin
        hit_d <= (ship_pixel && shot_pixel);
    end

    always_ff @(posedge s_clk) begin
        if (!lvl_start)
            destroyed_count <= 0;
        else if ((ship_pixel && shot_pixel) && !hit_d)
            destroyed_count <= destroyed_count + 1;
    end

    // =============================
    // SCORE SIMPLE
    // =============================
    always_ff @(posedge s_clk) begin
        if (!rst)
            score <= 0;
        else if ((ship_pixel && shot_pixel) && !hit_d)
            score <= score + 1;
    end

endmodule