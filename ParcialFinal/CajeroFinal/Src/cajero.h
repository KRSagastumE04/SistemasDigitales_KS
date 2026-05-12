/*
 * cajero.h
 * Logica del cajero automatico: cuentas, saldos y maquina de estados.
 *
 * Flujo de estados:
 *   IDLE         -> espera que se ingrese numero de cuenta
 *   ENTER_ACCT   -> usuario escribe numero de cuenta (hasta 6 digitos)
 *   LOGGED_IN    -> cuenta validada, mostrar menu de opciones
 *   ENTER_AMOUNT -> ingresando monto (para deposito o retiro)
 *   CONFIRM_OP   -> confirmacion de operacion antes de ejecutar
 *   RESULT       -> mostrando resultado (exito/error) por 2 segundos
 *
 * Teclas globales:
 *   0-9  -> ingresar digito
 *   *    -> borrar ultimo digito (backspace)
 *   D    -> confirmar / enter
 *   C    -> cancelar / cerrar sesion
 */
#ifndef CAJERO_H
#define CAJERO_H

#include <stdint.h>

/* ---------- Cuentas disponibles ---------- */
#define NUM_ACCOUNTS   4u

typedef struct {
    char     number[7];   /* Numero de cuenta (6 digitos + null) */
    char     owner[17];   /* Nombre del titular (16 chars + null) */
    int32_t  balance;     /* Saldo en centavos (e.g. 150000 = Q1500.00) */
} Account;

extern Account accounts[NUM_ACCOUNTS];

/* ---------- Maquina de estados ---------- */
typedef enum {
    STATE_IDLE         = 0,
    STATE_ENTER_ACCT   = 1,
    STATE_LOGGED_IN    = 2,
    STATE_ENTER_AMOUNT = 3,
    STATE_CONFIRM_OP   = 4,
    STATE_RESULT       = 5
} CajeroState;

typedef enum {
    OP_NONE    = 0,
    OP_SALDO   = 1,
    OP_DEPOSIT = 2,
    OP_RETIRO  = 3
} CajeroOp;

extern volatile CajeroState cajero_state;
extern volatile CajeroOp    cajero_op;
extern volatile int8_t      logged_account;   /* indice en accounts[], -1=ninguno */

/* Buffer de digitos ingresados por teclado */
#define MAX_DIGITS  8u
extern volatile uint8_t input_digits[MAX_DIGITS];
extern volatile uint8_t input_len;

/* Temporizador de pantalla de resultado (decrementado en SysTick) */
extern volatile uint8_t result_timer;

/* ---------- Funciones publicas ---------- */
void    cajero_init(void);
void    cajero_handle_key(char k);
void    cajero_btn_saldo(void);
void    cajero_btn_deposit(void);
void    cajero_btn_retiro(void);
void    cajero_tick_1s(void);          /* llamar desde SysTick cada 1s */

/* Utilidades */
void    input_reset(void);
int32_t input_to_amount(void);        /* convierte digitos a entero (centavos) */
int8_t  find_account(const char *num);/* retorna indice o -1 */
void    amount_to_str(int32_t cents, char *buf, uint8_t buflen);

#endif /* CAJERO_H */
