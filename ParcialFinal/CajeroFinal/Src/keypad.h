/*
 * keypad.h
 * Driver para teclado matricial 4x4.
 *
 * Hardware:
 *   Filas  (salidas):            PB0, PB1, PB2, PB3
 *   Columnas (entradas pull-up): PB4, PB5, PC10, PC12
 *
 * Distribucion de teclas:
 *   1  2  3  A
 *   4  5  6  B
 *   7  8  9  C
 *   *  0  #  D
 *
 * NUEVO USO EN CAJERO:
 *   4  -> Confirmar / Enter
 *   7  -> Cancelar / Salir
 *   *  -> Backspace
 *   #  -> no usado
 */
#ifndef KEYPAD_H
#define KEYPAD_H

#include <stdint.h>
#include "stm32l053xx.h"

/* Pines de filas (salidas) en GPIOB */
#define KP_ROW0_PIN   0u
#define KP_ROW1_PIN   1u
#define KP_ROW2_PIN   2u
#define KP_ROW3_PIN   3u

#define KP_ROW_MASK   ((1u<<KP_ROW0_PIN)|(1u<<KP_ROW1_PIN)| \
                       (1u<<KP_ROW2_PIN)|(1u<<KP_ROW3_PIN))

/* Columnas */
#define KP_COL0_PORT  GPIOB
#define KP_COL0_PIN   4u

#define KP_COL1_PORT  GPIOB
#define KP_COL1_PIN   5u

#define KP_COL2_PORT  GPIOC
#define KP_COL2_PIN   10u

#define KP_COL3_PORT  GPIOC
#define KP_COL3_PIN   12u

extern volatile uint8_t kp_row_seq;
extern volatile uint8_t kp_lock;
extern volatile uint8_t kp_row_active;
extern volatile uint8_t kp_key;
extern volatile uint8_t kp_pressed;

void keypad_init(void);
uint8_t keypad_getkey(void);
uint8_t kp_cols_all_high(void);
void keypad_tick(void);

#endif
