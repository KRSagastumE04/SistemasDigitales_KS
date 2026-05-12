/*
 * uart.c
 * USART1 a 9600 baud, 8N1.
 * PA9=TX (AF4), PA10=RX (AF4).
 * Inicializacion sin CubeMX: acceso directo a registros.
 */
#include "uart.h"
#include <string.h>

void uart_init(void) {
    /* Clock de GPIOA ya habilitado en main.c */
    /* Clock de USART1 */
    RCC->APB2ENR |= (1u << 14);  /* USART1EN */

    /* PA9 = AF4 (USART1_TX), PA10 = AF4 (USART1_RX) */
    /* MODER: modo alternativo = 10 */
    GPIOA->MODER &= ~((3u << (9*2)) | (3u << (10*2)));
    GPIOA->MODER |=  ((2u << (9*2)) | (2u << (10*2)));

    /* AFR[1] cubre pines 8-15; pin 9 -> AFR[1] bits [7:4], pin 10 -> bits [11:8] */
    GPIOA->AFR[1] &= ~((0xFu << 4) | (0xFu << 8));
    GPIOA->AFR[1] |=  ((4u   << 4) | (4u   << 8));  /* AF4 */

    /* BRR: 9600 baud a 16MHz -> 16000000/9600 = 1666 = 0x682 */
    USART1->BRR = 0x682u;

    /* CR1: habilitar TX, RX y USART */
    USART1->CR1 = (1u << 3) |  /* TE: transmit enable */
                  (1u << 2) |  /* RE: receive enable  */
                  (1u << 0);   /* UE: USART enable    */
}

void uart_send_char(char c) {
    /* Esperar a que TXE (bit 7 de ISR) este en 1 */
    while (!(USART1->ISR & (1u << 7)));
    USART1->TDR = (uint8_t)c;
}

void uart_send_str(const char *s) {
    while (*s) uart_send_char(*s++);
}

/*
 * uart_send_amount - envia centavos como string decimal.
 * Ejemplo: 150025 -> "150025"
 */
void uart_send_amount(int32_t cents) {
    if (cents < 0) { uart_send_char('-'); cents = -cents; }
    char buf[12];
    int8_t i = 0;
    if (cents == 0) { uart_send_char('0'); return; }
    while (cents > 0 && i < 11) {
        buf[i++] = (char)('0' + (cents % 10));
        cents /= 10;
    }
    /* invertir */
    for (int8_t j = i - 1; j >= 0; j--) uart_send_char(buf[j]);
}
