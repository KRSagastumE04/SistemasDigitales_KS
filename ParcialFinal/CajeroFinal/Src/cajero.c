/*
 * cajero.c
 * Logica completa del cajero automatico.
 *
 * Cuentas predefinidas (modificar segun necesidad).
 * Saldos en centavos: 100000 = Q1000.00
 */
#include "cajero.h"
#include "lcd.h"
#include "uart.h"
#include <string.h>

/* ------------------------------------------------------------------ */
/* Cuentas                                                              */
/* ------------------------------------------------------------------ */
Account accounts[NUM_ACCOUNTS] = {
    {"100001", "Carlos Lopez     ", 500000},   /* Q5000.00 */
    {"100002", "Maria Garcia     ", 250000},   /* Q2500.00 */
    {"100003", "Juan Perez       ", 100000},   /* Q1000.00 */
    {"111111", "Ana Gonzalez     ", 750000},   /* Q7500.00 */
};

/* ------------------------------------------------------------------ */
/* Estado global                                                        */
/* ------------------------------------------------------------------ */
volatile CajeroState cajero_state   = STATE_IDLE;
volatile CajeroOp    cajero_op      = OP_NONE;
volatile int8_t      logged_account = -1;

volatile uint8_t input_digits[MAX_DIGITS];
volatile uint8_t input_len = 0;
volatile uint8_t result_timer = 0;

/* ------------------------------------------------------------------ */
/* Utilidades                                                           */
/* ------------------------------------------------------------------ */

void input_reset(void) {
    input_len = 0;
    for (uint8_t i = 0; i < MAX_DIGITS; i++) input_digits[i] = 0;
}

/* Convierte los digitos del buffer a entero (valor en centavos).
 * Ejemplo: [1,5,0,0] -> 1500 centavos = Q15.00 */
int32_t input_to_amount(void) {
    int32_t val = 0;
    for (uint8_t i = 0; i < input_len; i++) {
        val = val * 10 + input_digits[i];
    }
    return val * 100;  /* convertir a centavos */
}

/* Busca cuenta por numero, retorna indice o -1 */
int8_t find_account(const char *num) {
    for (uint8_t i = 0; i < NUM_ACCOUNTS; i++) {
        if (strncmp(accounts[i].number, num, 6) == 0) return (int8_t)i;
    }
    return -1;
}

/*
 * amount_to_str - formatea centavos como "Q####.##"
 * Ejemplo: 150025 -> "Q1500.25"
 */
void amount_to_str(int32_t cents, char *buf, uint8_t buflen) {
    int32_t quetz = cents / 100;
    int32_t ctvs  = cents % 100;
    /* Formato simple sin printf */
    uint8_t i = 0;
    buf[i++] = 'Q';
    /* Convertir quetzales */
    if (quetz == 0) {
        buf[i++] = '0';
    } else {
        /* extraer digitos al reves */
        char tmp[8]; uint8_t tlen = 0;
        int32_t q = quetz;
        while (q > 0 && tlen < 7) { tmp[tlen++] = (char)('0' + (q % 10)); q /= 10; }
        for (int8_t j = (int8_t)(tlen - 1); j >= 0 && i < (buflen - 4); j--)
            buf[i++] = tmp[j];
    }
    buf[i++] = '.';
    buf[i++] = (char)('0' + (ctvs / 10));
    buf[i++] = (char)('0' + (ctvs % 10));
    buf[i]   = '\0';
}

/* ------------------------------------------------------------------ */
/* Pantallas LCD                                                        */
/* ------------------------------------------------------------------ */

static void show_welcome(void) {
    lcd_print_line(0, "** CAJERO AUTO **");
    lcd_print_line(1, "No. cuenta:     ");
}

static void show_enter_acct(void) {
    lcd_print_line(0, "Ingrese cuenta:");
    /* Mostrar digitos ingresados con cursor simulado */
    char line[17];
    for (uint8_t i = 0; i < 16; i++) line[i] = ' ';
    line[16] = '\0';
    for (uint8_t i = 0; i < input_len && i < 6; i++)
        line[i] = (char)('0' + input_digits[i]);
    if (input_len < 6) line[input_len] = '_';
    lcd_print_line(1, line);
}

static void show_menu(void) {
    lcd_print_line(0, accounts[logged_account].owner);
    lcd_print_line(1, "S=Saldo D=Dep R=Ret");
}

static void show_enter_amount(const char *label) {
    lcd_print_line(0, label);
    char line[17];
    for (uint8_t i = 0; i < 16; i++) line[i] = ' ';
    line[16] = '\0';
    /* Mostrar "Q" + digitos */
    line[0] = 'Q';
    for (uint8_t i = 0; i < input_len && i < 7; i++)
        line[i + 1] = (char)('0' + input_digits[i]);
    if (input_len < 7) line[input_len + 1] = '_';
    lcd_print_line(1, line);
}

static void show_result(const char *l1, const char *l2) {
    lcd_print_line(0, l1);
    lcd_print_line(1, l2);
    result_timer = 3;  /* 3 segundos en pantalla */
}

/* ------------------------------------------------------------------ */
/* Maquina de estados                                                   */
/* ------------------------------------------------------------------ */

void cajero_init(void) {
    cajero_state   = STATE_IDLE;
    cajero_op      = OP_NONE;
    logged_account = -1;
    input_reset();
    show_welcome();
    uart_send_str("BOOT\r\n");  // <- confirma que UART funciona
}

/* Transicion a STATE_ENTER_ACCT */
static void start_enter_acct(void) {
    cajero_state = STATE_ENTER_ACCT;
    input_reset();
    show_enter_acct();
}

/* Transicion al menu tras login exitoso */
static void go_to_menu(void) {
    cajero_state = STATE_LOGGED_IN;
    cajero_op    = OP_NONE;
    input_reset();
    show_menu();
}

/* Cerrar sesion -> IDLE */
static void logout(void) {
    logged_account = -1;
    cajero_state   = STATE_IDLE;
    cajero_op      = OP_NONE;
    input_reset();
    show_welcome();
    uart_send_str("LOGOUT\r\n");
}

/* ------------------------------------------------------------------ */
/* Procesado de tecla segun estado                                      */
/* ------------------------------------------------------------------ */
void cajero_handle_key(char k) {
    if (k == 0) return;

    switch (cajero_state) {

    /* ---- IDLE: cualquier tecla inicia ingreso de cuenta ---- */
    case STATE_IDLE:
        if (k >= '0' && k <= '9') {
            start_enter_acct();
            /* agregar el primer digito inmediatamente */
            input_digits[0] = (uint8_t)(k - '0');
            input_len = 1;
            show_enter_acct();
        }
        break;

    /* ---- Ingresando numero de cuenta ---- */
    case STATE_ENTER_ACCT:
        if (k >= '0' && k <= '9') {
            if (input_len < 6) {
                input_digits[input_len] = (uint8_t)(k - '0');
                input_len++;
                show_enter_acct();
            }
        } else if (k == '*') {
            /* Backspace */
            if (input_len > 0) { input_len--; input_digits[input_len] = 0; }
            if (input_len == 0) { cajero_state = STATE_IDLE; show_welcome(); }
            else show_enter_acct();
        } else if (k == 'D') {
            /* Confirmar cuenta */
            if (input_len == 6) {
                char num[7];
                for (uint8_t i = 0; i < 6; i++) num[i] = (char)('0' + input_digits[i]);
                num[6] = '\0';
                int8_t idx = find_account(num);
                if (idx >= 0) {
                    logged_account = idx;
                    go_to_menu();
                    /* Notificar al NodeMCU */
                    uart_send_str("LOGIN:");
                    uart_send_str(accounts[idx].number);
                    uart_send_str("\r\n");
                } else {
                    show_result("Cuenta no existe", "Intente de nuevo");
                    cajero_state = STATE_RESULT;
                    cajero_op    = OP_NONE;
                    /* al terminar result_timer -> IDLE */
                }
            }
        } else if (k == 'C') {
            cajero_state = STATE_IDLE;
            input_reset();
            show_welcome();
        }
        break;

    /* ---- Menu principal (logged in) ---- */
    case STATE_LOGGED_IN:
        if (k == 'C') {
            logout();
        }
        /* Los botones de accion (saldo/dep/ret) se manejan en cajero_btn_* */
        break;

    /* ---- Ingresando monto ---- */
    case STATE_ENTER_AMOUNT:
        if (k >= '0' && k <= '9') {
            if (input_len < 7) {
                input_digits[input_len] = (uint8_t)(k - '0');
                input_len++;
                if (cajero_op == OP_DEPOSIT) show_enter_amount("Depositar monto:");
                else                         show_enter_amount("Retirar monto: ");
            }
        } else if (k == '*') {
            if (input_len > 0) { input_len--; input_digits[input_len] = 0; }
            if (cajero_op == OP_DEPOSIT) show_enter_amount("Depositar monto:");
            else                         show_enter_amount("Retirar monto: ");
        } else if (k == 'D') {
            /* Confirmar monto -> pasar a confirmacion */
            if (input_len > 0) {
                cajero_state = STATE_CONFIRM_OP;
                char amtstr[12];
                amount_to_str(input_to_amount(), amtstr, 12);
                if (cajero_op == OP_DEPOSIT) {
                    lcd_print_line(0, "Confirmar dep:");
                } else {
                    lcd_print_line(0, "Confirmar retiro:");
                }
                lcd_print_line(1, amtstr);
                /* El usuario debe presionar D para confirmar o C para cancelar */
            }
        } else if (k == 'C') {
            go_to_menu();
        }
        break;

    /* ---- Confirmacion de operacion ---- */
    case STATE_CONFIRM_OP: {
        if (k == 'D') {
            int32_t amount = input_to_amount();
            char amtstr[12];
            amount_to_str(amount, amtstr, 12);

            if (cajero_op == OP_DEPOSIT) {
                accounts[logged_account].balance += amount;
                char newbal[12];
                amount_to_str(accounts[logged_account].balance, newbal, 12);
                show_result("Deposito exitoso", newbal);
                /* Enviar update al NodeMCU */
                uart_send_str("DEP:");
                uart_send_str(accounts[logged_account].number);
                uart_send_str(":");
                uart_send_amount(amount);
                uart_send_str(":");
                uart_send_amount(accounts[logged_account].balance);
                uart_send_str("\r\n");

            } else if (cajero_op == OP_RETIRO) {
                if (amount > accounts[logged_account].balance) {
                    show_result("Saldo insuf.", "Operac. cancelada");
                } else {
                    accounts[logged_account].balance -= amount;
                    char newbal[12];
                    amount_to_str(accounts[logged_account].balance, newbal, 12);
                    show_result("Retiro exitoso", newbal);
                    /* Enviar update al NodeMCU */
                    uart_send_str("RET:");
                    uart_send_str(accounts[logged_account].number);
                    uart_send_str(":");
                    uart_send_amount(amount);
                    uart_send_str(":");
                    uart_send_amount(accounts[logged_account].balance);
                    uart_send_str("\r\n");
                }
            }
            cajero_state = STATE_RESULT;

        } else if (k == 'C') {
            go_to_menu();
        }
        break;
    }

    case STATE_RESULT:
        /* En pantalla de resultado, C o D vuelven al menu o idle */
        if (k == 'C' || k == 'D') {
            result_timer = 0;
            if (logged_account >= 0) go_to_menu();
            else { cajero_state = STATE_IDLE; show_welcome(); }
        }
        break;

    default: break;
    }
}

/* ------------------------------------------------------------------ */
/* Botones de accion (EXTI PA5, PA6, PA7)                              */
/* ------------------------------------------------------------------ */

void cajero_btn_saldo(void) {
    if (cajero_state != STATE_LOGGED_IN) return;
    cajero_op = OP_SALDO;
    char line[17];
    amount_to_str(accounts[logged_account].balance, line, 17);
    show_result("Su saldo es:", line);
    cajero_state = STATE_RESULT;
    /* Notificar NodeMCU */
    uart_send_str("SAL:");
    uart_send_str(accounts[logged_account].number);
    uart_send_str("\r\n");
}

void cajero_btn_deposit(void) {
    if (cajero_state != STATE_LOGGED_IN) return;
    cajero_op    = OP_DEPOSIT;
    cajero_state = STATE_ENTER_AMOUNT;
    input_reset();
    show_enter_amount("Depositar monto:");
}

void cajero_btn_retiro(void) {
    if (cajero_state != STATE_LOGGED_IN) return;
    cajero_op    = OP_RETIRO;
    cajero_state = STATE_ENTER_AMOUNT;
    input_reset();
    show_enter_amount("Retirar monto: ");
}

/* ------------------------------------------------------------------ */
/* Tick de 1 segundo (llamar desde SysTick)                            */
/* ------------------------------------------------------------------ */
void cajero_tick_1s(void) {
    if (result_timer > 0) {
        result_timer--;
        if (result_timer == 0) {
            if (logged_account >= 0) go_to_menu();
            else { cajero_state = STATE_IDLE; show_welcome(); }
        }
    }
}



