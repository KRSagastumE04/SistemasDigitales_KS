module Alu (
    input  logic [3:0] A, B,          
    input  logic [2:0] ALUControl,    
    output logic [3:0] Result,        
    output logic Carry,               
    output logic Overflow,            
    output logic Negative,            
    output logic Zero                 
);

    // Variables internas
    logic [3:0] B_mux2_out;           
    logic [3:0] sum_result;           
    logic cout_sum;                   
    logic [3:0] and_result, or_result, sll_result, srl_result;

    // --- 1. PREPARACIÓN DE OPERANDOS ---
    // Si ALUControl[0] es 1, invertimos B para la resta
    assign B_mux2_out = (ALUControl[0]) ? ~B : B;
    
    // --- 2. INSTANCIA DEL SUMADOR (Tu módulo base) ---
    Adder_x4 sumx4 (
        .a(A),
        .b(B_mux2_out),
        .cin(ALUControl[0]),          
        .k(sum_result),               
        .cout(cout_sum)
    );

    // --- 3. CÁLCULO DE OPERACIONES LÓGICAS Y SHIFTS ---
    assign and_result = A & B;       // AND bit a bit
    assign or_result  = A | B;       // OR bit a bit
    assign sll_result = A << 1;      // Shift Left (Desplazar a la izquierda)
    assign srl_result = A >> 1;      // Shift Right (Desplazar a la derecha)

    // --- 4. SELECCIÓN DEL RESULTADO (Sustituye al mux4) ---
    always_comb begin
        case (ALUControl)
            3'b000: Result = sum_result; // Suma
            3'b001: Result = sum_result; // Resta
            3'b010: Result = and_result; // AND
            3'b011: Result = or_result;  // OR
            3'b100: Result = sll_result; // SLL
            3'b101: Result = srl_result; // SRL
            default: Result = 4'b0000;   // Caso por defecto
        endcase
    end

    // --- 5. GENERACIÓN DE FLAGS ---
    // Carry: Solo válido en Suma/Resta (cuando ALUControl es 000 o 001)
    assign Carry    = (~ALUControl[2] & ~ALUControl[1]) ? cout_sum : 1'b0;
    
    // Overflow: Detecta si el resultado excede la capacidad de 4 bits con signo
    assign Overflow = (~ALUControl[2] & ~ALUControl[1]) ? 
                      (A[3] == B_mux2_out[3]) && (Result[3] != A[3]) : 1'b0;
    
    // Negative: Bit más significativo del resultado
    assign Negative = Result[3];
    
    // Zero: 1 si todos los bits del resultado son cero
    assign Zero     = (Result == 4'b0000);

endmodule