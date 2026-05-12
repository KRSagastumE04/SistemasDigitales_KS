/*
 * main.c
 * Cajero Automatico - STM32L053R8 (Nucleo-64) a 16MHz HSI
 *
 * Mapa de pines:
 *   PC0  -> LCD RS
 *   PC1  -> LCD EN
 *   PC2  -> LCD D4
 *   PC3  -> LCD D5
 *   PC4  -> LCD D6
 *   PC5  -> LCD D7
 *   PC6  -> Boton SALDO      (entrada, pull-up, flanco BAJADA)
 *   PC9  -> Boton RETIRO     (entrada, pull-up, flanco BAJADA)
 *   PC11 -> Boton DEPOSITO   (entrada, pull-up, flanco BAJADA)
 *   PC10 -> Keypad Col 3     (entrada, pull-up)
 *   PC12 -> Keypad Col 4     (entrada, pull-up)
 *   PB0  -> Keypad Fila 1    (salida)
 *   PB1  -> Keypad Fila 2    (salida)
 *   PB2  -> Keypad Fila 3    (salida)
 *   PB3  -> Keypad Fila 4    (salida)
 *   PB4  -> Keypad Col 1     (entrada, pull-up)
 *   PB5  -> Keypad Col 2     (entrada, pull-up)
 *   PA9  -> USART1_TX        (AF4) -> Pico GP5 RX
 *   PA10 -> USART1_RX        (AF4) -> Pico GP4 TX
 *
 * Interrupciones:
 *   SysTick  @1s    : tick cajero
 *   TIM2     @10ms  : escaneo keypad
 *   EXTI4_15        : botones PC6, PC9, PC11
 */

#include <stdint.h>
#include "stm32l053xx.h"
#include "lcd.h"
#include "keypad.h"
#include "cajero.h"
#include "uart.h"

void delayMs(uint16_t n);

/* Debounce botones externos */
volatile uint8_t debounce_saldo = 0;
volatile uint8_t debounce_dep   = 0;
volatile uint8_t debounce_ret   = 0;

/* =========================================================
 * MAIN
 * ========================================================= */
int main(void) {
    __disable_irq();

    /* =====================================================
     * 1. CLOCK HSI 16MHz
     * ===================================================== */
    RCC->CR |= RCC_CR_HSION;
    while (!(RCC->CR & RCC_CR_HSIRDY));
    RCC->CFGR |= RCC_CFGR_SW_HSI;
    while ((RCC->CFGR & RCC_CFGR_SWS) != RCC_CFGR_SWS_HSI);

    /* =====================================================
     * 2. ACTIVAR CLOCKS GPIO + SYSCFG
     * ===================================================== */
    RCC->IOPENR |= (
        RCC_IOPENR_GPIOAEN |
        RCC_IOPENR_GPIOBEN |
        RCC_IOPENR_GPIOCEN
    );
    RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN;

    /* =====================================================
     * 3. PUERTO C
     *
     * PC0-PC5  : salidas LCD
     * PC6      : entrada pull-up boton SALDO
     * PC9      : entrada pull-up boton RETIRO
     * PC10     : entrada pull-up keypad Col 3
     * PC11     : entrada pull-up boton DEPOSITO
     * PC12     : entrada pull-up keypad Col 4
     * ===================================================== */

    /* PC0-PC5 como salidas para LCD */
    GPIOC->MODER &= ~0x00000FFFu;
    GPIOC->MODER |=  0x00000555u;
    GPIOC->ODR   &= ~0x3Fu;

    /* PC6, PC9, PC10, PC11, PC12 como entradas */
    GPIOC->MODER &= ~(
        (3u << 12) |   /* PC6  */
        (3u << 18) |   /* PC9  */
        (3u << 20) |   /* PC10 */
        (3u << 22) |   /* PC11 */
        (3u << 24)     /* PC12 */
    );

    /* Pull-up en todos */
    GPIOC->PUPDR &= ~(
        (3u << 12) |
        (3u << 18) |
        (3u << 20) |
        (3u << 22) |
        (3u << 24)
    );
    GPIOC->PUPDR |= (
        (1u << 12) |   /* PC6  pull-up */
        (1u << 18) |   /* PC9  pull-up */
        (1u << 20) |   /* PC10 pull-up */
        (1u << 22) |   /* PC11 pull-up */
        (1u << 24)     /* PC12 pull-up */
    );

    /* =====================================================
     * 4. PUERTO B
     *
     * PB0-PB3 : salidas filas keypad
     * PB4-PB5 : entradas pull-up columnas keypad 1 y 2
     * ===================================================== */
    GPIOB->MODER &= ~0x000000FFu;
    GPIOB->MODER |=  0x00000055u;

    GPIOB->MODER &= ~((3u << 8) | (3u << 10));

    GPIOB->PUPDR &= ~((3u << 8) | (3u << 10));
    GPIOB->PUPDR |=  ((1u << 8) | (1u << 10));

    /* Forzar PB4/PB5 a funcion GPIO pura */
    GPIOB->AFR[0] &= ~((0xFu << 16) | (0xFu << 20));
    GPIOB->OTYPER &= ~((1u << 4) | (1u << 5));

    /* Todas las filas en HIGH (reposo) */
    GPIOB->ODR |= 0x000Fu;

    /* =====================================================
     * 5. PUERTO A
     * PA9 y PA10 los configura uart_init() como AF4
     * ===================================================== */

    /* =====================================================
     * 6. EXTI - botones con flanco de BAJADA (FTSR)
     *
     * PC6  -> EXTI6  -> EXTICR[1] bits [11:8]
     * PC9  -> EXTI9  -> EXTICR[2] bits [7:4]
     * PC11 -> EXTI11 -> EXTICR[2] bits [15:12]
     *
     * Valor 2 en EXTICRx = Puerto C
     * ===================================================== */

    /* PC6 -> EXTI6 */
    SYSCFG->EXTICR[1] &= ~(0xFu << 8);
    SYSCFG->EXTICR[1] |=  (2u   << 8);

    /* PC9 -> EXTI9, PC11 -> EXTI11 */
    SYSCFG->EXTICR[2] &= ~((0xFu << 4) | (0xFu << 12));
    SYSCFG->EXTICR[2] |=  ((2u   << 4) | (2u   << 12));

    /* Habilitar mascaras */
    EXTI->IMR  |=  (1u << 6) | (1u << 9) | (1u << 11);

    /* Flanco de BAJADA */
    EXTI->FTSR |=  (1u << 6) | (1u << 9) | (1u << 11);
    EXTI->RTSR &= ~((1u << 6) | (1u << 9) | (1u << 11));

    /* =====================================================
     * 7. SYSTICK - tick cada 1 segundo
     * ===================================================== */
    SysTick->LOAD = 16000000u - 1u;
    SysTick->VAL  = 0u;
    SysTick->CTRL = 7u;

    /* =====================================================
     * 8. TIM2 - escaneo keypad cada 10ms
     * 16MHz / PSC=1600 / ARR=100 = 100Hz = 10ms
     * ===================================================== */
    RCC->APB1ENR |= RCC_APB1ENR_TIM2EN;
    TIM2->PSC  = 1600u - 1u;
    TIM2->ARR  = 100u  - 1u;
    TIM2->DIER |= TIM_DIER_UIE;
    TIM2->CR1  |= TIM_CR1_CEN;

    /* =====================================================
     * 9. NVIC
     * ===================================================== */
    NVIC_EnableIRQ(TIM2_IRQn);
    NVIC_EnableIRQ(EXTI4_15_IRQn);

    __enable_irq();

    /* =====================================================
     * 10. INICIALIZACIONES
     * ===================================================== */
    uart_init();
    lcd_init();
    keypad_init();
    cajero_init();

    /* =====================================================
     * 11. LOOP PRINCIPAL
     * ===================================================== */
    while (1) {
        __WFI();
    }
}

/* =========================================================
 * TIM2_IRQHandler - escaneo keypad cada 10ms
 * key_div: lee tecla cada 15 ticks = 150ms
 * Remapeo: 4->D(confirmar), 7->C(cancelar)
 * ========================================================= */
void TIM2_IRQHandler(void) {
    TIM2->SR = 0u;

    if (debounce_saldo > 0u) debounce_saldo--;
    if (debounce_dep   > 0u) debounce_dep--;
    if (debounce_ret   > 0u) debounce_ret--;

    keypad_tick();

    static uint8_t key_div = 0u;
    key_div++;
    if (key_div >= 15u) {
        key_div = 0u;
        uint8_t k = keypad_getkey();
        if (k != 0u) {
            if      (k == '4') cajero_handle_key('D');
            else if (k == '7') cajero_handle_key('C');
            else               cajero_handle_key((char)k);
        }
    }
}

/* =========================================================
 * SysTick_Handler - tick de 1 segundo
 * ========================================================= */
void SysTick_Handler(void) {
    cajero_tick_1s();
}

/* =========================================================
 * EXTI4_15_IRQHandler - botones de accion
 *
 * PC6  (EXTI6)  -> SALDO
 * PC9  (EXTI9)  -> RETIRO
 * PC11 (EXTI11) -> DEPOSITO
 *
 * Debounce: 8 ticks x 10ms = 80ms
 * ========================================================= */
void EXTI4_15_IRQHandler(void) {

    /* PC6 -> SALDO */
    if (EXTI->PR & (1u << 6)) {
        EXTI->PR = (1u << 6);
        uart_send_str("BTN:SALDO\r\n");
        if (debounce_saldo == 0u) {
            debounce_saldo = 8u;
            cajero_btn_saldo();
        }
    }

    /* PC9 -> RETIRO */
    if (EXTI->PR & (1u << 9)) {
        EXTI->PR = (1u << 9);
        uart_send_str("BTN:RET\r\n");
        if (debounce_ret == 0u) {
            debounce_ret = 8u;
            cajero_btn_retiro();
        }
    }

    /* PC11 -> DEPOSITO */
    if (EXTI->PR & (1u << 11)) {
        EXTI->PR = (1u << 11);
        uart_send_str("BTN:DEP\r\n");
        if (debounce_dep == 0u) {
            debounce_dep = 8u;
            cajero_btn_deposit();
        }
    }
}

/* =========================================================
 * delayMs - delay bloqueante
 * SOLO para lcd_init(), NUNCA en ISRs.
 * ========================================================= */
void delayMs(uint16_t n) {
    for (; n > 0u; n--)
        for (volatile uint16_t i = 0u; i < 3195u; i++);
}
