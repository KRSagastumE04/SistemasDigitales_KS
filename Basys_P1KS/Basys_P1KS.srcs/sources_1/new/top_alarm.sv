`timescale 1ns / 1ps

module top_alarm (
    input  logic clk,
    input  logic btnU,   // U: apagar alarma
    input  logic btnC,   // C: reset
    output logic [6:0] seg,
    output logic dp,
    output logic [3:0] an,
    output logic [1:0] led,
    output logic [1:0] JA
);

    // ---------------------------------------------------------
    // Reset simple (sin debounce)
    // ---------------------------------------------------------
    logic rst;
    assign rst = btnC;

    // ---------------------------------------------------------
    // Tick 1s
    // ---------------------------------------------------------
    logic tick_1s;
    reloj u_tick (
        .clk (clk),
        .rst (rst),
        .tick(tick_1s)
    );

    // ---------------------------------------------------------
    // Contadores HH:MM:SS
    // ---------------------------------------------------------
    logic [5:0] sec, min;
    logic [4:0] hour;

    always_ff @(posedge clk) begin
        if (rst) begin
            sec  <= 0;
            min  <= 0;
            hour <= 0;
        end else if (tick_1s) begin
            if (sec == 6'd59) begin
                sec <= 0;
                if (min == 6'd59) begin
                    min <= 0;
                    if (hour == 5'd23) hour <= 0;
                    else               hour <= hour + 1;
                end else begin
                    min <= min + 1;
                end
            end else begin
                sec <= sec + 1;
            end
        end
    end

    //Cuando esta los segundos estan en 00 se activa la alarma, esto es en 1 minuto los cambios 
    logic C_A;
    assign C_A = (sec == 6'd0);
    //FSM
    logic alarm_on;

    Alarm_FSM u_alarm (
        .clk(clk),
        .rst(rst),
        .C_A(C_A),
        .btn(btnU),
        .led(alarm_on)
    );

    // ---------------------------------------------------------
    // LEDs (sin parpadeo)
    // ---------------------------------------------------------
    assign led[0] = alarm_on;
    assign led[1] = 1'b0;

    // Buzzer 
    logic [23:0] buzz_div;
    always_ff @(posedge clk) begin
        if (rst) buzz_div <= 0;
        else     buzz_div <= buzz_div + 1;
    end

    assign JA[0] = alarm_on ? buzz_div[20] : 1'b0;
    assign JA[1] = 1'b0;

    // Display HH:DD
    logic [3:0] h_tens, h_units, m_tens, m_units;
    assign h_tens  = hour / 10;
    assign h_units = hour % 10;
    assign m_tens  = min  / 10;
    assign m_units = min  % 10;

    logic [3:0] dp_mask;
    assign dp_mask = 4'b0010; // tu separador

    seven_seg u_disp (
        .clk(clk),
        .d0(m_units), .d1(m_tens), .d2(h_units), .d3(h_tens),
        .dp_mask(dp_mask),
        .seg(seg), .dp(dp), .an(an)
    );


endmodule
