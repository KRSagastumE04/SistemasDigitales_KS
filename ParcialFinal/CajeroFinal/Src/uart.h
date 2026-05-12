/*
 * uart.h
 * Comunicacion serie con NodeMCU (ESP8266) via USART1.
 *
 * Hardware:
 *   PA9  -> USART1_TX -> RX2 del NodeMCU (GPIO16)
 *   PA10 -> USART1_RX -> TX2 del NodeMCU (GPIO17)
 *
 * Protocolo (texto plano, 9600 baud, terminado en \r\n):
 *
 *   STM32 -> NodeMCU (comandos):
 *     LOGIN:XXXXXX\r\n          cuenta logueada
 *     LOGOUT\r\n                sesion cerrada
 *     SAL:XXXXXX\r\n            consulta saldo
 *     DEP:XXXXXX:MONTO:BAL\r\n  deposito realizado
 *     RET:XXXXXX:MONTO:BAL\r\n  retiro realizado
 *
 *   NodeMCU -> STM32 (respuestas opcionales):
 *     OK\r\n   acuse de recibo
 */
#ifndef UART_H
#define UART_H

#include <stdint.h>
#include "stm32l053xx.h"

void uart_init(void);
void uart_send_char(char c);
void uart_send_str(const char *s);
void uart_send_amount(int32_t cents);   /* envia numero de centavos como string */

#endif /* UART_H */
