`timescale 1ns / 1ps

module FSM_Moore(
    // Control
    input  logic clk,
    input  logic rst,

    // Entradas
    input  logic Sauto,   // Sensor presencia auto
    input  logic Spago,   // Confirmación de pago (de Mealy)
    input  logic Spaso,   // Sensor de paso

    // Salidas
    output logic [1:0] Pt, // Estado motor
    output logic L         // LED
);

    // =====================================
    // Definición de estados
    // =====================================
    typedef enum logic [2:0] {
        Esperando_auto,
        Pagando,
        Abriendo_talanquera,
        Talanquera_abierta,
        Cerrando_talanquera
    } state_t;

    state_t estado_actual, proximo_estado;

    // =====================================
    // Registro de estado
    // =====================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            estado_actual <= Esperando_auto;
        else
            estado_actual <= proximo_estado;
    end

    // =====================================
    // Contador para simular tiempo de motor
    // =====================================
    logic [5:0] contador;      // 6 bits (cuenta hasta 63)
    logic m_abierta;
    logic m_cerrada;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            contador   <= 0;
            m_abierta  <= 0;
            m_cerrada  <= 0;
        end
        else begin
            case (estado_actual)

                Abriendo_talanquera: begin
                    if (contador >= 20) begin
                        m_abierta <= 1'b1;
                        contador  <= 0;
                    end
                    else begin
                        contador  <= contador + 1;
                        m_abierta <= 1'b0;
                    end
                    m_cerrada <= 1'b0;
                end

                Cerrando_talanquera: begin
                    if (contador >= 20) begin
                        m_cerrada <= 1'b1;
                        contador  <= 0;
                    end
                    else begin
                        contador  <= contador + 1;
                        m_cerrada <= 1'b0;
                    end
                    m_abierta <= 1'b0;
                end

                default: begin
                    contador   <= 0;
                    m_abierta  <= 1'b0;
                    m_cerrada  <= 1'b0;
                end

            endcase
        end
    end

    // =====================================
    // Lógica de próximo estado
    // =====================================
    always_comb begin
        proximo_estado = estado_actual;

        case (estado_actual)

            Esperando_auto:
                proximo_estado = Sauto ? Pagando : Esperando_auto;

            Pagando:
                proximo_estado = Spago ? Abriendo_talanquera :
                                 (Sauto ? Pagando : Esperando_auto);

            Abriendo_talanquera:
                proximo_estado = m_abierta ? Talanquera_abierta :
                                 Abriendo_talanquera;

            Talanquera_abierta:
                proximo_estado = Spaso ? Cerrando_talanquera :
                                 Talanquera_abierta;

            Cerrando_talanquera:
                proximo_estado = m_cerrada ? Esperando_auto :
                                 Cerrando_talanquera;

            default:
                proximo_estado = Esperando_auto;

        endcase
    end

    // =====================================
    // Definición de salidas (MOORE PURA)
    // =====================================
    localparam CERRADA  = 2'b00;
    localparam SUBIENDO = 2'b01;
    localparam ABIERTA  = 2'b10;

    localparam ROJO  = 1'b0;
    localparam VERDE = 1'b1;

    always_comb begin
        case (estado_actual)

            Esperando_auto: begin
                Pt = CERRADA;
                L  = ROJO;
            end

            Pagando: begin
                Pt = CERRADA;
                L  = ROJO;
            end

            Abriendo_talanquera: begin
                Pt = SUBIENDO;
                L  = VERDE;
            end

            Talanquera_abierta: begin
                Pt = ABIERTA;
                L  = VERDE;
            end

            Cerrando_talanquera: begin
                Pt = CERRADA;
                L  = ROJO;
            end

            default: begin
                Pt = CERRADA;
                L  = ROJO;
            end

        endcase
    end

endmodule



